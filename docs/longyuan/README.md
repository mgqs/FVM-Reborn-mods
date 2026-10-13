# 龙渊普通鼠：动作帧与机制

动画表直接读取 SWF 的 FrameLabel。以下区间含首尾，SWF 从第 1 帧计数，GameMaker 播放时减 1；速度为每秒 10 帧。

## pingmin

|动作|精灵|帧区间|
|---|---|---|
|正常行走|spr_pingmin|1–8|
|重伤行走|spr_pingmin|9–16|
|正常吃东西循环|spr_pingmin|17–20|
|重伤吃东西循环|spr_pingmin|21–24|
|倒地|spr_pingmin|25–37|

## dongfeng

|动作|精灵|帧区间|
|---|---|---|
|持扇前进|spr_dongfeng|1–10|
|持扇攻击|spr_dongfeng|11–34|
|无扇前进|spr_dongfeng|35–44|
|下落|spr_dongfeng|45–52|
|正常行走|spr_dongfeng|53–64|
|正常啃咬|spr_dongfeng|65–70|
|破损行走|spr_dongfeng|71–82|
|破损啃咬|spr_dongfeng|83–88|
|死亡|spr_dongfeng|89–102|

## gaoqiao

|动作|精灵|帧区间|
|---|---|---|
|正常移动|spr_gaoqiao|1–8|
|正常闪避1|spr_gaoqiao|9–19|
|正常闪避2|spr_gaoqiao|20–30|
|正常啃咬|spr_gaoqiao|31–37|
|正常后退|spr_gaoqiao|38–45|
|破损移动|spr_gaoqiao|46–53|
|破损闪避1|spr_gaoqiao|54–64|
|破损闪避2|spr_gaoqiao|65–75|
|破损啃咬|spr_gaoqiao|76–82|
|破损后退|spr_gaoqiao|83–90|
|死亡|spr_gaoqiao|91–103|

## langyabang

|动作|精灵|帧区间|
|---|---|---|
|正常行走|spr_langyabang|1–20|
|受伤行走|spr_langyabang|21–40|
|正常砸东西|spr_langyabang|41–56|
|受伤砸东西|spr_langyabang|57–72|
|死亡倒地|spr_langyabang|73–94|

## longmu

|动作|精灵|帧区间|
|---|---|---|
|正常有蛋前进|spr_longmu|1–12|
|正常有蛋啃咬|spr_longmu|13–18|
|正常原地发火|spr_longmu|19–27|
|正常无蛋前进|spr_longmu|28–35|
|正常无蛋啃咬|spr_longmu|36–41|
|破损有蛋前进|spr_longmu|42–53|
|破损有蛋啃咬|spr_longmu|54–59|
|破损原地发火|spr_longmu|60–68|
|破损无蛋前进|spr_longmu|69–76|
|破损无蛋啃咬|spr_longmu|77–82|
|死亡|spr_longmu|83–94|

## yaoguan

|动作|精灵|帧区间|
|---|---|---|
|正常前进|spr_yaoguan|1–12|
|正常啃咬|spr_yaoguan|13–20|
|正常回血|spr_yaoguan|21–36|
|破损前进|spr_yaoguan|37–48|
|破损啃咬|spr_yaoguan|49–56|
|破损回血|spr_yaoguan|57–72|
|死亡|spr_yaoguan|73–82|

## zhibuji

|动作|精灵|帧区间|
|---|---|---|
|全丝线移动|spr_zhibuji|1–8|
|全丝线发射子弹|spr_zhibuji|9–14|
|剩余2份丝线移动|spr_zhibuji|15–22|
|破损剩余2份丝线移动|spr_zhibuji|23–28|
|剩余1份丝线移动|spr_zhibuji|29–36|
|破损剩余1份丝线移动|spr_zhibuji|37–42|
|无丝线移动|spr_zhibuji|43–50|
|破损破损剩余1份丝线移动|spr_zhibuji|51–58|
|破损破损剩余1份丝线移动|spr_zhibuji|59–64|
|破损无丝线移动|spr_zhibuji|65–70|
|死亡|spr_zhibuji|71–83|

## kailu

