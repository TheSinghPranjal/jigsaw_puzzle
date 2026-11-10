"""The 500-level catalog: collections, subjects, scene recipes, titles, prompts."""
import math

import painter as P
from painter import H, W

COLLECTIONS = [
    ("palm_sunday", "collection_01_palm_sunday", "Palm Sunday and Jerusalem", "Palm branches, stone streets and the ancient city in festive welcome."),
    ("last_supper", "collection_02_last_supper", "The Last Supper and Biblical Moments", "Lamplit rooms, shared bread and quiet gatherings of the biblical era."),
    ("gethsemane", "collection_03_gethsemane", "Gethsemane Garden and Prayer", "Ancient olive groves and peaceful paths under moon and dawn."),
    ("passion", "collection_04_passion", "The Passion and the Cross", "Reverent, landscape-led scenes of the cross against wide skies."),
    ("resurrection", "collection_05_resurrection", "Resurrection and the Empty Tomb", "Morning light, a stone rolled away and gardens of renewal."),
    ("angels", "collection_06_angels", "Angels, Holy Spirit and Revelation", "Heavenly messengers, white doves and luminous horizons."),
    ("spring", "collection_07_spring", "Easter Morning and Spring", "Lilies, tulips and blossoming countryside on Easter morning."),
    ("nature", "collection_08_nature", "Easter Flowers, Lambs and Nature", "Lambs in meadows, spring rabbits and gardens in full bloom."),
    ("easter", "collection_09_easter", "Colorful Easter and Family Celebrations", "Painted eggs, baskets, festive tables and cheerful villages."),
    ("landscapes", "collection_10_landscapes", "Peaceful Landscapes and Scenic Wonders", "Mountains, lakes and coastlines rich with detail for big puzzles."),
]


# ------- shared terrain helpers -------
def holy_land(s, hy=.56, clouds=.5, far=True):
    s.sky(hy + .08, clouds)
    if far:
        s.land(hy - .08, .05, (150, 150, 170), (176, 164, 160), 2.2)
        s.haze(hy - .12, hy + .06, .35)
    s.land(hy, .035, (178, 160, 124), (150, 138, 96), 3)


def field(s, hy=.6, cols=((122, 164, 86), (84, 132, 70))):
    s.land(hy, .03, cols[0], cols[1], 2.4)


def far_hills(s, hy=.55):
    s.land(hy - .09, .06, (136, 156, 186), (160, 176, 186), 1.8)
    s.haze(hy - .14, hy + .03, .32)
    s.land(hy - .03, .04, (110, 150, 118), (126, 164, 116), 2.8)


# ------- collection 1 -------
def c1_procession(s, v):
    holy_land(s, .5)
    P.city(s, H * .52, W * s.r.uniform(.3, .7), scale=.62, count=26)
    P.stone_path(s, W * .52, 30, W * .5, W * .36, H * .55, H)
    P.crowd(s, .57, .78, 22)
    P.donkey(s, W * s.r.uniform(.4, .6), H * .86, 210, rider=((236, 226, 210), True, (160, 60, 70)))
    P.crowd(s, .86, 1.04, 7)
    for _ in range(36):
        P.palm_frond(s, W * s.r.uniform(.2, .8), H * s.r.uniform(.68, .98), 130, ang=s.r.uniform(-.4, .4))


def c1_fronds(s, v):
    holy_land(s, .62, .6)
    P.city(s, H * .62, scale=.42, count=20)
    field(s, .68, ((142, 150, 90), (92, 128, 70)))
    P.grass(s, .7, 1, 5000)
    for _ in range(42):
        P.palm_frond(s, s.r.uniform(-100, W), H * s.r.uniform(.72, 1.1), s.r.uniform(420, 860), ang=-math.pi / 2 + s.r.uniform(-.8, .8))


def c1_street(s, v):
    s.sky(.42, .35)
    h = H * .78
    for side in (-1, 1):
        for i in range(7):
            t = i / 6
            x = W / 2 + side * (150 + (1 - t) ** 1.6 * 780)
            wd, ht = 230 + (1 - t) * 360, 300 + (1 - t) * 780
            P.building(s, x - wd / 2, h + (1 - t) * 260, wd, ht, dome=i == 6)
    P.stone_path(s, W / 2, 34, W / 2, W * .46, H * .62, H)
    P.crowd(s, .68, .92, 12, palms=s.r.random() < .5)
    for _ in range(5):
        P.jar(s, s.r.uniform(.05, .95) * W, H * s.r.uniform(.88, .99), 130)


def c1_welcome(s, v):
    holy_land(s, .48, .45)
    P.city(s, H * .5, scale=.55, count=24)
    P.stone_path(s, W / 2, 26, W * .46, W * .4, H * .53, H)
    P.crowd(s, .55, 1.02, 34)
    P.figure(s, W * .5, H * .74, 300, robe=(240, 234, 220), halo=True, sash=(160, 60, 70))


def c1_donkeys(s, v):
    holy_land(s, .55, .4)
    for _ in range(4):
        P.olive(s, s.r.uniform(0, W), H * s.r.uniform(.58, .64), 300)
    field(s, .66, ((186, 168, 118), (150, 130, 88)))
    P.grass(s, .7, 1, 3500, [(170, 160, 92), (134, 142, 80), (196, 176, 110)])
    P.donkey(s, W * .32, H * .86, 300)
    P.donkey(s, W * .66, H * .78, 210)
    P.figure(s, W * .78, H * .94, 420, robe=(150, 110, 90))
    for i in range(4):
        P.jar(s, W * (.08 + i * .05), H * (.92 + i * .015), 150)


def c1_skyline(s, v):
    s.sky(.5, .55)
    s.land(.5, .05, (150, 148, 170), (170, 160, 150), 2)
    s.haze(.4, .6, .25)
    P.city(s, H * .66, scale=1.05, count=64, spread=W * .9)
    field(s, .68, ((150, 150, 100), (100, 124, 76)))
    P.grass(s, .72, 1, 6000)
    for i in range(8):
        P.cypress(s, s.r.uniform(0, W), H * s.r.uniform(.72, .78), s.r.uniform(150, 280))


def c1_olives(s, v):
    holy_land(s, .54, .5)
    P.city(s, H * .55, scale=.36, count=18, wall=False)
    field(s, .6, ((156, 150, 96), (118, 124, 76)))
    for i in sorted(s.r.uniform(.62, 1.0) for _ in range(9)):
        P.olive(s, s.r.uniform(.02, .98) * W, H * i, 240 + (i - .6) * 1100)


def c1_pathway(s, v):
    holy_land(s, .5, .4)
    P.city(s, H * .5, s.r.uniform(.3, .7) * W, scale=.5, count=22)
    field(s, .54, ((168, 160, 104), (130, 136, 84)))
    P.stone_path(s, W * s.r.uniform(.4, .6), 16, W * s.r.uniform(.3, .7), W * .3, H * .56, H)
    P.grass(s, .6, 1, 5000)
    for side in (.07, .93):
        P.palm(s, W * side, H * .98, 960)
    for _ in range(4):
        P.cypress(s, s.r.uniform(.15, .85) * W, H * .62, 170)


def c1_desert(s, v):
    s.sky(.5, .32)
    s.land(.46, .07, (170, 146, 140), (190, 160, 140), 1.5)
    s.haze(.36, .56, .3)
    s.land(.56, .05, (216, 180, 124), (196, 156, 104), 2)
    s.land(.68, .05, (230, 196, 136), (204, 164, 110), 1.4)
    for _ in range(9):
        P.palm(s, s.r.uniform(0, W), H * s.r.uniform(.68, .78), s.r.uniform(260, 460))
    P.city(s, H * .62, W * s.r.uniform(.2, .8), W * .3, 16, .34, wall=False)
    s.land(.84, .04, (214, 176, 118), (176, 136, 90), 2.4, tex=.22)
    for i in range(3):
        P.donkey(s, W * (.3 + i * .15), H * (.86 + i * .006), 118)
        P.figure(s, W * (.36 + i * .15), H * .86, 150, robe=(150, 110, 120))


def c1_village(s, v):
    holy_land(s, .46, .4)
    field(s, .52, ((176, 164, 112), (130, 140, 84)))
    pts = sorted((s.r.uniform(0, W), s.r.uniform(.56, .86) * H) for _ in range(20))
    for x, y in sorted(pts, key=lambda q: q[1]):
        t = (y / H - .56) / .3
        P.building(s, x, y, 130 + t * 240, 96 + t * 200, dome=s.r.random() < .12)
    P.grass(s, .84, 1, 3000)
    for _ in range(4):
        P.palm(s, s.r.uniform(0, W), H * s.r.uniform(.86, 1.0), s.r.uniform(420, 720))
    P.crowd(s, .88, 1.0, 5, palms=False)


# ------- collection 2 -------
def _meal(s, y=.56, people=False, spread=True):
    top, bot, wf, wn = P.table_top(s, y, cloth=s.r.choice([(236, 226, 206), (214, 196, 170), (220, 210, 196)]))
    if people:
        P.crowd(s, y - .01, y + .002, 9, palms=False)
        top, bot, wf, wn = P.table_top(s, y + .008, cloth=(236, 226, 206))
    if not spread:
        return top, bot, wf, wn
    r = s.r
    for _ in range(30):
        t = r.random()
        half = (wf + (wn - wf) * t) * .92
        x, yy = W / 2 + r.uniform(-half, half), top + (bot - top) * (t * .9 + .05)
        k = r.randrange(6)
        sz = 44 + 76 * t
        if k == 0:
            P.bread(s, x, yy, sz)
        elif k == 1:
            P.grapes(s, x, yy - sz * .6, sz * .95)
        elif k == 2:
            P.goblet(s, x, yy, sz * 2)
        elif k == 3:
            P.oil_lamp(s, x, yy, sz * .55)
        elif k == 4:
            P.jar(s, x, yy, sz * 2.8)
        else:
            s.blob(x, yy, sz * 1.1, sz * .34, s.tint((168, 118, 80)))
            P.bread(s, x, yy - sz * .2, sz * .66)
    return top, bot, wf, wn


def c2_room(s, v):
    P.interior(s, wall=(166, 130, 96))
    _meal(s, .58, people=True)


def c2_table(s, v):
    P.interior(s, wall=(156, 124, 96), arch_window=s.r.random() < .5)
    _meal(s, .52)
    for x in (.06, .94):
        P.jar(s, W * x, H * .98, 380)


def c2_bread(s, v):
    P.interior(s, wall=(146, 116, 92), arch_window=False)
    t, b, wf, wn = _meal(s, .44, spread=False)
    r = s.r
    for _ in range(11):
        P.bread(s, W * r.uniform(.14, .86), H * r.uniform(.5, .62), r.uniform(100, 170))
    for _ in range(4):
        P.grapes(s, W * r.uniform(.14, .86), H * r.uniform(.44, .5), 130)
    P.goblet(s, W * r.uniform(.3, .7), H * .56, 300)


