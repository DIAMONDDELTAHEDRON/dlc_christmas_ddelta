---@diagnostic disable: param-type-mismatch, missing-parameter
local ActorSprite, super = HookSystem.hookScript(ActorSprite)

function ActorSprite:init(actor)
    super.init(self, actor)

    self.jolly = JollyLib.getJollyConfig("christmas_hat", "activate")
    if self.jolly then
        if not (self.actor.christmas_hat_offset == nil and not JollyLib.getJollyConfig("christmas_hat", "add_even_if_not_specified")) then
            self.christmas_hat_sprite = Sprite("misc/christmas_hat")
            self.christmas_hat_sprite:setScale(self.actor.christmas_hat_scale or JollyLib.getJollyConfig("christmas_hat", "scale"))
            self.christmas_hat_sprite:setOriginExact(60, 80)
            self.christmas_hat_sprite:setLayer(10)
            self:addChild(self.christmas_hat_sprite)
            self:repositionChristmasHat()
        end
    end
end

function ActorSprite:getChristmasHatOffset(anim)
    -- local default_offset = self.actor.christmas_hat_offset or {0, 0}
    -- local offset = self:getOffset()
    -- return default_offset[1] - offset[1], default_offset[2] - offset[2]
    -- Log(self.actor:getDefaultAnim())
    if self.actor.christmas_hat_offset then
        return self.actor.christmas_hat_offset[anim or self.anim or self.actor:getDefault()] or {0, 0}
    else
        return {0, 0}
    end
end

function ActorSprite:repositionChristmasHat(anim)
    if not self.christmas_hat_sprite then return end
    self.christmas_hat_sprite:setPosition(unpack(self:getChristmasHatOffset(anim)))
end

function ActorSprite:update()
    super.update(self)

    self:repositionChristmasHat()
end

-- For some stupid reason this causes problem with acts
-- Wait it doesn't anymore?????
-- What????
-- function ActorSprite:setAnimation(anim, callback, ignore_actor_callback)
--     super.setAnimation(self, anim, callback, ignore_actor_callback)
--     -- Log(anim)
--     self:repositionChristmasHat(anim)
-- end

-- function ActorSprite:setSprite(...)
--     super.setSprite(self, ...)
--     self:repositionChristmasHat()
-- end

return ActorSprite