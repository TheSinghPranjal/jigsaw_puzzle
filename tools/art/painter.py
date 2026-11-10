"""Procedural scenic painter: original artwork, deterministic per seed.

Everything is drawn from code, so the images carry no third-party copyright and
any image can be regenerated exactly from its level id.
"""
import math
import random

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

W, H = 2048, 1536
Xg, Yg = np.meshgrid(np.arange(W, dtype=np.float32), np.arange(H, dtype=np.float32))

# name, top, mid, horizon, sun, cloud, land tint, phrase, is_night
PALETTES = [
    dict(name="dawn", top=(92, 118, 178), mid=(232, 170, 160), hor=(255, 214, 160), sun=(255, 226, 170), cloud=(255, 214, 200), land=(1.0, .93, .86), phrase="at Dawn", light="soft pink dawn light"),
    dict(name="morning", top=(96, 164, 226), mid=(172, 214, 240), hor=(244, 236, 214), sun=(255, 248, 220), cloud=(255, 255, 250), land=(1.0, 1.0, .96), phrase="in Morning Light", light="clear fresh morning light"),
    dict(name="golden", top=(120, 140, 190), mid=(246, 190, 130), hor=(255, 206, 120), sun=(255, 224, 150), cloud=(255, 200, 150), land=(1.06, .94, .78), phrase="at Golden Hour", light="warm low golden-hour sunlight"),
    dict(name="noon", top=(62, 136, 216), mid=(132, 192, 238), hor=(214, 232, 240), sun=(255, 252, 235), cloud=(255, 255, 255), land=(1.04, 1.04, 1.0), phrase="under Clear Skies", light="bright high sunlight"),
    dict(name="sunset", top=(70, 72, 140), mid=(226, 112, 118), hor=(255, 170, 90), sun=(255, 200, 120), cloud=(250, 150, 130), land=(.98, .78, .72), phrase="at Sunset", light="rich crimson sunset light"),
    dict(name="mist", top=(150, 170, 190), mid=(200, 212, 216), hor=(238, 234, 220), sun=(255, 246, 225), cloud=(240, 242, 240), land=(.92, .98, .98), phrase="in Morning Mist", light="soft diffused misty light"),
    dict(name="dusk", top=(44, 56, 120), mid=(126, 98, 160), hor=(240, 150, 130), sun=(250, 190, 150), cloud=(180, 130, 170), land=(.74, .72, .88), phrase="at Dusk", light="violet twilight glow"),
    dict(name="spring", top=(120, 186, 232), mid=(190, 226, 236), hor=(250, 240, 208), sun=(255, 244, 200), cloud=(255, 252, 244), land=(1.0, 1.08, .92), phrase="in Spring Light", light="gentle spring sunshine"),
    dict(name="moon", top=(14, 22, 62), mid=(38, 56, 112), hor=(96, 112, 160), sun=(236, 238, 250), cloud=(110, 124, 170), land=(.46, .54, .78), phrase="by Moonlight", light="silver moonlight with deep blue shadows", night=True),
    dict(name="stormbreak", top=(84, 96, 132), mid=(176, 176, 190), hor=(255, 222, 170), sun=(255, 238, 190), cloud=(214, 208, 214), land=(.92, .92, .9), phrase="as the Clouds Part", light="shafts of sunlight breaking through clouds"),
    dict(name="afternoon", top=(84, 150, 214), mid=(186, 214, 226), hor=(250, 224, 186), sun=(255, 240, 200), cloud=(255, 246, 232), land=(1.05, 1.0, .88), phrase="on a Warm Afternoon", light="warm amber afternoon light"),
]


def lerp(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))


def noise(nr, sx=400, sy=400, octaves=5, persist=.55):
    out = np.zeros((H, W), np.float32)
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        cw, ch = max(3, int(W / sx * 2 ** o) + 2), max(3, int(H / sy * 2 ** o) + 2)
        a = nr.random((ch, cw)).astype(np.float32)
        out += np.asarray(Image.fromarray(a, mode="F").resize((W, H), Image.BICUBIC)) * amp
        tot += amp
        amp *= persist
    out /= tot
    return (out - out.min()) / (np.ptp(out) + 1e-6)