|动作|精灵|帧区间|
|---|---|---|
|正常无火前进|spr_kailu|1–12|
|正常无火撞击|spr_kailu|13–19|
|正常蓄力|spr_kailu|20–33|
|正常小火前进|spr_kailu|34–45|
|正常小火撞击|spr_kailu|46–52|
|正常小火蓄力|spr_kailu|53–65|
|正常大火冲刺|spr_kailu|66–73|
|正常大火撞击|spr_kailu|74–82|
|破损无火前进|spr_kailu|83–94|
|破损无火撞击|spr_kailu|95–101|
|破损蓄力|spr_kailu|102–115|
|破损小火前进|spr_kailu|116–127|
|破损小火撞击|spr_kailu|128–134|
|破损小火蓄力|spr_kailu|135–147|
|破损大火冲刺|spr_kailu|148–155|
|破损大火撞击|spr_kailu|156–164|
|死亡|spr_kailu|165–176|

## zhinian

|动作|精灵|帧区间|
|---|---|---|
|正常前进|spr_zhinian|1–8|
|正常啃咬|spr_zhinian|9–13|
|破损前进|spr_zhinian|14–21|
|破损啃咬|spr_zhinian|22–26|
|死亡|spr_zhinian|27–40|

## fuzhou

|动作|精灵|帧区间|
|---|---|---|
|正常前进|spr_fuzhou|1–12|
|正常施法|spr_fuzhou|13–27|
|正常攻击|spr_fuzhou|28–35|
|破损前进|spr_fuzhou|36–47|
|破损施法|spr_fuzhou|48–62|
|破损攻击|spr_fuzhou|63–70|
|死亡|spr_fuzhou|71–81|

## zhizhujing

|动作|精灵|帧区间|
|---|---|---|
|正常待机|spr_zhizhujing|1–8|
|缠绕卡片|spr_zhizhujing|9–23|
|死亡|spr_zhizhujing|24–32|

## dijing

|动作|精灵|帧区间|
|---|---|---|
|正常走路|spr_dijing|1–8|
|受伤走路|spr_dijing|9–16|
|正常吃东西|spr_dijing|17–23|
|受伤吃东西|spr_dijing|24–30|
|倒地|spr_dijing|31–40|

## kailu_soul

|动作|精灵|帧区间|
|---|---|---|
|出生|spr_ly_kailu_soul|1–8|
|正常前进|spr_ly_kailu_soul|9–18|
|破损前进|spr_ly_kailu_soul|19–28|
|爆炸死亡|spr_ly_kailu_soul|29–45|
|普通死亡|spr_ly_kailu_soul|46–59|

## zhinian_soul

|动作|精灵|帧区间|
|---|---|---|
|出生|spr_ly_zhinian_soul|1–9|
|正常灵魂前进|spr_ly_zhinian_soul|10–21|
|正常攻击卡片|spr_ly_zhinian_soul|22–31|
|正常冲刺|spr_ly_zhinian_soul|32–53|
|破损灵魂前进|spr_ly_zhinian_soul|54–65|
|破损正常攻击卡片|spr_ly_zhinian_soul|66–75|
|破损冲刺|spr_ly_zhinian_soul|76–97|
|死亡|spr_ly_zhinian_soul|98–109|

## fuzhou_minion

|动作|精灵|帧区间|
|---|---|---|
|出生|spr_fuzhou_zhaohuan_2|1–8|
|正常前进|spr_fuzhou_zhaohuan_2|9–20|
|正常啃咬|spr_fuzhou_zhaohuan_2|21–27|
|破损前进|spr_fuzhou_zhaohuan_2|28–39|
|破损啃咬|spr_fuzhou_zhaohuan_2|40–46|
|死亡|spr_fuzhou_zhaohuan_2|47–57|

## amulet

|动作|精灵|帧区间|
|---|---|---|
|飞行|spr_fuzhou_gongji|1–6|
|变形|spr_fuzhou_gongji|7–18|
|死亡|spr_fuzhou_gongji|19–25|

## web

|动作|精灵|帧区间|
|---|---|---|
|出生|spr_zhizhujing_wang|1–7|
|待机|spr_zhizhujing_wang|8–19|
|死亡|spr_zhizhujing_wang|20–30|

## spider_soul

|动作|精灵|帧区间|
|---|---|---|
|正常待机|spr_zhizhujing_1|1–8|
|正常抱住物品|spr_zhizhujing_1|9–17|
|死亡|spr_zhizhujing_1|18–26|

## soul_fire

|动作|精灵|帧区间|
|---|---|---|
|三火出生|spr_ly_soul_fire|1–6|
|三火待机|spr_ly_soul_fire|7–12|
|二火待机|spr_ly_soul_fire|13–18|
|一火待机|spr_ly_soul_fire|19–24|
|一火消失|spr_ly_soul_fire|25–29|
