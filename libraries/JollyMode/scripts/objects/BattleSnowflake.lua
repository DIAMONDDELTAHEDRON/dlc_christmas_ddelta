local BattleSnowflake, super = Class(Object)

function BattleSnowflake:init(x, y)
    super.init(self, x, y)

    self.sprite = Assets.getTexture('world/events/snowflake')
    self:setSize(self.sprite:getDimensions())
    self:setOrigin(0.5)

    self.siner = 0
    self.physics.speed_y = 1
    self.graphics.spin = math.rad(MathUtils.random(0.5, 2)) * TableUtils.pick({-1, 1})
    self.alpha = MathUtils.random(0.25, 1)
    self.max_scale = MathUtils.random(0.75, 1.75)
    self:setScale(self.max_scale)
end

function BattleSnowflake:update()
    super.update(self)

    self.siner = self.siner + math.rad(5) * DTMULT
    self.scale_x = math.sin(self.siner) * self.max_scale

    if JollyLib.getJollyConfig("battle", "snowflake_layer") < 3 then
        if self.y > Game.battle.battle_ui.y + 10 then
            self:remove()
        end
    else
        if self.y > SCREEN_HEIGHT then
            self:remove()
        end
    end
end

function BattleSnowflake:draw()
    super.draw(self)

    Draw.setColor(COLORS.white, self.alpha * (1 - Game.battle.background_fade_alpha) * (Game.battle.transition_timer / 10))
    love.graphics.draw(self.sprite)
end

return BattleSnowflake