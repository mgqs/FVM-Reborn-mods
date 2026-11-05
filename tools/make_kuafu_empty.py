# -*- coding: utf-8 -*-
import json,re,os,shutil,uuid
ROOT=r"D:\gameProject\FVM-Reborn-mod"
SRCROOT={
 "spr_kuafu_armour": (r"C:\Users\18203\Desktop\跨服\精灵\特种装甲僵尸鼠\sprites","DefineSprite_79"),
 "spr_kuafu_panda":  (r"C:\Users\18203\Desktop\跨服\精灵\熊猫僵尸鼠\sprites","DefineSprite_78"),
 "spr_kuafu_wrestler": (r"C:\Users\18203\Desktop\跨服\精灵\摔跤手僵尸鼠\sprites","DefineSprite_77"),
}
EMPTY=[(0,20,41,61),(21,41,62,82),(42,59,119,136),(60,77,137,154),(78,99,183,204)]
def src_dir(a,b):
    for x in os.listdir(a):
        if x.startswith(b): return os.path.join(a,x)
    raise SystemExit("missing %s in %s"%(b,a))
def load_yy(p):
    return json.loads(re.sub(r",(\s*[}\]])",r"\1",open(p,encoding="utf-8-sig").read()))
def mk_empty(base):
    newspr=base+"_empty"
    srcd=os.path.join(ROOT,"sprites",base); dstd=os.path.join(ROOT,"sprites",newspr)
    j=load_yy(os.path.join(srcd,base+".yy"))
    if os.path.isdir(dstd): shutil.rmtree(dstd)
    os.makedirs(os.path.join(dstd,"layers"))
    guidmap={fr["name"]:str(uuid.uuid4()) for fr in j["frames"]}
    newlayer=str(uuid.uuid4())
    for fr in j["frames"]:
        new=guidmap[fr["name"]]; fr["name"]=new; fr["%Name"]=new
        os.makedirs(os.path.join(dstd,"layers",new),exist_ok=True)
    j["layers"][0]["name"]=newlayer; j["layers"][0]["%Name"]=newlayer
    j["sequence"]["name"]=newspr; j["sequence"]["%Name"]=newspr
    for kf in j["sequence"]["tracks"][0]["keyframes"]["Keyframes"]:
        kf["id"]=str(uuid.uuid4())
        ch=kf["Channels"]["0"]
        ch["Id"]["name"]=guidmap.get(ch["Id"]["name"],ch["Id"]["name"])
        ch["Id"]["path"]="sprites/%s/%s.yy"%(newspr,newspr)
    j["name"]=newspr; j["%Name"]=newspr
    sd=src_dir(*SRCROOT[base])
    idx2src={}
    for a,b,c,e in EMPTY:
        for k in range(b-a+1): idx2src[a+k]=c+k
    for i in range(len(j["frames"])):
        shutil.copyfile(os.path.join(sd,"%d.png"%idx2src[i]),
                        os.path.join(dstd,"layers",j["frames"][i]["name"],newlayer+".png"))
    open(os.path.join(dstd,newspr+".yy"),"w",encoding="utf-8").write(json.dumps(j,ensure_ascii=False,indent=1))
    return newspr
for base in SRCROOT:
    print("created",mk_empty(base))
