import re, collections

s = open('scripts/gods_shop_init/gods_shop_init.gml', encoding='utf-8').read()
entries = re.split(r'register_gods_goods\("', s)[1:]
rows = []
for e in entries:
    gid = e.split('"', 1)[0]
    m = re.search(r'"?type"?\s*:\s*"?(\w+)"?', e)
    typ = m.group(1) if m else '?'
    c = re.search(r'"?cost"?\s*:\s*"?(\d+)"?', e)
    sh = re.search(r'"?target_shape"?\s*:\s*(\d+)', e)
    nm = re.search(r'"?display_name"?\s*:\s*"([^"]*)"', e)
    rows.append((gid, typ, int(c.group(1)) if c else None, int(sh.group(1)) if sh else 0, nm.group(1) if nm else '', 'recipe_id' in e))

print(collections.Counter(r[1] for r in rows), len(rows))
tab1 = [r for r in rows if r[1] == 'card' or (r[1] == 'recipe' and r[3] == 0)]
tab2 = [r for r in rows if r[1] == 'shape' or (r[1] == 'recipe' and r[3] >= 1)]
print('tab1', len(tab1), 'tab2', len(tab2), 'pages', (len(tab1) + 15) // 16, (len(tab2) + 15) // 16)

print('=== 世界神使(非融合)卡 ===', sum(1 for r in rows if r[1] == 'card' and not r[5]))
print('=== 融合本体卡 ===', sum(1 for r in rows if r[1] == 'card' and r[5]))
print('=== 凭证 shape 总数 ===', sum(1 for r in rows if r[1] == 'shape'))
print('=== 食谱 recipe 总数 ===', sum(1 for r in rows if r[1] == 'recipe'))
tot_all = sum(r[2] for r in rows if r[2])
print('全店总价', tot_all, '石')
# 每个神：本体 + 三档凭证 全通价
by_god = collections.defaultdict(int)
for r in rows:
    by_god[r[0].rsplit('_', 1)[0]] += (r[2] or 0)
print('单神全通最贵前8:', sorted(by_god.items(), key=lambda x: -x[1])[:8])
print('单神全通最便宜前8:', sorted(by_god.items(), key=lambda x: x[1])[:8])
