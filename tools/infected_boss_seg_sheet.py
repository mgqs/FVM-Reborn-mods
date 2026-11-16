# -*- coding: utf-8 -*-
"""生成跨服 BOSS 精灵分段核验图：每段一行，标注段名 / 帧数 / 对应 SWF 帧区间。

用途：改完 Step 的取模常量后，目视确认「精灵分段」与「SWF FrameLabel」一一对应，
      并且代码里的 mod 常量 = 该段的一半帧数。

用法：python tools/infected_boss_seg_sheet.py
输出：output/infected_boss_frame_segments.png
"""
import json
import os
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'output', 'infected_boss_frame_segments.png')

SWF_ARNO = ('output/_tmp/swf_arno/DefineSprite_98_com.aurora.ui.maogoutd.resource.Intruder.'
            'kfcarbon.TerminatorBossMouseStrengthenMoveIntruderMovie')
SWF_ICE = ('output/_tmp/swf_bingzha/DefineSprite_84_com.aurora.ui.maogoutd.resource.Intruder.'
           'kfcarbon.WizardBossMouseMoveIntruderMovie')
SWF_FIRE = ('output/_tmp/swf_huozha/DefineSprite_107_com.aurora.ui.maogoutd.resource.Intruder.'
            'kfcarbon.WizardBossFireMouseMoveIntruderMovie')
SWF_PHA = ('output/_tmp/swf_pharaoh/DefineSprite_247_com.aurora.ui.maogoutd.resource.Intruder.'
           'kfcarbon.AbyssBPharaohBossMoveIntruderMovie')

# (段名, 精灵名, SWF目录, SWF 区间文字, 该区间帧数, 代码里的 mod 常量, 是否两段)
SHEETS = [
    ('变异阿诺 obj_infected_arno', [
        ('待机', 'spr_infected_arno_idle', SWF_ARNO, '#1~#12', 12, 12, False),
        ('进场', 'spr_infected_arno_appear', SWF_ARNO, '#123~#142', 20, 10, True),
        ('射击', 'spr_infected_arno_skill_1', SWF_ARNO, '#13~#52', 40, 20, True),
        ('冲刺预备', 'spr_infected_arno_skill_2_ready', SWF_ARNO, '#53~#72', 20, 10, True),
        ('冲刺', 'spr_infected_arno_skill_2', SWF_ARNO, '#73~#100', 28, 14, True),
        ('闪出', 'spr_infected_arno_disappear', SWF_ARNO, '#101~#122', 22, 11, True),
        ('死亡', 'spr_infected_arno_death', SWF_ARNO, '#143~#163', 21, 0, False),
    ]),
    ('感染冰渣 obj_infected_bingzha', [
        ('闪入', 'spr_infected_bingzha_appear', SWF_ICE, '#1~#10 + #20~#29', 20, 10, True),
        ('闪出', 'spr_infected_bingzha_disappear', SWF_ICE, '#11~#19 + #30~#38', 18, 9, True),
        ('念咒', 'spr_infected_bingzha_skill_1_ready', SWF_ICE, '#39~#54', 16, 8, True),
        ('释放冰球', 'spr_infected_bingzha_skill_1', SWF_ICE, '#55~#86', 32, 16, True),
        ('攻击', 'spr_infected_bingzha_skill_2', SWF_ICE, '#87~#121', 35, 17, True),
        ('死亡', 'spr_infected_bingzha_death', SWF_ICE, '#123~#162', 40, 0, False),
    ]),
    ('感染火渣 obj_infected_fire_residue', [
        ('闪入', 'spr_infected_bingzha_fire_appear', SWF_FIRE, '#1~#10 + #20~#29', 20, 10, True),
        ('闪出', 'spr_infected_bingzha_fire_disappear', SWF_FIRE, '#11~#19 + #30~#38', 18, 9, True),
        ('念咒', 'spr_infected_bingzha_fire_skill_1_ready', SWF_FIRE, '#39~#54', 16, 8, True),
        ('释放火球', 'spr_infected_bingzha_fire_skill_1', SWF_FIRE, '#55~#86', 32, 16, True),
        ('攻击', 'spr_infected_bingzha_fire_skill_2', SWF_FIRE, '#87~#120', 34, 17, True),
        ('死亡', 'spr_infected_bingzha_fire_death', SWF_FIRE, '#122~#161', 40, 0, False),
    ]),
    ('感染法老 obj_infected_pharaoh', [
        ('出场出土', 'spr_infected_pharaoh_appear', SWF_PHA, '#1~#58', 58, 58, False),
        ('悬浮待机', 'spr_infected_pharaoh_idle', SWF_PHA, '#59~#86', 28, 14, True),
        ('召唤甲虫', 'spr_infected_pharaoh_skill_1', SWF_PHA, '#87~#110', 24, 12, True),
        ('召唤木乃伊', 'spr_infected_pharaoh_skill_2', SWF_PHA, '#111~#148', 38, 19, True),
        ('召唤茧', 'spr_infected_pharaoh_skill_3', SWF_PHA, '#149~#182', 34, 17, True),
        ('死亡', 'spr_infected_pharaoh_death', SWF_PHA, '#183~#201', 19, 0, False),
    ]),
]

