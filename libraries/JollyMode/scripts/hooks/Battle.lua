---@diagnostic disable: inject-field, redundant-parameter
local Battle, super = HookSystem.hookScript(Battle)

function Battle:init()
    super.init(self)

    self.snowflake_timer = 0
end

function Battle:drawBackground()
    local color_1 = {66 / 255, 0, 66 / 255}
    local color_2 = color_1
    if JollyLib.getJollyConfig("battle", "activate") then
        color_2 = {0.6, 0.3, 0.3}
        color_1 = {0.3, 0.3, 0.3}
    end
    Draw.setColor(0, 0, 0, self.transition_timer / 10)
    love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH + 16, SCREEN_HEIGHT + 16)

    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(1)

    for i = 2, 16 do
        Draw.setColor(color_1, (self.transition_timer / 10) / 2)
        love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
        love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
    end

    for i = 3, 16 do
        Draw.setColor(color_2, self.transition_timer / 10)
        love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
        love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
    end
end

function Battle:update()
    super.update(self)

    if JollyLib.getJollyConfig("battle", "activate") then
        self.snowflake_timer = self.snowflake_timer + DTMULT
        local snowflake_timer_threshold = 15
        if self.snowflake_timer >= snowflake_timer_threshold then
            self.snowflake_timer = self.snowflake_timer - snowflake_timer_threshold
            local snowflake = self:addChild(BattleSnowflake(MathUtils.random(0, SCREEN_WIDTH), -10, "battle"))
            local layer = ({"below_battlers", "above_battlers", "above_ui", "top"})[JollyLib.getJollyConfig("battle", "snowflake_layer")]
            snowflake:setLayer(BATTLE_LAYERS[layer])
        end
    end
end

return Battle