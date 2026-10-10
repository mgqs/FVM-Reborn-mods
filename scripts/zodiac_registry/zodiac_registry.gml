function zodiac_definitions() {
    return [
        {id:"yanyantu", names:["炎焱兔","火火炎焱兔","焱焱炎焱兔"], cost:200, cd:40, cycle:1,
            atk:[1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5,1.6,1.7,1.8,2,2.2,2.4,2.6,2.8],
            evolved:[1.4,1.45,1.5,1.55,1.6,1.65,1.7,1.75,1.8,1.9,2,2.1,2.3,2.5,2.7,2.9,3.1], evolve_at:1,
            skill_stat:"cooldown", skills:[40,37,34,31,28,25,22,19,15],
            descriptions:["3×3范围指定产火卡片的火苗单值乘以倍率，向下取整，同类增幅取最高值。","提升火苗增幅倍率。","增幅范围扩大至5×5。"]},
        {id:"wugushe", names:["巫蛊蛇","暗黑巫蛊蛇","秘术巫蛊蛇"], cost:275, cd:15, cycle:1.8,
            atk:[70,80,90,100,110,120,140,160,200,260,340,420,500,620,740,860,980],
            evolved:[105,120,135,150,165,180,210,240,300,390,510,630,750,930,1110,1290,1470], evolve_at:1,
            skill_stat:"cycle", skills:[1.8,1.75,1.7,1.65,1.6,1.55,1.5,1.45,1.4],
            descriptions:["3×3范围每轮造成表列总伤害。蛊毒10%概率追加最大生命5%伤害，上限1000，并秒杀非精英。","蛊毒概率15%，追加最大生命8%伤害，上限1500。","攻击范围扩大至5×5。"]},
        {id:"kuileima", names:["傀儡马","机关傀儡马","灵枢傀儡马"], cost:390, cd:45, cycle:15,
            atk:[0.2,0.21,0.22,0.23,0.24,0.26,0.28,0.3,0.32,0.34,0.36,0.38,0.4,0.45,0.55,0.65,0.75],
            evolved:[0.4,0.42,0.44,0.46,0.48,0.52,0.56,0.6,0.64,0.68,0.72,0.76,0.8,0.9,1.1,1.3,1.5], evolve_at:2,
            skill_stat:"cycle", skills:[15,16,17,18,20,22,24,28,35],
            descriptions:["生命1亿，最多存在1张。锁定最高血量老鼠，优先BOSS，按比例转移受伤。持续时间结束或目标死亡时自毁。不能复制、改变星级或被普通冷却刷新，仅极寒冰沙可刷新。","死亡时造成5×5范围900灰烬爆炸。","伤害转移比例翻倍。"]},
        {id:"yufengma", names:["御风马","净化御风马","菩提御风马"], cost:280, cd:15, cycle:2,
            atk:[90,100,110,130,150,170,190,210,240,330,450,600,750,900,1100,1350,1600],
            evolved:[117,130,143,169,195,221,247,273,312,429,585,780,975,1170,1430,1755,2080],
            ultimate:[234,260,286,338,390,442,494,546,624,858,1170,1560,1950,2340,2860,3510,4160], evolve_at:1,
            skill_stat:"cycle", skills:[2,1.95,1.9,1.85,1.8,1.7,1.6,1.5,1.3],
            descriptions:["每次发射1枚风弹，击退陆空军0.5格。场上存在排风扇、9周年幸运草扇或旋风牛时改为3行大风，可受宴会女神增幅。","死亡时产生吹飞效果，基础伤害提升。","基础伤害翻倍，秒杀表列指定飞行老鼠。"]},
        {id:"fenjima", names:["焚寂马","星火焚寂马","烈日焚寂马"], cost:320, cd:15, cycle:1.8,
            atk:[50,60,70,80,90,100,120,140,160,200,240,280,380,580,780,980,1180],
            skill_stat:"cycle", skills:[1.8,1.75,1.7,1.65,1.6,1.5,1.4,1.3,1],
            descriptions:["发射1枚直线弹，可被水神、樱桃反弹布丁反弹，穿过火盆、金牛座、火神时被强化；命中老鼠后沿子弹方向分裂0°、±90°穿透波，目标格承受全部冲击波。","仅冲击波伤害提升50%。","增加±45°冲击波，共5道。"]},
        {id:"guiyuanma", names:["归元马","时空归元马","幻境归元马"], cost:375, cd:15, cycle:2.6,
            atk:[120,140,160,180,210,240,270,360,450,540,630,730,850,1000,1150,1350,1600],
            skill_stat:"cycle", skills:[2.6,2.55,2.5,2.45,2.4,2.35,2.3,2.2,2],
            descriptions:["前方3行索敌最近目标，1枚追踪弹。秒杀血量低于30%的非BOSS；其余非BOSS送回第9列变为原最大生命50%的呆呆鼠，能力同平民鼠。受莓果甜点、香料虎、宴会女神增幅。","秒杀阈值提升至50%。","前方5行索敌，发射2枚弹。"]},
        {id:"yanhuangma", names:["炎凰马","白炽炎凰马","焚天炎凰马"], cost:320, cd:15, cycle:3.5,
            atk:[150,170,190,220,260,300,340,400,500,600,800,1000,1300,1600,2000,2400,2800],
            evolved:[224,254,284,330,390,450,510,600,750,900,1200,1500,1950,2400,3000,3600,4200], evolve_at:2,
            skill_stat:"cycle", skills:[3.5,3.45,3.4,3.35,3.3,3.2,3.1,3,2.5],
            descriptions:["持续从场地左右两侧发射对向固定轨迹炎凰，攻击3行陆军，中路2次、上下各1次；无法攻击未显形鬼鼠、非主流，可放岩浆。受音盒马、浮生茶增幅。","场上至少7张时，最高攻击力的1张每5秒召唤竖向炎凰，攻击第7至9列，第8列2次。","攻击提升，击杀化为灰烬。"]},
        {id:"yinhema", names:["音盒马","叮咚音盒马","玲珑音盒马"], cost:320, cd:45, cycle:1,
            atk:[1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2,2.2,2.4,2.6,2.8,3.2,3.6,4],
            evolved:[1.6,1.7,1.8,1.9,2,2.1,2.2,2.3,2.4,2.5,2.7,2.9,3.1,3.3,3.7,4.1,4.5], evolve_at:2,
            skill_stat:"cooldown", skills:[45,43,41,39,37,34,30,25,15],
            descriptions:["3×3范围增幅迷你披萨炉、赖皮蛇、工匠神、炎凰马、炎帝。同类取最高倍率。","增幅范围扩大至5×5。","增幅倍率提升。"]},
        {id:"xiandima", names:["仙笛马","悠扬仙笛马","天籁仙笛马"], cost:335, cd:15, cycle:15,
            atk:[120,130,140,160,180,200,240,300,360,420,480,600,720,850,980,1110,1240],
            evolved:[240,260,280,320,360,400,480,600,720,840,960,1200,1440,1700,1960,2220,2480], evolve_at:2,
            skill_stat:"cycle", skills:[15,14.1,13.2,12.3,10.8,9.3,7.8,6.3,4.5],
            descriptions:["不占格。每攻击间隔的1/3召唤1只，积满3只后飞出，发射3枚，全屏优先BOSS、其次最高血量目标。","对BOSS造成2.1倍伤害。","子弹伤害翻倍，仍为3枚。"]},
        {id:"xingqiongma", names:["星穹马","璀璨星穹马","浩瀚星穹马"], cost:350, cd:60, cycle:1.2,
            atk:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
            cooldowns:[60,58,56,54,52,50,48,46,44,42,40,38,36,34,32,30,28],
            skill_stat:"zodiac_guard_duration", skills:[15,15.5,16,16.5,17,17.5,18,18.5,20],
            descriptions:["前摇1.2秒后复活5×5范围内最近被老鼠咬死的1张卡，排除复制卡。使用后消失。","范围内卡片获得技能对应时长的免伤，可抵挡1次老鼠攻击，包括致命攻击；8级技能抵挡2次。","一次复活3张。"]},
        {id:"starrabbit", names:["星星兔","星星兔·一转","星星兔·二转"], cost:225, cd:30, cycle:1.3,
            atk:[40,48,56,64,72,80,100,120,140,170,200,230,330,430,530,630,730],
            skill_stat:"cycle", skills:[1.3,1.25,1.2,1.15,1.1,1.05,1,0.9,0.8],
            descriptions:["向前方5个固定方向发射星弹，命中老鼠造成伤害；星弹可穿过火盆等障碍并可被水神、樱桃布丁反弹。","每个方向额外增加1发星弹，共10发；火盆只增加伤害。","每个方向额外增加2发星弹，共15发。"]},
        {id:"yinghuoshe", names:["萤火蛇","萤火蛇·一转","萤火蛇·二转"], cost:75, cd:30, cycle:15,
            atk:[300,350,400,450,500,550,600,700,900,900,900,900,900,900,900,900,900],
            flame:[20,21,22,23,24,25,27,29,31,33,35,37,42,47,57,67,80],
            skill_stat:"cycle", skills:[30,29,28,27,26,25,23,22,21,20,19,18,17,15,13,10,7],
            descriptions:["全屏照亮迷雾；每15秒产生1朵火；老鼠首次进入自身3×3范围时造成一次伤害。","每15秒产生2朵火。","伤害翻倍。"]}
    ];
}

