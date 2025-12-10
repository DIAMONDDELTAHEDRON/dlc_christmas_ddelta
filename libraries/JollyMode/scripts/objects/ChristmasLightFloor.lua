local ChristmasLightFloor, super = Class(Object)

function ChristmasLightFloor:init(main_light, layer, mask)
    super.init(self)

    self.debug_select = false
    self.main_light = main_light
    self.mask = mask
    -- if mask then
    --     self:setLayer(mask.layer + Game.world.map.depth_per_layer / 2)
    -- else
    --     self:setLayer(Game.world.player.layer - Game.world.map.depth_per_layer / 2)
    -- end
    self:setLayer(layer)
    self.pixel = Assets.getTexture('misc/pixel')
end

function ChristmasLightFloor:onAdd(parent)
    local width, height = Game.world.map.width * Game.world.map.tile_width, Game.world.map.height * Game.world.map.tile_height
    self:setSize(width, height)
    self.canvas = love.graphics.newCanvas(width, height)
    -- self.canvas_2 = love.graphics.newCanvas(width, height)
end

function ChristmasLightFloor:draw()
    super.draw(self)

    Draw.pushCanvas(self.canvas)
    love.graphics.clear(COLORS.black)
    love.graphics.setBlendMode("add")

    if not self.main_light.realistic_light then
        for _, object in ipairs(self.main_light.parts_to_draw) do
            if object.type == "bulb" then
                -- bulb_index = bulb_index + 1
                local value = MathUtils.rangeMap(math.cos(self.main_light.flicker_siner), -1, 1, 0, 1)
                local alpha = (object.index % 2) == 1 and value or 1 - value
                local y_diff = object.height
                local radius = MathUtils.rangeMap(y_diff, 0, 240, 24, 8)

                if self.flicker_type ~= "none" then
                    Draw.setColor(object.color, 0.1 * alpha)
                else
                    Draw.setColor(object.color, 0.1)
                end
                love.graphics.circle("fill", object.x, object.ground_y, radius)
                love.graphics.circle("fill", object.x, object.ground_y, radius * 1.5)
                love.graphics.circle("fill", object.x, object.ground_y, radius * 2)
            end
        end
    else
        Draw.setColor(COLORS.white)
        -- love.graphics.setBlendMode("add")
        local shader = Draw.pushShader("radial_gradient_light_floor", {
            texture_size = {self.width, self.height},
            strength = 1.2
        })
        for _, part in ipairs(self.main_light.parts_to_draw) do
            if part.type == "bulb" then
                -- Draw.pushCanvas(self.canvas_2)/
                -- love.graphics.clear()
                local draw_x, draw_y = part.x, part.ground_y
                shader:send("position", {draw_x, draw_y})
                local value = MathUtils.rangeMap(math.cos(self.main_light.flicker_siner), -1, 1, 0, 1)
                local color = (self.main_light.flicker_speed > 0) and
                            ColorUtils.mergeColor(part.color, COLORS.black, 0.2 + 0.8 * ((part.index % 2) == 0 and value or 1 - value)) or
                            ColorUtils.ensureAlpha(part.color)
                shader:send("draw_color", color)
                local y_diff = part.height
                local radius = MathUtils.rangeMap(y_diff, 0, 240, 480, 48)
                -- local radius = (1 / math.pow(9 * MathUtils.clamp(y_diff / self.main_light.brightness, 0, 1) + 1, 2) - 0.01) / 0.99 * self.main_light.brightness / 2
                shader:send("radius", {radius, radius})
                -- Log(y_diff, self.main_light.brightness, y_diff / self.main_light.brightness / 4)
                shader:send("range", {0, 1, y_diff / self.main_light.brightness / 4, 1})
                love.graphics.draw(self.pixel, 0, 0, 0, self.width, self.height)
            end
        end
        Draw.popShader()
    end

    -- love.graphics.setBlendMode("alpha")
    Draw.popCanvas()
    Draw.setColor(COLORS.white)

    if not self.main_light.realistic_light then
        Draw.pushShader("pixelate", {
            size = {self.width, self.height},
            factor = self.pixel_size
        })
    end
    if self.mask then
        love.graphics.stencil(function ()
            Draw.pushShader(Kristal.Shaders["Mask"], {})
            self.mask:draw()
            Draw.popShader()
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 1)
    end
    love.graphics.setBlendMode("add")
    Draw.draw(self.canvas)
    love.graphics.setBlendMode("alpha")
    if self.mask then
        love.graphics.setStencilTest()
    end
    if not self.main_light.realistic_light then
        Draw.popShader()
    end
end

return ChristmasLightFloor