/// ============================================================================
/// 天蝎座二转 · 随机池数据（2026-11-11 第二轮重排：全部按最高转职形态）
///   抽取：先掷 10% 判**特殊池 / 普通池**，再池内抽一张 → 打这张卡**满转的一轮攻击**
///     · 特殊池（写 spt: true）7 张 = 逆转牛 / 桂花酒 / 盖亚神使 / 巧克力大炮 /
///       脆心死神大炮 / 俱吠罗神使（护法）/ 白羊座精灵
///       这类走 tx_special_shot 的「原卡口径」，整轮效果保持原样
///     · 普通池 = 其余 81 条（平射 / 投手 / 追踪 / 纯防空 / 金卡 / 法师蛇 / bbq / 小笼包族），
///       **按档分层加权**（wt）：平射 50 > 投手 30 > 追踪 20 > 其他 10
///       （= 用户 2026-11-11 定的 10:6:4:2 等比放大，给 8周年蛋糕 6:3:1 留整数粒度）
///       金卡不另降权；法师蛇与 bbq 虽在普通池，毒雾 / 灼烧照旧保留
///   档位 w 已取消 → 下面的 tiers 只当分组标签用，不参与概率
///   每张卡只留最高转职形态的子弹；n = 这一轮打几发，per = 每批几发，gap = 批间隔帧
///     sp "rows3" 每 3 发一轮上/中/下三行；"rows" 多行铺开（可配 rows_off）；"rows2" 3 行×2 枚
///     "none" 原地连发（配 dxs/dys 换炮口）；"ang" 扇面角度（海星类）；"fan" 同排小偏移
///   mode = 另走 tx_special_shot 的原卡口径：
///     "zeus" "gaia" "cannon_lane" "cannon_target" "missile" "fashishe"
///     "huagao"（灯影花糕 8 只魂虫）"phoenix"（炎凰马 4 发）"cold_drew"（冰块 6 颗）
///     "gongjiang"（鲁班 2 折返 + 4 竖弹）"ice_god"（典伊 12 发）"baiyang"（白羊座冲撞车）
///     → 后 6 个是**整轮一次生成**
///     "bun"（小笼包族 8 张）：一批一个开火事件，n = 批数、per = 1、gap = 批间隔帧
///       bn_h / bn_x0 / bn_step = 每批水平发数 / 出膛点 x / 水平间距
///       bn_v / bn_vsep / bn_vspr = 配不配上下竖直弹 / 竖直间距 / 竖直弹对象
///   fx = 效果透传表（slow_timer / pierce_all / burn_damage / slow_frames / fire_chance …），
///        由 obj_tianxie 逐项写进子弹实例；dxs / dys = 按发序的出膛点；delays = 按发序的错帧
/// ============================================================================
function tx_pool_data()
{
    static _d = [
        { w: 10, name: "一档 直射·投掷", classes: [
            { name: "三线类", cards: [
                { nm: "三线酒架", o: obj_triplewinerack_bullet, dx: 40, dy: -80, spd: 8, n: 6, per: 3, gap: 10, sp: "rows3", wt: 50 },   // 满转 3 行 × 2 批（隔 10 帧）
                { nm: "子母三线酒架", o: obj_ronghesanxian_bullet, dx: 40, dy: -80, spd: 8, n: 9, per: 3, gap: 5, sp: "rows3", fx: { pierce_all: true, burn_damage: 190 }, wt: 50 },   // 满转 3 行 × 3 批；30% 挂燃烧（满级每跳 190）
                { nm: "射手座精灵", o: obj_sheshou_bullet, dx: 40, dy: -80, spd: 8, n: 6, per: 3, gap: 10, sp: "rows3", wt: 50 },   // 满转 3 行 × 2 批（隔 10 帧）
            ] },
            { name: "传统直线类", cards: [
                { nm: "冰冻小笼包", o: obj_icelongbao_bullet, dx: 40, dy: -75, spd: 8, wt: 50 },
                { nm: "咖啡杯", o: obj_coffeecup_bullet, dx: 40, dy: -35, spd: 8, shape: 2, wt: 50 },   // 满转射程整行
                { nm: "小笼包", o: obj_xiaolongbao_bullet, dx: 40, dy: -75, spd: 8, wt: 50 },
                { nm: "机枪咖啡杯", o: obj_ronghekafei_bullet, dx: 49, dy: -70, spd: 8, n: 3, per: 1, gap: 10, sp: "none", dxs: [49, 36, 72], dys: [-70, -49, -23], shape: 2, fx: { pierce_all: true }, wt: 50 },   // 满转 3 连发，三个炮口轮换
                { nm: "玉蜀黍", o: obj_corn_shooter_bullet_2, dx: 60, dy: -80, spd: 8, n: 6, per: 1, gap: 5, sp: "none", wt: 50 },   // 满转一轮 6 发
                // ── 小笼包族 8 张（2026-11-11 用户点名补齐）：全是直射 / 传统直线类 ──
                //   mode "bun"：**一批 = 一个开火事件**，整轮发数 / 批间隔照原卡走
                //     bn_h   = 每批水平发数（双层/三向/机枪都是 1，国王类 6）
                //     bn_x0  = 水平出膛点相对卡位的 x（原卡双层/三向/机枪 x+40，国王类 x+0）
                //     bn_step= 同一批里水平发之间的 x 间距（国王类 20，其余 0）
                //     bn_v / bn_vsep / bn_vspr = 配不配上下竖直弹、竖直间距、竖直弹对象
                //     n = 批数，per = 1，gap = 批间隔帧
                { nm: "双层小笼包", o: obj_xiaolongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, n: 2, per: 1, gap: 8, wt: 50 },   // 一轮 2 发水平（隔 8 帧）
                { nm: "双层冰冻小笼包", o: obj_icelongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, n: 2, per: 1, gap: 8, wt: 50 },   // 同上，冰冻弹（命中冰冻 600 帧）
                { nm: "三向小笼包", o: obj_xiaolongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, bn_v: true, bn_vspr: obj_xiaolongbao_bullet_vertical, n: 2, per: 1, gap: 12, wt: 50 },   // 2 批 × (水平 1 + 上下 2)
                { nm: "三向冰冻小笼包", o: obj_icelongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, bn_v: true, bn_vspr: obj_icelongbao_bullet_vertical, n: 2, per: 1, gap: 12, wt: 50 },   // 同上，冰冻弹
                { nm: "机枪小笼包", o: obj_xiaolongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, n: 6, per: 1, gap: 1, wt: 50 },   // 满转一轮 6 连发（每帧一发）
                { nm: "机枪冰冻小笼包", o: obj_icelongbao_bullet, mode: "bun", dx: 0, dy: -75, bn_h: 1, bn_x0: 40, n: 6, per: 1, gap: 1, wt: 50 },   // 同上，冰冻弹
                { nm: "国王小笼包", o: obj_xiaolongbao_bullet, mode: "bun", dx: 0, dy: -80, bn_h: 6, bn_x0: 0, bn_step: 20, n: 1, wt: 50 },   // 满转填满 5 槽 + 本体 = 6 发，按 x+20 铺开
                { nm: "三向国王小笼包", o: obj_xiaolongbao_bullet, mode: "bun", dx: 0, dy: -80, bn_h: 6, bn_x0: 0, bn_step: 20, bn_v: true, bn_vsep: 20, bn_vspr: obj_xiaolongbao_bullet_vertical, n: 1, wt: 50 },   // 6 列 × (水平 1 + 上下 2)
            ] },
            { name: "单线投手", cards: [
                { nm: "8周年蛋糕块", o: obj_eightcake_bullet, dx: -104, dy: -99, arc: true, wt: 18 },   // 二转按轮次轮换：多数轮是单体蛋糕块
                { nm: "8周年蜡烛", o: obj_eightcake_burn_bullet, dx: -104, dy: -99, arc: true, wt: 9 },   // 每 3 发一次，落地单格灼烧
                { nm: "8周年可乐炸弹", o: obj_eightcake_bomb, dx: -104, dy: -99, arc: true, wt: 3 },   // 每 10 发一次，3×3 灰烬
                { nm: "冰煮蛋器", o: obj_iceeggboilerpult_bullet, dx: -40, dy: -125, spd: 8, a: true, shape: 2, wt: 30 },   // 满转 25% 溅射 ±2 行 350px
                { nm: "双鱼座精灵", o: obj_shuangyu_bullet, dx: -60, dy: -145, spd: 8, a: true, shape: 2, n: 2, sp: "none", dxs: [-60, -20], dys: [-145, -105], wt: 30 },   // 同帧两发，两个错位出弹口
                { nm: "巧克力投手", o: obj_chocolatepult_bullet, dx: -20, dy: -125, spd: 8, a: true, shape: 2, n: 2, per: 1, gap: 11, sp: "none", wt: 30 },   // 同点连发 2 发，隔 11 帧
                { nm: "烤蜥蜴投手", o: obj_grilledlizardpult_bullet, dx: -30, dy: -135, spd: 10, a: true, shape: 2, n: 2, per: 1, gap: 10, sp: "none", wt: 30 },
                { nm: "煮蛋器投手", o: obj_eggboilerpult_bullet, dx: -40, dy: -125, spd: 8, a: true, shape: 2, n: 2, per: 1, gap: 10, sp: "none", wt: 30 },
                { nm: "臭豆腐投手", o: obj_stinkytofupult_bullet, dx: 20, dy: -125, spd: 8, a: true, shape: 2, n: 2, per: 1, gap: 11, sp: "none", poison_chance: 50, poison_spr: spr_stinkytofupult_bullet_poison, wt: 30 },   // 原卡 irandom(99)<50 出毒
                { nm: "色拉投手", o: obj_saladpult_bullet, dx: 40, dy: -95, spd: 8, a: true, shape: 2, n: 2, per: 1, gap: 21, sp: "none", wt: 30 },
                { nm: "雪芭煮蛋器", o: obj_ronghedan_god_bullet, dx: -40, dy: -125, spd: 8, a: true, shape: 2, n: 6, sp: "rows2", wt: 30 },   // 3 行 × 每行 2 枚
            ] },
            { name: "固定轨迹类", cards: [
                { nm: "灯影花糕", o: obj_huagao_bullet, mode: "huagao", n: 8, wt: 50 },   // 满转 8 只魂虫（2 缝隙 × 左右 × 2 层）
                { nm: "炎凰马", o: obj_zodiac_projectile, mode: "phoenix", n: 4, wt: 50 },   // 满转 左右各 1 × 2 条缝隙 = 4 发
                { nm: "赖皮蛇", o: obj_laipishe_bullet, dx: 0, dy: 0, spd: 6, wt: 50 },
                { nm: "迷你披萨炉", o: obj_pizzaoven_bullet, dx: 40, dy: -70, spd: 8, wt: 50 },
            ] },
            { name: "多线投手", cards: [
                { nm: "全能糖球投手", o: obj_sugarballpult_bullet, dx: -40, dy: -125, spd: 8, a: true, shape: 2, n: 2, per: 1, gap: 10, sp: "none", wt: 30 },
                { nm: "勺勺兔", o: obj_spoon_rabbit_bullet, dx: 0, dy: -160, spd: 8, a: true, n: 6, per: 3, gap: 10, sp: "rows3", wt: 30 },   // 满转 3 行 × 2 批
                { nm: "幻影蛇", o: obj_huanyingshe_bullet, dx: 40, dy: -80, spd: 8, a: true, n: 6, sp: "rows", rows_off: [-2, -1, 0, 1, 2, 2], wt: 30 },   // 6 发铺 5 行（余量补最前路）
            ] },
            { name: "水管类", cards: [
                { nm: "双向水管", o: obj_waterpipe_bullet, dx: 40, dy: -75, spd: 8, n: 6, per: 2, gap: 15, sp: "none", dxs: [40, -40, 40, -40, 40, -40], mir: true, wt: 50 },   // 满转 Step 开火 3 次 × 左右各 1 = 6 发
                { nm: "天秤座精灵", o: obj_tiancheng_bullet, dx: 40, dy: -75, spd: 8, n: 8, per: 2, gap: 10, sp: "none", dxs: [40, -40, 40, -40, 40, -40, 40, -40], mir: true, wt: 50 },   // 满转 Step 开火 4 次 × 左右各 1 = 8 发
            ] },
            { name: "海星类", cards: [
                { nm: "仙人球海星刺身", o: obj_ronghehaixing_bullet, dx: 0, dy: -45, n: 11, sp: "ang", ang: [180,180,180, 90,90, -90,-90, -145,-145, 145,145], mvs: [-8,-8,-8, 0,0, 0,0, 5,5, 5,5], mvys: [0,0,0, 8,8, -8,-8, -3,-3, 3,3], delays: [0,5,10, 0,5, 0,5, 0,5, 0,5], shape: 2, wt: 50 },   // 5 方向 × 3/2/2/2/2 发，同向错 5 帧
                { nm: "炭烧海星", o: obj_coalstarfish_bullet, dx: 0, dy: -45, n: 10, per: 5, gap: 6, sp: "ang", ang: [180, 90, -90, -145, 145], mvs: [-8, 0, 0, 5, 5], mvys: [0, 8, -8, -3, 3], shape: 2, wt: 50 },   // 5 方向 × 2 批（隔 6 帧）
                { nm: "猪猪料理机", o: obj_zhuzhuliaoliji_bullet, dx: 0, dy: -45, n: 10, per: 5, gap: 5, sp: "ang", ang: [180, 90, -90, -31, 31], vxs: [-8, 0, 0, 5, 5], vys: [0, 8, -8, -3, 3], shape: 2, fx: { slow_frames: 90 }, wt: 50 },   // 5 向 × 2 批；命中减速 1.5 秒
            ] },
            { name: "灼烧投手", cards: [
                { nm: "生煎锅", o: obj_panfriedbun_bullet, dx: 40, dy: -95, spd: 8, a: true, shape: 2, wt: 30 },   // 满转落地 3×3（上下各 1 行 +200px）
                { nm: "糖炒栗子", o: obj_tangchaolizi_bullet, dx: 40, dy: -80, spd: 8, a: true, shape: 2, art_up: 36, spr: spr_tangchaolizi_bullet_2, wt: 30 },   // 落点纵向按贴图格线上抬 36（原卡 _art_up）；满转落地 3×3
                { nm: "酱香锅烤栗子", o: obj_lizi_god_bullet, dx: 20, dy: -80, spd: 8, a: true, n: 3, sp: "rows3", shape: 2, wt: 30 },   // 三行各 1，同帧；满转特效 + 深度爆炸
                { nm: "铛铛虎", o: obj_dangdanghu_bullet, dx: 10, dy: -60, spd: 8, a: true, shape: 2, spr: spr_dangdanghu_bullet_2, wt: 30 },   // 它 Create 里 sx/tx 全是 0，必须由 tx_spawn 补落点；满转 3×3 方块
            ] },
            { name: "特殊直线类", cards: [
                { nm: "焚寂马", o: obj_zodiac_projectile, dx: 0, dy: -30, spd: 8, k: "fire", shape: 2, wt: 50 },   // 满转命中裂 5 道 wave
            ] },
            { name: "A型穿透类", cards: [
                { nm: "双刃蛇", o: obj_double_blade_snake_bullet, dx: 40, dy: -80, spd: 8, wt: 50 },
                { nm: "御风马", o: obj_zodiac_projectile, dx: 0, dy: -30, spd: 8, k: "wind", shape: 2, wt: 50 },   // 满转秒杀 / 击退
            ] },
            { name: "类海星类", cards: [
                { nm: "邪恶牛油果", o: obj_niuyouguo_bullet, dx: 42, dy: -58, spd: 9, n: 6, per: 3, gap: 4, sp: "ang", ang: [0, -35.26, 35.26, 0, -35.26, 35.26], tdirs: [0, -35.26, 35.26, 0, -35.26, 35.26], fx: { slow_timer: 90, pierce_all: true }, wt: 50 },   // 满转 3 向 × 2 批（隔 4 帧）；减速 90 帧 + 全程穿透
                { nm: "星星兔", o: obj_zodiac_projectile, dx: 0, dy: -30, spd: 8, n: 5, sp: "ang", ang: [0, 22.5, -22.5, 45, -45], k: "star", wt: 50 },   // 五向齐射
                { nm: "火影怪味鱿鱼", o: obj_youyu_god_bullet, dx: 7, dy: -44, spd: 8, n: 22, sp: "ang", ang: [0,0,0, 30,30, 60,60, 90,90, 135,135, 180,180,180, 225,225, 270,270, 300,300, 330,330], delays: [0,4,8, 0,4, 0,4, 0,4, 0,4, 0,4,8, 0,4, 0,4, 0,4, 0,4], shape: 2, wt: 50 },   // 满转 10 向，每向 2 发（中路 3 发），同向错 4 帧
            ] },
            { name: "B型穿透类", cards: [
                { nm: "法师蛇", o: obj_fashishe_bullet, mode: "fashishe", n: 9, per: 3, gap: 14, wt: 50 },   // 3 批 × 3 行；出膛点在地图左沿外半格、row 各不同、第 3 批铺毒（口径见 tx_special_shot）
                { nm: "焦油喷壶", o: obj_tarsprayer_bullet, dx: 50, dy: -75, spd: 8, shape: 2, wt: 50 },   // 满转射程 7 格
                { nm: "街头烤肉大师", o: obj_bbq_bullet, dx: 40, dy: -80, spd: 8, n: 6, per: 3, gap: 14, sp: "rows3", burn: true, wt: 50 },   // 满转 3 行 × 2 批；每第 4 发爆辣 + 铺火格
            ] },
        ] },
        { w: 6, name: "二档 防空·追踪", classes: [
            { name: "散点追踪", cards: [
                { nm: "冰块冷萃机", o: obj_cold_drew_bullet, mode: "cold_drew", n: 6, wt: 20 },   // 满转 6 颗，各打不同目标
            ] },
            { name: "特殊追踪", cards: [
                { nm: "归元马", o: obj_zodiac_projectile, dx: 0, dy: -35, spd: 8, a: true, n: 2, sp: "none", dys: [-35, -47], k: "return", shape: 2, wt: 20 },   // 同点上下错 12px
            ] },
            { name: "纯对空类", cards: [
                { nm: "糖葫芦炮弹", o: obj_tanghulu_bullet, dx: 0, dy: -95, spd: 10, n: 2, per: 1, gap: 15, sp: "none", wt: 10 },
                { nm: "防空喵", o: obj_fangkongmiao_bullet, dx: 0, dy: -95, spd: 11, n: 2, per: 1, gap: 12, sp: "none", shape: 2, fx: { slow_frames: 180 }, wt: 10 },   // 命中减速 3 秒
            ] },
            { name: "陆空兼备类", cards: [
                { nm: "梦幻多拿滋", o: obj_donut_bullet, dx: 20, dy: -30, spd: 6, n: 3, per: 1, gap: 5, sp: "none", shape: 2, wt: 10 },
                { nm: "热狗大炮", o: obj_hotdogcannon_bullet, dx: 40, dy: -65, spd: 8, a: true, n: 2, per: 1, gap: 5, sp: "none", wt: 10 },   // 原卡无空军 2 发、有空军 4 发
                { nm: "热狗蚝油双菇", o: obj_rongheshuanggu_bullet, o2: obj_rongheshuanggu_bullet_air, dx: 40, dy: -48, spd: 8, dy2: -128, n: 4, per: 1, gap: 3, sp: "none", fx: { pierce_all: true }, wt: 10 },   // 陆 4 + 空 4
                { nm: "蚝油双菇", o: obj_shuanggu_bullet, o2: obj_shuanggu_bullet_air, dx: 40, dy: -48, spd: 8, dy2: -128, n: 3, per: 1, gap: 5, sp: "none", wt: 10 },   // 陆 3 + 空 3
                { nm: "香肠", o: obj_sausage_bullet, dx: 40, dy: -65, spd: 8, a: true, wt: 10 },
            ] },
            { name: "飞镖追踪", cards: [
                { nm: "巨蟹座精灵", o: obj_juxie_bullet_2, dx: 40, dy: -55, spd: 10, a: true, n: 6, per: 1, gap: 5, sp: "none", wt: 20 },
                { nm: "章鱼烧", o: obj_takoyaki_bullet, dx: 0, dy: -55, spd: 10, a: true, n: 4, per: 2, gap: 31, sp: "none", dxs: [0, 40, 0, 40], wt: 20 },   // 每批 x 与 x+40 各 1，共 2 批
            ] },
        ] },
        { w: 2, name: "三档 大炮", classes: [
            { name: "怪物转移类", cards: [
                { nm: "逆转牛", o: obj_tianxie_alt, dx: 40, dy: -20, spd: 0, alt: "cow", spt: true },
            ] },
            { name: "群轰追踪", cards: [
                { nm: "咖喱龙虾炮", o: obj_currylobstercannon_bullet, mode: "cannon_target", dx: 0, dy: -90, dep: -1, n: 3, gap: 15, per: 1, spr: spr_curry_lobster_cannon_bullet_2, wt: 20 },   // 落点 = 优先级敌人那一格；每轮 3 发错 15 帧
                { nm: "火箭猪", o: obj_huojianzhu_bullet, mode: "missile", n: 3, wt: 20 },   // 3 枚导弹，错帧由 launch_delay 自己做
            ] },
            { name: "轰炸型", cards: [
                { nm: "巧克力大炮", o: obj_chocolatecannon_bullet, mode: "cannon_lane", col: 8, dx: 0, dy: -60, dep: -1, n: 2, gap: 6, per: 1, spt: true },   // 砸本行第 9 格，最高形态 2 发
                { nm: "盖亚神使", o: obj_gaia_bullet, mode: "gaia", n: 3, gap: 10, per: 1, spt: true },   // 3 发落石错 10 帧，落点 = 敌人身上
                { nm: "脆心死神大炮", o: obj_ronghedapao_bullet, mode: "cannon_lane", col: 8, dx: 0, dy: -100, dep: 1, n: 2, gap: 7, per: 1,
                  spr: spr_ronghedapao_bullet_2, blast_shape: 2, blast_row_half: 2, blast_col_half: 1, crush_kill: true, spt: true },   // 2 发错 7 帧；5 行×3 列爆炸 + 碾压
            ] },
            { name: "面包类", cards: [
                { nm: "桂花酒", o: obj_tianxie_alt, dx: 40, dy: -20, spd: 0, alt: "wine", spt: true },
            ] },
        ] },
        { w: 1, name: "四档 金卡·白羊", classes: [
            { name: "三线类", cards: [
                { nm: "丘比特神使", o: obj_love_god_bullet_3, dx: 40, dy: -80, spd: 8, n: 9, per: 3, gap: 10, sp: "rows3", shape: 3, wt: 50 },   // 满转 3 批 × 3 行
            ] },
            { name: "单线投手", cards: [
                { nm: "索尔神使", o: obj_thor_bullet, dx: -40, dy: -125, spd: 8, a: true, n: 3, per: 1, gap: 10, sp: "none", shape: 3, wt: 30 },
            ] },
            { name: "固定轨迹类", cards: [
                { nm: "神农氏神使", o: obj_shennong_god_bullet_h, dx: 40, dy: -80, spd: 6, n: 2, sp: "rows3", shape: 3, wt: 50 },   // 上行 + 本行各 1，同帧
                { nm: "鲁班神使", o: obj_gongjiang_god_bullet_horizontal, mode: "gongjiang", n: 6, wt: 50 },   // 满转 2 条折返 + 第 0/1 列上下竖弹 4 颗
            ] },
            { name: "多线投手", cards: [
                { nm: "尤弥尔神使", o: obj_ymir_bullet, dx: 40, dy: -80, spd: 8, a: true, n: 12, per: 3, gap: 5, sp: "rows3", shape: 3, wt: 30 },   // 满转 4 批 × 3 行
            ] },
            { name: "散点追踪", cards: [
                { nm: "典伊神使", o: obj_ice_god_bullet, mode: "ice_god", n: 12, wt: 20 },   // 12 发错高 50px，各锁一个目标
            ] },
            { name: "旋转喷壶类", cards: [
                { nm: "俱吠罗神使", o: obj_hufa_god_bullet, dx: 0, dy: -75, spd: 8, shape: 3, spr: spr_hufa_god_bullet_3, spt: true },   // 最高形态（转圈水球，Step 会朝 target_id 追）
            ] },
            { name: "水管类", cards: [
                { nm: "阿瑞斯神使", o: obj_war_god_bullet, dx: 40, dy: -50, spd: 8, n: 10, per: 2, gap: 5, sp: "none", dxs: [40, -40, 40, -40, 40, -40, 40, -40, 40, -40], mir: true, wt: 50 },   // 左右对射 × 5 批
            ] },
            { name: "海星类", cards: [
                { nm: "哈迪斯神使", o: obj_ghost_god_bullet_ping, dx: 0, dy: -50, n: 20, per: 5, gap: 5, sp: "ang", spds: [-8, 8, -8, 8, -8], mix: [obj_ghost_god_bullet_ping, obj_ghost_god_bullet_zhi, obj_ghost_god_bullet_zhi, obj_ghost_god_bullet_xie, obj_ghost_god_bullet_xie], ang: [180, 270, 90, 315, 45], shape: 3, wt: 50 },   // 满转 4 批 × 5 向（ping / zhi×2 / xie×2）
            ] },
            { name: "灼烧投手", cards: [
                { nm: "祝融神使", o: obj_zhurong_bullet, dx: 20, dy: -105, spd: 8, a: true, shape: 3, wt: 30 },   // 满转落点 7 行 × 5 列灼烧
            ] },
            { name: "类海星类", cards: [
                { nm: "里格神使", o: obj_rig_bullet, spr: spr_rig_bullet_3, shape: 3, dx: 60, dy: -40, spd: 8, n: 5, sp: "ang", mix: [obj_rig_bullet, obj_rig_bullet_oblique, obj_rig_bullet_oblique, obj_rig_bullet_oblique, obj_rig_bullet_oblique], ang: [0, 45, -45, 22.5, -22.5], wt: 50 },   // 1 直射 + 4 斜射（终转贴图 spr_rig_bullet_3）
            ] },
            { name: "纯对空类", cards: [
                { nm: "赫丘利神使", o: obj_power_god_bullet_1, dx: 40, dy: -80, spd: 8, n: 4, per: 1, gap: 10, sp: "none", wt: 10 },
            ] },
            { name: "群轰追踪", cards: [
                { nm: "宙斯神使", o: obj_zeus_bullet, mode: "zeus", n: 5, gap: 5, per: 1, wt: 20 },   // 一轮 5 道闪电，间隔 5 帧
            ] },
            { name: "B型穿透类", cards: [
                { nm: "后羿神使", o: obj_houyi_god_bullet, dx: 40, dy: -75, spd: 8, n: 3, sp: "rows3", dys: [-95, -75, -55], shape: 3, fx: { fire_chance: 0.30, burn_bonus: true, ash_kill: true, sanwei_stack: 2 }, wt: 50 },   // 满转三行各 1（上/中/下错 20px），30% 三昧真火
                { nm: "奥丁神使", o: obj_odin_bullet, dx: 40, dy: -95, spd: 8, shape: 3, wt: 50 },
            ] },
            { name: "陆空兼备类", cards: [
                { nm: "埃罗斯神使", o: obj_joker_bullet_3, dx: 40, dy: -80, spd: 8, n: 4, per: 1, gap: 15, sp: "none", wt: 10 },
            ] },
            { name: "飞镖追踪", cards: [
                { nm: "狄安娜神使", o: obj_moon_god_bullet, dx: 0, dy: -55, spd: 10, a: true, n: 8, per: 1, gap: 5, sp: "none", wt: 20 },
            ] },
            { name: "白羊类", cards: [
                { nm: "白羊座精灵", o: obj_baiyang_effect, mode: "baiyang", n: 1, spt: true },   // 本行一台冲撞车，撞飞秒杀（BOSS / 魂系鼠豁免）
            ] },
        ] },
    ];
    // ── 拍平两份池子（2026-11-11 第二轮重排）────────────────────────────────
    //   写 spt: true 的进**特殊池**（逆转牛 / 桂花酒 / 盖亚 / 两个巧克力大炮 / 护法 / 白羊座），
    //   其余全部进**普通池**（平射 / 投手 / 追踪 / 纯防空 / 金卡一律等权，金卡不另降权）。
    //   上面的档位 w 与 classes 现在只当分组标签，不参与概率。
    //   普通池另带一份**同长权重表** nw：没写 wt 的一律 10，八周年拆出来的三条写 6 / 3 / 1 →
    //     三条合起来正好等于「一张卡」的权重，不会被拆成三张、把别的卡稀释掉。
    //   返回 struct{ normal, special, nw }，obj_tianxie 的 tx_roll 按池抽 / 按权重抽。
    static _r = undefined;
    if (is_undefined(_r))
    {
        var _fn = [], _fs = [], _fw = [];
        for (var _t = 0; _t < array_length(_d); _t++)
        {
            for (var _c = 0; _c < array_length(_d[_t].classes); _c++)
            {
                var _cs = _d[_t].classes[_c].cards;
                for (var _k = 0; _k < array_length(_cs); _k++)
                {
                    if (variable_struct_exists(_cs[_k], "spt") && _cs[_k].spt) array_push(_fs, _cs[_k]);
                    else
                    {
                        array_push(_fn, _cs[_k]);
                        array_push(_fw, variable_struct_exists(_cs[_k], "wt") ? _cs[_k].wt : 10);
                    }
                }
            }
        }
        _r = { normal: _fn, special: _fs, nw: _fw };
    }
    return _r;
}