function zodiac_cards_init() {
    var _defs = zodiac_definitions();
    for (var i = 0; i < array_length(_defs); i++) {
        var d = _defs[i], shapes = [];
        for (var s = 0; s < 3; s++) {
            var damage = d.atk;
            if (variable_struct_exists(d,"evolved") && s >= d.evolve_at) damage = d.evolved;
            if (s == 2 && variable_struct_exists(d,"ultimate")) damage = d.ultimate;
            var cooldowns = variable_struct_exists(d,"cooldowns") ? d.cooldowns : array_create(17,d.cd);
            var card_hp = d.id == "kuileima" ? 100000000 : 50;
            var attack_range = 10;
            if (d.id == "yanyantu") attack_range = s == 2 ? 2.5 : 1.5;
            if (d.id == "yinhema") attack_range = s == 0 ? 1.5 : 2.5;
            var cooldown_frames = [];
            for (var level = 0; level < 17; level++) array_push(cooldown_frames,round(cooldowns[level]*60));
            var _shape_atk = damage;
            if (d.id == "yinghuoshe" && s == 2) {
                _shape_atk = [];
                for (var _ai = 0; _ai < array_length(d.atk); _ai++) array_push(_shape_atk, d.atk[_ai] * 2);
            }
            var _shape_data = {shape:s,name:d.names[s],description:d.descriptions[s],
                hp:array_create(17,card_hp),cost:array_create(17,d.cost),atk:_shape_atk,range:array_create(17,attack_range),
                cooldown:cooldown_frames,cycle:array_create(17,round(d.cycle*60))};
            if (d.id == "yinghuoshe") _shape_data.flame_produce = d.flame;
            array_push(shapes,_shape_data);
        }
        mod_register_plant_lite(d.id,shapes,false);
    }
}