def c2_lamps(s, v):
    P.interior(s, wall=(120, 94, 80), arch_window=False)
    r = s.r
    rows = 3
    for row in range(rows):
        count = 6 - row
        y = H * (.34 + row * .22)
        for i in range(count):
            x = W * (i + .5) / count + r.uniform(-16, 16)
            nw, nh = 92 + row * 24, 150 + row * 30
            s.d.pieslice([x - nw, y - nh * 1.5, x + nw, y - nh * .1], 180, 360, fill=s.tint((60, 42, 40)))
            s.d.rectangle([x - nw, y - nh * .8, x + nw, y + 30], fill=s.tint((60, 42, 40)))
            s.d.rectangle([x - nw - 14, y + 30, x + nw + 14, y + 52], fill=s.tint((176, 150, 120)))
            P.oil_lamp(s, x - 26, y + 6, 44 + row * 14)
    for i in range(7):
        P.jar(s, W * r.random(), H * r.uniform(.9, 1.02), r.uniform(200, 330))


def c2_vessels(s, v):
    P.interior(s, wall=(176, 140, 104))
    r = s.r
    s.d.rectangle([0, H * .48, W, H * .52], fill=s.tint((110, 78, 56)))
    for x in sorted(r.uniform(.04, .96) for _ in range(12)):
        P.jar(s, W * x, H * .48, r.uniform(130, 240))
    for x in sorted(r.uniform(.03, .97) for _ in range(8)):
        P.jar(s, W * x, H * r.uniform(.82, .98), r.uniform(280, 480))


def c2_upper(s, v):
    P.interior(s, wall=(186, 156, 118))
    r = s.r
    for x in (.14, .86):
        s.d.rectangle([W * x - 44, H * .08, W * x + 44, H * .7], fill=s.tint((206, 182, 146)))
        for yy in range(int(H * .08), int(H * .7), 40):
            s.d.line([(W * x - 44, yy), (W * x + 44, yy)], fill=s.tint((160, 138, 106)), width=2)
    _meal(s, .63)
    for i in range(4):
        P.oil_lamp(s, W * (.3 + i * .14), H * .24 + r.uniform(-20, 20), 40)


def c2_courtyard(s, v):
    s.sky(.5, .4)
    h = H * .74
    for i in range(6):
        x = W * (i - .5) / 4
        P.building(s, x, h, 380, 620, arch=True)
    P.stone_path(s, W / 2, W * .36, W / 2, W * .6, H * .72, H)
    for x in (.14, .86):
        P.palm(s, W * x, H * .92, 780)
    for i in range(7):
        P.jar(s, W * s.r.random(), H * s.r.uniform(.84, .98), s.r.uniform(150, 280))
    P.bouquet(s, W * .5, H * .96, 170)


def c2_marketplace(s, v):
    s.sky(.46, .35)
    r = s.r
    for i in range(9):
        P.building(s, W * i / 8 - 160, H * .66, 300, r.uniform(320, 620))
    P.stone_path(s, W / 2, W * .3, W / 2, W * .6, H * .64, H)
    for i in range(4):
        x, y = W * (.14 + i * .24), H * (.8 + (i % 2) * .08)
        col = r.choice([(200, 90, 90), (90, 130, 180), (214, 170, 90), (120, 150, 110)])
        s.poly([(x - 200, y - 280), (x + 200, y - 280), (x + 240, y - 200), (x - 240, y - 200)], s.tint(col))
        for px in (-210, 210):
            s.d.rectangle([x + px - 8, y - 210, x + px + 8, y], fill=s.tint((110, 80, 60)))
        s.d.rectangle([x - 220, y - 90, x + 220, y], fill=s.tint((150, 110, 76)))
        for _ in range(9):
            k = r.randrange(3)
            fx, fy = x + r.uniform(-190, 190), y - 100
            (P.bread if k == 0 else P.grapes)(s, fx, fy - (0 if k == 0 else 26), 46)
            if k == 2:
                P.jar(s, fx, fy + 6, 90)
    P.crowd(s, .92, 1.03, 6, palms=False)


def c2_hearth(s, v):
    P.interior(s, wall=(136, 106, 88), arch_window=False)
    r = s.r
    fx, fy = W * r.uniform(.3, .7), H * .72
    s.d.pieslice([fx - 280, fy - 500, fx + 280, fy + 60], 180, 360, fill=(26, 18, 20))
    s.d.rectangle([fx - 280, fy - 220, fx + 280, fy], fill=(26, 18, 20))
    for i in range(70):
        ang = r.uniform(0, 6.28)
        s.blob(fx + r.uniform(-200, 200), fy - r.uniform(0, 160), r.uniform(8, 34), r.uniform(16, 60), r.choice([(255, 140, 50), (255, 190, 80), (250, 100, 40)]))
    s.glow(fx, fy - 90, 330, (255, 160, 70), .55)
    for i in range(7):
        P.jar(s, W * r.random(), H * r.uniform(.84, .98), r.uniform(170, 320))
    for i in range(5):
        P.bread(s, W * r.random(), H * r.uniform(.92, 1), 90)


def c2_scroll(s, v):
    P.interior(s, wall=(170, 138, 104))
    t, b, wf, wn = P.table_top(s, .56, cloth=(150, 110, 78))
    r = s.r
    for _ in range(6):
        x, y = W * r.uniform(.2, .8), H * r.uniform(.6, .7)
        ln = r.uniform(240, 400)
        s.d.rounded_rectangle([x - ln / 2, y - 26, x + ln / 2, y + 26], 22, fill=s.tint((236, 220, 180)))
        for k in range(3):
            s.stroke([(x - ln / 2, y - 12 + k * 12), (x + ln / 2, y - 12 + k * 12)], s.tint((196, 176, 136)), 3)
    for x in (.2, .5, .8):
        P.oil_lamp(s, W * x, H * .6, 58)
    P.goblet(s, W * .62, H * .66, 180)
    P.jar(s, W * .34, H * .6, 240)


# ------- collection 3 -------
def _grove(s, hy, n, ymin=.62, big=1200):
    for i in sorted(s.r.uniform(ymin, 1.02) for _ in range(n)):
        P.olive(s, s.r.uniform(-.02, 1.02) * W, H * i, 220 + (i - ymin) * big)


def c3_grove(s, v):
    s.sky(.5, .5)
    far_hills(s, .55)
    field(s, .6, ((116, 134, 90), (76, 104, 72)))
    P.grass(s, .62, 1, 7000, [(112, 140, 90), (92, 126, 80), (140, 160, 96)])
    _grove(s, .6, 13)


def c3_path(s, v):
    s.sky(.46, .5)
    far_hills(s, .5)
    field(s, .52, ((134, 146, 96), (90, 112, 76)))
    P.grass(s, .54, 1, 7000)
    P.stone_path(s, W * s.r.uniform(.42, .58), 14, W * s.r.uniform(.35, .65), W * .24, H * .54, H)
    for side in (-1, 1):
        for i in range(5):
            t = i / 4
            P.olive(s, W / 2 + side * (120 + t * t * 900), H * (.58 + t * .42), 220 + t * 720)


def c3_moon(s, v):
    s.sky(.54, .35)
    s.land(.5, .08, (70, 80, 130), (90, 100, 140), 1.6)
    s.haze(.42, .6, .22)
    s.glow(s.sun[0], s.sun[1], 180, (220, 226, 255), .4)
    field(s, .64, ((70, 94, 86), (44, 64, 72)))
    P.grass(s, .66, 1, 5000, [(70, 96, 92), (52, 80, 84), (86, 112, 100)])
    _grove(s, .64, 9, .66)


