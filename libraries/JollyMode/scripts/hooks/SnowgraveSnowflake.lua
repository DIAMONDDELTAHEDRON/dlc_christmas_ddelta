local SnowGraveSnowflake, super = HookSystem.hookScript(SnowGraveSnowflake)

function SnowGraveSnowflake:init(...)
    super.init(self, ...)

    if JollyLib.getJollyConfig("jolly_spell") then
        self.snowflake = Assets.getTexture("effects/icespell/" .. (MathUtils.random() < 0.2 and "papyrus" or "toysanta"))
    end
end

return SnowGraveSnowflake