/// 整轮一次生成的口径（灯影花糕 / 炎凰马 / 冰块冷萃机 / 鲁班 / 典伊 / 白羊座）
///   这几张原卡是**一个开火事件里把整轮铺完**（不按 n 逐发循环），走 tx_special_shot 一次出完，
///   由 obj_tianxie 的 tx_spawn 判断后直接调，不再进「n 发循环 + gap 错帧」那套
function tx_is_whole_mode(_card)
{
    if (!variable_struct_exists(_card, "mode")) return false;
    var _m = _card.mode;
    return (_m == "huagao" || _m == "phoenix" || _m == "cold_drew"
         || _m == "gongjiang" || _m == "ice_god" || _m == "baiyang");
}

/// 全屏**最靠左**的可打敌人（_type = 弹体的 target_type：normal / track / air_only…）
///   局部变量在 with 里属于函数本身，所以直接用一个 var 收结果即可
function tx_enemy_leftmost(_type)
{
    var _id = noone, _bx = 999999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (!can_target_on(_type, target_type)) continue;
        if (x < _bx)
        {
            _bx = x;
            _id = id;
        }
    }
    return _id;
}

/// 离 _self **最近**的可打敌人（火箭猪的原卡口径：打离自己最近那只）
function tx_enemy_nearest(_self, _type)
{
    var _id = noone, _bd = 999999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (!can_target_on(_type, target_type)) continue;
        var _d = point_distance(x, y, _self.x, _self.y);
        if (_d < _bd)
        {
            _bd = _d;
            _id = id;
        }
    }
    return _id;
}

