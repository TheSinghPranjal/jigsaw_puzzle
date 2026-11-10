#!/usr/bin/env python3
"""Covers, logo, app icons, synthesized audio, and the asset QC report."""
import json
import math
import os
import subprocess
import sys
import tempfile
import wave

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
A = os.path.join(ROOT, "assets")
levels = json.load(open(os.path.join(A, "data", "levels.json")))
collections = json.load(open(os.path.join(A, "data", "collections.json")))

# hand-picked strongest image per collection
COVER_LEVEL = {"palm_sunday": 1, "last_supper": 52, "gethsemane": 107, "passion": 152, "resurrection": 206, "angels": 253, "spring": 303, "nature": 351, "easter": 401, "landscapes": 452}


def covers():
    d = os.path.join(A, "thumbnails", "collections")
    os.makedirs(d, exist_ok=True)
    for c in collections:
        im = Image.open(os.path.join(ROOT, levels[COVER_LEVEL[c["id"]] - 1]["image"])).convert("RGB")
        im.resize((640, 480), Image.LANCZOS).save(os.path.join(d, f"{c['id']}.webp"), quality=74, method=4)


def piece_path(cx, cy, s):
    """Outline of a classic puzzle piece, as points."""
    def bez(p0, p1, p2, p3, n=26):
        return [tuple((1 - t) ** 3 * p0[i] + 3 * (1 - t) ** 2 * t * p1[i] + 3 * (1 - t) * t * t * p2[i] + t ** 3 * p3[i] for i in (0, 1)) for t in np.linspace(0, 1, n)]

    def tab(a, b, out):
        ux, uy = b[0] - a[0], b[1] - a[1]
        nx, ny = uy * out, -ux * out
        P = lambda u, v: (a[0] + ux * u + nx * v, a[1] + uy * u + ny * v)
        return bez(P(0, 0), P(.2, 0), P(.5, -.08), P(.4, .09)) + bez(P(.4, .09), P(.3, .27), P(.7, .27), P(.6, .09)) + bez(P(.6, .09), P(.5, -.08), P(.8, 0), P(1, 0))

    h = s / 2
    tl, tr, br, bl = (cx - h, cy - h), (cx + h, cy - h), (cx + h, cy + h), (cx - h, cy + h)
    return tab(tl, tr, 1) + tab(tr, br, 1) + tab(br, bl, -1) + tab(bl, tl, -1)


def logo_mark(size, bg=True):
    k = 4
    s = size * k
    base = Image.open(os.path.join(ROOT, levels[COVER_LEVEL["spring"] - 1]["image"])).convert("RGB")
    grad = np.zeros((s, s, 3), np.float32)
    t = np.linspace(0, 1, s)[:, None, None]
    grad[:] = np.array((234, 227, 250), np.float32) * (1 - t) + np.array((252, 226, 214), np.float32) * t
    img = Image.fromarray(grad.astype(np.uint8)).convert("RGBA") if bg else Image.new("RGBA", (s, s), (0, 0, 0, 0))
    pts = piece_path(s * .5, s * .52, s * .56)
    shadow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).polygon([(x + s * .012, y + s * .03) for x, y in pts], fill=(80, 60, 120, 110))
    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(s * .02)))
    art = base.crop((200, 150, 1100, 1050)).resize((s, s), Image.LANCZOS).convert("RGBA")
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).polygon(pts, fill=255)
    art.putalpha(mask)
    img.alpha_composite(art)
    ImageDraw.Draw(img).line(pts + [pts[0]], fill=(255, 255, 255, 235), width=int(s * .013), joint="curve")
    return img.resize((size, size), Image.LANCZOS)


def branding():
    os.makedirs(os.path.join(A, "branding", "logo"), exist_ok=True)
    logo_mark(512, bg=False).save(os.path.join(A, "branding", "logo", "logo.png"))
    icon = logo_mark(1024).convert("RGB")
    ios = os.path.join(ROOT, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
    meta = json.load(open(os.path.join(ios, "Contents.json")))
    for e in meta["images"]:
        if "filename" not in e:
            continue
        base = float(e["size"].split("x")[0])
        px = int(base * float(e["scale"].rstrip("x")))
        icon.resize((px, px), Image.LANCZOS).save(os.path.join(ios, e["filename"]))
    for folder, px in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)):
        icon.resize((px, px), Image.LANCZOS).save(os.path.join(ROOT, f"android/app/src/main/res/mipmap-{folder}/ic_launcher.png"))


# ---------- audio ----------
SR = 44100
NOTE = lambda n: 440.0 * 2 ** ((n - 69) / 12)


def tone(freq, dur, kind="pad"):
    t = np.arange(int(SR * dur)) / SR
    if kind == "pad":
        sig = np.sin(2 * np.pi * freq * t) + .4 * np.sin(2 * np.pi * freq * 2.003 * t) + .22 * np.sin(2 * np.pi * freq * .5 * t)
        env = np.sin(np.pi * t / dur) ** 1.4
    else:  # plucked bell
        sig = np.sin(2 * np.pi * freq * t) + .45 * np.sin(2 * np.pi * freq * 3.01 * t) * np.exp(-t * 7) + .2 * np.sin(2 * np.pi * freq * 2 * t)
        env = np.minimum(1, t * 220) * np.exp(-t * (3.2 / max(dur, .1)))
    return sig * env


