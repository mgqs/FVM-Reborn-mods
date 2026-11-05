import zlib,struct,json
res={}
for name in ["特种装甲僵尸鼠","熊猫僵尸鼠","摔跤手僵尸鼠"]:
    p=r"C:\Users\18203\Desktop\跨服\SWF\%s.swf"%name
    d=open(p,"rb").read()
    body=zlib.decompress(d[8:]) if d[:3]==b"CWS" else d[8:]
    nbits=body[0]>>3; rectlen=((5+nbits*4)+7)//8
    pos=rectlen+4
    def rd(buf,start,end):
        out=[];q=start
        while q+2<=end:
            cl=struct.unpack_from("<H",buf,q)[0];q+=2
            code=cl>>6;ln=cl&0x3f
            if ln==0x3f: ln=struct.unpack_from("<I",buf,q)[0];q+=4
            out.append((code,q,ln));q+=ln
        return out
    info=[]
    for code,off,ln in rd(body,pos,len(body)):
        if code!=39: continue
        sid=struct.unpack_from("<H",body,off)[0]
        fc=struct.unpack_from("<H",body,off+2)[0]
        sub=rd(body,off+4,off+ln)
        frame=1;labels=[]
        for c2,o2,l2 in sub:
            if c2==1: frame+=1
            elif c2 in (41,43):
                s=body[o2:o2+l2].split(b"\x00")[0]
                try: t=s.decode("utf-8")
                except: t=s.decode("gb18030","replace")
                labels.append([frame,t])
        info.append({"sid":sid,"frames":fc,"labels":labels})
    res[name]=info
open(r"D:\gameProject\FVM-Reborn-mod\tools\_swf_labels.json","w",encoding="utf-8").write(json.dumps(res,ensure_ascii=False,indent=1))
print("ok")
