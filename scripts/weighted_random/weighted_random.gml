/// @function weighted_random(elements, weights)
/// @description 根据权重数组随机选择一个元素。
/// @param {array} elements  存放备选元素的数组
/// @param {array} weights   与 elements 一一对应的权重（real 类型，可为整数或小数）
/// @returns {any}           按权重随机选中的元素
function weighted_random(elements, weights) {
    var n = array_length(elements);
    var m = array_length(weights);
    
    // 如果权重数组长度不一致，取较小长度，避免越界
    if (n != m) {
        n = min(n, m);
    }
    
    // 如果有效长度为 0，返回 undefined
    if (n <= 0) {
        return undefined;
    }
    
    // 1. 计算总权重
    var total = 0;
    for (var i = 0; i < n; i++) {
        total += weights[i];
    }
    
    // 2. 若总权重 <= 0，直接返回第一个元素作为后备（或 undefined）
    if (total <= 0) {
        return elements[0];
    }
    
    // 3. 生成随机值 [0, total)
    var r = random(total);
    
    // 4. 累加权重，找到命中区间
    var cumulative = 0;
    for (var i = 0; i < n; i++) {
        cumulative += weights[i];
        if (r < cumulative) {
            return elements[i];
        }
    }
    
    // 因浮点误差理论上不会走到这里，作为兜底返回最后一个元素
    return elements[n - 1];
}