var reward_id = parent_gui.reward_list[list_num];
var reward_spr = 0;
var reward_sprite = spr_gods_hall_reward;
var reward_scale = 1.6;

switch (reward_id[0])
{
    case "金币":
        reward_sprite = spr_gods_hall_reward;
        reward_spr = 0;
        reward_scale = 1.6;
        break;
    
    case "神谕之石":
        reward_sprite = spr_oriacle_stone;
        reward_spr = 0;
        reward_scale = 1.6;
        break;
    
    case "天然香料":
        reward_sprite = spr_craft_material;
        reward_spr = 0;
        reward_scale = 0.8;
        break;
    
    case "秘制香料":
        reward_sprite = spr_craft_material;
        reward_spr = 1;
        reward_scale = 0.8;
        break;
    
    case "初级强化水晶":
        reward_sprite = spr_craft_material;
        reward_spr = 6;
        reward_scale = 0.8;
        break;
    
    case "中级强化水晶":
        reward_sprite = spr_craft_material;
        reward_spr = 7;
        reward_scale = 0.8;
        break;
    
    case "4级四叶草":
        reward_sprite = spr_craft_material;
        reward_spr = 9;
        reward_scale = 0.8;
        break;
    
    case "高级强化水晶":
        reward_sprite = spr_craft_material;
        reward_spr = 8;
        reward_scale = 0.8;
        break;
}

var reward = instance_create_depth(x - 2, y - 20, depth - 1, obj_gods_hall_reward);
reward.parent_gui = id;
reward.list_num = list_num;
reward.reward_id = reward_id;
reward.sprite_index = reward_sprite;
reward.image_index = reward_spr;
reward.image_xscale = reward_scale;
reward.image_yscale = reward_scale;
