local PresentPart, super = Class(Object)

function PresentPart:init(sprite, color_box, color_ribbon, x, y)
    super.init(self, x, y)

    self.sprite_box = Assets.getTexture("world/events/present/" .. sprite .. "_box")
    -- Idk what people actually call those and Im too lazy to look it up
    -- Oh wait its actually called ribbon lmao
    self.sprite_ribbon = Assets.getTexture("world/events/present/" .. sprite .. "_ribbon")

    self.color_box = color_box
    self.color_ribbon = color_ribbon
end

function PresentPart:draw()
    super.draw(self)

    Draw.setColor(self.color_box, self.alpha)
    love.graphics.draw(self.sprite_box)
    Draw.setColor(self.color_ribbon, self.alpha)
    love.graphics.draw(self.sprite_ribbon)
end

return PresentPart