/// 复刻「法师蛇」的毒雾（原卡 fashishe_poison_at 的移植），**全局函数版**
///   _self = 天蝎座实例（伤害读它的 atk）；全局版是为了让 tx_special_shot 也能铺毒
///   · 行末 3 格（第 7~9 列），最右一格能烧到场外 1 格
///   · 每跳伤害 = 天蝎座 atk；持续 / 跳数读 fashishe 注册表的 custom
function tx_poison_at(_self, _row)
{
    var _dur = 1, _ticks = 5;
    var _fi = get_plant_data_with_skill("fashishe", 2, 16, 0);
    if (_fi != undefined && ds_map_exists(_fi, "毒雾持续")) _dur   = _fi[? "毒雾持续"];
    if (_fi != undefined && ds_map_exists(_fi, "毒雾次数")) _ticks = _fi[? "毒雾次数"];
    var _frames   = max(1, round(_dur * 60));
    var _interval = max(1, round(_frames / max(1, _ticks)));

    var _c0 = global.grid_cols - 1;
    for (var _i = 0; _i < 3; _i++)
    {
        var _c = _c0 - _i;
        if (_c < 0) continue;
        var _cell = get_world_position_from_grid(_c, _row);

        var _fw = 69, _fh = 58, _fcx = 44.5, _fcy = 53;
        var _sx = global.grid_cell_size_x / _fw;
        var _sy = global.grid_cell_size_y / _fh;
        var _bx = _cell.x - (_fcx - sprite_get_xoffset(spr_fashishe_burn_ground)) * _sx;
        var _by = (_cell.y - 36) - (_fcy - sprite_get_yoffset(spr_fashishe_burn_ground)) * _sy;

        var _p = instance_create_depth(_bx, _by, -10 - _row * 45, obj_fashishe_poison_cell);
        _p.sprite_index = spr_fashishe_burn_ground;
        _p.frame_start  = 0;
        _p.frame_end    = sprite_get_number(spr_fashishe_burn_ground) - 1;
        _p.anim_loop_frames = 30;
        _p.damage        = _self.atk;
        _p.damage_type   = "normal";
        _p.life          = _frames;
        _p.tick_interval = _interval;
        _p.lock_grid     = true;
        _p.grid_col      = _c;
        _p.grid_row      = _row;
        _p.hittable_types = get_hittable_enemy_types("all");
        _p.extra_col_right = (_i == 0) ? 1 : 0;
        _p.image_xscale = _sx;
        _p.image_yscale = _sy;
    }
}

