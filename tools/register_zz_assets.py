# -*- coding: utf-8 -*-
"""登记「金马盛典」新增的脚本与对象到工程（yyp + folders）。

· 脚本  zz_lottery_init      → folders/脚本/Menu/Craft.yy
· 对象  obj_zz_enter / obj_zz_bg / obj_zz_shop_bg
                             → folders/物体/mod/金马盛典.yy（不存在则创建并挂到 mod.yy）

只增不删、按 name 去重，可重复执行。
用法：python tools/register_zz_assets.py
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YPP = os.path.join(ROOT, 'FVM_Reborn_makk.yyp')

SCRIPT_YY_TMPL = '''{
  "$GMScript":"v1",
  "%%Name":"%(name)s",
  "isCompatibility":false,
  "isDnD":false,
  "name":"%(name)s",
  "parent":{
    "name":"Craft",
    "path":"folders/脚本/Menu/Craft.yy",
  },
  "resourceType":"GMScript",
  "resourceVersion":"2.0",
}
'''

OBJ_YY_TMPL = '''{
  "$GMObject":"",
  "%%Name":"%(name)s",
  "eventList":[
%(events)s
  ],
  "managed":true,
  "name":"%(name)s",
  "overriddenProperties":[],
  "parent":{
    "name":"%(folder)s",
    "path":"%(folder_path)s",
  },
  "parentObjectId":null,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":0,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":0,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":%(sprite)s,
  "spriteMaskId":null,
  "visible":true,
}
'''

EVENT_TMPL = ('    {"$GMEvent":"v1","%%Name":"","collisionObjectId":null,"eventNum":%(num)d,'
              '"eventType":%(type)d,"isDnD":false,"name":"","resourceType":"GMEvent",'
              '"resourceVersion":"2.0",},')

FOLDER_TMPL = '''{
  "$GMFolder":"",
  "%%Name":"金马盛典",
  "folderPath":"folders/物体/mod/金马盛典.yy",
  "isDefaultView":false,
  "listViewItems":[],
  "name":"金马盛典",
  "resourceType":"GMFolder",
  "resourceVersion":"2.0",
  "viewLocked":false,
  "visible":true,
  "folders":[],
  "listItems":[
%(items)s
  ],
}
'''

# 事件后缀 → (eventType, eventNum)
EV = {
    'Create_0': (0, 0),
    'Destroy_0': (1, 0),
    'Step_0': (3, 0),
    'Step_1': (3, 1),
    'Draw_0': (8, 0),
    'Draw_64': (8, 64),
    'Mouse_4': (6, 4),
    'Mouse_10': (6, 10),
    'Mouse_11': (6, 11),
}

OBJECTS = ['obj_zz_enter', 'obj_zz_bg', 'obj_zz_shop_bg', 'obj_zz_buy_confirm']
SCRIPTS = ['zz_lottery_init']

# 对象自带精灵（其余为 null，全在 Draw 里画）
OBJ_SPRITES = {
    'obj_zz_enter': 'spr_zz_enter',
    'obj_zz_buy_confirm': 'spr_battle_escape_menu',   # 与商城确认框同一个底板精灵
}


def add_to_list(path, entry, anchor_re, indent='    '):
    s = io.open(path, encoding='utf-8').read()
    if entry in s:
        return False
    m = re.search(anchor_re, s)
    if not m:
        raise RuntimeError('锚点缺失: %s' % path)
    # 插到数组开头
    s = s[:m.end()] + '\n' + indent + entry + s[m.end():]
    io.open(path, 'w', encoding='utf-8', newline='\n').write(s)
    return True


def add_yyp(kind, name):
    """yyp 只有一个大 resources 数组，按 name 字典序插入，保持 IDE 习惯的顺序。"""
    entry = '    {"id":{"name":"%s","path":"%s/%s/%s.yy",},},' % (name, kind, name, name)
    s = io.open(YPP, encoding='utf-8').read()
    if '{"id":{"name":"%s","path":"%s/%s/%s.yy"' % (name, kind, name, name) in s:
        print('  yyp 已有 %s' % name)
        return
    m = re.search(r'"resources":\[\n', s)
    if not m:
        raise RuntimeError('yyp 找不到 resources 数组')
    # 找到第一条 name 大于当前 name 的条目，插在它前面
    pat = re.compile(r'    \{"id":\{"name":"([^"]+)","path":"[^"]+",\},},')
    pos = None
    for mm in pat.finditer(s, m.end()):
        if mm.group(1) > name:
            pos = mm.start()
            break
    if pos is None:
        # 名字排在最后 → 插到 resources 数组收尾之前
        endm = re.search(r'\n  \],\n', s[m.end():])
        if not endm:
            raise RuntimeError('yyp 找不到插入位置: %s' % name)
        pos = m.end() + endm.start() + 1
    s = s[:pos] + entry + '\n' + s[pos:]
    io.open(YPP, 'w', encoding='utf-8', newline='\n').write(s)
    print('  yyp 注册 %s' % name)


# IDE 里这个文件夹被手动改名成 zhuanzhuan 了（中文路径在部分工具链下不稳），
# 对象 .yy 的 parent 已经指向新路径，脚本跟着走。
FOLDER_NAME = 'zhuanzhuan'
FOLDER_PATH = 'folders/物体/mod/zhuanzhuan.yy'


def ensure_folder_yyp():
    """yyp 的 Folders 数组必须同时有这条，否则 IDE 打开工程会报
    "Cannot find folder path 'folders/物体/mod/zhuanzhuan.yy'"（对象 parent 指向它）。"""
    s = io.open(YPP, encoding='utf-8').read()
    if '"folderPath":"%s"' % FOLDER_PATH in s:
        print('  yyp 已注册文件夹 ' + FOLDER_NAME)
        return
    entry = ('    {"$GMFolder":"","%Name":"' + FOLDER_NAME + '","folderPath":"' + FOLDER_PATH + '",'
             '"name":"' + FOLDER_NAME + '","resourceType":"GMFolder","resourceVersion":"2.0",},')
    pat = re.compile(r'    \{"\$GMFolder":"","%Name":"[^"]*",'
                     r'"folderPath":"folders/物体/mod/[^"]*",[^\n]*\n')
    hits = list(pat.finditer(s))
    if not hits:
        raise RuntimeError('yyp 找不到 物体/mod 下的文件夹条目')
    pos = hits[-1].end()
    s = s[:pos] + entry + '\n' + s[pos:]
    io.open(YPP, 'w', encoding='utf-8', newline='\n').write(s)
    print('  yyp 注册文件夹 ' + FOLDER_NAME)


def ensure_folder():
    p = os.path.join(ROOT, FOLDER_PATH.replace('/', os.sep))
    if not os.path.exists(p):
        txt = (FOLDER_TMPL % dict(items='')).replace('金马盛典', FOLDER_NAME).replace(
            'folders/物体/mod/金马盛典.yy', FOLDER_PATH)
        io.open(p, 'w', encoding='utf-8', newline='\n').write(txt)
        print('  新建物体文件夹 ' + FOLDER_PATH)
    modf = os.path.join(ROOT, 'folders', '物体', 'mod.yy')
    entry = '{"name":"%s","path":"%s",},' % (FOLDER_NAME, FOLDER_PATH)
    s = io.open(modf, encoding='utf-8').read()
    if entry not in s:
        m = re.search(r'"folders":\[\n', s)
        s = s[:m.end()] + '    ' + entry + '\n' + s[m.end():]
        io.open(modf, 'w', encoding='utf-8', newline='\n').write(s)
        print('  mod.yy 挂载 ' + FOLDER_NAME + ' 文件夹')
    return p


def main():
    # ── 脚本 ──
    for name in SCRIPTS:
        d = os.path.join(ROOT, 'scripts', name)
        os.makedirs(d, exist_ok=True)
        yypath = os.path.join(d, name + '.yy')
        if not os.path.exists(yypath):
            io.open(yypath, 'w', encoding='utf-8', newline='\n').write(SCRIPT_YY_TMPL % dict(name=name))
            print('脚本 yy 已生成:', name)
        add_yyp('scripts', name)
        add_to_list(os.path.join(ROOT, 'folders', '脚本', 'Menu', 'Craft.yy'),
                    '{"name":"%s","path":"scripts/%s/%s.yy",},' % (name, name, name),
                    r'"listItems":\[\n')

    # ── 对象 ──
    ensure_folder_yyp()
    folder_yy = ensure_folder()
    for name in OBJECTS:
        d = os.path.join(ROOT, 'objects', name)
        if not os.path.isdir(d):
            print('!! 对象目录不存在，跳过:', name)
            continue
        yypath = os.path.join(d, name + '.yy')
        if not os.path.exists(yypath):
            evs = [EV[f[:-4]] for f in os.listdir(d) if f.endswith('.gml') and f[:-4] in EV]
            evs.sort()
            evs_txt = '\n'.join(EVENT_TMPL % dict(type=t, num=n) for t, n in evs)
            if name in OBJ_SPRITES:
                spr = OBJ_SPRITES[name]
                sprite = ('{\n    "name":"%s",\n    "path":"sprites/%s/%s.yy",\n  }'
                          % (spr, spr, spr))
            else:
                sprite = 'null'
            io.open(yypath, 'w', encoding='utf-8', newline='\n').write(
                OBJ_YY_TMPL % dict(name=name, events=evs_txt, sprite=sprite,
                                   folder=FOLDER_NAME, folder_path=FOLDER_PATH))
            print('对象 yy 已生成:', name, '事件数', len(evs))
        add_yyp('objects', name)
        add_to_list(folder_yy,
                    '{"name":"%s","path":"objects/%s/%s.yy",},' % (name, name, name),
                    r'"listItems":\[\n')

    print('完成')
    verify()


def verify():
    """自检：对象 parent 文件夹、资源本体，以及代码里引用到的每一个 spr_* 都已注册。

    第三条是 2026-11-17 的教训：`spr_mod_cs_exchange_card` 目录在磁盘上、图也齐，
    只是没进 yyp resources，运行期报
    `Variable obj_zz_shop_bg.spr_mod_cs_exchange_card not set before reading it`。
    """
    s = io.open(YPP, encoding='utf-8').read()
    folder_paths = set(re.findall(r'"folderPath":"([^"]+)"', s))
    res = set(re.findall(r'"id":\{"name":"([^"]+)","path":"[^"]+",\},', s))
    bad = []
    for name in OBJECTS + SCRIPTS:
        if name not in res:
            bad.append('yyp resources 缺 ' + name)
    for name in OBJECTS:
        yy = os.path.join(ROOT, 'objects', name, name + '.yy')
        if not os.path.exists(yy):
            bad.append('对象 yy 不存在 ' + name)
            continue
        ppath = re.search(r'"parent":\{\s*"name":"[^"]*",\s*"path":"([^"]+)"', io.open(yy, encoding='utf-8').read())
        if ppath and ppath.group(1) not in folder_paths:
            bad.append('%s 的 parent 文件夹未注册到 yyp: %s' % (name, ppath.group(1)))
    if FOLDER_PATH not in folder_paths:
        bad.append('yyp Folders 缺 ' + FOLDER_PATH)
    spr_dir = os.path.join(ROOT, 'sprites')
    for d in sorted(os.listdir(spr_dir)):
        if d.startswith('spr_zz_') and d not in res:
            bad.append('yyp resources 缺精灵 ' + d)
    # 代码引用 → yyp resources（漏一个就是运行期 Variable not set）
    import glob
    ids = set()
    for f in (glob.glob(os.path.join(ROOT, 'objects', 'obj_zz_*', '*.gml')) +
              glob.glob(os.path.join(ROOT, 'scripts', 'zz_lottery_init', '*.gml'))):
        ids |= set(re.findall(r'\bspr_[a-z0-9_]+',
                              io.open(f, encoding='utf-8', errors='ignore').read()))
    for i in sorted(ids):
        if i not in res:
            bad.append('代码引用的精灵未注册到 yyp: ' + i)
    if bad:
        print('!! 自检未通过:')
        for b in bad:
            print('   -', b)
        raise SystemExit(1)
    print('自检通过：文件夹 / 对象 / 脚本 / 代码引用的 %d 个精灵 全部已注册' % len(ids))


if __name__ == '__main__':
    main()
