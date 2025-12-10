local FallingSnowflake, super = Class(Object)

function FallingSnowflake:init(x, y, falling_height, falling_speed, wind)
    super.init(self, x, y)

    self.sprite = Assets.getTexture('world/events/snowflake')
    self:setSize(self.sprite:getDimensions())
    self.physics.speed_x = wind

    self.siner = 0
    self.spin_amount = math.rad(MathUtils.random(0.5, 2)) * TableUtils.pick({-1, 1})
    self.alpha = MathUtils.random(0.25, 1)
    self.max_scale = MathUtils.random(0.75, 1.75)
    self:setScale(self.max_scale)

    self.fadeout_started = false
    self.falling_height = falling_height
    self.falling_speed = falling_speed
    self.spin = 0
end

function FallingSnowflake:update()
    super.update(self)

    self.siner = self.siner + math.rad(5) * DTMULT
    self.scale_x = math.sin(self.siner) * self.max_scale
    self.spin = self.spin + self.spin_amount * DTMULT

    self.falling_height = self.falling_height - self.falling_speed * DTMULT
    if self.falling_height < 0 then
        self:remove()
    elseif self.falling_height <= 20 then
        self.alpha = MathUtils.rangeMap(self.falling_height, 20, 0, 1, 0)
    end
end

function FallingSnowflake:draw()
    super.draw(self)

    Draw.setColor(COLORS.white, self.alpha)
    local width, height = self.sprite:getDimensions()
    love.graphics.draw(self.sprite, 0, -self.falling_height, self.spin, 1, 1, width / 2, height / 2)
end

return FallingSnowflake