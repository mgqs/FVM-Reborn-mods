import json, os, sys, collections

A = r'D:/ruanjian/QQ/QQ下载/FVM_Reborn v3.0.0-PC单机版/level_data/tower'
B = r'D:/gameProject/FVM-Reborn-mod/datafiles/level_data/tower'


def strip_trailing_commas(s):
    out = []
    i, n, instr = 0, len(s), False
    while i < n:
        c = s[i]
        if instr:
            out.append(c)
            if c == '\\':
                out.append(s[i + 1]); i += 1
            elif c == '"':
                instr = False
        else:
            if c == '"':
                instr = True
                out.append(c)
            elif c == ',':
                j = i + 1
                while j < n and s[j] in ' \r\n\t':
                    j += 1
                if j < n and s[j] in ']}':
                    pass
                else:
                    out.append(c)
            else:
                out.append(c)
        i += 1
    return ''.join(out)


def load(p):
    d = open(p, 'rb').read().rstrip(b'\x00').decode('utf-8', 'replace').strip()
    try:
        return json.loads(d)
    except Exception:
        return json.loads(strip_trailing_commas(d))


def walk(pa, pb, path, out):
    if type(pa) is not type(pb) and not (isinstance(pa, (int, float)) and isinstance(pb, (int, float))):
        out.append((path, pa, pb))
        return
    if isinstance(pa, dict):
        for k in pa:
            if k not in pb:
                out.append((path + '.' + k, pa[k], '<MISSING>'))
            else:
                walk(pa[k], pb[k], path + '.' + k, out)
        for k in pb:
            if k not in pa:
                out.append((path + '.' + k, '<MISSING>', pb[k]))
    elif isinstance(pa, list):
        if len(pa) != len(pb):
            out.append((path + '.__len__', len(pa), len(pb)))
        for i in range(min(len(pa), len(pb))):
            walk(pa[i], pb[i], path + '[%d]' % i, out)
    else:
        if pa != pb:
            out.append((path, pa, pb))


def norm(path):
    import re
    return re.sub(r'\[\d+\]', '[]', path)


def main():
    files = sorted(os.listdir(A))
    semasame = []
    per_file = {}
    keycollect = collections.defaultdict(lambda: {'n_files': 0, 'n_occ': 0, 'examples': []})

    for f in files:
        da, db = load(os.path.join(A, f)), load(os.path.join(B, f))
        out = []
        walk(da, db, '', out)
        if not out:
            semasame.append(f)
            continue
        per_file[f] = out
        seen = set()
        for p, va, vb in out:
            n = norm(p)
            keycollect[n]['n_occ'] += 1
            if n not in seen:
                seen.add(n)
                keycollect[n]['n_files'] += 1
            if len(keycollect[n]['examples']) < 2:
                keycollect[n]['examples'].append((f, va, vb))

    print('=== 语义相同文件数: %d / %d ===' % (len(semasame), len(files)))
    print('=== 有差异文件: %d ===' % len(per_file))

    print('\n=== 差异字段汇总（按影响文件数排序）===')
    for k, v in sorted(keycollect.items(), key=lambda x: -x[1]['n_files']):
        print('%-45s files=%-3d occ=%-5d ex=%s' % (k[:45], v['n_files'], v['n_occ'], v['examples'][0]))

    if len(sys.argv) > 1:
        fn = sys.argv[1]
        print('\n=== 单文件明细: %s ===' % fn)
        for p, va, vb in per_file.get(fn, [])[:200]:
            print('%s\n   v3.0.0: %s\n   mod   : %s' % (p, json.dumps(va, ensure_ascii=False)[:120], json.dumps(vb, ensure_ascii=False)[:120]))


if __name__ == '__main__':
    main()