class Scene:
    def __init__(self, seed, palette):
        self.r = random.Random(seed)
        self.nr = np.random.default_rng(seed)
        self.p = palette
        self.night = palette.get("night", False)
        self.arr = np.zeros((H, W, 3), np.float32)
        self.sun = (W * self.r.uniform(.2, .8), H * self.r.uniform(.14, .34))
        self._im = None

    # --- canvas sync: numpy for fields, PIL for shapes
    @property
    def d(self):
        if self._im is None:
            self._im = Image.fromarray(np.clip(self.arr, 0, 255).astype(np.uint8))
            self._draw = ImageDraw.Draw(self._im)
        return self._draw

    def np(self):
        if self._im is not None:
            self.arr = np.asarray(self._im).astype(np.float32).copy()
            self._im = None
        return self.arr

    def tint(self, col, f=1.0, j=0):
        t = self.p["land"]
        k = self.r.uniform(-j, j) if j else 0
        return tuple(int(max(0, min(255, col[i] * t[i] * f * (1 + k)))) for i in range(3))

    # --- fields
    def sky(self, hy=.62, clouds=.5, sun=True):
        a = self.np()
        p = self.p
        t = np.clip(Yg / (H * hy), 0, 1)[..., None]
        top, mid, hor = [np.array(p[k], np.float32) for k in ("top", "mid", "hor")]
        k = np.clip(t * 2, 0, 1)
        k2 = np.clip(t * 2 - 1, 0, 1)
        a[:] = top * (1 - k) + mid * k
        a[:] = a * (1 - k2) + hor * k2
        sx, sy = self.sun
        if self.night:
            for _ in range(650):
                x, y = self.r.randrange(W), self.r.randrange(int(H * hy))
                v = self.r.uniform(120, 255)
                rad = 1 if self.r.random() < .85 else 2
                a[max(0, y - rad):y + rad, max(0, x - rad):x + rad] = (v, v, min(255, v + 20))
        if sun:
            d2 = (Xg - sx) ** 2 + (Yg - sy) ** 2
            glow = (np.exp(-d2 / (2 * 330.0 ** 2)) * .55 + np.exp(-d2 / (2 * 900.0 ** 2)) * .3)[..., None] * (.4 if self.night else 1)
            a[:] = a * (1 - glow) + np.array(p["sun"], np.float32) * glow
            disc = np.clip((64 - np.sqrt(d2)) / 3, 0, 1)[..., None]
            a[:] = a * (1 - disc) + np.array(p["sun"], np.float32) * disc
        if clouds > 0:
            n = noise(self.nr, 620, 200, 6)
            n2 = noise(self.nr, 380, 150, 5)
            cov = np.clip((n - (.6 - clouds * .3)) * 4.0, 0, 1)
            cov *= np.clip(1.2 - Yg / (H * hy), 0, 1)
            cc = np.array(p["cloud"], np.float32)
            shade = (.76 + .3 * n2)[..., None]
            cov = (cov * .92)[..., None]
            a[:] = a * (1 - cov) + np.clip(cc * shade, 0, 255) * cov

    def line(self, base, amp, freq=3.0, rough=.5, octs=6):
        ys = np.zeros(W, np.float32)
        a, f = 1.0, freq
        for _ in range(octs):
            ph = self.r.uniform(0, 6.28)
            ys += a * np.sin(np.arange(W) / W * f * 6.28 + ph + self.r.uniform(0, 1))
            a *= rough
            f *= 2.03
        return base * H - ys / max(1e-5, np.abs(ys).max()) * amp * H

    def land(self, base, amp, top, bot, freq=2.0, rough=.45, tex=.14, snow=False, line=None):
        a = self.np()
        ys = self.line(base, amp, freq, rough) if line is None else line
        yl = ys[Xg.astype(int)]
        depth = np.clip((Yg - yl) / (H - yl + 1), 0, 1)
        m = np.clip((Yg - yl) / 2.5, 0, 1)[..., None]
        n = noise(self.nr, 170, 120, 6)
        n2 = noise(self.nr, 44, 44, 3)
        c0 = np.array(self.tint(top), np.float32)
        c1 = np.array(self.tint(bot), np.float32)
        k = (depth ** .7)[..., None]
        col = c0 * (1 - k) + c1 * k
        col = col * (1 + ((n - .5) * tex * 2 + (n2 - .5) * tex)[..., None])
        if snow:
            s = np.clip(1.1 - (Yg - ys.min()) / (amp * H * 1.25) - (n - .5) * 1.1, 0, 1)[..., None]
            s = np.clip(s * 3 - .6, 0, 1)
            col = col * (1 - s) + np.array(self.tint((250, 250, 255)), np.float32) * s
        a[:] = a * (1 - m) + np.clip(col, 0, 255) * m
        return ys

    def haze(self, y0, y1, strength=.4):
        a = self.np()
        t = (1 - np.abs((Yg - (y0 + y1) / 2 * H) / ((y1 - y0) * H / 2))).clip(0, 1)
        n = noise(self.nr, 500, 120, 4)
        k = (t ** 1.3 * strength * (.5 + n))[..., None]
        a[:] = a * (1 - k) + np.array(self.p["hor"], np.float32) * k

    def glow(self, x, y, rad, col, strength=.8):
        a = self.np()
        x0, x1 = max(0, int(x - rad * 2.6)), min(W, int(x + rad * 2.6))
        y0, y1 = max(0, int(y - rad * 2.6)), min(H, int(y + rad * 2.6))
        if x1 <= x0 or y1 <= y0:
            return
        d2 = (Xg[y0:y1, x0:x1] - x) ** 2 + (Yg[y0:y1, x0:x1] - y) ** 2
        k = (np.exp(-d2 / (2 * rad * rad)) * strength)[..., None]
        a[y0:y1, x0:x1] = a[y0:y1, x0:x1] * (1 - k) + np.array(col, np.float32) * k

    def rays(self, x, y, n=9, spread=1.2, ang0=math.pi / 2, length=1500, col=None, strength=.28):
        a = self.np()
        col = np.array(col or self.p["sun"], np.float32)
        layer = Image.new("L", (W, H), 0)
        dr = ImageDraw.Draw(layer)
        for i in range(n):
            ang = ang0 - spread / 2 + spread * (i + self.r.random() * .7) / n
            wd = self.r.uniform(.015, .05)
            pts = [(x, y), (x + math.cos(ang - wd) * length, y + math.sin(ang - wd) * length),
                   (x + math.cos(ang + wd) * length, y + math.sin(ang + wd) * length)]
            dr.polygon(pts, fill=int(self.r.uniform(120, 255)))
        k = np.asarray(layer.filter(ImageFilter.GaussianBlur(26))).astype(np.float32) / 255
        d = np.sqrt((Xg - x) ** 2 + (Yg - y) ** 2)
        k = (k * np.clip(1.1 - d / length, 0, 1) * strength)[..., None]
        a[:] = a * (1 - k) + col * k

    def reflect(self, y):
        """Mirror everything above y into the water below it."""
        a = self.np()
        yi = int(y)
        rows = H - yi
        n = noise(self.nr, 700, 16, 3)
        for j in range(rows):
            src = max(0, yi - 1 - int(j * 1.15))
            amp = 3 + j * .05
            shift = ((n[yi + j] - .5) * amp * 8).astype(int)
            xs = np.clip(np.arange(W) + shift, 0, W - 1)
            a[yi + j] = a[src, xs]
        fade = np.clip((Yg - y) / rows, 0, 1)[..., None]
        deep = np.array(self.tint((46, 96, 124)), np.float32)
        k = fade * .42 + .12
        mask = (Yg >= yi)[..., None]
        a[:] = np.where(mask, a * (1 - k) + deep * k, a)
        for _ in range(900):
            jy = yi + int(rows * self.r.random() ** 1.5)
            jx = self.r.randrange(W)
            ln = int(12 + (jy - yi) * .16)
            v = self.r.uniform(.84, 1.18)
            a[jy:jy + 2, jx:jx + ln] = np.clip(a[jy:jy + 2, jx:jx + ln] * v, 0, 255)

    # --- generic drawing helpers
    def dab_field(self, y0, y1, n, cols, smin=3, smax=16, mask_fn=None):
        d = self.d
        pts = sorted(((self.r.uniform(0, W), y0 * H + (y1 - y0) * H * self.r.random() ** .75) for _ in range(n)), key=lambda q: q[1])
        for x, y in pts:
            if mask_fn and not mask_fn(x, y):
                continue
            t = (y / H - y0) / max(1e-4, y1 - y0)
            s = smin + (smax - smin) * t
            c = self.tint(self.r.choice(cols), 1, .1)
            ln = s * self.r.uniform(.8, 2.2)
            d.line([(x, y), (x + self.r.uniform(-.4, .4) * ln, y - ln)], fill=c, width=max(1, int(s * .55)))

    def blob(self, x, y, rx, ry, col):
        self.d.ellipse([x - rx, y - ry, x + rx, y + ry], fill=col)

    def poly(self, pts, col):
        self.d.polygon([(float(a), float(b)) for a, b in pts], fill=col)

    def stroke(self, pts, col, w):
        self.d.line([(float(a), float(b)) for a, b in pts], fill=col, width=int(max(1, w)), joint="curve")

    def finish(self, flip=False, strokes=95000):
        a = self.np()
        a[:] = np.clip(a, 0, 255)
        src = Image.fromarray(a.astype(np.uint8))
        px = src.load()
        painted = src.copy()
        dr = ImageDraw.Draw(painted)
        field = noise(self.nr, 260, 260, 3)
        for _ in range(strokes):
            x, y = self.r.randrange(W), self.r.randrange(H)
            c = px[x, y]
            v = self.r.uniform(.93, 1.07)
            c = (min(255, int(c[0] * v)), min(255, int(c[1] * v)), min(255, int(c[2] * v)))
            ang = field[y, x] * 6.28
            ln = self.r.uniform(4, 15)
            dr.line([(x - math.cos(ang) * ln, y - math.sin(ang) * ln), (x + math.cos(ang) * ln, y + math.sin(ang) * ln)], fill=c, width=self.r.choice((2, 3, 4)))
        out = Image.blend(src, painted, .62)
        o = np.asarray(out).astype(np.float32)
        vign = 1 - .17 * (((Xg - W / 2) / (W / 2)) ** 2 + ((Yg - H / 2) / (H / 2)) ** 2)[..., None]
        o = np.clip(((o / 255 - .5) * 1.07 + .5) * 255 * vign, 0, 255).astype(np.uint8)
        im = Image.fromarray(o)
        return im.transpose(Image.FLIP_LEFT_RIGHT) if flip else im


# ---------- vegetation ----------
def grass(s, y0, y1, n=9000, cols=None):
    s.dab_field(y0, y1, n, cols or [(92, 142, 70), (120, 168, 82), (70, 120, 62), (150, 186, 92)], 4, 22)


