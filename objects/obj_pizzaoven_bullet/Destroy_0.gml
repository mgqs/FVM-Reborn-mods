// 披萨炉子弹 Destroy 事件 - 清理已击中敌人列表
if (ds_exists(hitted_enemy, ds_type_list))
    ds_list_destroy(hitted_enemy);
