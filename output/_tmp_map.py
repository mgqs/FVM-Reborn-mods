import json, re
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
d=load("datafiles/level_data/cross/zhuore_0.json")
print(list(d.keys()))
m=d.get("map")
print("map type", type(m), "len", len(m) if m else None)
if isinstance(m,list):
    for row in m:
        print(row if not isinstance(row,list) else "".join(str(c) for c in row))