def palm(s, x, y, h, lean=None, sil=False):
    r = s.r
    lean = r.uniform(-.25, .25) if lean is None else lean
    tc = (40, 34, 40) if sil else s.tint((122, 92, 64))
    px, py = x, y
    for i in range(60):
        t = i / 59
        px, py = x + lean * h * t * t, y - h * t
        w = h * .03 * (1.25 - .6 * t)
        col = tc if sil or i % 4 else s.tint((92, 68, 48))
        s.blob(px, py, w, h * .012 + 2, col)
    leaf = [(44, 104, 62), (60, 128, 70), (88, 150, 76)]
    for i in range(11):
        ang = -math.pi + i * math.pi / 10 + r.uniform(-.1, .1)
        L = h * r.uniform(.42, .6)
        col = (34, 34, 42) if sil else s.tint(r.choice(leaf))
        prev = None
        for k in range(26):
            t = k / 25
            fx = px + math.cos(ang) * L * t
            fy = py + math.sin(ang) * L * t * .75 + L * .62 * t * t
            if prev:
                s.d.line([prev, (fx, fy)], fill=col, width=max(1, int(h * .007)))
            ll = h * .12 * math.sin(math.pi * min(1, t + .08)) ** .7
            s.d.line([(fx, fy), (fx + math.cos(ang + 1.2) * ll, fy + abs(math.sin(ang + 1.2)) * ll + ll * .4)], fill=col, width=max(1, int(h * .005)))
            s.d.line([(fx, fy), (fx + math.cos(ang - 1.2) * ll, fy + abs(math.sin(ang - 1.2)) * ll + ll * .4)], fill=col, width=max(1, int(h * .005)))
            prev = (fx, fy)


def olive(s, x, y, h):
    r = s.r
    bark = s.tint((96, 80, 66))
    dark = s.tint((58, 48, 44))
    for off in (-.1, 0, .11):
        pts = [(x + off * h * 1.3, y)]
        for t in (.25, .5, .72):
            pts.append((x + off * h * (1 + t) + r.uniform(-.06, .06) * h, y - h * t * .62))
        s.stroke(pts, dark, h * .08)
        s.stroke([(a - h * .012, b) for a, b in pts], bark, h * .05)
    cx, cy = x, y - h * .78
    cols = [(112, 136, 96), (134, 156, 112), (88, 116, 84), (160, 176, 128), (70, 96, 74)]
    n = int(90 + h * .9)
    items = []
    for _ in range(n):
        a, d = r.uniform(0, 6.28), r.random() ** .55
        fx, fy = cx + math.cos(a) * d * h * .68, cy + math.sin(a) * d * h * .42
        items.append((fx, fy))
    items.sort(key=lambda q: q[1], reverse=True)
    for fx, fy in items:
        lit = (cy + h * .4 - fy) / (h * .8)
        c = s.tint(cols[min(4, max(0, int(r.gauss(0, 1.0) + (1 - lit) * 3)))], .8 + lit * .34, .08)
        rr = h * r.uniform(.03, .07)
        s.blob(fx, fy, rr * 1.3, rr, c)


def conifer(s, x, y, h, col=(44, 86, 70), snow=False):
    r = s.r
    s.stroke([(x, y), (x, y - h * .2)], s.tint((70, 54, 44)), h * .05)
    for i in range(7):
        t = i / 7
        wd = h * .3 * (1 - t) + h * .03
        yy = y - h * .12 - t * h * .78
        c = s.tint(col, .8 + t * .45, .08)
        s.poly([(x - wd, yy), (x + wd, yy), (x, yy - h * .28)], c)
        if snow:
            s.poly([(x - wd * .6, yy - h * .09), (x + wd * .45, yy - h * .1), (x, yy - h * .28)], s.tint((240, 244, 252)))


def broadleaf(s, x, y, h, cols=None):
    r = s.r
    cols = cols or [(82, 136, 78), (108, 158, 88), (62, 112, 72), (140, 180, 100)]
    s.stroke([(x, y), (x + r.uniform(-.03, .03) * h, y - h * .5)], s.tint((88, 70, 54)), h * .07)
    cx, cy = x, y - h * .68
    pts = []
    for _ in range(int(70 + h * .7)):
        a, d = r.uniform(0, 6.28), r.random() ** .6
        pts.append((cx + math.cos(a) * d * h * .42, cy + math.sin(a) * d * h * .38))
    pts.sort(key=lambda q: -q[1])
    for fx, fy in pts:
        lit = (cy + h * .38 - fy) / (h * .76)
        c = s.tint(r.choice(cols), .72 + lit * .46, .06)
        rr = h * r.uniform(.04, .08)
        s.blob(fx, fy, rr * 1.2, rr, c)


def cypress(s, x, y, h):
    for i in range(int(h / 2)):
        t = i / (h / 2)
        wd = h * .085 * math.sin(math.pi * (t * .92 + .08)) ** .7
        s.d.line([(x - wd, y - t * h), (x + wd, y - t * h)], fill=s.tint((44, 78, 62), .85 + .3 * t, .1), width=3)


# ---------- flowers ----------
def stem(s, x, y, h, col=(70, 124, 66)):
    s.stroke([(x, y), (x + h * .06, y - h * .5), (x, y - h)], s.tint(col), max(2, h * .05))


def lily(s, x, y, rad):
    stem(s, x, y + rad * 3.2, rad * 3.2)
    s.poly([(x, y + rad * 2.8), (x - rad * 1.7, y + rad * 1.2), (x - rad * .3, y + rad * 1.6)], s.tint((84, 140, 76)))
    for i in range(6):
        a = i * math.pi / 3 + .26
        ca, sa = math.cos(a), math.sin(a)
        for shade, w, ln in (((214, 212, 192), .46, 1.08), ((255, 253, 244), .32, 1.0)):
            s.poly([(x + ca * rad * .1, y + sa * rad * .1), (x + ca * rad * .6 - sa * rad * w, y + sa * rad * .6 + ca * rad * w),
                    (x + ca * rad * ln, y + sa * rad * ln), (x + ca * rad * .6 + sa * rad * w, y + sa * rad * .6 - ca * rad * w)], s.tint(shade))
    s.blob(x, y, rad * .22, rad * .22, s.tint((222, 196, 92)))
    for i in range(5):
        a = i * 1.257
        s.blob(x + math.cos(a) * rad * .32, y + math.sin(a) * rad * .32, rad * .07, rad * .07, s.tint((196, 120, 44)))


def tulip(s, x, y, rad, col):
    stem(s, x, y + rad * 3.4, rad * 3.4)
    s.poly([(x, y + rad * 3.2), (x + rad * .9, y + rad * .9), (x + rad * .25, y + rad * 2.2)], s.tint((88, 148, 80)))
    dark = tuple(c * .78 for c in col)
    s.poly([(x - rad, y - rad * .9), (x - rad * .95, y + rad * .5), (x, y + rad), (x + rad * .95, y + rad * .5), (x + rad, y - rad * .9), (x + rad * .4, y - rad * .3), (x, y - rad * 1.05), (x - rad * .4, y - rad * .3)], s.tint(dark))
    s.poly([(x - rad * .5, y - rad * .55), (x - rad * .55, y + rad * .55), (x, y + rad * .92), (x + rad * .45, y + rad * .55), (x + rad * .35, y - rad * .55), (x, y - rad * 1.05)], s.tint(col))


def daffodil(s, x, y, rad):
    stem(s, x, y + rad * 3, rad * 3)
    for i in range(6):
        a = i * math.pi / 3
        ca, sa = math.cos(a), math.sin(a)
        s.poly([(x, y), (x + ca * rad * .5 - sa * rad * .34, y + sa * rad * .5 + ca * rad * .34), (x + ca * rad * 1.05, y + sa * rad * 1.05), (x + ca * rad * .5 + sa * rad * .34, y + sa * rad * .5 - ca * rad * .34)], s.tint((250, 222, 92)))
    s.blob(x, y, rad * .46, rad * .46, s.tint((240, 156, 44)))
    s.blob(x, y, rad * .26, rad * .26, s.tint((204, 116, 30)))


def daisy(s, x, y, rad, col=(255, 250, 240)):
    for i in range(9):
        a = i * .698
        s.blob(x + math.cos(a) * rad * .66, y + math.sin(a) * rad * .66, rad * .36, rad * .36, s.tint(col, 1, .04))
    s.blob(x, y, rad * .36, rad * .36, s.tint((240, 188, 64)))