def compose(chords, seconds_each, melody_scale, seed, bell=.35):
    rng = np.random.default_rng(seed)
    total = int(SR * len(chords) * seconds_each)
    out = np.zeros((total + SR * 4, 2))
    for i, ch in enumerate(chords):
        at = int(i * seconds_each * SR)
        for n in ch:
            s = tone(NOTE(n), seconds_each * 1.5) * .17
            pan = rng.uniform(.3, .7)
            out[at:at + len(s), 0] += s * pan
            out[at:at + len(s), 1] += s * (1 - pan)
        for b in range(8):
            if rng.random() > .5:
                continue
            n = int(rng.choice(melody_scale)) + 12 * int(rng.integers(0, 2))
            st = at + int(b / 8 * seconds_each * SR)
            s = tone(NOTE(n), 2.6, "bell") * bell * .32
            pan = rng.uniform(.2, .8)
            out[st:st + len(s), 0] += s * pan
            out[st:st + len(s), 1] += s * (1 - pan)
    tail = out[total:].copy()  # wrap the release around for a seamless loop
    out = out[:total]
    out[:len(tail)] += tail
    return out / (np.abs(out).max() + 1e-6) * .8


def write_audio(path, data, kbps=96):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pcm = (data * 32767).astype(np.int16)
    with tempfile.TemporaryDirectory() as tmp:
        w = os.path.join(tmp, "a.wav")
        with wave.open(w, "wb") as f:
            f.setnchannels(2)
            f.setsampwidth(2)
            f.setframerate(SR)
            f.writeframes(pcm.tobytes())
        subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", w, "-c:a", "aac", "-b:a", f"{kbps}k", path], check=True)


def stereo(m):
    return np.stack([m, m], axis=1)


def audio():
    C, F, G, Am, Dm, Em = [48, 55, 64, 67], [41, 53, 60, 69], [43, 50, 62, 71], [45, 52, 60, 69], [50, 57, 65, 69], [40, 52, 59, 67]
    pent = [60, 62, 64, 67, 69, 72]
    m = os.path.join(A, "audio", "music")
    write_audio(os.path.join(m, "menu_ambient.m4a"), compose([C, Am, F, G, C, Em, F, G], 6, pent, 1))
    write_audio(os.path.join(m, "calm_puzzle.m4a"), compose([Am, F, C, G, Dm, Am, F, G, C, Em], 7, pent, 2, .28))
    write_audio(os.path.join(m, "daily_puzzle.m4a"), compose([F, C, Dm, G, F, Am, G, C], 5, [65, 67, 69, 72, 74, 77], 3, .42))
    fx = os.path.join(A, "audio", "sound_effects")

    def seq(notes, gap, dur, gain=.7):
        out = np.zeros(int(SR * (gap * len(notes) + dur)))
        for i, n in enumerate(notes):
            s = tone(NOTE(n), dur, "bell")
            st = int(i * gap * SR)
            out[st:st + len(s)] += s
        return stereo(out / (np.abs(out).max() + 1e-6) * gain)

    write_audio(os.path.join(fx, "button.m4a"), seq([79], 0, .12, .4))
    write_audio(os.path.join(fx, "piece_place.m4a"), seq([60], 0, .1, .3))
    write_audio(os.path.join(fx, "piece_correct.m4a"), seq([72, 79], .07, .3, .55))
    write_audio(os.path.join(fx, "piece_wrong.m4a"), seq([52], 0, .2, .3))
    write_audio(os.path.join(fx, "victory.m4a"), seq([60, 64, 67, 72, 76, 79, 84], .11, 1.4))
    write_audio(os.path.join(fx, "reward.m4a"), seq([76, 79, 84, 88], .08, .7, .6))


# ---------- QC ----------
def qc():
    problems, hashes, sizes = [], [], 0
    for l in levels:
        for rel, want in ((l["image"], (1600, 1200)), (l["thumbnail"], (320, 240))):
            try:
                with Image.open(os.path.join(ROOT, rel)) as im:
                    im.load()
                    if im.size != want:
                        problems.append(f"{rel}: size {im.size}")
                    if rel == l["image"]:
                        g = im.convert("L")
                        small = np.asarray(g.resize((16, 12), Image.BILINEAR), np.float32)
                        hashes.append((l["levelId"], (small - small.mean()).ravel()))
                        blocks = np.asarray(g.resize((160, 120)), np.float32)
                        flat = 0
                        for y in range(0, 120, 12):
                            for x in range(0, 160, 16):
                                flat += blocks[y:y + 12, x:x + 16].std() < .9
                        if flat / 100 > .55:
                            problems.append(f"{rel}: {flat}% flat blocks")
                sizes += os.path.getsize(os.path.join(ROOT, rel))
            except Exception as e:  # noqa: BLE001
                problems.append(f"{rel}: {e}")
    mat = np.stack([h for _, h in hashes])
    mat /= np.linalg.norm(mat, axis=1, keepdims=True) + 1e-6
    sim = mat @ mat.T
    np.fill_diagonal(sim, -1)
    close = [(hashes[i][0], hashes[j][0], float(sim[i, j])) for i, j in zip(*np.where(np.triu(sim) > .985))]
    print(f"images checked: {len(hashes)}  total {sizes / 1e6:.1f} MB")
    print(f"unique image ids: {len({l['imageId'] for l in levels})}  unique files: {len({l['image'] for l in levels})}")
    print(f"near-duplicate pairs (corr>.985): {len(close)} {close[:12]}")
    print(f"max corr: {sim.max():.3f}")
    print(f"problems: {len(problems)}", problems[:20])
    return not problems


if __name__ == "__main__":
    covers()
    branding()
    audio()
    sys.exit(0 if qc() else 1)
