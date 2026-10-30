-- SWF TermiThreeShotGun behavior adapted to FVM Mod API.
-- Numerical card stats remain in card.json. Requires trajectory/burn runtime.
local function params(ctx) return ctx.params or {} end

-- AS3 RandomSeed 48-bit LCG, represented as three exact 16-bit words.
local function roll(high, low)
    local hi = (high & 65535) ~ 5
    local mid = ((low >> 16) & 65535) ~ 57068
    local lo = (low & 65535) ~ 58989
    local v2 = lo * 5 + mid * 57068 + hi * 58989
    local v3 = lo * 57068
    local v4 = lo * 58989
    v2 = v2 + ((v3 >> 16) & 65535)
    v3 = (v3 & 65535) + mid * 58989
    v2 = v2 + ((v3 >> 16) & 65535)
    v3 = (v3 & 65535) + ((v4 >> 16) & 65535)
    v2 = v2 + ((v3 >> 16) & 65535)
    v4 = (v4 & 65535) + 11
    v3 = (v3 & 65535) + (v4 >> 16)
    v2 = (v2 & 65535) + (v3 >> 16)
    return (((v2 & 65535) << 15) | ((v3 & 65535) >> 1)) % 101
end

local function fire(ctx, state)
    local p = params(ctx)
    local rate = p.source_tick_seconds or 0.05
    local speed = (p.source_bullet_speed or 10) / (60 * rate)
    local grade = math.floor(p.grade or 0)
    local powers = {13,16,19,22,25,28,31,34,42,50,70,90,110,135,160,190}
    local power = p.burn_power or powers[grade] or 0
    local rows = ctx.rows or p.rows
    assert(rows and rows >= 1, "Runtime must expose ctx.rows")
    local row_height = ctx.row_height or p.row_height
    assert(row_height and row_height > 0, "Runtime must expose ctx.row_height")
    for _, direction in ipairs({1, -1, 0}) do
        if ctx.row + direction >= 0 and ctx.row + direction < rows then
            state.shot_index = state.shot_index + 1
            local global_id = math.floor(p.source_card_id or ctx.id or 1)
            local seed = ((global_id << 14) | (state.round << 4) | state.shot_index) & 0x7fffffff
            api.shoot({sprite = p.projectile or "default", damage = ctx.atk,
                speed = speed, speed_y = direction * 2 * math.abs(speed),
                vertical_distance = direction == 0 and 0 or row_height * 0.9 + (direction == 1 and 20 or 0),
                row_offset = direction,
                offset_x = direction == 1 and 45 or 55,
                offset_y = (p.muzzle_y or -75) + (direction == 1 and -20 or 0),
                burn = {probability = 30, roll = roll(math.floor(p.battle_seed or 0), seed),
                    duration = 21, power = power}})
        end
    end
end

return {
    on_create = function(ctx, state)
        state.clock = 0
        state.source_time = 0
        state.last_round = 0
        state.round = 0
        state.shot_index = 0
        state.burst = -1
    end,
    on_step = function(ctx, state)
        local p = params(ctx)
        local rate = p.source_tick_seconds or 0.05
        assert(rate >= 0.025 and rate <= 1, "source_tick_seconds outside supported range")
        state.clock = state.clock + (ctx.dt or 1 / 60) / (ctx.slowed and 2 or 1)
        while state.clock + 1e-9 >= rate do
            state.clock = state.clock - rate
            state.source_time = state.source_time + 1
            local t = state.source_time
            -- cycle is the current game value, including skills/buffs, in 60-Hz ticks.
            local interval = math.max(1, (ctx.cycle or 78) / (60 * rate))
            if t > (p.place_delay_source_ticks or 20) and t >= state.last_round + interval then
                state.last_round = t
                local found = false
                for _, enemy in ipairs(ctx.enemies or {}) do
                    if enemy.hp > 0 and math.abs(enemy.row - ctx.row) <= 1 then found = true; break end
                end
                if found then
                    state.round = state.round + 1
                    state.shot_index = 0
                    state.burst = 0
                    api.animate({name = "attack"})
                end
            end
            if state.burst >= 0 and state.burst < 2 and t - state.last_round == 8 + 2 * state.burst then
                fire(ctx, state)
                state.burst = state.burst + 1
                if state.burst == 2 then state.burst = -1 end
            end
        end
    end
}