def flower_bed(s, y0, y1, n, kinds, rmin=7, rmax=40):
    r = s.r
    pal = [(232, 84, 96), (246, 150, 170), (250, 186, 74), (186, 120, 208), (240, 104, 60), (255, 240, 225)]
    items = sorted(((r.uniform(-20, W + 20), y0 * H + (y1 - y0) * H * r.random() ** .8) for _ in range(n)), key=lambda q: q[1])
    for x, y in items:
        t = (y / H - y0) / max(1e-4, y1 - y0)
        rad = rmin + (rmax - rmin) * t ** 1.3
        k = r.choice(kinds)
        if k == "lily":
            lily(s, x, y, rad * 1.25)
        elif k == "tulip":
            tulip(s, x, y, rad * .9, r.choice(pal[:5]))
        elif k == "daffodil":
            daffodil(s, x, y, rad)
        else:
            daisy(s, x, y, rad * .8, r.choice([(255, 250, 240), (250, 190, 210), (214, 190, 244), (255, 226, 130)]))


def poppy_dabs(s, y0, y1, n, cols):
    r = s.r
    for _ in range(n):
        y = y0 * H + (y1 - y0) * H * r.random() ** .7
        t = (y / H - y0) / max(1e-4, y1 - y0)
        rad = 2 + 15 * t
        x = r.uniform(0, W)
        s.blob(x, y, rad * r.uniform(.9, 1.3), rad * r.uniform(.6, 1), s.tint(r.choice(cols), 1, .1))


# ---------- architecture ----------
STONES = [(216, 196, 160), (232, 214, 178), (198, 176, 142), (224, 204, 176)]


def building(s, x, y, w, h, col=None, dome=False, arch=True):
    r = s.r
    col = col or r.choice(STONES)
    base = s.tint(col)
    side = s.tint(col, .72)
    s.poly([(x, y), (x, y - h), (x + w, y - h), (x + w, y)], base)
    s.poly([(x + w, y), (x + w, y - h), (x + w * 1.16, y - h * .96), (x + w * 1.16, y)], side)
    # masonry flecks give the walls real puzzle detail
    for _ in range(int(w * h / 500)):
        fx, fy = r.uniform(x, x + w), r.uniform(y - h, y)
        s.d.line([(fx, fy), (fx + r.uniform(5, 18), fy)], fill=s.tint(col, r.uniform(.8, 1.1)), width=2)
    win = (58, 44, 44) if not s.night else (246, 196, 110)
    cols = max(1, int(w / 44))
    rows = max(1, int(h / 62))
    for i in range(cols):
        for j in range(rows):
            if r.random() < .28:
                continue
            wx = x + (i + .5) * w / cols
            wy = y - (j + .62) * h / rows
            ww, wh = max(4, w / cols * .17), h / rows * .22
            s.d.rectangle([wx - ww, wy - wh * .3, wx + ww, wy + wh], fill=win)
            if arch:
                s.d.pieslice([wx - ww, wy - wh * .3 - ww, wx + ww, wy - wh * .3 + ww], 180, 360, fill=win)
    if dome:
        cx, rad = x + w / 2, w * .44
        c = r.choice([(214, 176, 92), (120, 158, 180), (190, 160, 120)])
        s.d.pieslice([cx - rad, y - h - rad * 1.2, cx + rad, y - h + rad * 1.2], 180, 360, fill=s.tint(c))
        s.d.pieslice([cx - rad * .9, y - h - rad * 1.1, cx - rad * .05, y - h + rad], 180, 300, fill=s.tint(c, 1.22))
    else:
        s.d.rectangle([x - 3, y - h - 8, x + w * 1.16 + 3, y - h], fill=s.tint(col, .86))


def city(s, y, cx=None, spread=None, count=None, scale=1.0, wall=True):
    r = s.r
    cx = W / 2 if cx is None else cx
    spread = spread or W * .55
    count = count or int(26 * scale + 16)
    items = []
    for _ in range(count):
        items.append((r.gauss(cx, spread * .42), r.uniform(.6, 1.0)))
    # back rows first
    for bx, sc in sorted(items, key=lambda q: q[1]):
        wd, h = r.uniform(70, 150) * scale * sc, r.uniform(80, 240) * scale * sc
        lift = (1 - sc) * 170 * scale
        building(s, bx - wd / 2, y - lift, wd, h, dome=r.random() < .16)
    if wall:
        wc = s.tint((206, 184, 150))
        s.d.rectangle([0, y - 86 * scale, W, y + 8], fill=wc)
        for bx in range(0, W, int(46 * scale)):
            s.d.rectangle([bx, y - 110 * scale, bx + 24 * scale, y - 84 * scale], fill=wc)
        for _ in range(int(1800 * scale)):
            fx, fy = r.uniform(0, W), r.uniform(y - 84 * scale, y)
            s.d.line([(fx, fy), (fx + r.uniform(10, 34), fy)], fill=s.tint((206, 184, 150), r.uniform(.76, 1.08)), width=2)
        for tx in sorted(r.uniform(0, W) for _ in range(3)):
            building(s, tx - 64 * scale, y, 128 * scale, 250 * scale, col=(214, 192, 158), arch=True)


def stone_path(s, x0, w0, x1, w1, y0, y1, col=(198, 178, 148)):
    r = s.r
    s.poly([(x0 - w0, y0), (x0 + w0, y0), (x1 + w1, y1), (x1 - w1, y1)], s.tint(col, .9))
    n = 1500
    for _ in range(n):
        t = r.random() ** .55
        cx, wd = x0 + (x1 - x0) * t, w0 + (w1 - w0) * t
        px, py = cx + r.uniform(-wd, wd), y0 + (y1 - y0) * t
        sz = 4 + 40 * t
        s.blob(px, py, sz, sz * .5, s.tint(r.choice(STONES), r.uniform(.72, 1.06)))


def cottage(s, x, y, w, walls=None, roof=None):
    r = s.r
    h = w * r.uniform(.56, .72)
    walls = walls or r.choice([(246, 236, 214), (236, 214, 190), (252, 226, 204), (214, 226, 232)])
    roof = roof or r.choice([(176, 92, 70), (126, 96, 88), (150, 76, 80), (112, 120, 130), (196, 152, 92)])
    s.poly([(x, y), (x, y - h), (x + w, y - h), (x + w, y)], s.tint(walls))
    s.poly([(x - w * .1, y - h), (x + w / 2, y - h - w * .5), (x + w * 1.1, y - h)], s.tint(roof))
    for i in range(int(w * .8)):
        a = r.random()
        rx = x - w * .1 + a * w * 1.2
        peak = (1 - abs(a - .5) * 2) * w * .5
        ry = y - h - r.uniform(0, peak)
        s.d.line([(rx, ry), (rx + r.uniform(8, 18), ry)], fill=s.tint(roof, r.uniform(.72, 1.18)), width=2)
    s.d.rectangle([x + w * .72, y - h - w * .42, x + w * .84, y - h - w * .1], fill=s.tint((150, 120, 104)))
    door = s.tint(r.choice([(92, 124, 150), (150, 90, 80), (96, 134, 100)]))
    s.d.rectangle([x + w * .42, y - h * .56, x + w * .58, y], fill=door)
    glass = (250, 214, 130) if s.night or s.p["name"] in ("dusk", "sunset") else (140, 176, 196)
    for wx in (.14, .68):
        s.d.rectangle([x + w * wx, y - h * .72, x + w * (wx + .18), y - h * .36], fill=s.tint((255, 255, 250)))
        s.d.rectangle([x + w * (wx + .015), y - h * .70, x + w * (wx + .165), y - h * .38], fill=glass)
        s.d.line([(x + w * (wx + .09), y - h * .72), (x + w * (wx + .09), y - h * .36)], fill=s.tint((255, 255, 250)), width=3)
    for _ in range(int(w * .7)):
        fx = x + r.uniform(0, w)
        fy = y - r.random() ** 2 * h * .5
        s.blob(fx, fy, r.uniform(3, 9), r.uniform(3, 8), s.tint(r.choice([(236, 110, 130), (250, 180, 80), (190, 130, 220), (92, 150, 84), (74, 130, 74)])))


