import glob, re
for p in sorted(glob.glob("datafiles/level_data/cross/castle-*.json")):
    s = open(p, encoding="utf-8-sig").read()
    bom = s.startswith("\ufeff"); b = s.lstrip("\ufeff")
    b2 = re.sub(r'(?m)^  ("bg_draw")', r'    \1', b)
    if b2 != b:
        open(p, "w", encoding="utf-8-sig" if bom else "utf-8", newline="\n").write(b2)
print("reindented")
