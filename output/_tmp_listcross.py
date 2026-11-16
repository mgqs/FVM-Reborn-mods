import os, glob, json, re
rows=[]
for f in sorted(glob.glob("datafiles/level_data/cross/*.json")):
    s = open(f, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    d = json.loads(s)
    bd = d.get("bg_draw")
    rows.append((os.path.basename(f), d.get("map_sprite"), d.get("map_cols"), d.get("map_rows"), "bg" if bd else "-", bd and (bd["x"],bd["y"],bd["sx"],bd["sy"]) or None))
for r in rows: print(r)
print("count", len(rows))
print("sprites used:", sorted(set(r[1] for r in rows)))