# ---------- figures and creatures ----------
def figure(s, x, y, h, robe=(120, 90, 140), halo=False, arms_up=False, sash=None):
    r = s.r
    rb = s.tint(robe)
    dk = s.tint(robe, .72)
    hx, hy = x, y - h * .88
    if halo:
        s.glow(hx, hy, h * .2, (255, 236, 170), .75)
        d = s.d
        d.ellipse([hx - h * .14, hy - h * .14, hx + h * .14, hy + h * .14], outline=(255, 226, 140), width=max(2, int(h * .012)))
    s.poly([(x - h * .17, y), (x - h * .09, y - h * .72), (x + h * .09, y - h * .72), (x + h * .17, y)], rb)
    s.poly([(x, y), (x + h * .02, y - h * .72), (x + h * .09, y - h * .72), (x + h * .17, y)], dk)
    for i in range(4):
        fx = x + (i - 1.5) * h * .07
        s.stroke([(fx * .98 + x * .02, y - h * .62), (fx, y)], dk, max(1, h * .008))
    if sash:
        s.poly([(x - h * .1, y - h * .72), (x + h * .1, y - h * .7), (x + h * .15, y - h * .1), (x + h * .06, y - h * .1)], s.tint(sash))
    if arms_up:
        s.stroke([(x - h * .08, y - h * .66), (x - h * .22, y - h * .9)], rb, h * .05)
        s.stroke([(x + h * .08, y - h * .66), (x + h * .22, y - h * .9)], rb, h * .05)
    s.blob(hx, hy - h * .012, h * .088, h * .1, s.tint(robe, .84))
    s.blob(hx, hy + h * .012, h * .06, h * .07, s.tint((214, 174, 138)))
    s.stroke([(hx - h * .06, hy - h * .03), (hx, hy - h * .07), (hx + h * .06, hy - h * .03)], s.tint((92, 66, 50)), max(2, h * .02))


def donkey(s, x, y, h, rider=None):
    col = s.tint((132, 118, 108))
    dk = s.tint((96, 84, 78))
    s.blob(x, y - h * .62, h * .46, h * .22, col)
    for lx in (-.34, -.2, .2, .34):
        s.stroke([(x + lx * h, y - h * .5), (x + lx * h, y)], dk, h * .05)
    s.stroke([(x + h * .36, y - h * .7), (x + h * .58, y - h * .95)], col, h * .16)
    s.blob(x + h * .64, y - h * .95, h * .15, h * .09, col)
    for ex in (.54, .6):
        s.poly([(x + ex * h, y - h * 1.04), (x + (ex + .03) * h, y - h * 1.26), (x + (ex + .07) * h, y - h * 1.03)], dk)
    s.stroke([(x - h * .46, y - h * .68), (x - h * .56, y - h * .36)], dk, h * .025)
    if rider:
        figure(s, x - h * .02, y - h * .66, h * 1.1, robe=rider[0], halo=rider[1], sash=rider[2])


def crowd(s, y0, y1, n, palms=True):
    r = s.r
    robes = [(180, 120, 90), (120, 140, 170), (160, 90, 90), (200, 170, 120), (110, 130, 110), (150, 120, 170), (230, 216, 190)]
    pts = sorted(((r.uniform(0, W), r.uniform(y0, y1) * H) for _ in range(n)), key=lambda q: q[1])
    for x, y in pts:
        t = (y / H - y0) / max(1e-4, y1 - y0)
        h = 90 + 170 * t
        figure(s, x, y, h, robe=r.choice(robes), arms_up=palms and r.random() < .4)
        if palms and r.random() < .55:
            hand = (x + r.choice((-1, 1)) * h * .22, y - h * .9)
            palm_frond(s, hand[0], hand[1], h * .55)


def palm_frond(s, x, y, ln, ang=None, col=None):
    r = s.r
    ang = (-math.pi / 2 + r.uniform(-.6, .6)) if ang is None else ang
    col = col or s.tint(r.choice([(70, 136, 72), (92, 156, 80), (52, 112, 66)]))
    prev = (x, y)
    for k in range(1, 20):
        t = k / 19
        fx, fy = x + math.cos(ang) * ln * t + ln * .1 * t * t, y + math.sin(ang) * ln * t + ln * .22 * t * t
        s.d.line([prev, (fx, fy)], fill=col, width=max(2, int(ln * .02)))
        ll = ln * .22 * math.sin(math.pi * min(1, t + .1))
        s.d.line([(fx, fy), (fx + math.cos(ang + 1.0) * ll, fy + math.sin(ang + 1.0) * ll)], fill=col, width=max(2, int(ln * .014)))
        s.d.line([(fx, fy), (fx + math.cos(ang - 1.0) * ll, fy + math.sin(ang - 1.0) * ll)], fill=col, width=max(2, int(ln * .014)))
        prev = (fx, fy)


def dove(s, x, y, rad, up=True):
    w = s.tint((252, 252, 250))
    sh = s.tint((208, 212, 222))
    lift = -1 if up else .55
    for k, col in ((-1, sh), (1, w)):
        tip = (x + k * .25 * rad - rad * .4, y + lift * rad * 2.1)
        root_a, root_b = (x - rad * .55, y - rad * .1), (x + rad * .45, y - rad * .1)
        pts = [root_a]
        for i in range(7):
            t = i / 6
            scallop = rad * .12 * (i % 2)
            pts.append((root_a[0] + (tip[0] - k * rad * .9 - root_a[0]) * t, root_a[1] + (tip[1] - root_a[1]) * t - scallop * lift))
        pts += [tip, (tip[0] + k * rad * .75, tip[1] - lift * rad * .12), root_b]
        s.poly(pts, col)
    s.blob(x, y, rad, rad * .46, w)
    s.blob(x + rad * .95, y - rad * .22, rad * .32, rad * .27, w)
    s.poly([(x + rad * 1.24, y - rad * .26), (x + rad * 1.5, y - rad * .18), (x + rad * 1.24, y - rad * .1)], s.tint((236, 170, 90)))
    s.blob(x + rad * 1.04, y - rad * .28, rad * .05, rad * .05, (24, 22, 26))
    for off in (-.14, 0, .14):
        s.poly([(x - rad * .8, y + off * rad), (x - rad * 1.95, y - rad * .3 + off * rad * 2), (x - rad * 1.95, y + rad * .12 + off * rad * 2)], sh if off else w)


def angel(s, x, y, h, robe=(250, 244, 232)):
    s.glow(x, y - h * .55, h * .62, s.p["sun"], .6)
    r = s.r
    for k in (-1, 1):
        # three overlapping rows of feathers sweeping up and out from the shoulder
        for layer, (span, width, f) in enumerate(((1.0, .16, .88), (.78, .13, .96), (.54, .1, 1.04))):
            for i in range(16):
                t = i / 15
                ang = 1.28 - t * 1.9
                root = (x + k * h * (.05 + t * .12), y - h * (.72 - t * .04))
                ln = h * span * (.48 + .36 * math.sin(t * 3.14) ** .6)
                tip = (root[0] + k * math.cos(ang) * ln, root[1] - math.sin(ang) * ln - h * .12 * (1 - t))
                nx, ny = -(tip[1] - root[1]) / max(1, ln) * h * width * .5, (tip[0] - root[0]) / max(1, ln) * h * width * .5
                mid = ((root[0] + tip[0]) / 2, (root[1] + tip[1]) / 2)
                s.poly([root, (mid[0] + nx, mid[1] + ny), tip, (mid[0] - nx, mid[1] - ny)], s.tint((255, 252, 244), f + r.uniform(-.03, .03)))
    figure(s, x, y, h, robe=robe, halo=True, sash=(236, 206, 140))