def c3_terrace(s, v):
    s.sky(.42, .5)
    far_hills(s, .46)
    r = s.r
    for i, y in enumerate((.5, .6, .71, .84)):
        field(s, y, ((132 + i * 6, 150, 92), (98, 118, 74)))
        s.d.rectangle([0, H * (y + .06), W, H * (y + .085)], fill=s.tint((180, 166, 136)))
        for xx in range(0, W, 46):
            s.blob(xx + r.uniform(-8, 8), H * (y + .072), 28, 16, s.tint(P.STONES[xx // 46 % 4], r.uniform(.76, 1.04)))
        for _ in range(6 - i):
            P.olive(s, W * r.random(), H * (y + .055), 200 + i * 120)


def c3_mount(s, v):
    s.sky(.5, .55)
    s.land(.5, .16, (120, 124, 150), (150, 150, 150), 1.2, tex=.2)
    s.haze(.44, .62, .3)
    P.city(s, H * .6, W * s.r.uniform(.2, .8), W * .3, 16, .3, wall=True)
    field(s, .64, ((134, 150, 92), (88, 110, 74)))
    P.grass(s, .66, 1, 6000)
    _grove(s, .64, 8, .68, 900)


def c3_sunrise(s, v):
    s.sun = (W * s.r.uniform(.3, .7), H * .46)
    s.sky(.56, .42)
    s.rays(s.sun[0], s.sun[1], 12, 6.2, 0, 1500, strength=.16)
    s.land(.53, .05, (120, 120, 150), (146, 136, 150), 2)
    s.haze(.46, .62, .34)
    field(s, .64, ((126, 128, 86), (72, 92, 66)))
    P.grass(s, .66, 1, 5000)
    for i in sorted(s.r.uniform(.68, 1.0) for _ in range(6)):
        P.olive(s, s.r.choice((s.r.uniform(.0, .32), s.r.uniform(.68, 1.0))) * W, H * i, 360 + (i - .68) * 1100)


def c3_prayer(s, v):
    s.sky(.5, .4)
    far_hills(s, .54)
    field(s, .62, ((110, 130, 88), (70, 98, 70)))
    P.grass(s, .64, 1, 6000, [(112, 140, 90), (92, 126, 80), (140, 160, 96)])
    x = W * s.r.uniform(.36, .62)
    y = H * .86
    for _ in range(620):
        a, d = s.r.uniform(3.14, 6.28), s.r.random() ** .5
        s.blob(x + math.cos(a) * d * 370, y + math.sin(a) * d * 180 + 40, 40, 22, s.tint(s.r.choice(P.STONES), s.r.uniform(.66, .92)))
    s.rays(x, -80, 7, .5, math.pi / 2, 1500, strength=.2)
    P.figure(s, x, y - 90, 320, robe=(236, 230, 216), halo=True, sash=(150, 70, 80))
    for i in sorted(s.r.uniform(.62, .86) for _ in range(7)):
        P.olive(s, s.r.choice((s.r.uniform(-.02, .24), s.r.uniform(.76, 1.02))) * W, H * i, 340 + (i - .62) * 900)


def c3_gnarled(s, v):
    s.sky(.5, .4)
    far_hills(s, .5)
    field(s, .56, ((132, 144, 92), (84, 108, 74)))
    P.grass(s, .58, 1, 7000)
    r = s.r
    for x, h in ((.28, 1120), (.72, 1000)):
        P.olive(s, W * (x + r.uniform(-.08, .08)), H * r.uniform(.94, 1.02), h)
    P.poppy_dabs(s, .7, 1, 520, [(232, 84, 96), (246, 214, 120), (250, 250, 240)])


def c3_wall(s, v):
    s.sky(.46, .45)
    far_hills(s, .5)
    field(s, .55, ((140, 150, 96), (92, 116, 76)))
    r = s.r
    y = H * .74
    for row in range(5):
        for x in range(-30, W + 60, 112):
            s.blob(x + r.uniform(-16, 16) + row % 2 * 56, y - row * 50, 62, 30, s.tint(r.choice(P.STONES), r.uniform(.76, 1.06)))
    s.d.pieslice([W * .46, y - 460, W * .6, y - 60], 180, 360, fill=s.tint((90, 74, 58)))
    s.d.rectangle([W * .46, y - 260, W * .6, y + 40], fill=s.tint((90, 74, 58)))
    P.grass(s, .76, 1, 7000)
    P.flower_bed(s, .8, 1.02, 60, ["daisy", "lily"], 10, 36)
    _grove(s, .6, 3, .58, 300)


def c3_stars(s, v):
    s.sky(.72, .12, sun=False)
    r = s.r
    s.d
    for k in range(4200):
        t = r.random()
        cy = H * .18 + (t - .5) * H * .08
        x = t * W
        y = cy + r.gauss(0, 66)
        s.blob(x, y, r.uniform(1, 3), r.uniform(1, 3), (220, 226, 250))
    s.land(.68, .09, (36, 46, 90), (40, 56, 88), 1.6)
    field(s, .76, ((40, 60, 76), (26, 42, 58)))
    P.grass(s, .78, 1, 4000, [(50, 76, 88), (38, 62, 76), (66, 92, 98)])
    _grove(s, .74, 8, .78, 1000)


# ------- collection 4 -------
def c4_hill(s, v):
    s.sun = (W * s.r.uniform(.3, .7), H * .36)
    s.sky(.66, .5)
    s.rays(s.sun[0], s.sun[1], 14, 6.28, 0, 1500, strength=.15)
    s.land(.6, .05, (134, 122, 150), (160, 140, 150), 2)
    s.haze(.5, .68, .3)
    ln = s.land(.72, .06, (118, 118, 90), (72, 84, 66), 1.4)
    i = W // 2 + s.r.randrange(-180, 180)
    P.cross(s, i, ln[i] + 16, 620, sil=True)
    P.grass(s, .74, 1, 5400, [(122, 150, 88), (96, 128, 78), (150, 170, 96)])


def c4_three(s, v):
    s.sun = (W * .5, H * .5)
    s.sky(.64, .36)
    s.rays(s.sun[0], s.sun[1], 18, 6.28, 0, 1500, strength=.22)
    ln = s.land(.68, .08, (70, 60, 80), (40, 40, 56), 1.1)
    for off, h in ((-300, 420), (0, 560), (300, 420)):
        x = W // 2 + off
        P.cross(s, x, ln[x] + 12, h, sil=True)
    P.grass(s, .76, 1, 4000, [(58, 66, 76), (46, 54, 66), (82, 86, 92)])
    P.poppy_dabs(s, .8, 1, 600, [(236, 196, 120), (214, 140, 120), (250, 226, 180)])


def c4_jerusalem(s, v):
    hy = s.r.uniform(.5, .66)
    s.sky(hy, .55)
    s.land(hy, .05, (136, 134, 160), (156, 150, 156), 2)
    P.city(s, H * (hy + .1), W * s.r.uniform(.3, .7), W * .7, 46, s.r.uniform(.45, .8))
    ln = s.land(hy + .18, .05, (136, 136, 96), (84, 100, 72), 1.6)
    x = int(W * s.r.uniform(.12, .88))
    P.cross(s, x, ln[x] + 12, s.r.uniform(300, 520), sil=False)
    P.grass(s, .7, 1, 6000)
    for _ in range(4):
        P.olive(s, W * s.r.random(), H * s.r.uniform(.8, 1), 360)


def c4_sky(s, v):
    s.sky(.8, .95)
    s.rays(W * s.r.uniform(.3, .7), H * .2, 16, 1.5, math.pi / 2, 1500, strength=.3)
    s.land(.76, .05, (110, 110, 128), (86, 96, 100), 2)
    ln = s.land(.84, .03, (100, 118, 84), (60, 84, 60), 2.4)
    x = int(W * s.r.uniform(.25, .75))
    P.cross(s, x, ln[x] + 8, 380, sil=True)
    P.grass(s, .85, 1, 3000)


def c4_mountains(s, v):
    s.sky(.5, .5)
    s.land(.44, .16, (116, 120, 156), (146, 140, 150), 1.1, rough=.55, tex=.22)
    s.haze(.42, .58, .3)
    s.land(.56, .08, (96, 106, 110), (110, 120, 100), 1.8, tex=.2)
    ln = s.land(.68, .05, (132, 138, 92), (86, 104, 72), 1.4)
    x = int(W * s.r.uniform(.3, .7))
    P.cross(s, x, ln[x] + 10, 430, sil=False)
    P.grass(s, .7, 1, 6000)
    for _ in range(5):
        P.cypress(s, W * s.r.random(), H * s.r.uniform(.72, .8), 230)


def c4_branches(s, v):
    s.sky(.7, .55)
    ln = s.land(.7, .06, (120, 118, 100), (76, 90, 66), 1.2)
    x = int(W * s.r.uniform(.42, .78))
    P.cross(s, x, ln[x] + 10, 400, sil=True)
    P.grass(s, .72, 1, 4000)
    r = s.r
    for _ in range(9):
        y0, x0 = r.uniform(-.05, .3) * H, r.choice((-60, W + 60))
        pts = [(x0, y0)]
        dirx = 1 if x0 < 0 else -1
        for k in range(8):
            pts.append((pts[-1][0] + dirx * r.uniform(60, 130), pts[-1][1] + r.uniform(-20, 60)))
        s.stroke(pts, s.tint((84, 66, 56)), 16)
        for k in range(1, 8):
            bx, by = pts[k]
            for _ in range(22):
                a, ln2 = r.uniform(0, 6.28), r.uniform(40, 120)
                ex, ey = bx + math.cos(a) * ln2, by + math.sin(a) * ln2
                s.poly([(bx, by), ((bx + ex) / 2 - 10, (by + ey) / 2 + 8), (ex, ey), ((bx + ex) / 2 + 10, (by + ey) / 2 - 8)], s.tint(r.choice([(112, 136, 96), (134, 156, 112), (88, 116, 84)])))
            for _ in range(3):
                s.blob(bx + r.uniform(-50, 50), by + r.uniform(-30, 50), 15, 20, s.tint((70, 64, 84)))


def c4_cloud(s, v):
    s.sky(.88, 1.0, sun=False)
    r = s.r
    sx, sy = W * r.uniform(.3, .7), H * r.uniform(.14, .3)
    s.glow(sx, sy, 250, s.p["sun"], .9)
    s.rays(sx, sy, 22, 2.2, math.pi / 2, 1600, strength=.32)
    s.land(.8, .05, (92, 98, 128), (74, 84, 98), 1.7)
    ln = s.land(.88, .025, (112, 128, 88), (66, 90, 60), 2)
    x = int(W * r.uniform(.2, .8))
    P.cross(s, x, ln[x] + 6, 290, sil=True)
    P.grass(s, .9, 1, 2400)


def c4_symbol(s, v):
    s.sky(.6, .4)
    s.land(.56, .05, (130, 140, 170), (150, 160, 170), 2)
    field(s, .62, ((124, 152, 92), (70, 104, 70)))
    P.grass(s, .64, 1, 6400)
    x = W * s.r.uniform(.3, .7)
    P.cross(s, x, H * .9, 900, sil=False)
    # draped white linen: a resurrection symbol
    s.poly([(x - 260, H * .36), (x - 40, H * .32), (x + 40, H * .32), (x + 260, H * .36), (x + 170, H * .62), (x + 60, H * .42), (x - 60, H * .42), (x - 170, H * .62)], s.tint((252, 250, 244)))
    P.flower_bed(s, .78, 1.03, 70, ["lily", "daisy"], 14, 46)


def c4_road(s, v):
    s.sky(.5, .5)
    far_hills(s, .52)
    field(s, .55, ((150, 150, 98), (96, 116, 76)))
    P.grass(s, .58, 1, 6000)
    P.stone_path(s, W * .6, 12, W * .34, W * .24, H * .55, H)
    ln = s.line(.55, .04)
    x = int(W * .6)
    P.cross(s, x, H * .57, 300, sil=True)
    for _ in range(5):
        P.olive(s, W * s.r.choice((.1, .2, .78, .9)), H * s.r.uniform(.7, 1), s.r.uniform(320, 640))
    P.poppy_dabs(s, .7, 1, 400, [(232, 84, 96), (246, 214, 120)])


def c4_vigil(s, v):
    s.sky(.6, .3)
    s.land(.56, .06, (70, 74, 120), (86, 88, 126), 1.6)
    P.city(s, H * .64, W * s.r.uniform(.3, .7), W * .55, 34, .46)
    ln = s.land(.72, .05, (70, 80, 90), (44, 58, 70), 1.4)
    for off, h in ((-220, 280), (0, 400), (220, 280)):
        x = W // 3 + off + s.r.randrange(0, W // 3)
        P.cross(s, x, ln[x] + 8, h, sil=True)
    for i in range(16):
        P.oil_lamp(s, W * s.r.random(), H * s.r.uniform(.8, .98), 30)
    P.grass(s, .76, 1, 2600, [(58, 76, 80), (44, 62, 70)])


# ------- collection 5 -------
def _garden(s, y=.78):
    P.grass(s, y - .1, 1, 8000)
    P.flower_bed(s, y, 1.04, 96, ["lily", "lily", "daisy", "tulip"], 14, 50)


def c5_tomb(s, v):
    s.sky(.54, .45)
    far_hills(s, .56)
    field(s, .62, ((134, 158, 92), (86, 118, 72)))
    P.tomb(s, W * s.r.uniform(.38, .62), H * .78, 520, s.r.choice((-1, 1)))
    _garden(s)


def c5_sunrise(s, v):
    s.sun = (W * s.r.uniform(.5, .8), H * .4)
    s.sky(.58, .4)
    s.rays(s.sun[0], s.sun[1], 18, 6.28, 0, 1500, strength=.22)
    far_hills(s, .58)
    field(s, .66, ((146, 150, 92), (88, 112, 72)))
    size = s.r.uniform(420, 680)
    tx = W * s.r.uniform(.2, .5)
    P.tomb(s, tx, H * s.r.uniform(.78, .88), size, 1)
    P.grass(s, .7, 1, 5400)
    P.olive(s, W * s.r.uniform(.68, .95), H * s.r.uniform(.8, .98), s.r.uniform(380, 720))


def c5_stone(s, v):
    s.sky(.4, .4)
    r = s.r
    for _ in range(3200):
        x, y = r.uniform(0, W), r.uniform(.18, .86) * H
        c = s.tint(r.choice([(176, 160, 138), (156, 142, 122), (198, 180, 154), (138, 124, 108)]), .8 + (y / H) * .3)
        s.blob(x, y, r.uniform(26, 66), r.uniform(18, 44), c)
    x = W * r.uniform(.12, .46)
    y = H * r.uniform(.8, .9)
    dw = r.uniform(190, 310)
    s.d.pieslice([x - dw, y - 780, x + dw, y - 120], 180, 360, fill=(22, 18, 22))
    s.d.rectangle([x - dw, y - 450, x + dw, y], fill=(22, 18, 22))
    s.glow(x, y - 260, 260, (255, 240, 200), .6)
    sx = x + dw + r.uniform(260, 420)
    s.blob(sx + 18, y - 318, 370, 370, s.tint((70, 62, 58)))
    s.blob(sx, y - 340, 360, 360, s.tint((186, 170, 146)))
    s.blob(sx, y - 340, 250, 250, s.tint((168, 152, 130)))
    for _ in range(1600):
        a, d = r.uniform(0, 6.28), r.random() ** .5
        s.blob(sx + math.cos(a) * d * 340, y - 340 + math.sin(a) * d * 340, r.uniform(4, 12), r.uniform(3, 7), s.tint((200, 182, 158), r.uniform(.78, 1.12)))
    field(s, .86, ((126, 150, 88), (84, 112, 70)))
    P.flower_bed(s, .88, 1.05, 40, ["lily", "daisy"], 22, 54)


def c5_garden(s, v):
    s.sky(.46, .4)
    far_hills(s, .5)
    field(s, .55, ((142, 166, 94), (94, 132, 74)))
    P.tomb(s, W * s.r.uniform(.6, .74), H * .62, 240, -1)
    for _ in range(9):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.56, .66), s.r.uniform(170, 330))
    P.stone_path(s, W * .62, 12, W * .38, W * .22, H * .62, H)
    _garden(s, .68)


def c5_light(s, v):
    s.sky(.5, .3)
    far_hills(s, .54)
    field(s, .6, ((130, 152, 92), (84, 112, 72)))
    x, y = W * .5, H * .78
    P.tomb(s, x, y, 640, s.r.choice((-1, 1)))
    s.rays(x, y - 180, 18, 2.4, -math.pi / 2, 1200, col=(255, 244, 210), strength=.42)
    P.grass(s, .8, 1, 2400)
    P.flower_bed(s, .82, 1.05, 54, ["lily"], 18, 50)


def c5_angels(s, v):
    s.sky(.52, .34)
    far_hills(s, .56)
    field(s, .62, ((134, 158, 92), (86, 118, 72)))
    tx = W * s.r.uniform(.3, .4)
    P.tomb(s, tx, H * .8, 480, 1)
    P.angel(s, tx + 690, H * .86, 500)
    _garden(s, .86)


def c5_lilies(s, v):
    s.sky(.5, .4)
    far_hills(s, .5)
    field(s, .54, ((134, 160, 92), (88, 124, 74)))
    P.grass(s, .56, .8, 5000)
    P.tomb(s, W * s.r.uniform(.2, .8), H * .58, 170, s.r.choice((-1, 1)))
    P.flower_bed(s, .62, 1.14, 170, ["lily"], 12, 92)


def c5_bloom(s, v):
    s.sky(.46, .4)
    far_hills(s, .48)
    field(s, .52, ((142, 170, 94), (92, 130, 74)))
    for _ in range(9):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.54, .62), s.r.uniform(200, 340), cols=[(246, 190, 210), (250, 214, 226), (236, 160, 190), (255, 236, 240)])
    P.flower_bed(s, .62, 1.1, 240, ["tulip", "daffodil", "lily", "daisy"], 10, 60)


