/// @function shuffle_array(arr)
/// @desc 随机打乱数组
/// @param {Array} arr  需要打乱的数组（会被直接修改）
/// @returns {Array}    打乱后的同一个数组引用
function shuffle_array(arr) {
    var n = array_length(arr);
    for (var i = n - 1; i > 0; i--) {
        // 在 [0, i] 范围内随机选取一个整数索引
        var j = irandom_range(0, i);
        // 如果索引不同则交换元素
        if (i != j) {
            var temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;
        }
    }
    return arr;
}