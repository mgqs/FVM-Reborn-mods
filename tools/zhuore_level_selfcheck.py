# -*- coding: utf-8 -*-
"""灼热地域（跨服章节）接入自检。

检查项：
  1. mod_maps_init 里 cross_server_hot_hell 的 8 个关卡 id / 文件是否对得上
  2. 关卡 JSON 里出现的敌人 id 是否都已 register_enemy（否则 global.enemy_map 取不到会崩）
  3. 本次新增的 18 只（13 小怪 + 5 BOSS）是否都进了情报岛
  4. spr_zhuorediyu / spr_mod_cs_bg 是否存在
  5. 血量调整（煎蛋铁锅僵尸鼠 2000 / 橘子滑板僵尸鼠 800）注册表与对象是否一致
  6. 猫豁免与边界判负豁免（BOSS / 技能产物 / 傀儡马代理）是否还在

用法：python tools/zhuore_level_selfcheck.py
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)

TRAILING = re.compile(r',(\s*[}\]])')
WS = r'[ \t]*'


def read(path):
    with open(path, encoding='utf-8-sig') as f:
        return f.read()


def load_json(path):
    s = read(path).rstrip('\x00')
    return json.loads(TRAILING.sub(r'\1', s))


def main():
    problems = []

    maps = read('scripts/mod_maps_init/mod_maps_init.gml')
    pos = maps.find('register_map("cross_server_hot_hell"')
    if pos < 0:
        print('✗ mod_maps_init 里没有 cross_server_hot_hell')
        return 1
    seg = maps[pos:]
    ids = re.findall(r'id:' + WS + r'"([^"]+)"', seg)
    files = re.findall(r'(?<![a-z_])level_file:' + WS + r'"([^"]+)"', seg)
    print('章节：cross_server_hot_hell  关卡 %d 个' % len(files))
    if len(files) != 8 or len(ids) != 8:
        problems.append('关卡数量不是 8（id=%d, file=%d）' % (len(ids), len(files)))
    for i, (lid, f) in enumerate(zip(ids, files)):
        p = os.path.join('datafiles', 'level_data', f)
        ok = os.path.exists(p)
        print('  [%d] %-10s %-24s %s' % (i, lid, f, 'OK' if ok else '缺失'))
        if not ok:
            problems.append('关卡文件缺失：' + p)

    reg = set()
    for base, _, fs in os.walk('scripts'):
        for fn in fs:
            if not fn.endswith('.gml'):
                continue
            reg.update(re.findall(r'register_enemy\(' + WS + r'"([^"]+)"',
                                  read(os.path.join(base, fn))))

    used = set()
    for f in files:
        d = load_json(os.path.join('datafiles', 'level_data', f))
        for w in d['waves']:
            for k in ('boss', 'boss2'):
                if w.get(k):
                    used.add(w[k])
            for sw in w['subwaves']:
                for e in sw['enemy_list']:
                    used.add(e['type'])
    missing = sorted(used - reg)
    print('关卡用到的敌人 %d 种，未注册 %d 种 %s' % (len(used), len(missing), missing))
    if missing:
        problems.append('关卡引用了未注册敌人：' + ', '.join(missing))

    info = read(os.path.join('scripts', 'enemy_info_island_init', 'enemy_info_island_init.gml')) + \
        read(os.path.join('scripts', 'mod_info_island_init', 'mod_info_island_init.gml'))
    new_ids = re.findall(r'register_enemy_info_island\(' + WS + r'"(kf_zr[^"]+)"', info)
    print('情报岛新增条目 %d 条（应为 18）' % len(new_ids))
    if len(new_ids) != len(set(new_ids)):
        problems.append('情报岛新增条目有重复')
    lack = [x for x in new_ids if x not in reg]
    if lack:
        problems.append('情报岛条目没有对应敌人：' + ', '.join(lack))
    if len(new_ids) != 18:
        problems.append('情报岛新增条目数不是 18')

    for spr in ('spr_zhuorediyu', 'spr_mod_cs_bg'):
        p = os.path.join('sprites', spr, spr + '.yy')
        if not os.path.exists(p):
            problems.append('精灵不存在：' + spr)

    # 血量调整：注册表 vs 对象 Create
    checks = [
        ('kuafu_iron_pan', 'obj_kuafu_iron_pan', 2000),
        ('kuafu_skateboard', 'obj_kuafu_skateboard', 800),
    ]
    for eid, obj, want in checks:
        m = re.search(r'register_enemy\(' + WS + r'"' + eid + r'"[^)]*?"hp":' + WS + r'(\d+)', read('scripts/enemy_init/enemy_init.gml'))
        reg_hp = int(m.group(1)) if m else -1
        obj_src = read(os.path.join('objects', obj, 'Create_0.gml'))
        mo = re.search(r'^hp' + WS + r'=' + WS + r'(\d+)', obj_src, re.M)
        obj_hp = int(mo.group(1)) if mo else -1
        ok = (reg_hp == want and obj_hp == want)
        print('%s：注册表 hp=%d 对象 hp=%d 目标 %d -> %s' % (eid, reg_hp, obj_hp, want, 'OK' if ok else '不一致'))
        if not ok:
            problems.append('%s 血量不一致（注册表 %d / 对象 %d）' % (eid, reg_hp, obj_hp))

    # 猫豁免：5 只 BOSS 与其技能产物不能触发第 0 列猫的唤醒/冲撞秒杀
    cat_src = read('objects/obj_cat/Create_0.gml')
    m = re.search(r'ignore_list' + WS + r'=' + WS + r'\[(.*?)\n\]', cat_src, re.S)
    cat_ids = re.findall(r'"([^"]+)"', m.group(1)) if m else []
    cat_need = ['kf_zrb_mary', 'kf_zrb_shi', 'kf_zrb_jack', 'kf_zrb_vajra', 'kf_zrb_cap']
    # 技能产物（电刺 / 权杖 / 便便 / 彩虹）同样不能唤醒猫：电刺就出现在第 0 列，
    # 距第 -1 列那只猫 117px，正好落在 120px 的唤醒半径里
    cat_need_skill = ['kf_zrb_vajra_spike', 'kf_zrb_shi_mace', 'kf_zrb_shi_poop', 'kf_zrb_cap_rainbow']
    cat_lack = [x for x in cat_need + cat_need_skill if x not in cat_ids]
    for bid in cat_need:
        obj_src = read(os.path.join('objects', 'obj_' + bid, 'Create_0.gml'))
        has_boss_flag = re.search(r'is_boss' + WS + r'=' + WS + r'true', obj_src) is not None
        if not has_boss_flag:
            problems.append('%s 未设置 is_boss（猫眼宝石/金牛烟花仍会撞掉它）' % bid)
    print('猫豁免表：5 只 BOSS + 4 个技能产物 %s（is_boss 标记已逐个校验）' % ('全部豁免' if not cat_lack else '缺 ' + ', '.join(cat_lack)))
    if cat_lack:
        problems.append('猫 ignore_list 缺少：' + ', '.join(cat_lack))

    # 傀儡马（kuileima）的巫毒代理：位置吸附卡片格，卡片放第 0 列时代理距第 -1 列猫 117px
    # （< 120px 唤醒半径）；mouse_id 被 decoy_sync_identity 同步成真实老鼠 id，没法靠 ignore_list 豁免，
    # 只能在 obj_cat 里按对象类型整类跳过。这里守住那行，避免以后被“清理豁免”时误删。
    cat_step = read('objects/obj_cat/Step_0.gml')
    has_decoy_skip = re.search(r'object_index' + WS + r'==' + WS + r'obj_kuileima_decoy' + WS + r'\)?' + WS + r'continue', cat_step) is not None
    print('傀儡马代理豁免：第 0 列猫跳过 obj_kuileima_decoy %s' % ('已接入' if has_decoy_skip else '缺失'))
    if not has_decoy_skip:
        problems.append('objects/obj_cat/Step_0.gml 缺少 obj_kuileima_decoy 跳过分支（傀儡马放第 0 列会误触发猫）')

    # 技能物件不能被击退到左边界后触发“老鼠跑掉”判负
    parent_src = read('objects/obj_enemy_parent/Create_0.gml')
    mb = re.search(r'block_mouse_id_list' + WS + r'=' + WS + r'\[(.*?)\]', parent_src, re.S)
    block_ids = re.findall(r'"([^"]+)"', mb.group(1)) if mb else []
    block_lack = [x for x in ['kf_zrb_vajra_spike', 'kf_zrb_shi_mace', 'kf_zrb_shi_poop', 'kf_zrb_cap_rainbow'] if x not in block_ids]
    print('技能物件判负豁免：%s' % ('OK' if not block_lack else '缺 ' + ', '.join(block_lack)))
    if block_lack:
        problems.append('block_mouse_id_list 缺少：' + ', '.join(block_lack))

    # 杰克技能4的火老鼠：到达第 0 列要自毁（否则走到左边界会触发失败判定）
    fire_src = read('objects/obj_kf_zrb_jack_fire_mouse/Step_0.gml')
    has_col0_kill = re.search(r'grid_col' + WS + r'<=' + WS + r'0[^\n]*\n?[^\n]*obj_wine_bottle_bomb_explode', fire_src) is not None \
        or ('grid_col <= 0' in fire_src and 'instance_destroy()' in fire_src)
    print('杰克火老鼠：第 0 列自毁 %s' % ('已接入' if has_col0_kill else '缺失'))
    if not has_col0_kill:
        problems.append('obj_kf_zrb_jack_fire_mouse 缺少第 0 列自毁')

    print()
    if problems:
        print('自检失败：')
        for p in problems:
            print('  - ' + p)
        return 1
    print('自检通过，无问题。')
    return 0


if __name__ == '__main__':
    sys.exit(main())