function zodiac_skill_init() {
    var _defs = zodiac_definitions();
    for (var i = 0; i < array_length(_defs); i++) {
        var d = _defs[i], skills = [];
        for (var k = 0; k < 9; k++) array_push(skills,round(d.skills[k]*60));
        register_card_skill(d.id,d.skill_stat,skills);
    }
}

function zodiac_slots_init() {
    var _defs = zodiac_definitions();
    for (var i = 0; i < array_length(_defs); i++) {
        var d = _defs[i], shapes = [];
        for (var s = 0; s < 3; s++) {
            var spr = asset_get_index("spr_"+d.id+(s == 0 ? "" : "_"+string(s)));
            if (spr < 0 && d.id == "yinghuoshe") spr = asset_get_index("sp_"+d.id+(s == 0 ? "" : "_"+string(s)));
            array_push(shapes,{shape:s,sprite:spr,cost:d.cost,cooldown:round(d.cd*60),description:d.names[s]+"："+d.descriptions[s],
                plant_type:d.id == "xiandima" ? "gridless" : "normal",feature_type:d.id == "yanhuangma" ? "lava" : "normal",
                target_card:"none",is_gold:0,place_preview:spr});
        }
        register_card(d.id,asset_get_index("obj_"+d.id),shapes);
    }
}

function zodiac_info_init() {
    var _defs = zodiac_definitions();
    for (var i = 0; i < array_length(_defs); i++) {
        var d = _defs[i];
        register_card_info_island(d.id,d.names[0]+"："+d.descriptions[0]+"\n一转："+d.descriptions[1]+"\n二转："+d.descriptions[2]);
    }
}
