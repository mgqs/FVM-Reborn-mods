# -*- coding: utf-8 -*-
"""检查对象 Step 里硬编码的取模常量是否超出精灵帧数。

背景：这些 BOSS 的动画都用「正常段 + 受伤段」两半切帧，代码写成

    image_index = floor(timer/5) mod N          // 正常段，用到 0 .. N-1
    image_index = floor(timer/5) mod N + N      // 受伤段，用到 N .. 2N-1

所以：同一行出现 `+ N` 的，要求 2N <= 精灵帧数；只出现 `mod N` 的，要求 N <= 帧数。
照抄原版常量（原版精灵帧数不同）就会越界，表现为某一半动画闪成空帧或定帧。

用法：
    python tools/check_frame_range.py <对象名> [<对象名> ...]
    python tools/check_frame_range.py --all        # objects/obj_infected_* 全扫

退出码：0 全部通过；2 有越界。
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_yy(path):
    s = open(path, encoding='utf-8-sig').read()
    s = re.sub(r',(\s*[}\]])', r'\1', s)
    return json.loads(s)


def sprite_frames(name):
    p = os.path.join(ROOT, 'sprites', name, name + '.yy')
    if not os.path.exists(p):
        return None
    return len(load_yy(p).get('frames', []))


def create_spr_list(obj):
    """读 Create_0 里的 spr_list = [a,b,c...]（按下标）。"""
    p = os.path.join(ROOT, 'objects', obj, 'Create_0.gml')
    if not os.path.exists(p):
        return {}
    txt = open(p, encoding='utf-8').read()
    m = re.search(r'spr_list\s*=\s*\[([^\]]+)\]', txt)
    if not m:
        return {}
    names = [x.strip() for x in m.group(1).split(',') if x.strip()]
    return {i: n for i, n in enumerate(names)}


SPR_RE = re.compile(r'sprite_index\s*=\s*(?:spr_list\[(\d+)\]|(spr_\w+))')
MOD_RE = re.compile(r'(?:mod|%)\s*(\d+)')
HALF_RE = re.compile(r'\+\s*(\d+)\s*$')


def scan(obj):
    sp = os.path.join(ROOT, 'objects', obj, 'Step_0.gml')
    if not os.path.exists(sp):
        return []
    lines = open(sp, encoding='utf-8').read().splitlines()
    lst = create_spr_list(obj)

    # 代码里 spr_list 会在 Step 里按 shape 被重新赋值，两套写法都解析
    for i, line in enumerate(lines, 1):
        m = re.search(r'spr_list\s*=\s*\[([^\]]+)\]', line)
        if m:
            names = [x.strip() for x in m.group(1).split(',') if x.strip()]
            lst = {k: n for k, n in enumerate(names)}

    cur, cur_line = None, 0
    rows, problems = [], []
    for i, line in enumerate(lines, 1):
        m = SPR_RE.search(line)
        if m:
            cur = lst.get(int(m.group(1))) if m.group(1) is not None else m.group(2)
            cur_line = i
            continue
        if cur is None:
            continue
        for mm in MOD_RE.finditer(line):
            n = int(mm.group(1))
            tail = line[mm.end():]
            hm = re.search(r'\+\s*(\d+)', tail)
            halves = 2 if (hm and int(hm.group(1)) == n) else 1
            need = n * halves
            total = sprite_frames(cur)
            rows.append((cur, total, n, halves, need, i, cur_line))
            if total is not None and need > total:
                problems.append((obj, cur, total, n, need, i, cur_line))

    if rows:
        print(f'== {obj}')
    for cur, total, n, halves, need, ln, sl in rows:
        mark = ''
        if total is not None and need > total:
            mark = f'  <== 越界：mod {n}{" +%d" % n if halves == 2 else ""} 需要 {need} 帧，实际 {total} 帧'
        seg = '两段' if halves == 2 else '单段'
        print(f'   {cur:42s} 帧数={str(total):>4s}  mod {n:<3d} {seg} (行{ln}){mark}')
    return problems


def main(argv):
    if not argv:
        print(__doc__)
        return 1
    if argv[0] == '--all':
        targets = sorted(os.path.basename(d) for d in
                         glob.glob(os.path.join(ROOT, 'objects', 'obj_infected_*'))
                         if os.path.isdir(d))
    else:
        targets = argv
    bad = []
    for obj in targets:
        bad.extend(scan(obj))
    print()
    if bad:
        print(f'发现 {len(bad)} 处越界：')
        for obj, spr, total, n, need, ln, sl in bad:
            print(f'  {obj} / {spr}: mod {n} 在行{ln}（sprite 于行{sl}）需要 {need} 帧，实际 {total} 帧')
        return 2
    print('全部取模常量都在精灵帧数范围内。')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
