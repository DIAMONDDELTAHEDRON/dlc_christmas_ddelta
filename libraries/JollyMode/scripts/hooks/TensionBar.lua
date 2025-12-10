local TensionBar, super = HookSystem.hookScript(TensionBar)

function TensionBar:init(...)
    super.init(self, ...)

    self.jolly = JollyLib.getJollyConfig("battle", "activate")
    if self.jolly then
        self.tp_bar_fill = Assets.getTexture("ui/battle/tp_bar_fill_jolly")
        self.tp_bar_outline = Assets.getTexture("ui/battle/tp_bar_outline_jolly")
        self.tp_bar_overlay = Assets.getTexture("ui/battle/tp_bar_overlay_jolly")
    elseif Game:getConfig("oldTensionBar") then
        self.tp_bar_fill = Assets.getTexture("ui/battle/tp_bar_fill_old")
        self.tp_bar_outline = Assets.getTexture("ui/battle/tp_bar_outline_old")
    else
        self.tp_bar_fill = Assets.getTexture("ui/battle/tp_bar_fill")
        self.tp_bar_outline = Assets.getTexture("ui/battle/tp_bar_outline")
    end
end

function TensionBar:drawBack()
    Draw.setColor(self:hasReducedTension() and PALETTE["tension_back_reduced"] or PALETTE["tension_back"])
    local width = self.jolly and 60 or 25
    Draw.drawPart(self.tp_bar_fill, 0, 0, 0, 0, width, 196 - (self:getPercentageFor250(self.current) * 196) + 1)
end

function TensionBar:drawOverlay(...)
    if not self.jolly then return end
    local args = {...}
    love.graphics.stencil(function ()
        Draw.drawPart(self.tp_bar_fill, TableUtils.unpack(args))
    end, "replace", 1)
    love.graphics.setStencilTest("equal", 1)
    Draw.setColor(COLORS.white, Game.battle.encounter.reduced_tension and 0.5 or 0.75)
    Draw.draw(self.tp_bar_overlay)
    love.graphics.setStencilTest()
end

function TensionBar:drawFill()
    local tension_fill = self:getFillColor()
    local tension_max = self:getFillMaxColor()
    local tension_decrease = self:getFillDecreaseColor()

    local width = self.jolly and 60 or 25
    if (self.apparent < self.current) then
        Draw.setColor(tension_decrease)
        local y = MathUtils.clamp(196 - (self:getPercentageFor250(self.current) * 196) + 1, 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, 196)

        Draw.setColor(tension_fill)
        local y2 = MathUtils.clamp(196 - (self:getPercentageFor250(self.apparent) * 196) + 1 + (self:getPercentageFor(self.tension_preview) * 196), 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y2, 0, y2, width, 196)
        self:drawOverlay(0, y2, 0, y2, width, 196)
    elseif (self.apparent > self.current) then
        Draw.setColor(1, 1, 1, 1)
        local y = MathUtils.clamp(196 - (self:getPercentageFor250(self.apparent) * 196) + 1, 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, 196)

        Draw.setColor(tension_fill)
        if (self.maxed) then
            Draw.setColor(tension_max)
        end

        local y2 = MathUtils.clamp(196 - (self:getPercentageFor250(self.current) * 196) + 1 + (self:getPercentageFor(self.tension_preview) * 196), 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y2, 0, y2, width, 196)
        self:drawOverlay(0, y2, 0, y2, width, 196)
    elseif (self.apparent == self.current) then
        Draw.setColor(tension_fill)
        if (self.maxed) then
            Draw.setColor(tension_max)
        end

        local y = MathUtils.clamp(196 - (self:getPercentageFor250(self.current) * 196) + 1 + (self:getPercentageFor(self.tension_preview) * 196), 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, 196)
        self:drawOverlay(0, y, 0, y, width, 196)
    end

    if (self.tension_preview > 0) then
        local alpha = (math.abs((math.sin((self.tension_preview_timer / 8)) * 0.5)) + 0.2)
        local color_to_set = { 1, 1, 1, alpha }

        local theight = 196 - (self:getPercentageFor250(self.current) * 196)
        local theight2 = theight + (self:getPercentageFor(self.tension_preview) * 196)
        -- Note: causes a visual bug.
        if (theight2 > ((0 + 196) - 1)) then
            theight2 = ((0 + 196) - 1)
            color_to_set = { COLORS.dkgray[1], COLORS.dkgray[2], COLORS.dkgray[3], 0.7 }
        end

        local y = theight2 + 1
        local h = theight - theight2 + 1

        -- No idea how Deltarune draws this, cause this code was added in Kristal:
        local r, g, b, _ = love.graphics.getColor()
        Draw.setColor(r, g, b, 0.7)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, h)
        -- And back to the translated code:
        Draw.setColor(color_to_set)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, h)

        Draw.setColor(1, 1, 1, 1)
    end


    if ((self.apparent > 20) and (self.apparent < 250)) then
        Draw.setColor(1, 1, 1, 1)
        local y = MathUtils.clamp(196 - (self:getPercentageFor250(self.current) * 196) + 1, 0, 196)
        Draw.drawPart(self.tp_bar_fill, 0, y, 0, y, width, 3)
    end
end

function TensionBar:draw()
    if self.jolly then
        love.graphics.translate(-35, 0)
    end
    Draw.setColor(1, 1, 1, 1)
    Draw.draw(self.tp_bar_outline, 0, 0)
    self:drawBack()
    self:drawFill()
    if self.jolly then
        love.graphics.translate(35, 0)
    end

    self:drawText()

    super.super.draw(self)
end

return TensionBar