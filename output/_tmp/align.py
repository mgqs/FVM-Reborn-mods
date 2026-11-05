import sys; sys.path.insert(0,'tools')
import zhuore_build as B, zhuore_spec as S
from PIL import Image
import numpy as np

def sig(im, n=40):
    im = im.convert('RGBA').resize((n, n), Image.LANCZOS)
    a = np.asarray(im, dtype=np.float32)
    rgb = a[..., :3] / 255.0
    al = a[..., 3:] / 255.0
    return np.concatenate([rgb * al, al], axis=2).reshape(-1)

def align(key, spr, n):
    m = [x for x in S.MICE if x['key'] == key][0]
    srcs = B.src_frames(m)
    O = [sig(B.frame_image(spr, i)) for i in range(n)]
    Sp = [sig(Image.open(p)) for p in srcs]
    M = np.stack([np.stack([np.abs(o - s).mean() for s in Sp]) for o in O])
    best = M.argmin(1)
    print('==', spr, 'orig', n, 'src', len(srcs))
    prev = -1; segs = []
    for i, b in enumerate(best):
        if b != prev:
            segs.append((i, int(b)))
            prev = b
    out = []
    for j, (oi, si) in enumerate(segs):
        eo = segs[j+1][0] if j+1 < len(segs) else n
        es = segs[j+1][1] if j+1 < len(segs) else best[-1]+1
        out.append('orig %d..%d -> src %d..%d' % (oi, eo-1, si, es-1))
    print('\n'.join(out))

align('warrior_minion', 'spr_warrior_minion_mouse', 95)
