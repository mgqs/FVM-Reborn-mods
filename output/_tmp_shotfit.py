import numpy as np
from PIL import Image
im = Image.open(r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3").convert("RGB")
a = np.asarray(im).astype(np.float32)
H,W,_ = a.shape
def comb(region, lo, hi):
    x0,y0,x1,y1 = region
    g = a[y0:y1, x0:x1].mean(axis=2)
    gx = np.abs(np.diff(g, axis=1)).mean(axis=0)
    gy = np.abs(np.diff(g, axis=0)).mean(axis=1)
    def best(prof):
        n=len(prof); b=(-1e9,None,None)
        for p in np.arange(lo, hi+1e-9, 0.25):
            for ph in np.arange(0.0, p, 0.5):
                idx=np.arange(ph, n-1, p)
                if len(idx)<4: continue
                on=np.clip(np.round(idx).astype(int),0,n-2)
                mid=np.clip(np.round(idx+p*0.5).astype(int),0,n-2)
                sc=prof[on].mean()-prof[mid].mean()
                if sc>b[0]: b=(sc,float(p),float(ph))
        return b
    return best(gx), best(gy)
for reg,label in [((250,0,446,375),"right area"),((0,0,446,20),"top strip")]:
    bx,by = comb(reg, 40, 140)
    print(label, "pitchX=%.2f ph=%.2f sc=%.2f | pitchY=%.2f ph=%.2f sc=%.2f"%(bx[1],bx[2],bx[0],by[1],by[2],by[0]))
# card centers: threshold bright yellow/purple cards
g = a.mean(axis=2)
# find columns with high saturation brightness (cards) in left 210 px
mask = (a.max(axis=2) > 120) & ((a.max(axis=2)-a.min(axis=2)) > 40)
prof = mask[:, 0:210].sum(axis=0)
peaks=[]
for i in range(2, len(prof)-2):
    if prof[i]==prof[i-2:i+3].max() and prof[i] > prof.mean()*1.4:
        if not peaks or i-peaks[-1]>12: peaks.append(i)
        elif prof[i]>prof[peaks[-1]]: peaks[-1]=i
print("card column centers:", peaks, "diffs:", np.diff(peaks).tolist())
profy = mask[:, 0:210].sum(axis=1)
peaksy=[]
for i in range(2, len(profy)-2):
    if profy[i]==profy[i-2:i+3].max() and profy[i] > profy.mean()*1.2:
        if not peaksy or i-peaksy[-1]>12: peaksy.append(i)
        elif profy[i]>profy[peaksy[-1]]: peaksy[-1]=i
print("card row centers:", peaksy, "diffs:", np.diff(peaksy).tolist())
