import numpy as np
from PIL import Image
shot = Image.open(r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3").convert("RGB")
a = np.asarray(shot).astype(np.float32)
g = a.mean(axis=2)
gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
def comb(profile, p_lo, p_hi, p_step=0.5, ph_step=0.5):
    n=len(profile); best=(-1e9,None,None)
    p=p_lo
    while p<=p_hi:
        ph=0.0
        while ph<p:
            idx=np.arange(ph, n-1, p)
            if len(idx)>=5:
                on=np.clip(np.round(idx).astype(int),0,n-2)
                mid=np.clip(np.round(idx+p*0.5).astype(int),0,n-2)
                sc=profile[on].mean()-profile[mid].mean()
                if sc>best[0]: best=(sc,float(p),float(ph))
            ph+=ph_step
        p+=p_step
    return best
bx=comb(gx, 60, 130, 0.5, 0.5)
by=comb(gy, 60, 140, 0.5, 0.5)
print("shot %dx%d"%(shot.width, shot.height))
print("pitchX=%.2f phaseX=%.2f score=%.2f"%(bx[1],bx[2],bx[0]))
print("pitchY=%.2f phaseY=%.2f score=%.2f"%(by[1],by[2],by[0]))
print("if pitchX=107 -> scale %.3f ; pitchY=116 -> scale %.3f"%(bx[1]/107.0, by[1]/116.0))
