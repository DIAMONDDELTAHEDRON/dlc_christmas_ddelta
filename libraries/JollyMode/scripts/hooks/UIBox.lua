---@class UIBox : Object
---@overload fun(...) : UIBox
local UIBox, super = HookSystem.hookScript(UIBox)

function UIBox:init(x, y, width, height, skin)
    super.init(self, x, y, width, height, skin)

    self.pixel = Assets.getTexture('misc/pixel')

    self.jolly = JollyLib.getJollyConfig("ui", "border")
    if self.jolly then
        self.left_mask   = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/left_mask")
        self.top_mask    = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/top_mask")
        self.corner_mask = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/corner_mask")
        self.stripe_mask = Assets.getTexture("ui/box/stripe_mask")

        local left_width  = self.left[1]:getWidth()
        -- local left_height = self.left[1]:getHeight()
        -- local top_width   = self.top[1]:getWidth()
        local top_height  = self.top[1]:getHeight()

        if self.skin == "dark_jolly" then
            local total_width, total_height = self.width + left_width * 4, self.height + top_height * 4
            self.christmas_light = ChristmasLightUI(-left_width * 2, -top_height * 2, total_width, total_height)
            self.christmas_light:setLayer(1)
            local seed = self.width * self.height + self.width + self.height
            self.christmas_light.seed = seed
            self:addChild(self.christmas_light)
            -- self:addChild(UISnow(left_width, -24, self.width, seed + self.x * self.y + self.x + self.y))
            love.math.setRandomSeed(seed)
            self.christmas_light:addPoint(left_width, top_height + MathUtils.random(0, 40))
            local total_points = MathUtils.round(self.width / 90) - 1
            local space_between_points = (total_width - left_width) / (total_points + 1)
            for i = 1, total_points do
                self.christmas_light:addPoint(left_width + i * space_between_points + MathUtils.random(-space_between_points, space_between_points) * 0.4, top_height)
            end
            self.christmas_light:addPoint(total_width - left_width, top_height + MathUtils.random(0, 40))
            self.christmas_light:update()
            MathUtils.renewRandomSeed()

            -- For the light
            -- For some reason adding the MaskFX removes the cool glow
            -- self.left_mask_light   = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/left_mask_light")
            -- self.top_mask_light    = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/top_mask_light")
            -- self.corner_mask_light = Assets.getFramesOrTexture("ui/box/" .. self.skin .. "/corner_mask_light")
            -- self.christmas_light:addFX(MaskFX(self))
        end
    end
end

-- function UIBox:drawMask()
--     if self.christmas_light then
--         local left_width  = self.left[1]:getWidth()
--         local left_height = self.left[1]:getHeight()
--         local top_width   = self.top[1]:getWidth()
--         local top_height  = self.top[1]:getHeight()

--         Draw.pushShader(Kristal.Shaders["Mask"], {})
--         love.graphics.rectangle("fill", 0, 0, self.width, self.height)
--         Draw.draw(self.left_mask_light[math.floor(self.left_frame)], 0, 0, 0, 2, self.height / left_height, left_width, 0)
--         Draw.draw(self.left_mask_light[math.floor(self.left_frame)], self.width, 0, math.pi, 2, self.height / left_height, left_width, left_height)

--         Draw.draw(self.top_mask_light[math.floor(self.top_frame)], 0, 0, 0, self.width / top_width, 2, 0, top_height)
--         Draw.draw(self.top_mask_light[math.floor(self.top_frame)], 0, self.height, math.pi, self.width / top_width, 2, top_width, top_height)

--         for i = 1, 4 do
--             local cx, cy = self.corners[i][1] * self.width, self.corners[i][2] * self.height
--             local sprite = self.corner_mask_light[math.floor(self.corner_frame)]
--             local width_  = 2 * ((self.corners[i][1] * 2) - 1) * -1
--             local height_ = 2 * ((self.corners[i][2] * 2) - 1) * -1
--             Draw.draw(sprite, cx, cy, 0, width_, height_, sprite:getWidth(), sprite:getHeight())
--         end
--         Draw.popShader()
--     end
-- end

