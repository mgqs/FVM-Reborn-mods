import glob, json, re, sys
sys.path.insert(0, "tools")
import cross_bg_align as C
bad = 0
for p in sorted(glob.glob("datafiles/level_data/cross/*.json")):
    s = open(p, encoding="utf-8-sig").read().replace("\x00","")
    s2 = re.sub(r",(\s*[}\]])", r"\1", s)
    try:
        d = json.loads(s2)
    except Exception as e:
        print("PARSE FAIL", p, e); bad += 1; continue
    bg = d.get("bg_draw")
    if bg is None: print("NO BG", p); bad += 1; continue
    fam = C.family_of(d["map_sprite"])
    seam_screen_x = bg["x"] + fam["seam_x"] * bg["sx"]
    seam_screen_y = bg["y"] + fam["seam_y"] * bg["sy"]
    ex = 698 + 107 * round((seam_screen_x - 698) / 107)
    ey = 199 + 116 * round((seam_screen_y - 199) / 116)
    dx, dy = seam_screen_x - ex, seam_screen_y - ey
    pitch_x = fam["px"] * bg["sx"] - 107
    pitch_y = fam["py"] * bg["sy"] - 116
    artw = C._art_size(fam["sprites"][0])[0] * bg["sx"]
    arth = C._art_size(fam["sprites"][0])[1] * bg["sy"]
    gapx = max(0, -bg["x"]) + max(0, bg["x"] + artw - 1920)
    gapy = max(0, -bg["y"]) + max(0, bg["y"] + arth - 1080)
    flag = "" if abs(dx) < 1 and abs(dy) < 1 and abs(pitch_x) < 0.05 and abs(pitch_y) < 0.05 and gapx <= 1 and gapy <= 1 else "  <-- CHECK"
    if flag: bad += 1
    n_lava = sum(1 for row in d["map"] for c in row if "lava" in (c.get("object") or []))
    print("%-20s seam=(%7.2f,%7.2f) d=(%+.2f,%+.2f) dpitch=(%+.3f,%+.3f) gap=(%.1f,%.1f) lava=%d%s"
          % (p.split("\\")[-1], seam_screen_x, seam_screen_y, dx, dy, pitch_x, pitch_y, gapx, gapy, n_lava, flag))
print("problems:", bad)
