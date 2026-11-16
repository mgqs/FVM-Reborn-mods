# -*- coding: utf-8 -*-
"""工程精灵帧 -> SWF 帧  单调对齐（DP），用于判定切帧是否连续、是否重复、是否有缺口。
用法: python tools/swf_align.py <sprite名> <swf精灵目录>
"""
import sys, os, re, json, glob, hashlib
from PIL import Image

def load_yy(p):
    s = open(p, encoding='utf-8-sig').read()
    s = re.sub(r',(\s*[}\]])', r'\1', s)
    return json.loads(s)

def thumb(p, size=(48, 48)):
    im = Image.open(p).convert('RGBA')
    bb = im.getbbox()
    if bb:
        im = im.crop(bb)
    return im.resize(size, Image.BILINEAR).tobytes()

def cost(a, b):
    return sum(abs(x - y) for x, y in zip(a, b)) / len(a)

def main(sprite, swfdir):
    yy = f'sprites/{sprite}/{sprite}.yy'
    y = load_yy(yy)
    frames = [f['name'] for f in y.get('frames', [])]
    P = [thumb(f'sprites/{sprite}/{f}.png') for f in frames]
    flu = sorted(glob.glob(os.path.join(swfdir, '*.png')),
                 key=lambda p: int(re.sub(r'\D', '', os.path.basename(p)) or 0))
    S = [thumb(p) for p in flu]
    n, m = len(P), len(S)
    INF = 1e18
    # dp[i][j]: 前 i 个工程帧对齐到 SWF 前 j 帧（严格递增，允许跳 SWF 帧）
    dp = [[INF] * (m + 1) for _ in range(n + 1)]
    bk = [[None] * (m + 1) for _ in range(n + 1)]
    for j in range(m + 1):
        dp[0][j] = 0
    for i in range(1, n + 1):
        for j in range(1, m + 1):
            c = cost(P[i - 1], S[j - 1])
            best, arg = dp[i - 1][j - 1] + c, 'diag'
            if dp[i][j - 1] < best + 0:  # 跳过 SWF 帧（不消耗工程帧）
                pass
            # 跳过 SWF 帧 j
            if dp[i][j - 1] < best:
                best, arg = dp[i][j - 1], 'skip'
            dp[i][j] = best
            bk[i][j] = arg
    print(f'{sprite}: 工程 {n} 帧, SWF {m} 帧 -> 对齐代价 {dp[n][m] / n:.2f}/帧')
    # 回溯
    i, j = n, m
    seq = []
    while i > 0:
        if bk[i][j] == 'skip':
            j -= 1
        else:
            seq.append((i - 1, j - 1))
            i -= 1
            j -= 1
    seq.reverse()
    print(f'  {"工程帧":<8}{"SWF帧(1基)":<12}单帧代价')
    for pi, sj in seq:
        print(f'  f{pi:<7}#{sj+1:<11}{cost(P[pi], S[sj]):.2f}')

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
