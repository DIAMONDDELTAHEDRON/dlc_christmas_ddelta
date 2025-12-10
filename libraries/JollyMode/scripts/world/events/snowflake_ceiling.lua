local SnowflakeDeco, super = Class(Event, "snowflake_ceiling")

function SnowflakeDeco:init(data)
    super.init(self, data)
    -- self:setSize(40, 40)

    local properties = data.properties or {}
    self.radius = properties["radius"] or 40
    self.amount = properties["amount"] or 16
    self.seed = properties["seed"] or 1
    self.string_length = properties["string_length"] or (160 + 80)
    self.fadeout_length = properties["fadeout_length"] or 80

    self.texture = Assets.getTexture("world/events/snowflake")
    self.pixel = Assets.getTexture('misc/pixel')
    self.snowflakes = {}

    love.math.setRandomSeed(2 * JollyLib.stringToHash(Game.world.map.id) + self.seed)
    for i = 1, self.amount do
        table.insert(self.snowflakes, {
            x = love.math.randomNormal(1, 0) * self.radius,
            y = love.math.randomNormal(1, 0) * self.radius,
            siner = math.rad(MathUtils.random(0, 360)),
            siner_multi = MathUtils.random(0.7, 1.3),
            color = ColorUtils.mergeColor(COLORS.white, ColorUtils.hexToRGB("c6c8ff"), MathUtils.random(0, 1))
        })
    end
    MathUtils.renewRandomSeed()
end

function SnowflakeDeco:update()
    super.update(self)

    for _, snowflake in ipairs(self.snowflakes) do
        snowflake.siner = snowflake.siner + 0.05 * snowflake.siner_multi * DTMULT
    end
end

function SnowflakeDeco:draw()
    super.draw(self)

    local tex_width, tex_height = self.texture:getDimensions()
    for _, snowflake in ipairs(self.snowflakes) do
        Draw.setColor(snowflake.color)
        love.graphics.setLineWidth(2)
        love.graphics.line(snowflake.x, snowflake.y, snowflake.x, snowflake.y - (self.string_length - self.fadeout_length))
        Draw.setColor(COLORS.white)
        Draw.pushShader(Assets.getShader("gradient_a"), {
            from = snowflake.color,
            to = snowflake.color,
            scale = 1
        })
        Draw.draw(self.pixel, snowflake.x, snowflake.y - (self.string_length - self.fadeout_length), math.rad(180), 2, self.fadeout_length, 0.5, 0)
        Draw.popShader()
        Draw.setColor(snowflake.color)
        local sine = math.sin(snowflake.siner) * 2
        love.graphics.draw(self.texture, snowflake.x, snowflake.y, 0, sine, 2, tex_width / 2, tex_height / 2)
    end
end

return SnowflakeDeco