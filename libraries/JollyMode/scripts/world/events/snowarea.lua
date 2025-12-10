local SnowArea, super = Class(Event, "snowarea")

function SnowArea:init(data)
    super.init(self, data)

    local properties = data.properties or {}
    self.falling_height = properties["height"] or 320
    self.falling_speed = properties["speed"] or 1
    self.frequency = properties["frequency"] or (5 / 30)
    self.wind = properties["wind"] or 0
    self.adjust_wind = properties["adjust_wind"] or false
    self.generate_on_add = properties["generate_on_add"] or false

    self.spawn_timer = 0
end

function SnowArea:spawnSnowflake(height)
    local x, y = MathUtils.random(self.x, self.x + self.width), MathUtils.random(self.y, self.y + self.height)
    if self.adjust_wind then
        x = x - (height / self.falling_speed) * self.wind
    end
    local snowflake = WorldSnowflake(x, y, height, self.falling_speed, self.wind)
    return Game.world:spawnObject(snowflake, self.layer)
end

function SnowArea:onAdd(parent)
    super.onAdd(self, parent)

    if self.generate_on_add then
        for i = 1, self.falling_height / self.falling_speed / (self.frequency * 30) do
            -- How long the snowflake would've been alive for in frames at 30 FPS
            local alive_time = i * self.frequency * 30
            local snowflake = self:spawnSnowflake(self.falling_height - alive_time * self.falling_speed)
            snowflake.spin = snowflake.spin_amount * alive_time
            snowflake.siner = alive_time * math.rad(5)
        end
    end
end

function SnowArea:update()
    super.update(self)

    self.spawn_timer = self.spawn_timer + DT
    if self.spawn_timer >= self.frequency then
        self.spawn_timer = self.spawn_timer - self.frequency
        self:spawnSnowflake(self.falling_height)
    end
end

return SnowArea