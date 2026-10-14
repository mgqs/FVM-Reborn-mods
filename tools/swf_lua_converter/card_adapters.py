"""Verified source profiles are one backend, not a universal AS3 translator.

Never choose a profile by a file name alone. Unknown source versions must fail.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ENTRY = 'com.aurora.ui.maogoutd.resource.defender.fusionCard.termiThreeShotGun.TermiThreeShotGunPrimaryAttackFighterResource'


def adapt_card(out, records, analysis):
    if analysis['entry'] != ENTRY:
        return None
    lock = json.loads((HERE / 'adapters/termi_three_shot_gun.lock.json').read_text(encoding='utf-8'))
    archive_hash = hashlib.sha256((out / 'original.swf').read_bytes()).hexdigest()
    if archive_hash != lock['swf_sha256']:
        raise ValueError('发现终极三线枪入口，但 SWF 版本尚未适配；禁止套用其他版本的行为。')
    actual = {str(Path(r['file'])).replace('\\', '/'): r['sha256'] for r in records}
    if actual != lock['source_sha256']:
        raise ValueError('脚本目录与已核对版本不同；需要重新分析行为依赖。')
    rules = {
        'adapter': 'termi_three_shot_gun_v1', 'entry': ENTRY,
        'output_kind': 'single_card_behavior',
        'requirements': ['FVM external_mod_system trajectory/burn source interfaces',
                         'ctx.rows / ctx.row_height / ctx.slowed', 'api.shoot accepts speed_y / vertical_distance / burn'],
        'behavior_mapping': [
            {'source': 'TermiThreeShotGunPrimaryAttackFighter.a_3954/lauchShot/pushShot',
             'implementation': 'logic.lua: 8-tick preparation, two volleys separated by 2 source ticks, three rows, edge checks'},
            {'source': 'TermiThreeShotGunPrimaryShot.a_1797/a_4216',
             'implementation': 'api.shoot speed_y and vertical_distance; original row assignment retained'},
            {'source': 'BaseShotTrigger.CheckValid/RollProbability + RandomSeed',
             'implementation': 'boss/dead/invisible rejection on impact; Lua 48-bit LCG, nextInt(101) <= 30'},
            {'source': 'BurnBuffTrigger + IntruderBurnEffect + HurtBuff + EffectManager',
             'implementation': 'target-owned independent 100-ms layers; damage on effect ticks 0,10,20 before duration decrement'},
            {'source': 'a_3953 / a_4348 / BattleFieldView / a_4206',
             'implementation': 'host card lifecycle, target query, projectile collision, source-independent damage event; not bulk AS3 transpilation'},
            {'source': 'TermiThreeShotGunDefence',
             'implementation': 'hp/atk/cycle from JSON; grade-derived burn power from Lua or behavior_params.burn_power'},
            {'source': 'MovieClip resource classes, UI, text labels, pooling, encryption wrappers',
             'implementation': 'PNG animation and host lifecycle replace these services; original AS3 retained'}
        ],
        'unverified_or_different': [
            '游戏构建未执行；Lua DLL 加载与命令轨迹测试不证明实际战场行为等价',
            'Flash 的 50-ms 默认攻击时钟映射到 60-Hz；可在 JSON 指定 source_tick_seconds=0.025 适配原版快速时钟',
            '目标查询沿用当前游戏 target_type；Flash 原版战场特殊地图、机关、Buff 和子弹分裂等父类规则不自动复制',
            '随机算法相同，但要复现同一次原版战斗必须提供 battle_seed/source_card_id；当前游戏默认种子与原版不同',
            '斜线终点以当前游戏行高缩放；坐标从 Flash 顶部定位适配为卡片底部定位，muzzle_y 默认 -75 可在 JSON 调整',
            '命中直接移除，灼烧贴图、数字文本和受击闪光由当前游戏表现替代；不输出 Flash 动画',
            '原版护甲、免疫、灼烧清除规则与当前游戏可能不同；伤害接入当前游戏事件',
            '并非通用方法级依赖/静态初始化转换；对未知父类行为没有自动翻译能力，未知 SWF 版本阻止输出'
        ],
        'json_configuration': {
            'script': 'logic.lua', 'target_type': 'normal', 'atk': '由作者提供星级数组',
            'cycle': '由作者提供技能/星级数值；原版基础技能间隔 78 游戏帧',
            'projectiles': {'default': '配置你自己的 PNG 动画与命中/反弹/增强规则'},
            'behavior_params': {'projectile': 'default', 'grade': 1, 'burn_power': 13,
                'source_tick_seconds': 0.05, 'source_bullet_speed': 10,
                'place_delay_source_ticks': 20, 'muzzle_y': -75, 'battle_seed': 0}
        }
    }
    return (HERE / 'adapters/termi_three_shot_gun.lua').read_text(encoding='utf-8'), rules