function UIBox:drawDarkLight()
    self.left_frame   = ((self.left_frame   + (DTMULT / self.speed)) - 1) % #self.left   + 1
    self.top_frame    = ((self.top_frame    + (DTMULT / self.speed)) - 1) % #self.top    + 1
    self.corner_frame = ((self.corner_frame + (DTMULT / self.speed)) - 1) % #self.corner + 1

    local left_width  = self.left[1]:getWidth()
    local left_height = self.left[1]:getHeight()
    local top_width   = self.top[1]:getWidth()
    local top_height  = self.top[1]:getHeight()

    local  r, g, b,a = self:getDrawColor()
    local fr,fg,fb   = unpack(self.fill_color)
    Draw.setColor(fr,fg,fb,a)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    Draw.setColor(r, g, b, a)

    Draw.draw(self.left[math.floor(self.left_frame)], 0, 0, 0, 2, self.height / left_height, left_width, 0)
    Draw.draw(self.left[math.floor(self.left_frame)], self.width, 0, math.pi, 2, self.height / left_height, left_width, left_height)

    Draw.draw(self.top[math.floor(self.top_frame)], 0, 0, 0, self.width / top_width, 2, 0, top_height)
    Draw.draw(self.top[math.floor(self.top_frame)], 0, self.height, math.pi, self.width / top_width, 2, top_width, top_height)

    for i = 1, 4 do
        local cx, cy = self.corners[i][1] * self.width, self.corners[i][2] * self.height
        local sprite = self.corner[math.floor(self.corner_frame)]
        local width  = 2 * ((self.corners[i][1] * 2) - 1) * -1
        local height = 2 * ((self.corners[i][2] * 2) - 1) * -1
        Draw.draw(sprite, cx, cy, 0, width, height, sprite:getWidth(), sprite:getHeight())
    end

    if self.jolly then
        love.graphics.stencil(function ()
            Draw.pushShader(Kristal.Shaders["Mask"], {})
            Draw.draw(self.left_mask[math.floor(self.left_frame)], 0, 0, 0, 2, self.height / left_height, left_width, 0)
            Draw.draw(self.left_mask[math.floor(self.left_frame)], self.width, 0, math.pi, 2, self.height / left_height, left_width, left_height)

            Draw.draw(self.top_mask[math.floor(self.top_frame)], 0, 0, 0, self.width / top_width, 2, 0, top_height)
            Draw.draw(self.top_mask[math.floor(self.top_frame)], 0, self.height, math.pi, self.width / top_width, 2, top_width, top_height)

            for i = 1, 4 do
                local cx, cy = self.corners[i][1] * self.width, self.corners[i][2] * self.height
                local sprite = self.corner_mask[math.floor(self.corner_frame)]
                local width  = 2 * ((self.corners[i][1] * 2) - 1) * -1
                local height = 2 * ((self.corners[i][2] * 2) - 1) * -1
                Draw.draw(sprite, cx, cy, 0, width, height, sprite:getWidth(), sprite:getHeight())
            end
            Draw.popShader()
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 1)
        -- Log("top_width", top_width, "left_height", left_height)
        local total_width, total_height = left_width * 4 + self.width, top_height * 4 + self.height
        local stripe_width, stripe_height = self.stripe_mask:getDimensions()
        -- love.graphics.translate(-top_width, -left_height)
        Draw.setColor(COLORS.white)
        for x = 0, total_width, stripe_width * 2 do
            for y = 0, total_height, stripe_height * 2 do
                -- Log(x, y)
                Draw.draw(self.stripe_mask, x - left_width * 2, y - top_height * 2, 0, 2, 2)
            end
        end
        -- love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        -- love.graphics.translate(top_width, left_height)
        love.graphics.setStencilTest()
    end

    -- if self.radial_gradient then
    --     Draw.pushShader("radial_gradient", {
    --         position = {self.width / 2, self.height / 2},
    --         texture_size = {self.width, self.height},
    --         radius = {100, 60},
    --         draw_color = COLORS.red
    --     })
    --     love.graphics.draw(self.pixel, 0, 0, 0, self.width, self.height)
    --     Draw.popShader()
    -- end
end

function UIBox:draw()
    -- if self.skin == "dark" or self.skin == "light" then
    self:drawDarkLight()
    -- end

    super.super.draw(self)
end

return UIBox