local JollyRedBusterFX, super = Class(FXBase)

function JollyRedBusterFX:draw(texture)
    Draw.setColor(COLORS.white, 0.4)
    local x, y = self.parent.x, self.parent.y
    love.graphics.draw(texture, x, y, 0, 1.4, 1.4, x, y)
    love.graphics.draw(texture, x, y, 0, 1.3, 1.3, x, y)
    love.graphics.draw(texture, x, y, 0, 1.2, 1.2, x, y)
    love.graphics.draw(texture, x, y, 0, 1.1, 1.1, x, y)
    Draw.setColor(COLORS.white)
    love.graphics.draw(texture, x, y, 0, 1  , 1  , x, y)
end

return JollyRedBusterFX