def bird(s, x, y, rad, col):
    s.blob(x, y, rad, rad * .72, col)
    s.blob(x + rad * .8, y - rad * .55, rad * .5, rad * .46, col)
    s.poly([(x + rad * 1.2, y - rad * .6), (x + rad * 1.7, y - rad * .46), (x + rad * 1.2, y - rad * .36)], (236, 170, 60))
    s.poly([(x - rad * .8, y), (x - rad * 1.9, y + rad * .3), (x - rad * .7, y + rad * .45)], tuple(int(c * .75) for c in col))
    s.blob(x - rad * .12, y - rad * .05, rad * .62, rad * .4, tuple(int(c * .82) for c in col))
    s.blob(x + rad * .96, y - rad * .64, rad * .09, rad * .09, (20, 20, 24))


def butterfly(s, x, y, rad, col):
    alt = tuple(int(min(255, c * 1.2)) for c in col)
    for k in (-1, 1):
        s.d.ellipse([x + (k * rad * 1.1) - rad * .9, y - rad * 1.0, x + (k * rad * 1.1) + rad * .9, y + rad * .2], fill=col)
        s.d.ellipse([x + (k * rad * .85) - rad * .55, y - rad * .05, x + (k * rad * .85) + rad * .55, y + rad * .85], fill=alt)
        s.blob(x + k * rad * 1.1, y - rad * .5, rad * .3, rad * .3, (255, 245, 220))
    s.blob(x, y, rad * .12, rad * .75, (46, 36, 40))


def lamb(s, x, y, h, facing=1):
    r = s.r
    for lx in (-.28, -.12, .16, .3):
        s.stroke([(x + lx * h, y - h * .34), (x + lx * h, y)], s.tint((58, 50, 50)), h * .07)
    wool = [(255, 252, 244), (240, 234, 222), (250, 244, 232), (226, 218, 206)]
    for _ in range(int(120 + h * .9)):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        wx, wy = x + math.cos(a) * d * h * .42, y - h * .55 + math.sin(a) * d * h * .27
        rr = h * r.uniform(.06, .1)
        s.blob(wx, wy, rr, rr, s.tint(r.choice(wool)))
    hx, hy = x + facing * h * .44, y - h * .74
    for e in (-1, 1):
        s.blob(hx + e * h * .16, hy - h * .02, h * .1, h * .05, s.tint((70, 60, 58)))
    s.blob(hx, hy, h * .15, h * .19, s.tint((84, 72, 68)))
    for _ in range(26):
        s.blob(hx + r.uniform(-.13, .13) * h, hy - h * r.uniform(.13, .24), h * .05, h * .05, s.tint(r.choice(wool)))
    for e in (-1, 1):
        s.blob(hx + e * h * .07, hy - h * .02, h * .023, h * .026, (16, 14, 16))
    s.blob(hx, hy + h * .1, h * .05, h * .03, s.tint((206, 150, 150)))


def rabbit(s, x, y, h, col=(176, 148, 124)):
    r = s.r
    c = s.tint(col)
    dk = s.tint(col, .78)
    s.blob(x, y - h * .34, h * .36, h * .34, c)
    s.blob(x - h * .34, y - h * .22, h * .13, h * .13, s.tint((252, 248, 240)))
    hx, hy = x + h * .26, y - h * .74
    for e in (-.1, .1):
        s.poly([(hx + e * h - h * .05, hy - h * .1), (hx + e * h * 1.6 - h * .03, hy - h * .62), (hx + e * h * 1.6 + h * .06, hy - h * .6), (hx + e * h + h * .06, hy - h * .1)], c)
        s.poly([(hx + e * h - h * .01, hy - h * .12), (hx + e * h * 1.6, hy - h * .54), (hx + e * h * 1.6 + h * .03, hy - h * .54), (hx + e * h + h * .03, hy - h * .12)], s.tint((236, 186, 180)))
    s.blob(hx, hy, h * .21, h * .19, c)
    s.blob(x + h * .08, y - h * .1, h * .16, h * .1, dk)
    s.blob(hx + h * .08, hy - h * .03, h * .035, h * .04, (20, 16, 18))
    s.blob(hx + h * .2, hy + h * .05, h * .03, h * .02, s.tint((206, 130, 130)))
    for _ in range(int(h * 1.2)):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        s.blob(x + math.cos(a) * d * h * .33, y - h * .34 + math.sin(a) * d * h * .3, 3, 2, s.tint(col, r.uniform(.8, 1.15)))


def nest(s, x, y, rad):
    r = s.r
    for _ in range(420):
        a = r.uniform(0, 6.28)
        d = r.uniform(.75, 1.1)
        fx, fy = x + math.cos(a) * rad * d, y + math.sin(a) * rad * d * .45
        s.d.line([(fx, fy), (fx + r.uniform(-30, 30), fy + r.uniform(-9, 9))], fill=s.tint((130, 100, 66), r.uniform(.7, 1.2)), width=3)
    for i in range(3):
        cx = x + (i - 1) * rad * .55
        s.blob(cx, y - rad * .24, rad * .3, rad * .3, s.tint((250, 216, 90)))
        s.blob(cx - rad * .08, y - rad * .3, rad * .035, rad * .035, (20, 20, 20))
        s.poly([(cx, y - rad * .4), (cx - rad * .08, y - rad * .24), (cx + rad * .08, y - rad * .24)], (236, 130, 60))
    for _ in range(320):
        a = r.uniform(0, 3.14)
        d = r.uniform(.8, 1.15)
        fx, fy = x + math.cos(a) * rad * d, y + math.sin(a) * rad * d * .52
        s.d.line([(fx, fy), (fx + r.uniform(-30, 30), fy + r.uniform(-8, 8))], fill=s.tint((150, 118, 76), r.uniform(.7, 1.2)), width=3)


# ---------- biblical and festive props ----------
def cross(s, x, y, h, sil=True, thick=.06):
    col = (40, 32, 38) if sil else s.tint((112, 82, 58))
    t = h * thick
    s.d.rectangle([x - t / 2, y - h, x + t / 2, y], fill=col)
    s.d.rectangle([x - h * .3, y - h * .74, x + h * .3, y - h * .74 + t], fill=col)
    if not sil:
        for _ in range(int(h * .8)):
            gy = s.r.uniform(y - h, y)
            s.d.line([(x - t / 2 + s.r.uniform(0, t), gy), (x - t / 2 + s.r.uniform(0, t), gy + s.r.uniform(8, 26))], fill=s.tint((76, 54, 40)), width=2)


def tomb(s, x, y, h, open_side=1):
    r = s.r
    for _ in range(int(1400)):
        a, d = r.uniform(3.14, 6.28), r.random() ** .4
        fx, fy = x + math.cos(a) * d * h * 1.25, y + math.sin(a) * d * h * 1.05
        c = s.tint(r.choice([(176, 160, 138), (156, 142, 122), (198, 180, 154), (138, 124, 108)]), .82 + (y - fy) / h * .28)
        rr = r.uniform(16, 42)
        s.blob(fx, fy, rr, rr * .7, c)
    s.d.pieslice([x - h * .3, y - h * .78, x + h * .3, y - h * .1], 180, 360, fill=s.tint((130, 118, 104)))
    s.d.rectangle([x - h * .3, y - h * .44, x + h * .3, y], fill=s.tint((130, 118, 104)))
    s.d.pieslice([x - h * .24, y - h * .72, x + h * .24, y - h * .16], 180, 360, fill=(26, 20, 24))
    s.d.rectangle([x - h * .24, y - h * .44, x + h * .24, y], fill=(26, 20, 24))
    s.glow(x, y - h * .25, h * .3, (255, 240, 200), .55)
    sx = x + open_side * h * .74
    s.blob(sx + 8, y - h * .24 + 12, h * .29, h * .29, s.tint((70, 64, 58)))
    s.blob(sx, y - h * .26, h * .28, h * .28, s.tint((184, 168, 146)))
    s.blob(sx, y - h * .26, h * .2, h * .2, s.tint((166, 150, 130)))
    for _ in range(320):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        s.blob(sx + math.cos(a) * d * h * .26, y - h * .26 + math.sin(a) * d * h * .26, 5, 3, s.tint((196, 178, 154), r.uniform(.8, 1.12)))


