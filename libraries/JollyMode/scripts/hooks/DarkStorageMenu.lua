local DarkStorageMenu, super = HookSystem.hookScript(DarkStorageMenu)

function DarkStorageMenu:init(...)
    super.init(self, ...)

    self.jolly = JollyLib.getJollyConfig("ui", "light")
    if self.jolly then
        self.stripe_mask = Assets.getTexture("ui/box/stripe_mask")
    end
end

function DarkStorageMenu:draw()
    local function drawOutlines()
        love.graphics.setLineWidth(4)
        Draw.setColor(PALETTE["world_border"])
        love.graphics.rectangle("line", 42, 122, 557, 155)
        love.graphics.rectangle("line", 42, 277, 557, 152)
    end
    if JollyLib.getJollyConfig("ui", "light") then
        love.graphics.stencil(function ()
            love.graphics.setColorMask(true, true, true, true)
            drawOutlines()
        end, "replace", 1)
        love.graphics.setStencilTest("equal", 1)
        local stripe_width, stripe_height = self.stripe_mask:getDimensions()
        Draw.setColor(COLORS.red)
        for x = 0, self.width, stripe_width * 2 do
            for y = 0, self.height, stripe_height * 2 do
                -- Log(x, y)`
                Draw.draw(self.stripe_mask, x, y, 0, 2, 2)
            end
        end
        love.graphics.setStencilTest()
    else
        drawOutlines()
    end

    Draw.setColor(PALETTE["world_fill"])
    love.graphics.rectangle("fill", 44, 124, 553, 151)
    love.graphics.rectangle("fill", 44, 279, 553, 148)
    love.graphics.setLineWidth(1)

    self:drawStorage(1)
    self:drawStorage(2)

    super.super.draw(self)
end

return DarkStorageMenu