/// ============================================================================
/// 特殊子弹：**按原卡口径**生成（2026-11-11 用户口径「特殊子弹都按原卡参数和情况弄」）
///   平射 / 投掷 / 追踪这类通用弹体，obj_tianxie 的通用逻辑（出生点 + 速度 + 抛物线）就够；
///   但宙斯、盖亚、大炮、火箭猪这些弹体的「出生点 / 索敌 / 落点 / 形态参数」是各卡自己算的，
///   通用逻辑猜不准（落点、贴图、爆炸范围会全错），所以这里照抄原卡的开火事件：
///     "zeus"          宙斯神使      ← objects/obj_zeus/Other_11
///     "gaia"          盖亚神使      ← objects/obj_gaia/Other_11
///     "cannon_lane"   巧克力 / 死神炮 ← obj_chocolate_cannon / obj_ronghedapao/Other_11
///     "cannon_target" 咖喱龙虾炮    ← obj_curry_lobster_cannon/Other_11
///     "missile"       火箭猪        ← obj_huojianzhu/Other_11
///     "fashishe"      法师蛇        ← obj_fashishe（出膛点 / 分批 / 毒雾）
///     "huagao"        灯影花糕 8 只魂虫   ← obj_huagao/Step_0
///     "phoenix"       炎凰马 4 发         ← obj_yanhuangma/Step_0
///     "cold_drew"     冰块冷萃机 6 颗     ← obj_cold_drew/Other_11
///     "gongjiang"     鲁班 2 折返 + 4 竖弹 ← obj_gongjiang_god/Other_11
///     "ice_god"       典伊 12 发          ← obj_ice_god/Other_11
///     "baiyang"       白羊座 1 行冲撞车    ← obj_baiyang/Step_0
///   后 6 个是**整轮一次生成**（tx_is_whole_mode），不看 n / per / gap。
///   参数一律取**最高转职形态**（原卡 shape 2 / 3 的数值），伤害一律 = 天蝎座 atk。
///   🔴 _self = 天蝎座实例（x / y / depth / atk / grid_row 都从它读），不要在函数里写 self
/// ============================================================================
function tx_special_shot(_self, _card, _si)
{
    var _dx = variable_struct_exists(_card, "dx") ? _card.dx : 0;
    var _dy = variable_struct_exists(_card, "dy") ? _card.dy : -80;
    var _dep = variable_struct_exists(_card, "dep") ? _card.dep : 0;

    // ── 法师蛇：**出膛点在地图最左沿外半格**，不是卡口（2026-11-11 修）──────────
    //   原卡 fashishe_fire_one：x = grid_offset_x - 0.5 格、y = 该行格中线 - 36、
    //   每批 3 行同时各出一颗（row 各不同）；第 3 批（第 3/6/9 发）当帧给这三行铺毒雾。
    //   走通用逻辑的话子弹从卡口飞出、row 全压在天蝎座那一行 → 看着歪、判定也错。
    if (_card.mode == "fashishe")
    {
        var _fr    = clamp(_self.grid_row + (_si mod 3) - 1, 0, global.grid_rows - 1);
        var _lane  = global.grid_offset_y + _fr * global.grid_cell_size_y + global.grid_cell_size_y * 0.5 - 36;
        var _start = global.grid_offset_x - 0.5 * global.grid_cell_size_x;
        var _end   = global.grid_offset_x + (global.grid_cols + 1) * global.grid_cell_size_x;

        var _bf = instance_create_depth(_start, _lane, _self.depth - 500, obj_fashishe_bullet);
        _bf.row            = _fr;
        _bf.base_y         = _lane;
        _bf.phase          = 0;
        _bf.damage         = _self.atk;
        _bf.end_x          = _end;
        _bf.damage_type    = "pierce";                       // 毒针全程穿透（同原卡，能穿地形障碍）
        _bf.target_type    = "normal";
        _bf.hittable_types = get_hittable_enemy_types("normal");
        _bf.sprite_index   = spr_fashishe_bullet_2;          // 最高形态

        // 第 3 批（_si 6~8）铺毒雾：本批的 3 行各铺一次（tx_poison_cells 里按行铺行末 3 格）
        if (_si div 3 == 2) tx_poison_at(_self, _fr);
        return;
    }

    // ── 宙斯：锁全屏最靠左敌人 → 提前量 30 帧 → 电击落在 predicted_x ──────────
    //   弹体建在落点右边 100px、同高（y-50）；命中范围由弹体自己的 _range / _r 决定
    if (_card.mode == "zeus")
    {
        var _tz = tx_enemy_leftmost("track");
        if (!instance_exists(_tz)) return;

        var _zes = variable_instance_exists(_tz, "move_speed") ? _tz.move_speed : 0;
        var _zpx = _tz.x - _zes * 30;
        var _zpy = _tz.y - 50;

        var _bz = instance_create_depth(_zpx + 100, _zpy, _self.depth - 1, obj_zeus_bullet);
        _bz.atk      = _self.atk;
        _bz.damage   = _self.atk;
        _bz.target_x = _zpx;
        _bz.target_y = _zpy;
        _bz.grid_row = _tz.grid_row;
        _bz.grid_col = _tz.grid_col;
        _bz._range   = 240;    // 最高形态（原卡 shape 3）：240px / ±2 行
        _bz._r       = 2;
        return;
    }

    // ── 盖亚：建在本卡上方 330px → 升到屏幕顶 → 换到 target_x 从天上砸下来 ──────
    //   落点 = 敌人**身上**（原卡传的是 target_enemy.y，别减 50）· row 用目标行
    if (_card.mode == "gaia")
    {
        var _tg = tx_enemy_leftmost("normal");
        var _gtx, _gty, _grow;

        if (instance_exists(_tg))
        {
            _gtx = _tg.x; _gty = _tg.y; _grow = _tg.grid_row;
        }
        else
        {
            // 空放：原卡落到最右场外一格、本行高度
            var _gcell = get_world_position_from_grid(global.grid_cols, _self.grid_row);
            _gtx = _gcell.x; _gty = _self.y; _grow = _self.grid_row;
        }

        var _bg = instance_create_depth(_self.x, _self.y - 330, _self.depth - 45, obj_gaia_bullet);
        _bg.target_x     = _gtx;
        _bg.target_y     = _gty;
        _bg.row          = _grow;
        _bg.damage       = _self.atk;
        _bg.shape_bullet = 2;                      // 最高形态（原卡 shape 2）
        _bg.sprite_index = spr_gaia_bullet_2;
        return;
    }

    // ── 固定列大炮（巧克力 / 脆心死神）：升空 → 砸本行第 9 格（col = 8）───────
    //   不吃敌人位置，原卡就是固定砸行末；爆炸范围 / 碾压由数据表 blast_* 传
    if (_card.mode == "cannon_lane")
    {
        var _bc = instance_create_depth(_self.x + _dx, _self.y + _dy, _self.depth + _dep, _card.o);
        _bc.target_col = variable_struct_exists(_card, "col") ? _card.col : global.grid_cols - 1;
        _bc.target_row = _self.grid_row;
        _bc.damage     = _self.atk;

        if (variable_struct_exists(_card, "spr"))             _bc.sprite_index   = _card.spr;
        if (variable_struct_exists(_card, "blast_shape"))     _bc.blast_shape    = _card.blast_shape;
        if (variable_struct_exists(_card, "blast_row_half"))  _bc.blast_row_half = _card.blast_row_half;
        if (variable_struct_exists(_card, "blast_col_half"))  _bc.blast_col_half = _card.blast_col_half;
        if (variable_struct_exists(_card, "crush_kill"))      _bc.crush_kill     = _card.crush_kill;
        return;
    }

    // ── 追敌格大炮（咖喱龙虾炮）：落点 = 优先级敌人那一格 ────────────────────
    //   弹体带 target_enemy，下落期间目标死了会自己重锁（原卡 Step 的行为）
    if (_card.mode == "cannon_target")
    {
        var _tc = tx_enemy_leftmost("track");
        if (!instance_exists(_tc)) return;

        var _bt = instance_create_depth(_self.x + _dx, _self.y + _dy, _self.depth + _dep, _card.o);
        _bt.target_col   = _tc.grid_col;
        _bt.target_row   = _tc.grid_row;
        _bt.target_enemy = _tc;
        _bt.damage       = _self.atk;
        _bt.b_shape      = 2;                      // 最高形态（爆炸贴图用）
        if (variable_struct_exists(_card, "spr")) _bt.sprite_index = _card.spr;
        return;
    }

    // ── 火箭猪：导弹直接建在**最近敌人**那格上方 30px，3 枚错开 10 帧 ─────────
    if (_card.mode == "missile")
    {
        var _tm = tx_enemy_nearest(_self, "track");
        if (!instance_exists(_tm)) return;

        var _mcell = get_world_position_from_grid(_tm.grid_col, _tm.grid_row);
        var _bm = instance_create_depth(_mcell.x, _mcell.y - 30, _self.depth - 500, obj_huojianzhu_bullet);
        _bm.damage       = _self.atk;
        _bm.target_enemy = _tm;
        _bm.grid_row     = _tm.grid_row;
        _bm.grid_col     = _tm.grid_col;
        _bm.launch_delay = _si * 10;               // 原卡：第 i 枚错开 i*10 帧
        _bm.wave         = _si;
        _bm.sprite_index = spr_huojianzhu_bullet_2;

        // 定身时间：读注册表 custom["定身时间"]（最高形态 2 秒；BOSS 由敌人父对象免疫）
        var _mst   = 2;
        var _minfo = get_plant_data_with_skill("huojianzhu", 2, 16, 0);
        if (_minfo != undefined && ds_map_exists(_minfo, "定身时间")) _mst = _minfo[? "定身时间"];
        _bm.stun_frames = round(_mst * 60);
        return;
    }

    // ── 灯影花糕：**整轮 8 只魂虫一次铺完**（原卡 obj_huagao/Step_0 的开火段）──────
    //   2 条缝隙 × 左右两端 × 2 层 = 8 只，全部横飞（vertical = false），
    //   每只覆盖缝隙上下两行；中路敌人吃 4 下、边路吃 2 下（hits_mid / hits_side）
    if (_card.mode == "huagao")
    {
        var _h_spr    = huagao_bullet_sprite(2);              // 最高形态贴图
        var _h_tag    = huagao_next_attack_tag();             // 同一轮共用（每敌只结算一次）
        var _h_gaps   = [clamp(_self.grid_row, 1, global.grid_rows - 1),
                         clamp(_self.grid_row + 1, 1, global.grid_rows - 1)];
        var _h_sides  = [combat_left_x() - 20, combat_right_x() + 20];
        var _h_dirs   = [1, -1];

        for (var _hg = 0; _hg < 2; _hg++)
        {
            var _h_gap = _h_gaps[_hg];
            var _h_cov = [];
            if (_h_gap - 1 >= 0)               array_push(_h_cov, _h_gap - 1);
            if (_h_gap < global.grid_rows)     array_push(_h_cov, _h_gap);
            var _h_gy = global.grid_offset_y + (_h_gap - 0.25) * global.grid_cell_size_y;

            for (var _hs = 0; _hs < 2; _hs++)
            {
                for (var _hl = 0; _hl < 2; _hl++)
                {
                    var _h_y = _h_gy + ((_hl == 0) ? -10 : 10);      // 两层错 10px
                    huagao_spawn_bug(_self, _h_sides[_hs], _h_y, _h_dirs[_hs], false, _h_cov, [],
                                     _self.grid_row, _h_spr, _self.atk, 4, 2, _h_tag);
                }
            }
        }
        return;
    }

    // ── 炎凰马：**整轮 4 发一次铺完**（原卡 obj_yanhuangma/Step_0 的开火段）──────
    //   上缝隙左→右、下缝隙左→右；横向全程穿透，满转击杀出灰烬
    if (_card.mode == "phoenix")
    {
        var _ph_up   = clamp(_self.grid_row, 1, global.grid_rows - 1);
        var _ph_dn   = clamp(_self.grid_row + 1, 1, global.grid_rows - 1);
        var _ph_gaps = [_ph_up, _ph_up, _ph_dn, _ph_dn];
        var _ph_xs   = [combat_left_x() - 20, combat_right_x() + 20, combat_left_x() - 20, combat_right_x() + 20];
        var _ph_dirs = [0, 180, 0, 180];
        var _ph_spr  = spr_yanhuangma_bullet_2;

        for (var _pi = 0; _pi < 4; _pi++)
        {
            var _ph_y  = global.grid_offset_y + (_ph_gaps[_pi] - 0.25) * global.grid_cell_size_y;
            var _ph_b  = instance_create_depth(_ph_xs[_pi], _ph_y, -2500, obj_zodiac_projectile);
            _ph_b.kind             = "phoenix";
            _ph_b.damage           = _self.atk;
            _ph_b.base_damage      = _self.atk;
            _ph_b.shape            = 2;
            _ph_b.target_id        = noone;
            _ph_b.move_x           = lengthdir_x(8, _ph_dirs[_pi]);
            _ph_b.move_y           = lengthdir_y(8, _ph_dirs[_pi]);
            _ph_b.image_angle      = _ph_dirs[_pi];
            _ph_b.sprite_index     = _ph_spr;
            _ph_b.can_dandantu_store = false;
            _ph_b.cover_a          = _ph_gaps[_pi] - 1;
            _ph_b.cover_b          = _ph_gaps[_pi];
            if (_ph_dirs[_pi] == 180)
            {
                _ph_b.image_angle  = 0;
                _ph_b.image_xscale = -1;
            }
        }
        return;
    }

    // ── 冰块冷萃机：**整轮 6 颗一次铺完**，打最靠左的 6 个不同目标 ─────────────
    //   目标不够 6 个时按原卡口径补「血最多的主目标」，同目标的重复弹错 10 帧
    if (_card.mode == "cold_drew")
    {
        var _cd_tg = [];
        with (obj_enemy_parent) { if (hp > 0) array_push(_cd_tg, id); }
        if (array_length(_cd_tg) <= 0) return;

        array_sort(_cd_tg, function(_a, _b) { return _a.x - _b.x; });

        var _cd_main = _cd_tg[0], _cd_hp = -1;
        for (var _cm = 0; _cm < array_length(_cd_tg); _cm++)
        {
            if (_cd_tg[_cm].maxhp > _cd_hp) { _cd_hp = _cd_tg[_cm].maxhp; _cd_main = _cd_tg[_cm]; }
        }

        var _cd_rep = 0;
        for (var _ci = 0; _ci < 6; _ci++)
        {
            var _ct = (_ci < array_length(_cd_tg)) ? _cd_tg[_ci] : _cd_main;
            if (!instance_exists(_ct)) continue;

            var _cb = instance_create_depth(_ct.x, _ct.y - 20, _ct.depth - 1, obj_cold_drew_bullet);
            _cb.target_id    = _ct.id;
            _cb.damage       = _self.atk;
            _cb.row          = _ct.grid_row;
            _cb.grid_row     = _ct.grid_row;
            _cb.shape_bullet = 2;                       // 满转：命中溅射 ±1 行 165px
            _cb.delay        = (_ct == _cd_main) ? (_cd_rep * 10) : 0;
            if (_ct == _cd_main) _cd_rep++;
        }
        return;
    }

    // ── 鲁班神使：**整轮 6 颗一次铺完**（原卡 obj_gongjiang_god/Other_11）────────
    //   2 条水平折返（上路→中、下路→中）+ 第 0/1 列上下 4 颗竖弹；
    //   命中 20% 定身 90 帧、30% 毒雾（满转数值）、击杀灰烬（弹体自己处理）
    if (_card.mode == "gongjiang")
    {
        var _gj_col  = combat_max_col();
        var _gj_mid  = clamp(3, 0, global.grid_rows - 1);
        var _gj_top  = get_world_position_from_grid(_gj_col, 0);
        _gj_top.y   -= global.grid_cell_size_y / 2;
        var _gj_wmid = get_world_position_from_grid(_gj_col, _gj_mid);
        var _gj_bot  = get_world_position_from_grid(_gj_col, clamp(6, 0, global.grid_rows - 1));
        var _gj_spr  = spr_gongjiang_god_bullet_3;
        var _gj_pspr = spr_gongjiang_god_effect_3_2;

        for (var _gd = 0; _gd < 2; _gd++)
        {
            var _gh = instance_create_depth(_self.x, _self.y, _self.depth - 500, obj_gongjiang_god_bullet_horizontal);
            _gh.damage         = _self.atk;
            _gh.move_speed     = 8;
            _gh.damage_type    = "normal";
            _gh.target_type    = "all";
            _gh.hittable_types = get_hittable_enemy_types("all");
            _gh.shape          = 3;
            _gh.origin_card_id = _self.id;
            _gh.start_x        = _self.x;
            _gh.start_y        = _self.y;
            _gh.wp1_x          = (_gd == 0) ? _gj_top.x : _gj_bot.x;
            _gh.wp1_y          = (_gd == 0) ? _gj_top.y : _gj_bot.y;
            _gh.wp2_x          = _gj_wmid.x;
            _gh.wp2_y          = _gj_wmid.y;
            _gh.sprite_index   = _gj_spr;
            _gh.pin_chance     = 0.20;
            _gh.pin_duration   = 90;
            _gh.poison_chance  = 0.30;
            _gh.poison_spr     = _gj_pspr;
        }

        for (var _gc = 0; _gc <= 1; _gc++)
        {
            var _gp = get_world_position_from_grid(_gc, _gj_mid);
            for (var _gv = 0; _gv < 2; _gv++)
            {
                var _gb = instance_create_depth(_gp.x, _gp.y, _self.depth - 500, obj_gongjiang_god_bullet_vertical);
                _gb.damage         = _self.atk;
                _gb.move_speed     = 8;
                _gb.vertical_dir   = (_gv == 0) ? -1 : 1;
                _gb.col            = _gc;
                _gb.shape          = 3;
                _gb.damage_type    = "normal";
                _gb.target_type    = "all";
                _gb.hittable_types = get_hittable_enemy_types("all");
                _gb.sprite_index   = _gj_spr;
                _gb.image_angle    = (_gv == 0) ? 90 : 270;
                _gb.pin_chance     = 0.20;
                _gb.pin_duration   = 90;
                _gb.poison_chance  = 0.30;
                _gb.poison_spr     = _gj_pspr;
            }
        }
        return;
    }

    // ── 典伊神使：**整轮 12 发一次铺完**（原卡 obj_ice_god/Other_11）─────────────
    //   每发错高 50px、按 i % 敌人数轮转锁敌、落点按敌人速度提前预判；全部附冰 10 秒
    if (_card.mode == "ice_god")
    {
        var _ic_tg = [];
        with (obj_enemy_parent) { if (hp > 0) array_push(_ic_tg, id); }
        if (array_length(_ic_tg) <= 0) return;

        array_sort(_ic_tg, function(_a, _b) { return _a.x - _b.x; });
        var _ic_n = array_length(_ic_tg);

        for (var _ii = 0; _ii < 12; _ii++)
        {
            var _ie  = _ic_tg[_ii mod _ic_n];
            if (!instance_exists(_ie)) continue;
            var _ies = variable_instance_exists(_ie, "move_speed") ? _ie.move_speed : 0;
            var _iix = _ie.x - ((_ies * (600 - (_ii * 50))) / 40);      // 下落期间敌人往左走的量
            var _iiy = _ie.y - 600 - (_ii * 50);

            var _ib = instance_create_depth(_iix, _iiy, _self.depth - 500, obj_ice_god_bullet);
            _ib.damage          = _self.atk;
            _ib.target_instance = _ie;
            _ib.target_enemy    = _ie;
            _ib.target_x        = _iix;
            _ib.target_y        = _ie.y;
            _ib.move_speed      = 40;
            _ib.shape           = 3;
            _ib.row             = _ie.grid_row;
            _ib.grid_row        = _ie.grid_row;
            _ib.sprite_index    = spr_ice_god_bullet_1;
        }
        return;
    }

    // ── 小笼包族（双层 / 三向 / 机枪 / 国王 及各自冰冻版）：**一批 = 一个开火事件** ──
    //   原卡每个 Other_11 只建「本批发数」，整轮几批由各自 Step 的 event_user(1) 次数决定；
    //   这里用 n = 批数、per = 1、gap = 批间隔帧，由 tx_spawn 分批调回来，_si 就是批序号。
    //   双层/三向/机枪：水平 1 颗在 x+40、y-75；三向再配上下竖直各 1（x、y-95，col = 本列）。
    //   国王小笼包：bun_count+1 发在一个事件里铺开（满转 5 槽 + 本体 = 6），按 x+20*i、y-80。
    //   三向国王：上面 6 列每列再配上下竖直各 1（y-95±20*i）。
    if (_card.mode == "bun")
    {
        var _bn_x0   = variable_struct_exists(_card, "bn_x0")   ? _card.bn_x0   : 40;
        var _bn_h    = variable_struct_exists(_card, "bn_h")    ? _card.bn_h    : 1;
        var _bn_step = variable_struct_exists(_card, "bn_step") ? _card.bn_step : 0;
        var _bn_v    = variable_struct_exists(_card, "bn_v") && _card.bn_v;
        var _bn_vsep = variable_struct_exists(_card, "bn_vsep") ? _card.bn_vsep : 0;
        var _bn_vspr = variable_struct_exists(_card, "bn_vspr") ? _card.bn_vspr : obj_xiaolongbao_bullet_vertical;

        for (var _bh = 0; _bh < _bn_h; _bh++)
        {
            var _bx = _self.x + _bn_x0 + _bn_step * _bh;
            var _by = _self.y + _dy;

            var _bb = instance_create_depth(_bx, _by, _self.depth - 500, _card.o);
            _bb.damage    = _self.atk;
            _bb.move_speed = 8;
            _bb.row        = _self.grid_row;
            _bb.grid_row   = _self.grid_row;

            if (_bn_v)
            {
                // 竖直弹：靠 col 判列、靠 y += move_speed 上下飞（同原卡 obj_*_bullet_vertical）
                //   原卡竖直弹的 x 一律取卡位本身（不是水平弹那个 x+40 炮口）
                var _vu = instance_create_depth(_self.x, _self.y - 95 + _bn_vsep * _bh, _self.depth - 500, _bn_vspr);
                _vu.damage     = _self.atk;
                _vu.move_speed = 8;
                _vu.col        = _self.grid_col;
                _vu.image_angle = -90;

                var _vd = instance_create_depth(_self.x, _self.y - 95 - _bn_vsep * _bh, _self.depth - 500, _bn_vspr);
                _vd.damage     = _self.atk;
                _vd.move_speed = -8;
                _vd.col        = _self.grid_col;
                _vd.image_angle = 90;
            }
        }
        return;
    }

    // ── 白羊座：**1 行冲撞车**（2026-11-11 用户口径「1 行冲撞车，撞飞秒杀」）──────
    //   原卡 obj_baiyang/Step_0 只在 shape 2 时才补上下两行，这里按用户要求**只放本行一台**；
    //   撞飞秒杀由 obj_baiyang_effect/Step_0 自己做（BOSS 与魂系鼠豁免，只吃 atk），跑出屏自毁。
    if (_card.mode == "baiyang")
    {
        var _by  = global.grid_offset_y + _self.grid_row * global.grid_cell_size_y + global.grid_cell_size_y * 0.5;
        var _car = instance_create_depth(_self.x + _dx, _by, _self.depth - 500, obj_baiyang_effect);
        _car.atk      = _self.atk;
        _car.grid_row = _self.grid_row;
        return;
    }
}
