// 斜劈沟壑：原 1.8 只盖得住中间几格，对角线两端（row0/col8、row6/col2 那一带）
// 卡片明明已经被摧毁却看不到裂缝。按 +50% 拉长到 2.7，让整条对角线都有特效。
image_xscale = 2.7
image_yscale = 2.7
image_speed = 0

timer = 0
type = 0

state = "appear"

pos_list = []