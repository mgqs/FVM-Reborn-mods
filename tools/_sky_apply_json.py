# -*- coding: utf-8 -*-
"""给 8 个梦魇天空关卡 JSON 的 cloud 事件加 no_resident:true。

只做字符串替换，不用 json.dump 回写（AGENTS.md §10：json.dump 会破坏浮点写法、
丢掉文件尾的 NUL）。原文件备份到 output/梦魇天空预览/backup/json/。
"""
import os
import shutil

ROOT = r'D:\gameProject\FVM-Reborn-mod'
BACKUP = os.path.join(ROOT, 'output', '梦魇天空预览', 'backup', 'json')
os.makedirs(BACKUP, exist_ok=True)

OLD = '            "cloud_type": "night"\n'
NEW = '            "cloud_type": "night",\n            "no_resident": true\n'

for n in range(8):
    p = os.path.join(ROOT, 'datafiles', 'level_data', 'cross', 'nightmare_sky-%d.json' % n)
    raw = open(p, 'rb').read()

    # 保留文件尾的 NUL / 换行
    tail = b''
    body = raw
    while body and body[-1:] in (b'\x00', b'\n', b'\r'):
        tail = body[-1:] + tail
        body = body[:-1]
    if b'\x00' in body:
        raise SystemExit('%s 中间含 NUL，人工处理' % p)

    text = body.decode('utf-8')
    cnt = text.count(OLD)
    if cnt != 1:
        raise SystemExit('%s 匹配 %d 处，预期 1 处' % (p, cnt))
    text = text.replace(OLD, NEW)

    bak = os.path.join(BACKUP, 'nightmare_sky-%d.json' % n)
    if not os.path.exists(bak):
        shutil.copy2(p, bak)

    open(p, 'wb').write(text.encode('utf-8') + tail)
    print('nightmare_sky-%d.json 已加 no_resident（尾字节保留 %r）' % (n, tail))
