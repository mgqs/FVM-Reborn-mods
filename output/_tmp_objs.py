import glob, os, json, re, collections
def load(p):
    s=open(p,encoding="utf-8-sig").read().replace("\x00","")
    s=re.sub(r",(\s*[}\]])",r"\1",s)
    return json.loads(s)
for f in sorted(glob.glob("datafiles/level_data/cross/*.json")):
    d=load(f)
    objs=collections.Counter()
    for row in d["map"]:
        for c in row:
            for o in (c.get("object") or []): objs[o]+=1
    print(os.path.basename(f), dict(objs))
