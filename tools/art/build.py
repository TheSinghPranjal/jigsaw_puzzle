#!/usr/bin/env python3
"""Render puzzle art and write every manifest.

  python3 tools/art/build.py --manifest-only       # data files only
  python3 tools/art/build.py --sample 1,51,101     # render some levels to --out
  python3 tools/art/build.py --all                 # render whatever is missing
"""
import argparse
import csv
import json
import math
import multiprocessing as mp
import os
import sys
import time

from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import catalog as C  # noqa: E402
import painter as P  # noqa: E402

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ASSETS = os.path.join(ROOT, "assets")
GAME_SIZE = (1600, 1200)
THUMB_SIZE = (320, 240)
ASPECT = 4 / 3


def piece_count(level):
    return 10 * math.ceil(level / 10)


def piece_aspect(rows, cols):
    return ASPECT * rows / cols


def choose_grid(n):
    """Exact rows*cols when pieces stay a reasonable shape, else near-grid + merges.

    Counts like 470 = 10 x 47 only factor into sliver pieces, so those use a
    near-square grid with a few pairs of cells joined to hit the count exactly.
    """
    best = None
    for r in range(1, n + 1):
        if n % r:
            continue
        c = n // r
        if r > c:
            break
        score = abs(math.log(piece_aspect(r, c)))
        if best is None or score < best[0]:
            best = (score, r, c)
    _, r, c = best
    if piece_aspect(r, c) >= .5:
        return r, c, []
    near = None
    for r2 in range(2, n):
        c2 = math.ceil(n / r2)
        if not .75 <= piece_aspect(r2, c2) <= 1.4:
            continue
        extra = r2 * c2 - n
        if extra > r2:
            continue
        key = (extra, abs(math.log(piece_aspect(r2, c2))))
        if near is None or key < near[0]:
            near = (key, r2, c2)
    _, r2, c2 = near
    extra = r2 * c2 - n
    merges = []
    for i in range(extra):
        row = int((i + .5) * r2 / extra)
        col = 1 + (n * 31 + i * 17) % (c2 - 3)
        merges.append([row, col])
    return r2, c2, merges


MOONLIT_COLLECTIONS = (2, 3, 5)
# Subjects whose name states a time of day keep palettes that match it.
_NIGHT, _RISE, _EVE = [8, 6], [0, 2, 9, 5, 1], [4, 6, 2]
PAL_LOCK = {"c3_moon": _NIGHT, "c3_stars": _NIGHT, "c4_vigil": _NIGHT, "c6_stars": _NIGHT, "c3_sunrise": _RISE, "c4_three": _RISE,
            "c5_sunrise": _RISE, "c7_sunrise": _RISE, "c10_valley": _RISE, "c10_sunset": _EVE, "c9_lanterns": _EVE, "c6_horizon": _EVE + [0]}