def c5_risen(s, v):
    s.sky(.5, .4)
    far_hills(s, .56)
    field(s, .64, ((136, 160, 94), (88, 120, 74)))
    x, y = W * s.r.uniform(.42, .62), H * .9
    s.rays(x, y - 420, 20, 6.28, 0, 1200, col=(255, 244, 200), strength=.3)
    P.figure(s, x, y, 780, robe=(250, 246, 236), halo=True, sash=(220, 190, 130))
    P.tomb(s, W * .16 if x > W / 2 else W * .84, H * .72, 300, 1 if x > W / 2 else -1)
    _garden(s, .84)


def c5_hope(s, v):
    s.sky(.5, .55)
    s.land(.46, .12, (128, 138, 176), (150, 160, 176), 1.3)
    s.haze(.42, .58, .3)
    far_hills(s, .62)
    field(s, .68, ((150, 176, 96), (92, 136, 76)))
    P.grass(s, .7, 1, 6000)
    P.stone_path(s, W * s.r.uniform(.4, .6), 12, W * s.r.uniform(.4, .6), W * .2, H * .68, H)
    P.poppy_dabs(s, .74, 1, 1200, [(255, 250, 240), (250, 226, 130), (244, 180, 200)])
    P.dove(s, W * s.r.uniform(.3, .7), H * .3, 62)


# ------- collection 6 -------
def c6_angel(s, v):
    s.sky(.72, .8)
    P.angel(s, W * s.r.uniform(.35, .65), H * .9, 1040)
    for i in range(5):
        s.blob(W * s.r.random(), H * s.r.uniform(.9, 1), 340, 90, s.tint(s.p["cloud"]))


def c6_light(s, v):
    s.sun = (W * s.r.uniform(.3, .7), H * .26)
    s.sky(.74, .7)
    s.rays(s.sun[0], s.sun[1], 26, 6.28, 0, 1600, col=(255, 248, 220), strength=.3)
    s.land(.76, .06, (120, 124, 170), (130, 140, 170), 1.8)
    s.haze(.7, .86, .4)
    s.land(.88, .04, (130, 150, 110), (90, 120, 86), 2.2)
    P.grass(s, .9, 1, 2400)


def c6_doves(s, v):
    s.sky(.66, .62)
    r = s.r
    for _ in range(19):
        P.dove(s, W * r.random(), H * r.uniform(.08, .7), r.uniform(26, 100), r.random() < .7)
    s.land(.82, .04, (116, 142, 112), (84, 118, 84), 2)
    P.grass(s, .84, 1, 2600)


def c6_spirit(s, v):
    s.sun = (W * .5, H * .18)
    s.sky(.8, .55)
    s.rays(W * .5, H * .06, 16, 1.3, math.pi / 2, 1700, col=(255, 246, 210), strength=.42)
    P.dove(s, W * .5, H * .26, 165, up=True)
    s.glow(W * .5, H * .26, 320, (255, 244, 200), .3)
    s.land(.8, .05, (116, 120, 164), (120, 140, 150), 2)
    P.city(s, H * .86, W * .5, W * .5, 24, .36, wall=False)
    s.land(.9, .03, (110, 136, 96), (76, 110, 76), 2)
    P.grass(s, .91, 1, 2000)


def c6_celestial(s, v):
    s.sky(.9, .55)
    r = s.r
    for layer in range(3):
        y = H * (.5 + layer * .16)
        for i in range(10):
            s.blob(W * r.random(), y + r.uniform(-60, 60), r.uniform(240, 520), r.uniform(70, 130), s.tint(s.p["cloud"], .86 + layer * .06))
    for i in range(3):
        P.building(s, W * (.3 + i * .15), H * .62, 220, 520 - i * 50, col=(250, 240, 214), dome=True)
    s.glow(W * .5, H * .42, 400, s.p["sun"], .5)
    for i in range(14):
        s.blob(W * r.random(), H * r.uniform(.72, 1.0), r.uniform(240, 560), r.uniform(70, 130), s.tint(s.p["cloud"], .98))


def c6_horizon(s, v):
    s.sun = (W * s.r.uniform(.2, .8), H * .56)
    s.sky(.62, .5)
    s.glow(s.sun[0], s.sun[1], 500, s.p["sun"], .55)
    s.land(.62, .03, (110, 110, 150), (74, 90, 128), 1.5)
    a = H * .68
    s.reflect(a)
    s.d
    for i in range(10):
        P.dove(s, W * s.r.random(), H * s.r.uniform(.12, .5), s.r.uniform(18, 44))


def c6_symbol(s, v):
    s.sky(.6, .4)
    r = s.r
    far_hills(s, .62)
    field(s, .68, ((130, 160, 94), (80, 118, 74)))
    P.grass(s, .7, 1, 5400)
    x, y = W * r.uniform(.35, .65), H * .92
    P.bouquet(s, x, y, 540)
    for i in range(7):
        P.oil_lamp(s, W * r.random(), H * r.uniform(.84, .98), 46)
    P.dove(s, x, H * .24, 100)


def c6_mountain(s, v):
    s.sky(.56, .55)
    s.land(.42, .2, (106, 116, 164), (140, 146, 178), 1.1, rough=.58, tex=.24, snow=True)
    s.haze(.44, .62, .3)
    s.land(.62, .08, (84, 112, 112), (96, 124, 96), 2, tex=.2)
    field(s, .74, ((136, 166, 96), (84, 122, 76)))
    P.grass(s, .76, 1, 5000)
    for i in range(3):
        P.dove(s, W * s.r.random(), H * s.r.uniform(.1, .3), 44)
    s.rays(W * s.r.uniform(.3, .7), -60, 8, .8, math.pi / 2, 1500, strength=.22)


def c6_stars(s, v):
    s.sky(.74, .16, sun=False)
    r = s.r
    s.d
    for i in range(3):
        cx, cy = W * r.uniform(.1, .9), H * r.uniform(.1, .5)
        s.glow(cx, cy, r.uniform(160, 260), r.choice([(150, 110, 200), (90, 120, 210), (230, 150, 190)]), .4)
    s.d
    for _ in range(800):
        x, y, q = r.uniform(0, W), r.uniform(0, .76) * H, r.random() ** 4 * 5 + 1
        s.blob(x, y, q, q, r.choice([(255, 252, 240), (214, 226, 255), (255, 226, 200)]))
    x, y = W * r.uniform(.3, .7), H * .2
    s.glow(x, y, 120, (255, 248, 220), .9)
    s.rays(x, y, 8, 6.28, 0, 700, col=(255, 250, 230), strength=.5)
    s.land(.74, .06, (30, 40, 84), (26, 40, 76), 1.6)
    ln = s.land(.84, .05, (40, 52, 76), (24, 36, 52), 1.3)
    for i in range(40):
        P.conifer(s, W * r.random(), H * r.uniform(.82, .9), r.uniform(120, 220), col=(30, 50, 62))


def c6_landscape(s, v):
    s.sky(.5, .6)
    s.land(.44, .13, (130, 130, 172), (160, 156, 184), 1.3, rough=.55)
    s.haze(.42, .6, .34)
    far_hills(s, .62)
    a = H * .7
    s.reflect(a)
    s.d
    for _ in range(6):
        P.dove(s, W * s.r.random(), H * s.r.uniform(.1, .4), 34)
    for _ in range(7):
        P.conifer(s, s.r.choice((s.r.uniform(0, .2), s.r.uniform(.8, 1))) * W, H * s.r.uniform(.86, 1.02), s.r.uniform(260, 620))


# ------- collection 7 -------
def c7_garden(s, v):
    s.sky(.44, .45)
    far_hills(s, .48)
    field(s, .52, ((150, 180, 96), (96, 142, 78)))
    for _ in range(7):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.54, .6), s.r.uniform(200, 360))
    P.stone_path(s, W * .55, 16, W * .46, W * .2, H * .58, H)
    P.grass(s, .6, 1, 5000)
    P.flower_bed(s, .62, 1.06, 200, ["tulip", "daisy", "daffodil"], 10, 54)


def c7_sunrise(s, v):
    s.sun = (W * s.r.uniform(.3, .7), H * .44)
    s.sky(.56, .42)
    s.rays(s.sun[0], s.sun[1], 18, 6.28, 0, 1500, strength=.18)
    far_hills(s, .56)
    field(s, .64, ((156, 176, 96), (96, 136, 76)))
    P.grass(s, .66, 1, 7000)
    P.poppy_dabs(s, .7, 1, 2400, [(255, 226, 120), (250, 250, 240), (246, 170, 190)])


def c7_lilies(s, v):
    s.sky(.4, .5)
    far_hills(s, .42)
    field(s, .46, ((136, 168, 96), (84, 128, 76)))
    P.flower_bed(s, .5, 1.2, 150, ["lily"], 16, 130)


