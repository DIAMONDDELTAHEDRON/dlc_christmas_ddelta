-- Used to synchronize the timer for Christmas Light UI
local GlobalLightUITimer, super = Class(Object)

function GlobalLightUITimer:init()
    super.init(self)

    self.visible = false

    self.flicker_siner = 0
    self.flicker_stop = 0
    self.flicker_stop_timer = 0
end

function GlobalLightUITimer:update()
    -- super.update call not needed
    -- super.update(self)

    if self.flicker_stop_timer >= 0 then
        self.flicker_stop_timer = self.flicker_stop_timer - DTMULT
    else
        local add = DTMULT / 16 * JollyLib.getJollyConfig("ui", "light", "flicker_speed")
        self.flicker_siner = (self.flicker_siner + add) % math.rad(360)
        self.flicker_stop = self.flicker_stop + add
        if self.flicker_stop >= math.rad(180) then
            self.flicker_siner = MathUtils.roundToMultiple(self.flicker_siner, math.rad(180))
            self.flicker_stop = self.flicker_stop - math.rad(180)
            self.flicker_stop_timer = JollyLib.getJollyConfig("ui", "light", "flicker_halt") * 30
        end
    end
end

return GlobalLightUITimer