local TensionBarGlow, super = HookSystem.hookScript(TensionBarGlow)

-- function TensionBarGlow:draw()
--     if self.parent.jolly then
--         love.graphics.translate(-35, 0)
--     end
--     super.draw(self)
--     if self.parent.jolly then
--         love.graphics.translate(35, 0)
--     end
-- end

function TensionBarGlow:draw()
    -- Simplified draw code. DELTARUNE's is very verbose for no real reason
    -- The largest change is the lack of for loop, because DELTARUNE had a for loop
    -- that only did a single iteration... so that was completely removed

    Draw.setColor(1, 1, 1, 1)

    love.graphics.setBlendMode("add")

    -- Can be simplified to `0.75 * self.current_alpha`, but the `1` is the
    -- current iteration of the for loop... the one that only ran a single time
    local alpha = (1 - (1 * 0.25)) * self.current_alpha

    -- Do our draw code in all 8 directions
    local offsets = { -1, 0, 1 }
    for _, dx in ipairs(offsets) do
        for _, dy in ipairs(offsets) do
            if not (dx == 0 and dy == 0) then
                Draw.draw(self.parent.tp_text, -30 + dx, 30 + dy, 0, 1, 1)

                love.graphics.setFont(self.parent.font)
                Draw.setColor(1, 1, 1, alpha)

                if Game.tension < 100 then
                    love.graphics.print(tostring(math.floor(Game.tension)), -30 + dx, 70 + dy)
                    love.graphics.print("%", -25 + dx, 95 + dy)
                else
                    love.graphics.print("M", -28 + dx, 70 + dy)
                    love.graphics.print("A", -24 + dx, 90 + dy)
                    love.graphics.print("X", -20 + dx, 110 + dy)
                end
            end
        end
    end

    love.graphics.setBlendMode("alpha")

    if self.parent.jolly then
        love.graphics.translate(-35, 0)
    end
    Draw.setColor(1, 1, 1, 0.75 * self.current_alpha)
    Draw.draw(self.parent.tp_bar_fill, 0, 0, 0, 1, 1)
    if self.parent.jolly then
        love.graphics.translate(35, 0)
    end

    super.super.draw(self)
end

return TensionBarGlow