def c7_tulips(s, v):
    s.sky(.42, .5)
    far_hills(s, .44)
    field(s, .48, ((140, 176, 96), (86, 132, 76)))
    r = s.r
    pal = [(232, 84, 96), (246, 150, 170), (250, 186, 74), (186, 120, 208), (240, 104, 60)]
    vx = W * r.uniform(.3, .7)
    for row in range(-9, 10):
        col = r.choice(pal)
        for k in range(46):
            t = (k / 45) ** 1.7
            y = H * (.5 + .56 * t)
            x = vx + row * (40 + t * 330) + r.uniform(-4, 4)
            P.tulip(s, x, y, 6 + 58 * t, col)


def c7_daffodils(s, v):
    s.sky(.46, .5)
    far_hills(s, .5)
    field(s, .54, ((150, 176, 96), (96, 136, 78)))
    for _ in range(5):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.56, .6), s.r.uniform(240, 340))
    P.grass(s, .56, 1, 4000)
    P.flower_bed(s, .58, 1.12, 210, ["daffodil"], 10, 76)


def c7_butterflies(s, v):
    s.sky(.42, .4)
    far_hills(s, .46)
    field(s, .5, ((150, 180, 96), (96, 140, 78)))
    P.flower_bed(s, .6, 1.08, 150, ["daisy", "tulip"], 12, 64)
    for _ in range(19):
        P.butterfly(s, W * s.r.random(), H * s.r.uniform(.28, .72), s.r.uniform(30, 86), s.r.choice([(246, 150, 60), (120, 150, 230), (232, 90, 130), (250, 214, 90), (170, 110, 220)]))


def c7_birds(s, v):
    s.sky(.5, .4)
    far_hills(s, .54)
    field(s, .6, ((150, 176, 96), (96, 140, 78)))
    P.grass(s, .62, 1, 5000)
    r = s.r
    bx = W * r.choice((.22, .78))
    P.broadleaf(s, bx, H * 1.04, 1420, cols=[(250, 214, 226), (246, 190, 210), (255, 236, 240), (236, 170, 196)])
    for _ in range(11):
        a = r.uniform(0, 6.28)
        P.bird(s, bx + math.cos(a) * r.uniform(80, 480), H * .36 + math.sin(a) * r.uniform(40, 300), r.uniform(36, 66), s.tint(r.choice([(230, 110, 70), (90, 130, 200), (246, 200, 90), (130, 170, 110)])))


def c7_meadow(s, v):
    s.sky(.5, .55)
    far_hills(s, .5)
    a = field(s, .56, ((160, 186, 98), (100, 146, 80)))
    for _ in range(5):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.56, .62), 240)
    P.grass(s, .58, 1, 13000, [(132, 176, 86), (108, 158, 80), (170, 198, 100), (88, 138, 72)])
    P.poppy_dabs(s, .6, 1, 1800, [(232, 84, 96), (250, 250, 240), (255, 226, 120), (190, 150, 230)])


def c7_cottage(s, v):
    s.sky(.46, .45)
    far_hills(s, .48)
    field(s, .54, ((146, 176, 96), (96, 138, 78)))
    for _ in range(5):
        P.broadleaf(s, W * s.r.random(), H * .58, s.r.uniform(280, 440))
    P.cottage(s, W * s.r.uniform(.22, .46), H * .76, 720)
    P.stone_path(s, W * .5, 40, W * .5, W * .2, H * .76, H)
    P.grass(s, .76, 1, 3200)
    P.flower_bed(s, .76, 1.06, 130, ["tulip", "daisy", "lily"], 14, 56)


def c7_path(s, v):
    s.sky(.42, .45)
    far_hills(s, .46)
    field(s, .5, ((150, 180, 96), (96, 140, 78)))
    cx0, cx1 = W * s.r.uniform(.4, .6), W * s.r.uniform(.4, .6)
    P.stone_path(s, cx0, 10, cx1, W * .14, H * .5, H)
    r = s.r
    for side in (-1, 1):
        for k in range(120):
            t = r.random() ** 1.5
            y = H * (.5 + .55 * t)
            x = cx0 + (cx1 - cx0) * t + side * (W * .02 + W * .22 * t + r.uniform(0, W * .12 + W * .2 * t))
            k2 = r.randrange(3)
            rad = 7 + 56 * t
            if k2 == 0:
                P.tulip(s, x, y, rad * .9, r.choice([(232, 84, 96), (246, 150, 170), (250, 186, 74), (186, 120, 208)]))
            elif k2 == 1:
                P.daffodil(s, x, y, rad)
            else:
                P.daisy(s, x, y, rad, r.choice([(255, 250, 240), (250, 190, 210), (214, 190, 244)]))
    for side in (.06, .94):
        P.broadleaf(s, W * side, H * .68, 620, cols=[(250, 214, 226), (246, 190, 210), (255, 236, 240)])


def c7_church(s, v):
    s.sky(.46, .4)
    far_hills(s, .5)
    field(s, .56, ((150, 178, 96), (96, 138, 78)))
    x, y = W * s.r.uniform(.34, .58), H * .7
    w = 460
    s.poly([(x, y), (x, y - 330), (x + w, y - 330), (x + w, y)], s.tint((244, 236, 220)))
    s.poly([(x - 30, y - 330), (x + w / 2, y - 560), (x + w + 30, y - 330)], s.tint((160, 90, 74)))
    s.poly([(x + w * .4, y - 330), (x + w * .4, y - 760), (x + w * .6, y - 760), (x + w * .6, y - 330)], s.tint((244, 236, 220)))
    s.poly([(x + w * .36, y - 760), (x + w * .5, y - 980), (x + w * .64, y - 760)], s.tint((140, 84, 72)))
    P.cross(s, x + w * .5, y - 970, 96, sil=False, thick=.1)
    s.d.pieslice([x + w * .4, y - 240, x + w * .6, y - 40], 180, 360, fill=s.tint((110, 76, 60)))
    s.d.rectangle([x + w * .4, y - 140, x + w * .6, y], fill=s.tint((110, 76, 60)))
    for wx in (.12, .78):
        s.d.pieslice([x + w * wx, y - 280, x + w * (wx + .1), y - 200], 180, 360, fill=s.tint((120, 150, 200)))
        s.d.rectangle([x + w * wx, y - 240, x + w * (wx + .1), y - 120], fill=s.tint((120, 150, 200)))
    P.grass(s, .7, 1, 4400)
    P.flower_bed(s, .72, 1.06, 150, ["lily", "tulip", "daffodil"], 12, 52)
    P.stone_path(s, x + w * .5, 50, x + w * .5, W * .18, y, H)


# ------- collection 8 -------
def _pasture(s, hy=.56):
    s.sky(hy - .06, .5)
    far_hills(s, hy)
    field(s, hy + .06, ((150, 180, 96), (96, 142, 78)))
    P.grass(s, hy + .08, 1, 8000, [(132, 176, 86), (108, 158, 80), (170, 198, 100)])


def c8_lambs(s, v):
    _pasture(s)
    r = s.r
    P.flower_bed(s, .68, 1.0, 40, ["daisy"], 8, 26)
    for y in sorted(r.uniform(.68, .96) for _ in range(9)):
        P.lamb(s, W * r.random(), H * y, 120 + (y - .68) * 900, r.choice((-1, 1)))


def c8_onelamb(s, v):
    _pasture(s, .46)
    r = s.r
    P.flower_bed(s, .58, 1.08, 110, ["daisy", "daffodil"], 8, 44)
    P.lamb(s, W * r.uniform(.3, .7), H * .94, 760, r.choice((-1, 1)))


def c8_rabbits(s, v):
    _pasture(s, .5)
    r = s.r
    P.flower_bed(s, .62, 1.06, 90, ["daisy", "tulip"], 8, 40)
    for y in sorted(r.uniform(.68, .98) for _ in range(6)):
        P.rabbit(s, W * r.random(), H * y, 130 + (y - .68) * 800, r.choice([(176, 148, 124), (150, 130, 112), (226, 216, 204), (200, 170, 140)]))


def c8_birds(s, v):
    _pasture(s, .46)
    r = s.r
    s.d
    for _ in range(3):
        y = H * r.uniform(.72, .94)
        s.stroke([(-20, y + 60), (W * .3, y), (W * .7, y + 30), (W + 20, y - 40)], s.tint((96, 72, 54)), 46)
    P.nest(s, W * r.uniform(.3, .7), H * .78, 280)
    for _ in range(50):
        P.broadleaf(s, W * r.random(), H * r.uniform(.2, .46), 60)
    for _ in range(4):
        P.bird(s, W * r.random(), H * r.uniform(.3, .6), 56, s.tint(r.choice([(230, 110, 70), (90, 130, 200), (246, 200, 90)])))


def c8_lilies(s, v):
    s.sky(.42, .4)
    far_hills(s, .42)
    field(s, .46, ((130, 164, 94), (80, 124, 74)))
    r = s.r
    for _ in range(26):
        P.lily(s, W * r.random(), H * r.uniform(.5, 1.0), r.uniform(60, 180))


def c8_arrange(s, v):
    P.interior(s, wall=s.r.choice([(226, 214, 200), (236, 222, 206), (206, 214, 214)]))
    P.table_top(s, .6, cloth=(250, 244, 236))
    P.bouquet(s, W * s.r.uniform(.38, .62), H * .76, 700)
    for i in range(3):
        P.bouquet(s, W * s.r.choice((.14, .84, .24, .74)), H * .72, 260)


def c8_hills(s, v):
    s.sky(.42, .55)
    r = s.r
    y = .44
    for i in range(6):
        col = (120 + i * 8, 170 - i * 2, 92 + i * 2)
        field(s, y + i * .1, (col, (col[0] - 34, col[1] - 34, col[2] - 18)))
        for _ in range(3 + i * 3):
            P.broadleaf(s, W * r.random(), H * (y + i * .1 + r.uniform(.03, .08)), 80 + i * 44)
    for _ in range(10):
        P.lamb(s, W * r.random(), H * r.uniform(.6, .95), 70)


def c8_butter(s, v):
    _pasture(s, .42)
    r = s.r
    P.flower_bed(s, .56, 1.1, 130, ["daisy", "lily", "tulip"], 12, 60)
    for _ in range(16):
        P.butterfly(s, W * r.random(), H * r.uniform(.2, .8), r.uniform(26, 120), r.choice([(246, 150, 60), (120, 150, 230), (232, 90, 130), (250, 214, 90)]))


def c8_flowers(s, v):
    s.sky(.36, .4)
    far_hills(s, .36)
    field(s, .4, ((130, 170, 94), (86, 130, 76)))
    P.flower_bed(s, .42, 1.12, 380, ["tulip", "daffodil", "lily", "daisy"], 10, 76)


def c8_stream(s, v):
    s.sky(.42, .45)
    far_hills(s, .46)
    field(s, .5, ((148, 178, 96), (94, 138, 78)))
    a = s.np()
    r = s.r
    s.d
    pts_l, pts_r = [], []
    for k in range(40):
        t = k / 39
        y = H * (.5 + .5 * t)
        cx = W * .5 + math.sin(t * 5 + r.uniform(0, .2)) * (70 + 400 * t)
        half = 20 + 300 * t
        pts_l.append((cx - half, y))
        pts_r.append((cx + half, y))
    s.poly(pts_l + pts_r[::-1], s.tint((120, 176, 214)))
    for _ in range(1600):
        k = r.randrange(40)
        t = k / 39
        px = pts_l[k][0] + r.random() * (pts_r[k][0] - pts_l[k][0])
        ln = 8 + 54 * t
        s.d.line([(px, pts_l[k][1]), (px + ln, pts_l[k][1])], fill=s.tint(r.choice([(170, 216, 240), (250, 252, 255), (96, 150, 196)])), width=2)
    P.flower_bed(s, .56, 1.06, 110, ["daisy", "daffodil"], 8, 48)
    for _ in range(4):
        P.lamb(s, W * r.choice((r.uniform(0, .18), r.uniform(.82, 1))), H * r.uniform(.72, .96), 240)


