"""二期海克斯：注册段(ex/en) 与 apply 读取段的一致性检查

历史 bug：hex_190 的 b3_finger_hp 注册在 en 段，apply 里却用 _ex 读 -> 永远不生效。
本脚本把每个词条注册的键所属段，和 apply 里实际读取用的指针做交叉比对。
"""
import re
import sys
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'scripts', 'hex_batch3', 'hex_batch3.gml')

BS = chr(92)          # 反斜杠（绕开 shell 的路径转换）
D = BS + 's*'         # 空白
OB = BS + '{'
CB = BS + '}'


def main():
    src = open(SRC, encoding='utf-8').read()

    pat_reg = re.compile(r'hex_register\(' + D + r'"(hex_' + BS + r'w+)"' + D + r',' + D + OB + r'(.*?)' + chr(10) + r'    ' + BS + r'}\);', re.S)
    regs = {}
    for m in pat_reg.finditer(src):
        rid, body = m.group(1), m.group(2)
        exm = re.search(r'ex:' + D + OB + r'(.*?)' + CB + r',' + D + r'en:', body, re.S)
        enm = re.search(r'en:' + D + OB + r'(.*?)' + CB + D + r'$', body, re.S)
        exk = set(re.findall(r'(' + BS + r'w+)' + D + ':', exm.group(1))) if exm else set()
        enk = set(re.findall(r'(' + BS + r'w+)' + D + ':', enm.group(1))) if enm else set()
        regs[rid] = (exk, enk)

    ap_start = src.find('function hex_b3_apply')
    tail = src.find('卡片侧读取口')
    ap = src[ap_start:tail]

    reads = {}
    for m in re.finditer(r'variable_struct_exists\(' + D + r'(_ex|_en)' + D + r',' + D + r'"(' + BS + r'w+)"' + D + r'\)', ap):
        reads.setdefault(m.group(2), set()).add(m.group(1))

    bad = []
    for rid, (exk, enk) in regs.items():
        for k in exk:
            r = reads.get(k)
            if r and '_ex' not in r:
                bad.append((rid, 'ex', k, sorted(r)))
        for k in enk:
            r = reads.get(k)
            if r and '_en' not in r:
                bad.append((rid, 'en', k, sorted(r)))

    print('解析 %d 条词条，%d 个键有 apply 读取点' % (len(regs), len(reads)))
    if bad:
        for rid, seg, k, r in sorted(bad):
            print('  [X] %-10s 注册在 %s 段，apply 只用 %s 读 (%s)' % (rid, seg, r, k))
    else:
        print('  [OK] ex/en 段完全对齐')
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
