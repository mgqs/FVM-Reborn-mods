# -*- coding: utf-8 -*-
"""把工程精灵逐帧与 SWF 导出的精灵帧做匹配，输出「工程帧 -> SWF帧」映射。
用法: python tools/swf_match.py <sprite名> <swf目录>/<DefineSprite_xxx>
"""
import sys, os, re, json, glob
from PIL import Image

def load_yy(p):
    s = open(p, encoding='utf-8-sig').read()
    s = re.sub(r',(\s*[}\]])', r'\1', s)
    return json.loads(s)

def norm(p, size=(64, 64)):
    im = Image.open(p).convert('RGBA')
    bb = im.getbbox()
    if bb:
        im = im.crop(bb)
    im = im.resize(size, Image.BILINEAR)
    return im, bb, Image.open(p).size

def dist(a, b):
    pa, pb = a.load(), b.load()
    w, h = a.size
    s = 0
    n = 0
    for y in range(0, h, 2):
        for x in range(0, w, 2):
            ra, ga, ba, aa = pa[x, y]
            rb, gb, bb2, ab = pb[x, y]
            s += abs(ra - rb) + abs(ga - gb) + abs(ba - bb2) + abs(aa - ab)
            n += 1
    return s / (n * 4.0)

def main(sprite, swfdir):
    yy = f'sprites/{sprite}/{sprite}.yy'
    y = load_yy(yy)
    frames = [f['name'] for f in y.get('frames', [])]
    proj = [norm(f'sprites/{sprite}/{f}.png') for f in frames]
    swf_files = sorted(glob.glob(os.path.join(swfdir, '*.png')),
                       key=lambda p: int(re.sub(r'\D', '', os.path.basename(p)) or 0))
    swf = [norm(p) for p in swf_files]
    print(f'{sprite}: 工程 {len(proj)} 帧, SWF {len(swf)} 帧  ({os.path.basename(swfdir)})')
    print(f'  工程画布 {proj[0][2]}  SWF画布 {swf[0][2] if swf else None}')
    for i, (im, bb, sz) in enumerate(proj):
        best = sorted(((dist(im, s[0]), j) for j, s in enumerate(swf)))[:2]
        d0, j0 = best[0]
        d1, j1 = best[1] if len(best) > 1 else (999, -1)
        flag = '' if d0 < 6 else ('  <<模糊' if d0 < 15 else '  <<无匹配')
        print(f'  proj f{i:<3d} -> swf #{j0+1:<3d} d={d0:6.2f}  (次优 #{j1+1} d={d1:6.2f}){flag}')

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