# ------- collection 9 -------
def _festive_table(s, y=.54):
    t, b, wf, wn = P.table_top(s, y, cloth=s.r.choice([(252, 240, 236), (236, 240, 252), (240, 250, 236), (255, 246, 222)]))
    return t, b, wf, wn


def c9_eggs(s, v):
    s.sky(.4, .4)
    field(s, .3, ((130, 170, 92), (92, 134, 72)))
    P.grass(s, .32, 1, 12000)
    r = s.r
    for y in sorted(r.uniform(.36, 1.04) for _ in range(90)):
        P.egg(s, W * r.random(), H * y, 40 + (y - .3) * 270)


def c9_basket(s, v):
    s.sky(.44, .5)
    far_hills(s, .46)
    field(s, .5, ((140, 174, 94), (90, 136, 76)))
    P.grass(s, .52, 1, 8000)
    P.flower_bed(s, .6, .8, 60, ["daisy", "tulip"], 8, 32)
    r = s.r
    P.basket(s, W * r.uniform(.4, .6), H * .95, 880)
    for _ in range(15):
        P.egg(s, W * r.random(), H * r.uniform(.72, 1.02), r.uniform(70, 150))


def c9_table(s, v):
    s.sky(.3, .4)
    far_hills(s, .36)
    field(s, .4, ((140, 174, 94), (90, 136, 76)))
    for _ in range(9):
        P.broadleaf(s, W * s.r.random(), H * .42, s.r.uniform(160, 340))
    P.bunting(s, H * .05)
    _festive_table(s, .52)
    r = s.r
    P.cake(s, W * .5, H * .66, 360)
    for x in (.2, .8):
        P.basket(s, W * x, H * .7, 300)
    for x in (.33, .68):
        P.bouquet(s, W * x, H * .63, 180)
    for _ in range(16):
        P.egg(s, W * r.uniform(.12, .88), H * r.uniform(.6, .7), r.uniform(50, 90))


def c9_cakes(s, v):
    P.interior(s, wall=s.r.choice([(244, 226, 216), (226, 232, 242), (232, 240, 226)]))
    _festive_table(s, .56)
    r = s.r
    for i in range(3):
        P.cake(s, W * (.24 + i * .26), H * (.68 + (i % 2) * .03), 370 - (i % 2) * 40)
    for _ in range(10):
        P.egg(s, W * r.uniform(.1, .9), H * r.uniform(.7, .73), r.uniform(50, 90))


def c9_decor(s, v):
    P.interior(s, wall=s.r.choice([(250, 232, 226), (232, 228, 248), (224, 240, 244)]), arch_window=True)
    P.bunting(s, H * .02, 160)
    P.bunting(s, H * .12, 130)
    r = s.r
    _festive_table(s, .66)
    for i in range(5):
        P.basket(s, W * (.14 + i * .18), H * .78, 230)
    for _ in range(12):
        P.egg(s, W * r.random(), H * r.uniform(.78, .84), 70)


def c9_village(s, v):
    s.sky(.44, .4)
    far_hills(s, .48)
    field(s, .52, ((150, 176, 96), (96, 136, 78)))
    P.bunting(s, H * .08, 100)
    r = s.r
    bright = [(250, 210, 200), (200, 226, 244), (244, 234, 170), (210, 236, 204), (226, 208, 240)]
    for y in sorted(r.uniform(.58, .84) for _ in range(13)):
        P.cottage(s, W * r.random() - 90, H * y, 180 + (y - .58) * 1100, walls=r.choice(bright))
    P.stone_path(s, W * .5, 30, W * .5, W * .2, H * .8, H)
    P.flower_bed(s, .84, 1.08, 70, ["tulip", "daisy"], 14, 40)


def c9_family(s, v):
    s.sky(.46, .4)
    far_hills(s, .5)
    field(s, .54, ((150, 180, 96), (96, 140, 78)))
    P.grass(s, .56, 1, 6000)
    r = s.r
    P.bunting(s, H * .1, 80)
    for _ in range(4):
        P.broadleaf(s, W * r.random(), H * .58, r.uniform(340, 460))
    pal = [(244, 166, 185), (147, 199, 234), (169, 214, 184), (241, 199, 107), (190, 170, 230)]
    for y in sorted(r.uniform(.66, 1.0) for _ in range(9)):
        P.figure(s, W * r.random(), H * y, 170 + (y - .66) * 760, robe=r.choice(pal))
    for _ in range(40):
        P.egg(s, W * r.random(), H * r.uniform(.66, 1.02), r.uniform(40, 86))


def c9_painting(s, v):
    P.interior(s, wall=(228, 214, 192), arch_window=False)
    _festive_table(s, .32)
    s.d.rectangle([0, H * .4, W, H], fill=s.tint((250, 246, 236)))
    r = s.r
    for y in sorted(r.uniform(.48, 1.0) for _ in range(40)):
        P.egg(s, W * r.random(), H * y, r.uniform(120, 230))
    for x in (.16, .4, .64, .86):
        cup_col = r.choice([(244, 166, 185), (147, 199, 234), (169, 214, 184), (241, 199, 107)])
        s.d.rounded_rectangle([W * x - 90, H * .46, W * x + 90, H * .6], 20, fill=s.tint(cup_col))
        s.blob(W * x, H * .46, 90, 26, s.tint(cup_col, .62))


def c9_bouquets(s, v):
    s.sky(.36, .4)
    far_hills(s, .38)
    field(s, .42, ((140, 174, 94), (90, 136, 76)))
    _festive_table(s, .5)
    r = s.r
    for i in range(5):
        P.bouquet(s, W * (.12 + i * .19), H * r.uniform(.64, .67), r.uniform(240, 380))
    for _ in range(8):
        P.egg(s, W * r.random(), H * r.uniform(.68, .72), 76)


def c9_lanterns(s, v):
    s.sky(.5, .3)
    far_hills(s, .54)
    field(s, .6, ((130, 150, 90), (80, 110, 72)))
    P.grass(s, .62, 1, 6000)
    r = s.r
    for _ in range(3):
        y0 = H * r.uniform(.04, .22)
        P.bunting(s, y0, r.uniform(90, 180))
    for _ in range(14):
        x, y = W * r.random(), H * r.uniform(.14, .5)
        c = r.choice([(255, 180, 90), (250, 130, 110), (250, 210, 110), (200, 150, 240)])
        s.glow(x, y, 70, c, .4)
        s.blob(x, y, 42, 50, s.tint(c))
        s.d.rectangle([x - 18, y - 60, x + 18, y - 50], fill=(110, 80, 60))
    for _ in range(4):
        P.cottage(s, W * r.random() - 100, H * .66, 360)
    P.flower_bed(s, .78, 1.06, 70, ["tulip", "daisy"], 14, 44)


# ------- collection 10 -------
def _valley(s, hy):
    field(s, hy, ((132, 170, 94), (84, 132, 76)))
    P.grass(s, hy + .02, 1, 7000)


def c10_mountains(s, v):
    s.sky(.5, .55)
    s.land(.34, .2, (108, 120, 156), (146, 154, 180), 1.2, rough=.58, tex=.28, snow=True)
    s.land(.5, .12, (92, 106, 130), (110, 128, 130), 1.6, tex=.26)
    s.haze(.5, .66, .3)
    s.land(.64, .07, (70, 110, 100), (86, 124, 92), 2, tex=.2)
    for _ in range(46):
        P.conifer(s, W * s.r.random(), H * s.r.uniform(.66, .74), s.r.uniform(90, 200))
    _valley(s, .76)
    for _ in range(26):
        P.conifer(s, W * s.r.random(), H * s.r.uniform(.8, 1.04), s.r.uniform(220, 560))


def c10_lake(s, v):
    s.sky(.5, .55)
    s.land(.36, .16, (112, 124, 158), (146, 154, 180), 1.3, rough=.55, tex=.26, snow=s.r.random() < .6)
    s.land(.5, .06, (70, 110, 100), (86, 124, 92), 2.4, tex=.2)
    for _ in range(44):
        P.conifer(s, W * s.r.random(), H * s.r.uniform(.5, .56), s.r.uniform(60, 130))
    s.reflect(H * .56)
    s.d
    P.grass(s, .94, 1, 800)
    for _ in range(9):
        P.conifer(s, s.r.choice((s.r.uniform(-.02, .16), s.r.uniform(.84, 1.02))) * W, H * s.r.uniform(.92, 1.06), s.r.uniform(400, 820))


def c10_waterfall(s, v):
    s.sky(.3, .4)
    s.land(.18, .06, (116, 150, 124), (106, 136, 110), 2)
    r = s.r
    s.d
    lw, rw = W * r.uniform(.36, .42), W * r.uniform(.58, .64)
    for _ in range(7000):
        x = r.choice((r.uniform(-30, lw), r.uniform(rw, W + 30)))
        y = r.uniform(.18, .82) * H
        c = s.tint(r.choice([(128, 118, 110), (110, 100, 96), (150, 136, 124), (96, 92, 92)]), r.uniform(.76, 1.12))
        s.blob(x, y, r.uniform(22, 56), r.uniform(14, 36), c)
    for _ in range(420):
        x = r.choice((r.uniform(-30, lw), r.uniform(rw, W + 30)))
        y = r.uniform(.18, .66) * H
        P.broadleaf(s, x, y, r.uniform(60, 130))
    s.d.rectangle([lw - 20, H * .2, rw + 20, H * .8], fill=s.tint((186, 214, 232)))
    for _ in range(4600):
        x = r.uniform(lw - 20, rw + 20)
        y = r.uniform(.2, .78) * H
        s.d.line([(x, y), (x + r.uniform(-3, 3), y + r.uniform(40, 170))], fill=s.tint(r.choice([(255, 255, 255), (222, 238, 248), (170, 204, 228)])), width=r.choice((2, 3, 5)))
    s.glow(W / 2, H * .8, 300, (255, 255, 255), .5)
    s.d.rectangle([0, H * .8, W, H], fill=s.tint((102, 168, 190)))
    for _ in range(3000):
        x, y = r.uniform(0, W), r.uniform(.8, 1) * H
        s.d.line([(x, y), (x + r.uniform(16, 80), y)], fill=s.tint(r.choice([(140, 200, 222), (230, 244, 250), (70, 130, 160)])), width=3)
    for _ in range(46):
        x = r.choice((r.uniform(0, .3), r.uniform(.7, 1))) * W
        s.blob(x, H * r.uniform(.78, .96), r.uniform(50, 140), r.uniform(30, 70), s.tint((120, 112, 104), r.uniform(.76, 1.1)))


