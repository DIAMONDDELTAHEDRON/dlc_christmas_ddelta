local SnowGraveSpell, super = HookSystem.hookScript(SnowGraveSpell)

function SnowGraveSpell:init(user)
---@diagnostic disable-next-line: redundant-parameter
    super.init(self, user)
    self.bg_snowfall = Assets.getTexture("effects/icespell/snowfall" .. (JollyLib.getJollyConfig("jolly_spell") and "_jolly" or ""))
    self.sound_timer = -20
end

function SnowGraveSpell:update()
    super.update(self)

    self.sound_timer = self.sound_timer + DTMULT
    if self.sound_timer > 2.5 and self.timer <= 75 then
        self.sound_timer = self.sound_timer - 2.5
        Assets.playSound("toysanta")
    end
end

return SnowGraveSpell