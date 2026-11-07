# -*- coding: utf-8 -*-
import re,io
base=r"D:\gameProject\FVM-Reborn-mod"
src=io.open(base+r"\scripts\gacha_random_card\gacha_random_card.gml",encoding="utf-8").read()
def grab(key):
    seg=src[src.index("var %s = ["%key):]; seg=seg[:seg.index("];")]
    return re.findall(r'"([a-z0-9_]+)"',seg)
NORMAL=set(grab("_normal")); MAPONLY=set(grab("_map_only"))

def reg(fn):
    t=io.open(base+fn,encoding="utf-8").read()
    out={}
    for m in re.finditer(r'register_card\(\s*"([a-z0-9_]+)"\s*,\s*([A-Za-z0-9_]+)\s*,\s*\[',t):
        cid=m.group(1); start=m.end()-1; d=0
        for j in range(start,len(t)):
            if t[j]=="[": d+=1
            elif t[j]=="]":
                d-=1
                if d==0: break
        seg=t[start:j+1]
        out[cid]=dict(gold=bool(re.search(r'is_gold["]?\s*:\s*1',seg)), fusion=bool(re.search(r'is_fusion["]?\s*:\s*1',seg)))
    return out
allc={}; allc.update(reg(r"\scripts\slots_init\slots_init.gml")); allc.update(reg(r"\scripts\mod_slots_init\mod_slots_init.gml"))
print("deck 卡数 %d"%len(allc))
zod=[];nor=[];gold=[];fus=[];mapo=[]
for cid,v in sorted(allc.items()):
    if v["gold"]: gold.append(cid)
    elif v["fusion"]: fus.append(cid)
    elif cid in MAPONLY: mapo.append(cid)
    elif cid in NORMAL: nor.append(cid)
    else: zod.append(cid)
print("金卡 %d / 融合 %d / 地图解锁 %d / 普通 %d / 生肖 %d  合计 %d"%(
    len(gold),len(fus),len(mapo),len(nor),len(zod),len(gold)+len(fus)+len(mapo)+len(nor)+len(zod)))
print("\n自动落入生肖池(非用户名单)的卡 %d 张:"%len([c for c in zod if c not in ("lihe",)]))
print("  "+" ".join(zod))
docz=set(re.findall(r'^\|\s*`([a-z0-9_]+)`',io.open(base+r"\docs\抽卡概率与卡池总表.md",encoding="utf-8").read()[io.open(base+r"\docs\抽卡概率与卡池总表.md",encoding="utf-8").read().index("### 2.4"):io.open(base+r"\docs\抽卡概率与卡池总表.md",encoding="utf-8").read().index("### 2.5")],re.M))
print("\n文档生肖 68 张中，实现里不是生肖的: %s"%(sorted(docz-set(zod)) or "无"))
print("实现里生肖但文档没列的: %s"%(sorted(set(zod)-docz) or "无"))