def c10_forest(s, v):
    s.sky(.4, .3)
    r = s.r
    for y in sorted(r.uniform(.44, .62) for _ in range(140)):
        P.conifer(s, W * r.random(), H * y, r.uniform(160, 330), col=(60, 104, 92))
    s.haze(.42, .62, .4)
    for y in sorted(r.uniform(.62, .8) for _ in range(60)):
        P.conifer(s, W * r.random(), H * y, r.uniform(380, 640))
    _valley(s, .78)
    s.rays(W * r.uniform(.2, .8), -100, 12, 1.0, math.pi / 2, 1700, strength=.22)
    P.flower_bed(s, .82, 1.05, 70, ["daisy"], 8, 26)
    for y in sorted(r.uniform(.86, 1.08) for _ in range(9)):
        P.conifer(s, r.choice((r.uniform(-.02, .28), r.uniform(.72, 1.02))) * W, H * y, r.uniform(760, 1200))


def c10_sunset(s, v):
    s.sun = (W * s.r.uniform(.25, .75), H * .5)
    s.sky(.6, .7)
    s.glow(s.sun[0], s.sun[1], 400, s.p["sun"], .6)
    s.land(.56, .1, (90, 80, 120), (110, 90, 130), 1.4, tex=.2)
    s.land(.62, .05, (70, 66, 100), (60, 60, 90), 2)
    s.reflect(H * .68)
    s.d
    for _ in range(40):
        P.conifer(s, s.r.choice((s.r.uniform(0, .3), s.r.uniform(.7, 1))) * W, H * s.r.uniform(.86, 1.04), s.r.uniform(320, 640), col=(30, 34, 54))


def c10_beach(s, v):
    s.sky(.5, .5)
    s.land(.48, .03, (150, 160, 180), (160, 170, 180), 1.5)
    s.d.rectangle([0, H * .5, W, H * .68], fill=s.tint((60, 150, 186)))
    r = s.r
    for _ in range(4000):
        x, y = r.uniform(0, W), H * r.uniform(.5, .69)
        s.d.line([(x, y), (x + r.uniform(16, 90), y)], fill=s.tint(r.choice([(100, 190, 214), (40, 124, 170), (180, 232, 236)])), width=2)
    ln = s.land(.68, .025, (232, 214, 170), (216, 190, 146), 1.2, tex=.2)
    for k in range(7):
        pts = [(x, ln[x] + k * 3) for x in range(0, W, 12)]
        s.stroke(pts, s.tint((250, 252, 250), .94 + k * .01), 6)
    for _ in range(600):
        s.blob(r.uniform(0, W), H * r.uniform(.72, 1), r.uniform(2, 7), r.uniform(1, 4), s.tint((192, 170, 134)))
    for x, h in ((.1, 1140), (.2, 880), (.88, 980)):
        P.palm(s, W * (x + r.uniform(-.04, .04)), H * r.uniform(.92, 1.02), h)
    for i in range(8):
        y = H * r.uniform(.86, 1.0)
        c = r.choice([(190, 100, 90), (150, 130, 180), (250, 226, 170), (120, 170, 190)])
        s.blob(W * r.random(), y, 44, 26, s.tint(c))


def c10_fields(s, v):
    s.sky(.44, .5)
    far_hills(s, .46)
    r = s.r
    vx = W * r.uniform(.3, .7)
    field(s, .5, ((170, 150, 200), (120, 90, 170)))
    hue = r.choice(([(170, 130, 220), (140, 100, 200), (196, 160, 236), (120, 90, 180)], [(246, 210, 90), (236, 180, 60), (255, 230, 130), (220, 160, 40)], [(232, 84, 96), (246, 140, 150), (200, 60, 80), (250, 190, 196)]))
    for row in range(-16, 17):
        for k in range(120):
            t = (k / 119) ** 1.6
            y = H * (.5 + .52 * t)
            x = vx + row * (26 + t * 240) + r.uniform(-8, 8) * (1 + t * 6)
            rad = 4 + 42 * t
            s.blob(x, y, rad, rad * .8, s.tint(r.choice(hue), 1, .08))
    for _ in range(3):
        P.cottage(s, W * r.random(), H * .52, 170)
    for _ in range(5):
        P.cypress(s, W * r.random(), H * .54, 150)


def c10_village(s, v):
    s.sky(.42, .45)
    s.land(.36, .12, (120, 138, 164), (156, 164, 180), 1.3, snow=True)
    s.haze(.36, .52, .3)
    field(s, .5, ((140, 176, 96), (92, 138, 78)))
    r = s.r
    for y in sorted(r.uniform(.54, .92) for _ in range(30)):
        P.cottage(s, W * r.random() - 80, H * y, 110 + (y - .54) * 740)
        if r.random() < .5:
            P.conifer(s, W * r.random(), H * y, 170)
    P.stone_path(s, W * .5, 10, W * .4, W * .14, H * .62, H)
    P.flower_bed(s, .94, 1.05, 30, ["tulip", "daisy"], 26, 44)


def c10_castle(s, v):
    s.sky(.5, .55)
    far_hills(s, .56)
    field(s, .62, ((136, 170, 94), (88, 130, 76)))
    r = s.r
    cx = W * r.uniform(.3, .7)
    base = H * .68
    for i in range(7):
        wd, ht = r.uniform(130, 220), r.uniform(330, 780)
        x = cx - 620 + i * 190
        P.building(s, x, base, wd, ht, col=(204, 194, 180), dome=False)
        s.poly([(x - 16, base - ht), (x + wd * 1.16 + 16, base - ht), (x + wd * .58, base - ht - wd * .9)], s.tint((96, 106, 136)))
    P.grass(s, .68, 1, 4000)
    for _ in range(12):
        P.broadleaf(s, W * r.random(), H * r.uniform(.7, 1.02), r.uniform(260, 560))


def c10_gardens(s, v):
    s.sky(.42, .45)
    far_hills(s, .44)
    field(s, .48, ((134, 170, 92), (88, 132, 74)))
    r = s.r
    for row in range(6):
        y = .52 + row * .09
        for x in range(-1, 8 + row):
            cx = W * (x + .5) / (6 + row)
            rad = 30 + row * 14
            for _ in range(46):
                a, d = r.uniform(0, 6.28), r.random() ** .5
                s.blob(cx + math.cos(a) * rad * 1.5 * d, H * y + math.sin(a) * rad * .8 * d, rad * .22, rad * .17, s.tint(r.choice([(92, 140, 80), (70, 120, 70), (120, 160, 90)]) if row % 2 else r.choice([(232, 96, 120), (250, 170, 90), (190, 130, 220), (250, 220, 120)])))
        s.d.rectangle([0, H * (y + .04), W, H * (y + .058)], fill=s.tint((218, 200, 166)))
    P.building(s, W * r.uniform(.3, .5), H * .52, 520, 240, col=(244, 236, 220), arch=True)
    for x in (.05, .95):
        P.cypress(s, W * x, H * .96, 980)


def c10_river(s, v):
    s.sky(.42, .5)
    s.land(.38, .1, (118, 130, 160), (146, 156, 176), 1.4, rough=.55)
    far_hills(s, .5)
    field(s, .54, ((142, 172, 92), (92, 136, 76)))
    P.grass(s, .56, 1, 5000)
    r = s.r
    s.d
    L, R = [], []
    ph = r.uniform(0, 3)
    for k in range(50):
        t = (k / 49) ** 1.4
        y = H * (.54 + .46 * t)
        cx = W * .5 + math.sin(t * 7 + ph) * (40 + 460 * t)
        half = 10 + 300 * t
        L.append((cx - half, y))
        R.append((cx + half, y))
    s.poly(L + R[::-1], s.tint(s.p["mid"], .86))
    for _ in range(2600):
        k = r.randrange(50)
        t = k / 49
        px = L[k][0] + r.random() * (R[k][0] - L[k][0])
        s.d.line([(px, L[k][1]), (px + 8 + 60 * t, L[k][1])], fill=s.tint(r.choice([(170, 216, 240), (250, 252, 255), (96, 150, 196)])), width=2)
    for _ in range(18):
        P.broadleaf(s, W * r.random(), H * r.uniform(.56, .7), r.uniform(100, 240))


def c10_countryside(s, v):
    s.sky(.42, .55)
    r = s.r
    far_hills(s, .46)
    y = .5
    pal = [(170, 190, 100), (130, 170, 90), (206, 190, 110), (150, 180, 100), (110, 156, 86), (190, 170, 100)]
    for i in range(7):
        col = pal[i % len(pal)]
        field(s, y + i * .075, (col, (col[0] - 26, col[1] - 26, col[2] - 16)), )
        for _ in range(4 + i * 3):
            P.broadleaf(s, W * r.random(), H * (y + i * .075 + r.uniform(.02, .06)), 60 + i * 36)
    for _ in range(4):
        P.cottage(s, W * r.random(), H * r.uniform(.6, .74), r.uniform(150, 280))


def c10_snow(s, v):
    s.sky(.5, .5)
    r = s.r
    s.land(.34, .2, (160, 174, 206), (214, 224, 240), 1.2, rough=.58, tex=.2, snow=True)
    s.land(.56, .06, (214, 224, 240), (232, 238, 246), 1.8, tex=.08)
    for y in sorted(r.uniform(.56, .74) for _ in range(60)):
        P.conifer(s, W * r.random(), H * y, r.uniform(120, 280), col=(50, 86, 92), snow=True)
    s.land(.76, .03, (240, 244, 250), (218, 226, 240), 2, tex=.08)
    for _ in range(4):
        x = W * r.random()
        P.cottage(s, x, H * r.uniform(.74, .82), r.uniform(200, 340), roof=(240, 244, 250))
        s.glow(x + 80, H * .74, 60, (255, 200, 120), .4)
    for y in sorted(r.uniform(.84, 1.06) for _ in range(9)):
        P.conifer(s, r.choice((r.uniform(-.02, .26), r.uniform(.74, 1.02))) * W, H * y, r.uniform(360, 760), col=(44, 80, 84), snow=True)
    for _ in range(1800):
        q = r.uniform(1, 5)
        s.blob(r.uniform(0, W), r.uniform(0, H), q, q, (255, 255, 255))


def c10_valley(s, v):
    s.sun = (W * s.r.uniform(.3, .7), H * .36)
    s.sky(.5, .42)
    s.land(.4, .14, (110, 120, 160), (150, 150, 170), 1.3, rough=.55, tex=.24)
    s.haze(.36, .6, .46)
    s.land(.56, .08, (96, 130, 110), (110, 146, 100), 1.9)
    s.haze(.5, .7, .36)
    _valley(s, .72)
    P.poppy_dabs(s, .74, 1, 1400, [(250, 226, 120), (250, 250, 240), (232, 96, 110)])
    for _ in range(6):
        P.broadleaf(s, W * s.r.random(), H * s.r.uniform(.76, .9), s.r.uniform(260, 460))