def oil_lamp(s, x, y, rad):
    s.glow(x, y - rad * 1.6, rad * 4.2, (255, 190, 100), .5)
    s.blob(x, y, rad * 1.4, rad * .6, s.tint((168, 112, 72)))
    s.poly([(x + rad, y - rad * .2), (x + rad * 2, y - rad * .5), (x + rad * 1.1, y + rad * .3)], s.tint((148, 98, 62)))
    s.poly([(x + rad * 1.7, y - rad * .5), (x + rad * 1.88, y - rad * 1.7), (x + rad * 2.1, y - rad * .5)], (255, 214, 120))
    s.blob(x + rad * 1.88, y - rad * .75, rad * .13, rad * .2, (255, 250, 220))


def bread(s, x, y, rad):
    s.blob(x, y, rad, rad * .55, s.tint((186, 128, 66)))
    s.blob(x - rad * .08, y - rad * .1, rad * .8, rad * .4, s.tint((222, 168, 96)))
    for i in range(3):
        fx = x + (i - 1) * rad * .42
        s.stroke([(fx - rad * .14, y - rad * .22), (fx + rad * .14, y + rad * .16)], s.tint((150, 96, 52)), rad * .07)


def grapes(s, x, y, rad):
    r = s.r
    col = r.choice([(92, 56, 118), (120, 64, 126), (140, 170, 84)])
    for row in range(5):
        for i in range(5 - row):
            gx = x + (i - (4 - row) / 2) * rad * .52 + r.uniform(-2, 2)
            gy = y + row * rad * .42
            s.blob(gx, gy, rad * .27, rad * .27, s.tint(col, r.uniform(.8, 1.1)))
            s.blob(gx - rad * .08, gy - rad * .09, rad * .07, rad * .07, s.tint((240, 230, 250)))
    s.poly([(x, y - rad * .3), (x - rad * .85, y - rad * .5), (x - rad * .2, y - rad * .05)], s.tint((86, 136, 74)))


def jar(s, x, y, h, col=None):
    r = s.r
    col = col or r.choice([(176, 112, 76), (156, 96, 70), (192, 140, 96)])
    pts = []
    for i in range(30):
        t = i / 29
        pts.append((h * (.16 + .26 * math.sin(math.pi * min(1, t * 1.15)) ** .8), y - t * h))
    s.poly([(x - a, b) for a, b in pts] + [(x + a, b) for a, b in reversed(pts)], s.tint(col))
    s.poly([(x + a * .15, b) for a, b in pts] + [(x + a, b) for a, b in reversed(pts)], s.tint(col, .78))
    for j in range(5):
        by = y - h * (.28 + j * .09)
        s.stroke([(x - h * .32, by), (x + h * .32, by)], s.tint(col, .62), 2)
    s.blob(x, y - h, h * .2, h * .05, s.tint(col, .54))


def goblet(s, x, y, h):
    c = s.tint((206, 166, 92))
    s.poly([(x - h * .24, y - h), (x + h * .24, y - h), (x + h * .13, y - h * .56), (x - h * .13, y - h * .56)], c)
    s.d.rectangle([x - h * .03, y - h * .56, x + h * .03, y - h * .1], fill=s.tint((176, 136, 72)))
    s.blob(x, y - h * .06, h * .2, h * .06, s.tint((176, 136, 72)))
    s.blob(x, y - h, h * .24, h * .06, s.tint((110, 38, 56)))


