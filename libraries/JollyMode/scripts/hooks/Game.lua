local Game = HookSystem.hookScript(Game)

function Game:getLightTimer()
    return self.light_timer.flicker_siner
end

return Game