// 烈火虎集中式储能管理脚本
// 新机制：场上所有 obj_flame 生成时按其 value 比例充能：
//   deposit = round(value * storage_ratio / 100) 进入储能（上限裁剪）
// 火焰本身照常落地/收集；储能满后立即返还全部并销毁卡片。

// 储能存入：带上限裁剪，返回实际存入量（整数，安全边界）
function liehuohu_storage_deposit(owner, amount) {
    if (!instance_exists(owner)) return 0;
    if (!variable_instance_exists(owner, "storage_amount")) return 0;
    if (!variable_instance_exists(owner, "storage_limit")) return 0;
    if (!variable_instance_exists(owner, "return_pending")) return 0;

    if (amount <= 0) return 0;
    if (owner.return_pending) return 0;

    var _accepted = 0;
    var _is_full = false;
    with (owner) {
        if (!return_pending && storage_amount < storage_limit) {
            _accepted = min(amount, storage_limit - storage_amount);
            storage_amount += _accepted;
            if (storage_amount >= storage_limit) {
                _is_full = true;
            }
        }
    }

    // 满储后立即返还并销毁卡片
    if (_is_full) {
        liehuohu_storage_refund(owner);
        if (instance_exists(owner)) {
            instance_destroy(owner);
        }
    }

    return _accepted;
}

// 储能一次性返还：卡片消失时调用，幂等（重复调用只返还一次）
function liehuohu_storage_refund(owner) {
    if (!instance_exists(owner)) {
        show_debug_message("liehuohu_refund: owner 不存在");
        return;
    }
    if (!variable_instance_exists(owner, "return_pending")) {
        show_debug_message("liehuohu_refund: owner 字段缺失");
        return;
    }
    if (owner.return_pending) return;

    var _refund = 0;
    with (owner) {
        if (!return_pending) {
            _refund = storage_amount;
            storage_amount = 0;
            return_pending = true;
        }
    }

    if (_refund < 0 || is_nan(_refund)) {
        _refund = 0;
    }
    _refund = floor(_refund);
    if (_refund > 0) {
        global.flame += _refund;
    }
}