function room_transition_state() {
    if (!variable_global_exists("room_trans")) {
        global.room_trans = { mode: 0, alpha: 0, color: c_black, target: -1, speed: 0.08, action_fn: undefined, action_arg: undefined }
    }
    if (!variable_struct_exists(global.room_trans, "action_fn")) global.room_trans.action_fn = undefined
    if (!variable_struct_exists(global.room_trans, "action_arg")) global.room_trans.action_arg = undefined
    return global.room_trans
}

function room_transition_alpha() {
    return room_transition_state().alpha
}

function room_transition_start(_target, _color = c_black, _speed = 0.08) {
    if (!room_exists(_target)) { return false }
    if (!ui_anim_on(1)) { room_goto(_target); return true }
    var _state = room_transition_state()
    _state.mode = 1
    _state.alpha = 0
    _state.color = _color
    _state.target = _target
    _state.speed = max(_speed, 0.001)
    _state.action_fn = undefined
    _state.action_arg = undefined
    if (!instance_exists(obj_notice_controller)) {
        instance_create_depth(0, 0, -9900, obj_notice_controller)
    }
    return true
}

function room_transition_in_place(_action_fn, _action_arg = undefined, _speed = 0.08) {
    if (!ui_anim_on(1)) {
        if (_action_fn != undefined) _action_fn(_action_arg)
        return true
    }
    var _state = room_transition_state()
    _state.mode = 1
    _state.alpha = 0
    _state.color = c_black
    _state.target = -1
    _state.speed = max(_speed, 0.001)
    _state.action_fn = _action_fn
    _state.action_arg = _action_arg
    if (!instance_exists(obj_notice_controller)) {
        instance_create_depth(0, 0, -9900, obj_notice_controller)
    }
    return true
}

function map_switch_apply(_data) {
    if (_data == undefined) return
    global.map_name = _data.name
    global.map_id = _data.id
}

function room_transition_step() {
    var _state = room_transition_state()
    if (_state.mode == 0) { return }

    // Only fade-out raises opacity; fade-in must decrease it independently.
    if (_state.mode == 1) _state.alpha = min(_state.alpha + _state.speed, 1)
    if (_state.mode == 1 && _state.alpha >= 1) {
        var _target = _state.target
        _state.target = -1
        if (_target >= 0 && room_exists(_target)) {
            _state.mode = 2
            room_goto(_target)
        } else if (_state.action_fn != undefined) {
            var _action = _state.action_fn
            var _argument = _state.action_arg
            _state.action_fn = undefined
            _state.action_arg = undefined
            _action(_argument)
            _state.mode = 3
        } else {
            _state.mode = 3
        }
        return
    }
    if (_state.mode == 2 && _state.alpha >= 1) {
        _state.alpha = 1
        _state.mode = 3
    } else if (_state.mode == 3) {
        _state.alpha = max(_state.alpha - _state.speed, 0)
        if (_state.alpha <= 0) { _state.mode = 0 }
    }
}
