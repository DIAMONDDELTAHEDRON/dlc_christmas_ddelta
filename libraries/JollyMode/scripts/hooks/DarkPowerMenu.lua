local DarkPowerMenu, super = HookSystem.hookScript(DarkPowerMenu)

function DarkPowerMenu:draw()
    if JollyLib.getJollyConfig("ui", "light") then
        love.graphics.setFont(self.font)

        Draw.setColor(COLORS.white)
        love.graphics.stencil(function ()
            love.graphics.setColorMask(true, true, true, true)
            love.graphics.rectangle("fill", -24, 104, 525, 6)
            if Game:getConfig("oldUIPositions") then
                love.graphics.rectangle("fill", 212, 104, 6, 196)
            else
                love.graphics.rectangle("fill", 212, 104, 6, 200)
            end
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 1)
        local left_width  = self.bg.left[1]:getWidth()
        local top_height  = self.bg.top[1]:getHeight()
        local total_width, total_height = left_width * 4 + self.bg.width, top_height * 4 + self.bg.height
        local stripe_width, stripe_height = self.bg.stripe_mask:getDimensions()
        -- love.graphics.translate(-top_width, -left_height)
        for x = 0, total_width, stripe_width * 2 do
            for y = 0, total_height, stripe_height * 2 do
                -- Log(x, y)
                Draw.draw(self.bg.stripe_mask, x - left_width * 2, y - top_height * 2, 0, 2, 2)
            end
        end
        love.graphics.setStencilTest()

        Draw.setColor(1, 1, 1, 1)
        Draw.draw(self.caption_sprites[  "char"],  42, -28, 0, 2, 2)
        Draw.draw(self.caption_sprites[ "stats"],  42,  98, 0, 2, 2)
        Draw.draw(self.caption_sprites["spells"], 298,  98, 0, 2, 2)

        self:drawChar()
        self:drawStats()
        self:drawSpells()
        super.super.draw(self)
    else
        super.draw(self)
    end
end

return DarkPowerMenu