import json,re,glob
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    return json.loads(re.sub(r",(\s*[}\]])",r"\1",s))
for f in ["shuihuo_0","shuihuo_4","zhuore_0","wudu_0","nightmare_sky_0","castle-0"]:
    p="datafiles/level_data/cross/%s.json"%f
    d=load(p)
    types=[row[1]["type"] for row in d["map"]]
    print(f, "row types:", types)
    for r,row in enumerate(d["map"]):
        print("   ", r, "".join("#" if "lava" in (c.get("object") or []) else ("O" if c.get("object") else ("~" if c["type"]!="normal" else ".")) for c in row), [c["type"] for c in row])
