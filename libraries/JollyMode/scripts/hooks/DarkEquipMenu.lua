local DarkEquipMenu, super = HookSystem.hookScript(DarkEquipMenu)

function DarkEquipMenu:draw()
    if JollyLib.getJollyConfig("ui", "light") then
        love.graphics.setFont(self.font)

        Draw.setColor(COLORS.white)
        love.graphics.stencil(function ()
            love.graphics.setColorMask(true, true, true, true)
            love.graphics.rectangle("fill", 188, -24, 6, 139)
            love.graphics.rectangle("fill", -24, 109, 58, 6)
            love.graphics.rectangle("fill", 130, 109, 160, 6)
            love.graphics.rectangle("fill", 422, 109, 81, 6)
            love.graphics.rectangle("fill", 241, 109, 6, 192)
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
        Draw.draw(self.caption_sprites["char"], 36, -26, 0, 2, 2)
        Draw.draw(self.caption_sprites["equipped"], 294, -26, 0, 2, 2)
        Draw.draw(self.caption_sprites["stats"], 34, 104, 0, 2, 2)
        if self.selected_slot == 1 then
            Draw.draw(self.caption_sprites["weapons"], 290, 104, 0, 2, 2)
        else
            Draw.draw(self.caption_sprites["armors"], 290, 104, 0, 2, 2)
        end

        self:drawChar()
        self:drawEquipped()
        self:drawItems()
        self:drawStats()

        super.super.draw(self)
    else
        super.draw(self)
    end
end

return DarkEquipMenu