ROW_H = 116
THUMB_H = 82
LABEL_W = 320
SAMPLES = 8


def load_yy(p):
    s = open(p, encoding='utf-8-sig').read()
    s = re.sub(r',(\s*[}\]])', r'\1', s)
    return json.loads(s)


def frames_of(name):
    y = load_yy(os.path.join(ROOT, 'sprites', name, name + '.yy'))
    return [f['name'] for f in y['frames']]


def font(size):
    for f in ('msyh.ttc', 'simhei.ttf', 'arial.ttf'):
        try:
            return ImageFont.truetype(f, size)
        except OSError:
            continue
    return ImageFont.load_default()


def main():
    f_t = font(20)
    f_s = font(15)
    title_h = 40
    total_h = title_h + sum(34 + ROW_H * len(rows) for _, rows in SHEETS) + 20
    width = 1480
    canvas = Image.new('RGB', (width, total_h), (250, 250, 252))
    d = ImageDraw.Draw(canvas)

    y = 12
    for boss, rows in SHEETS:
        d.text((16, y), boss, font=f_t, fill=(20, 20, 30))
        y += 34
        for seg, spr, swfdir, rng, rng_n, n, halves in rows:
            fl = frames_of(spr)
            idxs = [round(i * (len(fl) - 1) / (SAMPLES - 1)) for i in range(SAMPLES)]
            x = LABEL_W
            for k in idxs:
                p = os.path.join(ROOT, 'sprites', spr, fl[k] + '.png')
                im = Image.open(p).convert('RGBA')
                sc = THUMB_H / im.height
                im = im.resize((max(1, int(im.width * sc)), THUMB_H), Image.LANCZOS)
                bg = Image.new('RGBA', im.size, (232, 236, 243, 255))
                bg.alpha_composite(im)
                canvas.paste(bg.convert('RGB'), (x, y + 6))
                d.text((x + 2, y + 6 + THUMB_H + 2), f'{k + 1}', font=f_s, fill=(120, 126, 140))
                x += im.width + 8

            if n == 0:
                tag, color = 'image_number（整段）', (110, 116, 130)
            elif halves:
                need = n * 2
                tag = f'mod {n} / +{n}  →  用满 {need} 帧'
                color = (24, 120, 60) if need == len(fl) else (190, 110, 20)
            else:
                tag = f'mod {n}  →  用满 {n} 帧'
                color = (24, 120, 60) if n == len(fl) else (190, 110, 20)

            d.text((16, y + 8), seg, font=font(19), fill=(20, 20, 30))
            d.text((16, y + 36), f'精灵 {len(fl)} 帧  /  SWF {rng}（{rng_n}）', font=f_s,
                   fill=(110, 116, 130))
            d.text((16, y + 60), tag, font=f_s, fill=color)
            d.line([(10, y + ROW_H - 2), (width - 10, y + ROW_H - 2)], fill=(223, 227, 236), width=1)
            y += ROW_H

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    canvas.save(OUT)
    print('已输出', OUT, canvas.size)


if __name__ == '__main__':
    main()
