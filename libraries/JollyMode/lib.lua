local Lib = {}

function Lib:init()
    Registry.registerGlobal("JollyLib", self)
end

function Lib.getJollyConfig(...)
    local args = {...}
    local config = Kristal.getLibConfig("jollymode", args[1])
    table.remove(args, 1)
    for _, value in ipairs(args) do
        config = config[value]
    end
    return config
end

function Lib:postInit()
    Game.light_timer = Game.stage:addChild(GlobalLightUITimer())
    local border_alpha = JollyLib.getJollyConfig("border_alpha")
    if border_alpha > 0 then
        local sprite = Game.stage:addChild(Sprite("ui/christmas_border"))
        sprite.alpha = border_alpha
        sprite:setLayer(5)
    end
end

function Lib:getUISkin()
    if JollyLib.getJollyConfig("ui", "border") then
        return Game:isLight() and "light_jolly" or "dark_jolly"
    end
end

function Lib.stringToHash(str)
    local numbers = {string.byte(str, 1, #str)}
    local total = 0
    for i, n in ipairs(numbers) do
        total = total + i * n * 40
    end
    return total
end

return Lib