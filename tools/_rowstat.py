# -*- coding: utf-8 -*-
import io,os,json,glob
root=r"D:\gameProject\FVM-Reborn-mod\datafiles\level_data"
rows={}
def scan(p):
    try:
        t=io.open(p,encoding="utf-8").read().rstrip("\x00").strip()
        d=json.loads(t)
    except Exception as e:
        return None
    best=0; bestinfo=None; over9=0; total=0
    for wi,w in enumerate(d.get("waves",[]) or []):
        for si,s in enumerate(w.get("subwaves",[]) or []):
            cnt={}
            for e in (s.get("enemy_list") or []):
                if not e.get("type"): continue
                r=e.get("row",0)
                cnt[r]=cnt.get(r,0)+1
                total+=1
            if cnt:
                mr=max(cnt.values())
                if mr>best: best=mr; bestinfo=(wi,si,dict(cnt))
                if mr>1: over9+=1
    return best,bestinfo,over9,total
out=[]
for p in glob.glob(root+r"\**\*.json",recursive=True):
    r=scan(p)
    if r: out.append((os.path.basename(p),)+r)
out.sort(key=lambda x:-x[1])
print("=== 单个 subwave 同行最多（top 15）===")
for n,b,info,o,t in out[:15]:
    print("%-34s max同行=%-3d subwave数(同行>1)=%-4d 总怪=%d" % (n,b,o,t))
print("\n=== 同行>1 的 subwave 总数 / 关卡数 ===")
print("有同行堆叠的关卡数:", sum(1 for x in out if x[3]>0), "/", len(out))
import statistics
print("max同行 中位数:", statistics.median([x[1] for x in out]), " 平均:", round(statistics.mean([x[1] for x in out]),2))
print("max同行 >= 5 的关卡数:", sum(1 for x in out if x[1]>=5))
