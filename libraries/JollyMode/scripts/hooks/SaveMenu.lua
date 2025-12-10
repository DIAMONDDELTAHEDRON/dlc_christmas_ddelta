local SaveMenu, super = HookSystem.hookScript(SaveMenu)

function SaveMenu:init(marker)
    super.init(self, marker)

    if JollyLib.getJollyConfig("ui", "light") then
        self.divider_sprite = Assets.getTexture("ui/box/dark_jolly/top")
        self.divider_sprite_mask = Assets.getTexture("ui/box/dark_jolly/top_mask")
    end
end

function SaveMenu:draw()
    if not JollyLib.getJollyConfig("ui", "light") then
        super.draw(self)
    else
        love.graphics.setFont(self.font)
        if self.state == "MAIN" then
            local data = Game:getSavePreview()

            -- Header
            Draw.setColor(PALETTE["world_text"])
            love.graphics.print(data.name, 120, 120)
            love.graphics.print("LV "..data.level, 352, 120)

            local hours = math.floor(data.playtime / 3600)
            local minutes = math.floor(data.playtime / 60 % 60)
            local seconds = math.floor(data.playtime % 60)
            local time_text = string.format("%d:%02d:%02d", hours, minutes, seconds)
            love.graphics.print(time_text, 522 - self.font:getWidth(time_text), 120)

            -- Room name
            love.graphics.print(data.room_name, 319.5 - self.font:getWidth(data.room_name)/2, 170)

            -- Buttons
            love.graphics.print("Save", 170, 220)
            love.graphics.print("Return", 350, 220)
            if Game.inventory.storage_enabled then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_gray"])
            end
            love.graphics.print("Storage", 170, 260)
            
            if Game:getConfig("enableRecruits") and #Game:getRecruits(true) > 0 then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_gray"])
            end
            love.graphics.print("Recruits", 350, 260)

            -- Heart
            local heart_positions_x = {142, 322}
            local heart_positions_y = {228, 270}
            Draw.setColor(Game:getSoulColor())
            Draw.draw(self.heart_sprite, heart_positions_x[self.selected_x], heart_positions_y[self.selected_y])
        elseif self.state == "SAVE" or self.state == "OVERWRITE" then
            self:drawSaveFile(0, Game:getSavePreview(), 74, 26, false, true)

            self:drawSaveFile(1, self.saves[1], 74, 138, self.selected_y == 1)
            Draw.draw(self.divider_sprite, 74, 208, 0, 493, 2)

            self:drawSaveFile(2, self.saves[2], 74, 222, self.selected_y == 2)
            Draw.draw(self.divider_sprite, 74, 292, 0, 493, 2)

            self:drawSaveFile(3, self.saves[3], 74, 306, self.selected_y == 3)
            Draw.draw(self.divider_sprite, 74, 376, 0, 493, 2)

            love.graphics.stencil(function ()
                Draw.pushShader(Kristal.Shaders["Mask"], {})
                Draw.draw(self.divider_sprite_mask, 74, 208, 0, 493, 2)
                Draw.draw(self.divider_sprite_mask, 74, 292, 0, 493, 2)
                Draw.draw(self.divider_sprite_mask, 74, 376, 0, 493, 2)
                Draw.popShader()
            end)
            love.graphics.setStencilTest("equal", 1)
            local left_width  = self.save_list.left[1]:getWidth()
            local top_height  = self.save_list.top[1]:getHeight()
            local total_width, total_height = left_width * 4 + self.save_list.width, top_height * 4 + self.save_list.height
            local stripe_width, stripe_height = self.save_list.stripe_mask:getDimensions()
            love.graphics.translate(self.save_list.x, self.save_list.y)
            for x = 0, total_width, stripe_width * 2 do
                for y = 0, total_height, stripe_height * 2 do
                    -- Log(x, y)
                    Draw.draw(self.save_list.stripe_mask, x - left_width * 2, y - top_height * 2, 0, 2, 2)
                end
            end
            love.graphics.translate(-self.save_list.x, -self.save_list.y)
            love.graphics.setStencilTest()

            if self.selected_y == 4 then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, 236, 402)

                Draw.setColor(PALETTE["world_text_selected"])
            else
                Draw.setColor(PALETTE["world_text"])
            end
            love.graphics.print("Return", 278, 394)
        elseif self.state == "SAVED" then
            self:drawSaveFile(self.saved_file, self.saves[self.saved_file], 74, 26, false, true)

            self:drawSaveFile(1, self.saves[1], 74, 138, self.selected_y == 1)
            Draw.draw(self.divider_sprite, 74, 208, 0, 493, 2)

            self:drawSaveFile(2, self.saves[2], 74, 222, self.selected_y == 2)
            Draw.draw(self.divider_sprite, 74, 292, 0, 493, 2)

            self:drawSaveFile(3, self.saves[3], 74, 306, self.selected_y == 3)

            love.graphics.stencil(function ()
                Draw.pushShader(Kristal.Shaders["Mask"], {})
                Draw.draw(self.divider_sprite_mask, 74, 208, 0, 493, 2)
                Draw.draw(self.divider_sprite_mask, 74, 292, 0, 493, 2)
                Draw.popShader()
            end)
            love.graphics.setStencilTest("equal", 1)
            local left_width  = self.save_list.left[1]:getWidth()
            local top_height  = self.save_list.top[1]:getHeight()
            local total_width, total_height = left_width * 4 + self.save_list.width, top_height * 4 + self.save_list.height
            local stripe_width, stripe_height = self.save_list.stripe_mask:getDimensions()
            love.graphics.translate(self.save_list.x, self.save_list.y)
            for x = 0, total_width, stripe_width * 2 do
                for y = 0, total_height, stripe_height * 2 do
                    -- Log(x, y)
                    Draw.draw(self.save_list.stripe_mask, x - left_width * 2, y - top_height * 2, 0, 2, 2)
                end
            end
            love.graphics.translate(-self.save_list.x, -self.save_list.y)
            love.graphics.setStencilTest()
        end

        super.super.draw(self)

        if self.state == "OVERWRITE" then
            Draw.setColor(PALETTE["world_text"])
            local overwrite_text = "Overwrite Slot "..self.selected_y.."?"
            love.graphics.print(overwrite_text, SCREEN_WIDTH/2 - self.font:getWidth(overwrite_text)/2, 123)

            local function drawOverwriteSave(data, x, y)
                local w = 478

                -- Header
                love.graphics.print(data.name, x + (w/2) - self.font:getWidth(data.name)/2, y)
                love.graphics.print("LV "..data.level, x, y)

                local minutes = math.floor(data.playtime / 60)
                local seconds = math.floor(data.playtime % 60)
                local time_text = string.format("%d:%02d", minutes, seconds)
                love.graphics.print(time_text, x + w - self.font:getWidth(time_text), y)

                -- Room name
                love.graphics.print(data.room_name, x + (w/2) - self.font:getWidth(data.room_name)/2, y+30)
            end

            Draw.setColor(PALETTE["world_text"])
            drawOverwriteSave(self.saves[self.selected_y], 80, 165)
            Draw.setColor(PALETTE["world_text_selected"])
            drawOverwriteSave(Game:getSavePreview(), 80, 235)

            if self.selected_x == 1 then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, 142, 332)

                Draw.setColor(PALETTE["world_text_selected"])
            else
                Draw.setColor(PALETTE["world_text"])
            end
            love.graphics.print("Save", 170, 324)

            if self.selected_x == 2 then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, 322, 332)

                Draw.setColor(PALETTE["world_text_selected"])
            else
                Draw.setColor(PALETTE["world_text"])
            end
            love.graphics.print("Return", 350, 324)
        end
    end
end

return SaveMenu