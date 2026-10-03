// 正常生产 obj_flame 落地（火焰本身照常落地/收集，储能由 obj_flame 生成时统一触发）
for (var i = 0; i < flame_burst_count; i++) {
    var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
    inst.value = flame_produce;
}