def c10_coast(s, v):
    s.sky(.46, .55)
    r = s.r
    s.d.rectangle([0, H * .46, W, H], fill=s.tint((64, 142, 180)))
    for _ in range(9000):
        x, y = r.uniform(0, W), H * (.46 + r.random() ** 1.5 * .54)
        s.d.line([(x, y), (x + r.uniform(16, 90), y)], fill=s.tint(r.choice([(90, 170, 200), (40, 110, 150), (190, 232, 236), (130, 200, 220)])), width=r.choice((2, 3)))
    # a headland filling the left of the frame; final flip varies the side
    def edge(y):
        return W * (.34 + .34 * (y / H - .24) + .03 * math.sin(y * .012))
    for _ in range(5200):
        y = r.uniform(.28, 1.04) * H
        x = r.uniform(-40, edge(y))
        c_ = s.tint(r.choice([(168, 148, 120), (146, 128, 108), (190, 170, 138), (128, 112, 98)]), .72 + (y / H) * .4)
        s.blob(x, y, r.uniform(26, 66), r.uniform(16, 40), c_)
    for y in sorted(r.uniform(.26, .72) for _ in range(46)):
        t = (y - .26) / .46
        x = r.uniform(-30, edge(y * H) - 90)
        P.building(s, x, y * H, 90 + t * 150, 80 + t * 130, col=r.choice([(250, 246, 238), (244, 238, 226), (236, 232, 240)]), dome=r.random() < .22)
    for _ in range(170):
        y = r.uniform(.34, 1.0) * H
        s.blob(r.uniform(-20, edge(y)), y, r.uniform(16, 52), r.uniform(12, 30), s.tint(r.choice([(96, 140, 86), (120, 160, 90), (232, 110, 140), (250, 170, 190)])))
    for _ in range(26):
        x, y = r.uniform(.72, 1) * W, r.uniform(.56, 1) * H
        s.d.line([(x, y), (x + 120, y)], fill=s.tint((252, 252, 250)), width=3)


# subject id, title, scene description (used in the AI prompt), recipe
SUBJECTS = {
    "palm_sunday": [
        ("Triumphal Entry", "Jesus riding a donkey through welcoming crowds toward the city gate", c1_procession),
        ("Waving Palms", "palm branches raised high before the walls of ancient Jerusalem", c1_fronds),
        ("Streets of Jerusalem", "a narrow ancient stone street of sunlit biblical-era houses", c1_street),
        ("The Welcoming Crowd", "crowds of robed villagers greeting Jesus with palms on the road", c1_welcome),
        ("Donkeys on the Road", "gentle donkeys resting beside clay jars on a dusty country lane", c1_donkeys),
        ("Golden Skyline", "a panoramic skyline of domes, towers and city walls", c1_skyline),
        ("Olive Slopes", "silvery olive trees climbing the slopes outside the city", c1_olives),
        ("The Stone Way", "a winding stone pathway between tall palms leading to the city", c1_pathway),
        ("Desert Caravan", "a small caravan among palms and sand-coloured Middle Eastern hills", c1_desert),
        ("Hillside Village", "a biblical-era village of flat-roofed houses among palms", c1_village),
    ],
    "last_supper": [
        ("The Upper Gathering", "a respectful gathering of robed figures at a long table in a stone room", c2_room),
        ("Table of Plenty", "an ancient wooden table laid with bread, grapes, goblets and oil lamps", c2_table),
        ("Breaking of Bread", "rustic loaves and grapes on a linen cloth", c2_bread),
        ("Hall of Lamps", "rows of glowing clay oil lamps along a darkened stone wall", c2_lamps),
        ("Clay Vessels", "shelves of hand-thrown ceramic jars in a warm storeroom", c2_vessels),
        ("Columned Chamber", "a columned upper room set for a shared meal", c2_upper),
        ("Quiet Courtyard", "a sunlit arched courtyard with palms and tall water jars", c2_courtyard),
        ("Ancient Market", "a lively ancient market with striped awnings, bread and fruit", c2_marketplace),
        ("Hearthside", "a glowing hearth in a simple stone home", c2_hearth),
        ("Scrolls by Lamplight", "parchment scrolls and an oil lamp on a wooden desk", c2_scroll),
    ],
    "gethsemane": [
        ("Ancient Olive Grove", "a grove of ancient gnarled olive trees", c3_grove),
        ("Garden Path", "a stone path between olive trees receding into the distance", c3_path),
        ("Moonlit Garden", "an olive garden under a bright moon and deep blue sky", c3_moon),
        ("Terraced Slopes", "stone-walled olive terraces descending a hillside", c3_terrace),
        ("Mount of Olives", "the Mount of Olives with distant city walls and mountains", c3_mount),
        ("Sunrise over the Grove", "a low sun rising behind olive tree silhouettes", c3_sunrise),
        ("A Quiet Prayer", "Jesus kneeling in quiet prayer on a rock under a shaft of light", c3_prayer),
        ("The Oldest Trees", "two monumental olive trees among wildflowers", c3_gnarled),
        ("Garden Gate", "an arched gate in a dry-stone garden wall with wildflowers", c3_wall),
        ("Starry Garden", "olive trees beneath a sweeping band of stars", c3_stars),
    ],
    "passion": [
        ("Cross on the Hill", "a single wooden cross on a quiet hill in a landscape-focused view", c4_hill),
        ("Three Crosses", "three cross silhouettes against a rising sun", c4_three),
        ("Beyond the City", "a distant cross on a hill overlooking Jerusalem", c4_jerusalem),
        ("Dramatic Skies", "towering clouds lit from within above a small far-off cross", c4_sky),
        ("Mountain Vigil", "a cross on a green rise before blue mountains", c4_mountains),
        ("Through Olive Branches", "a cross seen through framing olive branches", c4_branches),
        ("Light through Clouds", "sunbeams pouring through clouds over a quiet hillside", c4_cloud),
        ("Linen and Lilies", "an empty cross draped in white linen among Easter lilies", c4_symbol),
        ("The Long Road", "a stone road through wildflowers to a distant cross", c4_road),
        ("Night Vigil", "crosses on a hill with lamplit vigil above a sleeping city", c4_vigil),
    ],
    "resurrection": [
        ("The Empty Tomb", "an ancient rock-cut tomb with the stone rolled away, surrounded by flowers", c5_tomb),
        ("Sunrise at the Tomb", "the sun rising beyond an open tomb beside an olive tree", c5_sunrise),
        ("Stone Rolled Away", "a huge round stone rolled aside from a dark doorway", c5_stone),
        ("Garden of the Tomb", "a winding path through a garden to a far-off open tomb", c5_garden),
        ("Light from Within", "radiant light streaming out of an open tomb", c5_light),
        ("Angel at the Tomb", "a radiant angel standing beside the open tomb", c5_angels),
        ("White Lilies", "a sweeping foreground of white Easter lilies near the tomb", c5_lilies),
        ("Blooming Morning", "blossom trees and spring flowers in a resurrection garden", c5_bloom),
        ("He Is Risen", "the risen Jesus in white robes radiating soft light in a garden", c5_risen),
        ("Hopeful Horizon", "a hopeful path through green valleys with a single dove", c5_hope),
    ],
    "angels": [
        ("Messenger of Light", "a majestic angel with vast white wings among clouds", c6_angel),
        ("Heavenly Rays", "a burst of heavenly light above layered hills", c6_light),
        ("Flight of Doves", "white doves wheeling through a bright sky over a meadow", c6_doves),
        ("Descending Dove", "a white dove descending in a shaft of light over a village", c6_spirit),
        ("Celestial City", "a shining white domed city above a sea of clouds", c6_celestial),
        ("Glowing Horizon", "a glowing horizon mirrored in still water with distant doves", c6_horizon),
        ("Signs of Peace", "flowers, lamps and a white dove in a symbolic composition", c6_symbol),
        ("Holy Mountain", "a snow-topped mountain under parting clouds and doves", c6_mountain),
        ("The Bright Star", "one brilliant star in a nebula sky above dark pines", c6_stars),
        ("Spirit of the Lake", "a mirror lake with doves and framing pines", c6_landscape),
    ],
    "spring": [
        ("Spring Garden", "a winding path through a blossoming spring garden", c7_garden),
        ("Easter Sunrise", "a sunrise over dew-lit fields of small flowers", c7_sunrise),
        ("Easter Lilies", "a dense field of large white Easter lilies", c7_lilies),
        ("Tulip Rows", "striped rows of tulips converging on the horizon", c7_tulips),
        ("Daffodil Bank", "a bank of golden daffodils beneath young trees", c7_daffodils),
        ("Butterfly Meadow", "colourful butterflies over a flowering meadow", c7_butterflies),
        ("Songbirds in Blossom", "songbirds perched in a great pink blossom tree", c7_birds),
        ("Green Meadow", "a lush green meadow sprinkled with wildflowers", c7_meadow),
        ("Spring Cottage", "a cottage with a flower-filled front garden", c7_cottage),
        ("Flower-Lined Path", "a stone path lined with tulips and daffodils under blossom", c7_path),
    ],
    "nature": [
        ("Lambs in the Meadow", "a small flock of lambs grazing in a flowering meadow", c8_lambs),
        ("Spring Lamb", "one fluffy lamb close up among wildflowers", c8_onelamb),
        ("Rabbits at Play", "soft rabbits among flowers on a green slope", c8_rabbits),
        ("Baby Birds", "three yellow chicks in a twig nest on a branch", c8_birds),
        ("Lily Close-Up", "large detailed lily blooms filling the view", c8_lilies),
        ("Spring Arrangement", "elegant vases of spring flowers on a linen table", c8_arrange),
        ("Rolling Green Hills", "layered green hills dotted with trees and sheep", c8_hills),
        ("Painted Wings", "large butterflies over a mixed bed of flowers", c8_butter),
        ("Flower Garden", "a riotous flower garden with no bare ground", c8_flowers),
        ("Meadow Stream", "a sparkling stream with lambs on its flowery banks", c8_stream),
    ],
    "easter": [
        ("Egg Hunt", "dozens of ornately patterned eggs hidden in thick grass", c9_eggs),
        ("Easter Basket", "a large woven basket overflowing with patterned eggs", c9_basket),
        ("Garden Feast", "an outdoor festive table with cake, baskets and bunting", c9_table),
        ("Easter Cakes", "three decorated tiered cakes on a pastel table", c9_cakes),
        ("Festive Room", "a sunlit room hung with bunting and baskets", c9_decor),
        ("Colorful Village", "a pastel village street decked with bunting", c9_village),
        ("Family Garden", "families in pastel clothes hunting eggs in a garden", c9_family),
        ("Painting Eggs", "a white table covered with eggs and pots of colour", c9_painting),
        ("Table of Blooms", "a row of bouquets along a garden table", c9_bouquets),
        ("Evening Lanterns", "paper lanterns and bunting glowing over a village green", c9_lanterns),
    ],
    "landscapes": [
        ("Alpine Peaks", "snow-capped alpine peaks above pine forest", c10_mountains),
        ("Mirror Lake", "a still mountain lake reflecting peaks and pines", c10_lake),
        ("Hidden Waterfall", "a broad waterfall between moss-covered cliffs", c10_waterfall),
        ("Deep Forest", "sunbeams through a deep layered conifer forest", c10_forest),
        ("Lakeside Sunset", "a blazing sunset reflected over a dark forest lake", c10_sunset),
        ("Palm Beach", "a sandy beach with palms and bright surf", c10_beach),
        ("Endless Blooms", "vast rows of flowers running to the horizon", c10_fields),
        ("Mountain Village", "a dense alpine village of cottages", c10_village),
        ("Hilltop Castle", "a many-towered castle on a green rise", c10_castle),
        ("Formal Gardens", "formal parterre gardens before a pale villa", c10_gardens),
        ("Winding River", "a river meandering through green valleys", c10_river),
        ("Patchwork Countryside", "patchwork fields, hedgerows and farmsteads", c10_countryside),
        ("Snowy Hamlet", "a snowy hamlet among frosted pines", c10_snow),
        ("Sunrise Valley", "misty layered valleys at first light", c10_valley),
        ("Whitewashed Coast", "a rocky coast crowned with whitewashed houses", c10_coast),
    ],
}