def egg(s, x, y, h, rot=None):
    r = s.r
    rot = r.uniform(-30, 30) if rot is None else rot
    size = int(h * 1.5)
    if size < 8:
        return
    sp = Image.new("RGB", (size, size), (0, 0, 0))
    dr = ImageDraw.Draw(sp)
    pal = [(244, 166, 185), (147, 199, 234), (169, 214, 184), (241, 199, 107), (141, 120, 200), (246, 140, 100), (252, 244, 230), (232, 96, 120)]
    a, b = r.sample(pal, 2)
    c3 = r.choice(pal)
    dr.rectangle([0, 0, size, size], fill=tuple(s.tint(a)))
    kind = r.randrange(4)
    if kind == 0:
        for i in range(0, size, max(6, size // 7)):
            dr.rectangle([0, i, size, i + max(3, size // 16)], fill=tuple(s.tint(b)))
    elif kind == 1:
        for _ in range(24):
            px, py, q = r.uniform(0, size), r.uniform(0, size), size * .05
            dr.ellipse([px - q, py - q, px + q, py + q], fill=tuple(s.tint(b)))
    elif kind == 2:
        for row in range(0, size, max(8, size // 6)):
            pts = [(i, row + (size // 12) * (-1 if (i // max(1, size // 10)) % 2 else 1)) for i in range(0, size + size // 10, max(1, size // 10))]
            dr.line(pts, fill=tuple(s.tint(b)), width=max(3, size // 22))
    else:
        for i in range(0, size, max(8, size // 5)):
            dr.rectangle([0, i, size, i + size // 10], fill=tuple(s.tint(b)))
            for j in range(0, size, max(6, size // 7)):
                dr.ellipse([j, i + size // 8, j + size // 14, i + size // 8 + size // 14], fill=tuple(s.tint(c3)))
    m = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(m)
    cx, wd, ht = size / 2, h * .36, h * .5
    pts = []
    for i in range(60):
        t = i / 60 * 6.283
        k = 1 - .18 * math.sin(t)  # narrower towards the top
        pts.append((cx + math.cos(t) * wd * k, size / 2 + math.sin(t) * ht))
    md.polygon(pts, fill=255)
    arr = np.asarray(sp).astype(np.float32)
    yy, xx = np.mgrid[0:size, 0:size]
    sh = np.clip(1.16 - (((xx - size * .42) / (wd * 1.6)) ** 2 + ((yy - size * .36) / (ht * 1.6)) ** 2) * .5, .55, 1.2)[..., None]
    sp = Image.fromarray(np.clip(arr * sh, 0, 255).astype(np.uint8))
    sp = sp.rotate(rot, Image.BICUBIC)
    m = m.rotate(rot, Image.BICUBIC)
    s.d  # make sure the PIL layer is live
    s._im.paste(sp, (int(x - size / 2), int(y - size / 2)), m)


def basket(s, x, y, w):
    r = s.r
    h = w * .5
    s.stroke([(x - w * .46, y - h * .7)] + [(x + math.cos(t * 3.14) * -w * .46, y - h * .7 - math.sin(t * 3.14) * w * .56) for t in np.linspace(0, 1, 26)], s.tint((142, 104, 66)), w * .05)
    for i in range(int(9 + w * .03)):
        egg(s, x + r.uniform(-.34, .34) * w, y - h * r.uniform(.72, 1.0), w * r.uniform(.22, .28))
    s.poly([(x - w * .5, y - h * .7), (x + w * .5, y - h * .7), (x + w * .36, y), (x - w * .36, y)], s.tint((176, 134, 84)))
    bh = max(5, int(w * .05))
    for row, yy in enumerate(range(int(y - h * .7), int(y), bh)):
        t = (yy - (y - h * .7)) / (h * .7)
        half = w * (.5 - .14 * t)
        for k, xx in enumerate(range(int(x - half), int(x + half), bh * 2)):
            s.d.rectangle([xx, yy, xx + bh * 2 - 2, yy + bh - 1], fill=s.tint((176, 134, 84), 1.14 if (k + row) % 2 else .76))
    s.blob(x, y - h * .7, w * .5, w * .05, s.tint((128, 92, 58)))


def cake(s, x, y, w):
    r = s.r
    tiers = r.choice([2, 3])
    col = r.choice([(252, 234, 224), (240, 216, 240), (222, 240, 226), (255, 240, 200)])
    icing = r.choice([(244, 166, 185), (147, 199, 234), (241, 199, 107), (141, 120, 200)])
    s.blob(x, y, w * .62, w * .1, s.tint((246, 240, 230)))
    yy = y
    for i in range(tiers):
        tw = w * (1 - i * .27) / 2
        th = w * .24
        s.d.rectangle([x - tw, yy - th, x + tw, yy], fill=s.tint(col))
        s.d.rectangle([x + tw * .4, yy - th, x + tw, yy], fill=s.tint(col, .88))
        s.blob(x, yy, tw, tw * .17, s.tint(col, .94))
        s.blob(x, yy - th, tw, tw * .17, s.tint(icing))
        for k in range(int(tw / 13)):
            dx = x - tw + k * 26 + 8
            s.d.rounded_rectangle([dx, yy - th, dx + 15, yy - th + r.uniform(16, th * .55)], 6, fill=s.tint(icing))
        for k in range(int(tw / 15)):
            dx = x - tw + 14 + k * 30
            s.blob(dx, yy - w * .03, 7, 7, s.tint(r.choice([(232, 96, 120), (252, 244, 230), (169, 214, 184)])))
        yy -= th
    for i in range(5):
        daisy(s, x + (i - 2) * w * .08, yy - 8, w * .05, r.choice([(255, 250, 240), (250, 190, 210), (255, 226, 130)]))


def bouquet(s, x, y, w):
    r = s.r
    col = r.choice([(176, 200, 220), (240, 226, 200), (214, 180, 214)])
    s.poly([(x - w * .2, y), (x - w * .28, y - w * .7), (x + w * .28, y - w * .7), (x + w * .2, y)], s.tint(col))
    s.poly([(x + w * .05, y), (x + w * .08, y - w * .7), (x + w * .28, y - w * .7), (x + w * .2, y)], s.tint(col, .82))
    for _ in range(46):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        s.blob(x + math.cos(a) * d * w * .5, y - w * 1.05 + math.sin(a) * d * w * .38, w * .07, w * .05, s.tint(r.choice([(82, 136, 78), (110, 160, 90)])))
    for _ in range(int(16)):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        fx, fy = x + math.cos(a) * d * w * .48, y - w * 1.05 + math.sin(a) * d * w * .36
        k = r.randrange(3)
        if k == 0:
            lily(s, fx, fy, w * .12)
        elif k == 1:
            tulip(s, fx, fy, w * .075, r.choice([(232, 84, 96), (246, 150, 170), (250, 186, 74)]))
        else:
            daisy(s, fx, fy, w * .09, r.choice([(255, 250, 240), (250, 190, 210), (214, 190, 244)]))


def bunting(s, y, sag=120):
    r = s.r
    pal = [(244, 166, 185), (147, 199, 234), (169, 214, 184), (241, 199, 107), (190, 170, 230)]
    prev = None
    for i in range(0, W + 90, 90):
        t = i / W
        yy = y + 4 * sag * t * (1 - t)
        if prev:
            s.stroke([prev, (i, yy)], s.tint((236, 230, 220)), 3)
        s.poly([(i + 8, yy), (i + 72, yy + 5), (i + 40, yy + 78)], s.tint(pal[i // 90 % len(pal)]))
        prev = (i, yy)


def interior(s, warm=True, wall=(170, 136, 100), arch_window=True):
    """Stone room with depth; returns the table-top y."""
    r = s.r
    a = s.np()
    n = noise(s.nr, 300, 300, 5)
    b = noise(s.nr, 30, 30, 3)
    wc = np.array(s.tint(wall), np.float32)
    a[:] = wc * (.62 + .55 * n + .16 * b)[..., None]
    s.d
    for row, yy in enumerate(range(0, H, 74)):
        off = 62 * (row % 2)
        s.d.line([(0, yy), (W, yy)], fill=s.tint(wall, .55), width=3)
        for xx in range(off, W, 124):
            s.d.line([(xx, yy), (xx, yy + 74)], fill=s.tint(wall, .55), width=3)
    if arch_window:
        count = r.choice((1, 2, 3))
        for i in range(count):
            ax = W * (i + .5) / count
            aw = W * r.uniform(.11, .17) if count > 1 else W * .2
            top, bot = H * .14, H * .62
            s.d.pieslice([ax - aw, top, ax + aw, top + aw * 2], 180, 360, fill=s.p["hor"])
            s.d.rectangle([ax - aw, top + aw, ax + aw, bot], fill=s.p["mid"])
            # view through the arch: distant hills
            for k in range(3):
                hy = bot - (2 - k) * H * .05 - H * .03
                pts = [(ax - aw + t * 2 * aw, hy + math.sin(t * 9 + r.uniform(0, 3)) * 14) for t in np.linspace(0, 1, 18)]
                s.poly(pts + [(ax + aw, bot), (ax - aw, bot)], s.tint((96 + k * 18, 120 + k * 14, 96), 1.0))
            for w_ in range(5):
                s.d.pieslice([ax - aw - w_ * 5, top - w_ * 5, ax + aw + w_ * 5, top + aw * 2 + w_ * 5], 180, 360, outline=s.tint(wall, .5 + w_ * .08), width=4)
            s.d.rectangle([ax - aw - 22, top + aw, ax - aw, bot], fill=s.tint(wall, .7))
            s.d.rectangle([ax + aw, top + aw, ax + aw + 22, bot], fill=s.tint(wall, .7))
            s.d.rectangle([ax - aw - 34, bot, ax + aw + 34, bot + 22], fill=s.tint(wall, .86))
            s.rays(ax, top, n=5, spread=.8, length=1100, strength=.15)
    # floor
    fy = H * .68
    s.d.rectangle([0, fy, W, H], fill=s.tint((122, 92, 68)))
    for i in range(16):
        t = (i / 15) ** 2
        s.d.line([(0, fy + t * (H - fy)), (W, fy + t * (H - fy))], fill=s.tint((90, 68, 52)), width=3)
    for i in range(-14, 15):
        s.d.line([(W / 2 + i * 40, fy), (W / 2 + i * 240, H)], fill=s.tint((90, 68, 52)), width=3)
    return fy


def table_top(s, y, nx=.9, fx=.72, depth=.17, cloth=(240, 232, 214)):
    """Perspective table. Returns (near y, far y, half width near)."""
    r = s.r
    top, bot = y * H, (y + depth) * H
    wfar, wnear = W * fx / 2, W * nx / 2
    s.poly([(W / 2 - wfar, top), (W / 2 + wfar, top), (W / 2 + wnear, bot), (W / 2 - wnear, bot)], s.tint(cloth))
    for _ in range(2200):
        t = r.random()
        half = wfar + (wnear - wfar) * t
        px, py = W / 2 + r.uniform(-half, half), top + (bot - top) * t
        s.d.line([(px, py), (px + r.uniform(8, 40), py)], fill=s.tint(cloth, r.uniform(.9, 1.04)), width=2)
    s.d.rectangle([W / 2 - wnear, bot, W / 2 + wnear, bot + H * .05], fill=s.tint(cloth, .78))
    for xx in range(int(W / 2 - wnear), int(W / 2 + wnear), 26):
        s.d.line([(xx, bot), (xx, bot + H * .05)], fill=s.tint(cloth, .66), width=3)
    for lg in (-.84, .84):
        s.d.rectangle([W / 2 + wnear * lg - 26, bot + H * .05, W / 2 + wnear * lg + 26, H], fill=s.tint((92, 66, 46)))
    return top, bot, wfar, wnear
