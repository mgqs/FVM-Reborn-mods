-- 每张放置的卡片都有独立的 state，避免不同卡片共享攻击计时。
-- ctx.atk 和 ctx.cycle 会读取当前星级、技能和游戏增益后的数值。
return {
  on_create = function(ctx, state)
    state.attack_ticks = 0
  end,

  on_step = function(ctx, state)
    local params = ctx.params or {}
    state.attack_ticks = math.min((state.attack_ticks or 0) + 1, ctx.cycle)
    if state.attack_ticks < ctx.cycle then return end

    -- 查找前方同一行的目标；range_pixels 是像素距离，可在 JSON 修改。
    for _, enemy in ipairs(ctx.enemies or {}) do
      local distance = enemy.x - ctx.x
      if enemy.row == ctx.row and distance >= 0
          and distance <= (params.range_pixels or 1000) then
        api.shoot({
          sprite = "ice", -- 对应 card.json 的 projectiles.ice
          damage = ctx.atk,
          speed = params.bullet_speed or 8,
          slow_ticks = params.slow_ticks or 180,
          offset_x = params.offset_x or 40,
          offset_y = params.offset_y or -75
        })
        state.attack_ticks = 0
        break
      end
    end
  end
}