def tier_name(tier):
    names = ["Beginner", "Easy", "Comfortable", "Moderate", "Challenging", "Hard", "Expert", "Master"]
    return names[min(len(names) - 1, (tier - 1) // 7)]


def build_catalog():
    levels, collections = [], []
    pal_count = len(P.PALETTES)
    seen_titles = set()
    level = 0
    for ci, (cid, folder, title, desc) in enumerate(C.COLLECTIONS):
        subs = C.SUBJECTS[cid]
        start = level + 1
        for i in range(50):
            level += 1
            si = i % len(subs)
            round_ = i // len(subs)
            name, scene_desc, fn = subs[si]
            interior_scene = fn.__name__.startswith(("c2_room", "c2_table", "c2_bread", "c2_lamps", "c2_vessels", "c2_upper", "c2_hearth", "c2_scroll", "c8_arrange", "c9_cakes", "c9_decor", "c9_painting"))
            pal_idx = (si * 3 + round_ * (2 if pal_count % 2 else 3) + ci * 5) % pal_count
            if P.PALETTES[pal_idx].get("night") and ci not in MOONLIT_COLLECTIONS:
                pal_idx = 7 if si % 2 else 10  # sunlit scenes stay in daylight
            if P.PALETTES[pal_idx]["name"] == "dusk" and ci in (7, 8):
                pal_idx = 2
            locked = PAL_LOCK.get(fn.__name__)
            if locked:
                pal_idx = locked[round_ % len(locked)]
            pal = P.PALETTES[pal_idx]
            title_s = f"{name}, Scene {round_ + 1}" if interior_scene or locked else f"{name} {pal['phrase']}"
            n = 2
            base = title_s
            while title_s in seen_titles:
                title_s = f"{base} {_roman(n)}"
                n += 1
            seen_titles.add(title_s)
            n_pieces = piece_count(level)
            rows, cols, merges = choose_grid(n_pieces)
            tier = math.ceil(level / 10)
            filename = f"level_{level:03d}.webp"
            levels.append(dict(
                levelId=level, collectionId=cid, imageId=f"puzzle_{level:03d}", title=title_s,
                description=f"{scene_desc[0].upper()}{scene_desc[1:]}, {pal['light']}.",
                pieceCount=n_pieces, rows=rows, cols=cols, merges=merges, seed=(level * 7919 + 13) & 0x7fffffff,
                rotation=False, tier=tier, difficulty=tier_name(tier), rewardCoins=10,
                unlockRequirement=None if level == 1 else level - 1,
                image=f"assets/puzzle_images/{folder}/{filename}",
                thumbnail=f"assets/thumbnails/levels/level_{level:03d}_thumb.webp",
                estimatedMinutes=max(2, round(n_pieces * .22)), dailyEligible=True, favoriteEligible=True,
                _fn=fn.__name__, _pal=pal_idx, _subject=si, _scene=scene_desc, _folder=folder, _file=filename))
        collections.append(dict(id=cid, order=ci + 1, title=title, description=desc, firstLevel=start, lastLevel=level,
                                cover=f"assets/thumbnails/collections/{cid}.webp", totalPuzzles=50))
    return levels, collections


def _roman(n):
    return ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"][n]


CAMERAS = ["low eye-level view", "elevated three-quarter view", "wide establishing view", "intimate close view", "panoramic long-lens view"]
STYLES = ["cinematic digital painting", "realistic scenic illustration", "soft painterly landscape", "richly detailed matte painting"]


def prompt_for(l):
    pal = P.PALETTES[l["_pal"]]
    i = l["levelId"]
    return dict(
        levelId=i, imageId=l["imageId"], subject=l["_scene"], environment=C.COLLECTIONS[(i - 1) // 50][2],
        composition=f"layered foreground, midground and background, {'subject left of centre' if i % 2 else 'subject right of centre'}",
        lighting=pal["light"], camera=CAMERAS[i % len(CAMERAS)], palette=pal["name"],
        prompt=(f"Create a breathtaking {STYLES[i % len(STYLES)]} of {l['_scene']}. {pal['light'].capitalize()}, "
                f"{CAMERAS[i % len(CAMERAS)]}, layered depth with rich fine detail across the whole frame, "
                f"reverent and family-friendly, premium scenic jigsaw artwork, landscape 4:3 composition, no text, no watermark, no border."),
    )


def render_level(l):
    t0 = time.time()
    folder = os.path.join(ASSETS, "puzzle_images", l["_folder"])
    path = os.path.join(folder, l["_file"])
    thumb = os.path.join(ASSETS, "thumbnails", "levels", f"level_{l['levelId']:03d}_thumb.webp")
    os.makedirs(folder, exist_ok=True)
    os.makedirs(os.path.dirname(thumb), exist_ok=True)
    im = paint(l)
    im.resize(GAME_SIZE, Image.LANCZOS).save(path, "WEBP", quality=72, method=4)
    im.resize(THUMB_SIZE, Image.LANCZOS).save(thumb, "WEBP", quality=70, method=4)
    return l["levelId"], time.time() - t0


def paint(l):
    fn = getattr(C, l["_fn"])
    s = P.Scene(l["seed"], P.PALETTES[l["_pal"]])
    fn(s, l["levelId"])
    return s.finish(flip=l["levelId"] % 7 in (1, 4))


def public(l):
    return {k: v for k, v in l.items() if not k.startswith("_")}


def write_manifests(levels, collections):
    data = os.path.join(ASSETS, "data")
    man = os.path.join(ASSETS, "manifests")
    os.makedirs(data, exist_ok=True)
    os.makedirs(man, exist_ok=True)
    with open(os.path.join(data, "levels.json"), "w") as f:
        json.dump([public(l) for l in levels], f, separators=(",", ":"))
    with open(os.path.join(data, "collections.json"), "w") as f:
        json.dump(collections, f, separators=(",", ":"))
    with open(os.path.join(man, "COLLECTIONS.json"), "w") as f:
        json.dump(collections, f, indent=1)
    with open(os.path.join(man, "LEVEL_IMAGE_MAPPING.json"), "w") as f:
        json.dump({str(l["levelId"]): l["imageId"] for l in levels}, f, indent=0)
    entries = []
    for l in levels:
        exists = os.path.exists(os.path.join(ROOT, l["image"])) and os.path.exists(os.path.join(ROOT, l["thumbnail"]))
        entries.append(dict(
            imageId=l["imageId"], levelId=l["levelId"], collectionId=l["collectionId"], title=l["title"],
            filename=l["image"], thumbnail=l["thumbnail"], width=GAME_SIZE[0], height=GAME_SIZE[1], aspectRatio="4:3",
            sourceType="procedural_original", license="original_generated_artwork", generated=exists))
    with open(os.path.join(man, "ASSET_MANIFEST.json"), "w") as f:
        json.dump(entries, f, indent=0)
    prompts = [prompt_for(l) for l in levels]
    with open(os.path.join(man, "IMAGE_GENERATION_PROMPTS.csv"), "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(prompts[0].keys()))
        w.writeheader()
        w.writerows(prompts)
    with open(os.path.join(man, "IMAGE_ATTRIBUTIONS.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["imageId", "sourceType", "creator", "license", "sourceUrl", "attributionRequired"])
        for l in levels:
            w.writerow([l["imageId"], "procedural_original", "tools/art generator (this project)", "original_generated_artwork", "", "no"])
    return sum(e["generated"] for e in entries)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--manifest-only", action="store_true")
    ap.add_argument("--sample")
    ap.add_argument("--redo", help="comma-separated recipe names to render again")
    ap.add_argument("--out")
    ap.add_argument("--jobs", type=int, default=6)
    a = ap.parse_args()
    levels, cols = build_catalog()
    if a.sample:
        ids = [int(x) for x in a.sample.split(",")]
        os.makedirs(a.out, exist_ok=True)
        for i in ids:
            t0 = time.time()
            paint(levels[i - 1]).resize((800, 600), Image.LANCZOS).save(os.path.join(a.out, f"s{i:03d}.jpg"), quality=85)
            print(i, levels[i - 1]["title"], f"{time.time() - t0:.1f}s", flush=True)
        sys.exit(0)
    if a.redo:
        names = set(a.redo.split(","))
        todo = [l for l in levels if l["_fn"] in names]
        with mp.Pool(a.jobs) as pool:
            print("re-rendered", len(list(pool.imap_unordered(render_level, todo))), flush=True)
    if a.all:
        todo = [l for l in levels if not (os.path.exists(os.path.join(ROOT, l["image"])) and os.path.exists(os.path.join(ROOT, l["thumbnail"])))]
        print(f"rendering {len(todo)} of {len(levels)}", flush=True)
        t0 = time.time()
        with mp.Pool(a.jobs) as pool:
            for n, (lv, dt) in enumerate(pool.imap_unordered(render_level, todo, chunksize=2), 1):
                if n % 20 == 0 or n == len(todo):
                    print(f"{n}/{len(todo)} level {lv} {dt:.1f}s elapsed {time.time() - t0:.0f}s", flush=True)
    print("generated:", write_manifests(levels, cols))
