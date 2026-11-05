# -*- coding: utf-8 -*-
import os,shutil,json,re
PROJ=r"D:\gameProject\FVM-Reborn-mod"
SRC={
 "spr_kuafu_armour": (r"C:\Users\18203\Desktop\跨服\精灵\特种装甲僵尸鼠\sprites", "DefineSprite_79"),
 "spr_kuafu_panda":  (r"C:\Users\18203\Desktop\跨服\精灵\熊猫僵尸鼠\sprites",   "DefineSprite_78"),
 "spr_kuafu_wrestler":(r"C:\Users\18203\Desktop\跨服\精灵\摔跤手僵尸鼠\sprites",  "DefineSprite_77"),
}
# 主序列 100 帧映射：目标index区间 <- 源帧号区间(1-based, 含)
MAIN=[(0,20,1,21),(21,41,20,40),(42,59,83,100),(60,77,101,118),(78,99,183,204)]
THROW=[(0,13,155,168),(14,27,169,182)]

def src_dir(root,pref):
    for d in os.listdir(root):
        if d.startswith(pref):
            return os.path.join(root,d)
    raise SystemExit("no src "+pref)

def frames_of(spr):
    d=os.path.join(PROJ,"sprites",spr)
    yy=[f for f in os.listdir(d) if f.endswith(".yy")][0]
    raw=open(os.path.join(d,yy),encoding="utf-8-sig").read()
    raw=re.sub(r",(\s*[}\]])",r"\1",raw)
    j=json.loads(raw)
    return d,[f["name"] for f in j["frames"]],j

plan=[]
for spr,(root,pref) in SRC.items():
    sd=src_dir(root,pref)
    plan.append((spr,sd))
    plan.append((spr+"_throw",sd))

# 先备份
bak=os.path.join(PROJ,".workbuddy","backup","kuafu_fix_20261105")
os.makedirs(bak,exist_ok=True)
for spr,_ in plan:
    d=os.path.join(PROJ,"sprites",spr)
    tgt=os.path.join(bak,spr)
    if os.path.isdir(tgt): shutil.rmtree(tgt)
    shutil.copytree(d,tgt)
print("backup ->",bak)

report=[]
for spr,sd in plan:
    d,ids,j=frames_of(spr)
    n=len(ids)
    mapping = MAIN if not spr.endswith("_throw") else THROW
    # 建立 目标模板 index -> 源帧路径
    idx2src={}
    for a,b,c,e in mapping:
        for k in range(b-a+1):
            idx2src[a+k]=os.path.join(sd,"%d.png"%(c+k))
    missing=[i for i in range(n) if i not in idx2src]
    done=0
    for i in range(n):
        sp=idx2src.get(i)
        if not sp or not os.path.isfile(sp): continue
        fdir=os.path.join(d,"layers",ids[i])
        if not os.path.isdir(fdir):
            os.makedirs(fdir)
        pngs=sorted([x for x in os.listdir(fdir) if x.endswith(".png")])
        target=os.path.join(fdir,pngs[0]) if pngs else os.path.join(fdir,ids[i]+".png")
        shutil.copyfile(sp,target)
        done+=1
    report.append((spr,n,done,len(missing)))

print("%-26s %-6s %-6s %s"%("sprite","frames","done","unmapped"))
for r in report: print("%-26s %-6d %-6d %d"%r)
