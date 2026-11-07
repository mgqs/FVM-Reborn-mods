# -*- coding: utf-8 -*-
import os,re
root=r"D:\gameProject\FVM-Reborn-mod\objects"
hits=[]
for dp,dn,fn in os.walk(root):
    for f in fn:
        if not f.endswith(".gml"): continue
        p=os.path.join(dp,f)
        try: lines=open(p,encoding="utf-8",errors="replace").read().split("\n")
        except: continue
        # 找 with (obj_enemy_...) 起始行，用括号深度跟踪块范围
        i=0
        while i<len(lines):
            L=lines[i]
            if re.search(r"with\s*\(\s*obj_enemy", L) or re.search(r"with\s*\(\s*other\s*\)", L):
                # 从该行开始，找到块结束（大括号平衡，或缩进回归）
                depth=0; started=False; j=i
                while j<len(lines):
                    for ch in lines[j]:
                        if ch=="{": depth+=1; started=True
                        elif ch=="}": depth-=1
                    if started and depth<=0: break
                    if not started and j>i: break
                    j+=1
                block="\n".join(lines[i:j+1])
                # 在块内找裸 shape（前面不是 . 或字母）
                for k,bl in enumerate(lines[i:j+1], start=i+1):
                    for m in re.finditer(r"(?<![\.\w])(shape)\s*(>=|==|<=|>|<)", bl):
                        hits.append((p.replace(root,"objects"), k, bl.strip()))
                i=j+1
                continue
            i+=1
print("==== with(obj_enemy_*) 块内裸引用 shape 的行 ====")
seen=set()
for p,k,bl in hits:
    key=(p,k)
    if key in seen: continue
    seen.add(key)
    print(f"{p}:{k}  {bl}")
print("总计", len(seen), "处")
