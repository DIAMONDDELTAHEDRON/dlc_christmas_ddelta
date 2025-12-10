---@diagnostic disable: redefined-local
local ChristmasLight, super = Class(Object)

function ChristmasLight:init(options)
    super.init(self)
    self.debug_select = false

    options = options or {}

    self.canvas = nil
    self.points = {}
    self.pixel_size = 2
    self.line_width = 2

    self:setOptions(options)

    -- self.current_flicker_type = "none" -- slow/fast
    self.flicker_siner = 0
    self.flicker_stop = 0
    self.flicker_stop_timer = 0
    self.seed = nil

    self.bulb_density = 1

    self.base_density = 40
    self.drop_length = 25
    self.precision = 10

    self.processed = false
    self.parts_to_draw = {}

    self.bulb_texture_base = Assets.getTexture("world/bulb/light_base")
    self.bulb_texture_top = Assets.getTexture("world/bulb/light_top")
    self.bulb_texture_wire = Assets.getTexture("world/bulb/light_wire")
    self.pixel = Assets.getTexture('misc/pixel')
end

function ChristmasLight:setOption(key, option, default_value)
    if option ~= nil then
        self[key] = option
    elseif self[key] == nil then
        self[key] = default_value
    end
end

function ChristmasLight:setOptions(options)
    -- self:setOption("shape", options["shape"])
    -- self:setOption("flicker_type", options["flicker"], "slow")
    self:setOption("flicker_speed", options["flicker_speed"], 1)
    self:setOption("flicker_halt", options["flicker_halt"], 0.5)
    self:setOption("bulb_color", options["color"], "colorful")
    self:setOption("bulb_glare", options["bulb_glare"], JollyLib.getJollyConfig("world", "light", "glare_default"))
    self:setOption("floor", options["floor"], JollyLib.getJollyConfig("world", "light", "floor_default"))
    self:setOption("mask", options["mask"])
    self:setOption("floor_layer", options["floor_layer"])
    self:setOption("density_multi", options["density"], 1)
    self:setOption("group", options["group"], 0)
    self:setOption("start_fadeout_height", options["fadeout_start"])
    self:setOption("end_fadeout_height", options["fadeout_end"])
    self:setOption("brightness", (options["brightness"] and options["brightness"] * 300 or nil), 300)
    self:setOption("looseness_default", options["looseness_default"], 1)
    self:setOption("height_default", options["height_default"], 120)
    self:setOption("realistic_light", options["realistic"], JollyLib.getJollyConfig("world", "light", "realistic_default"))
end

function ChristmasLight:addPoint(x, y, order, properties)
    table.insert(self.points, {
        x = x,
        y = y,
        order = (order or #self.points),
        looseness = properties["looseness"] or self.looseness_default,
        height = properties["height"] or self.height_default,
    })
end

function ChristmasLight:onAdd(parent)
    local width, height = Game.world.map.width * Game.world.map.tile_width, Game.world.map.height * Game.world.map.tile_height
    self:setSize(width, height)
    self.canvas = love.graphics.newCanvas(width, height)
end

function ChristmasLight:getDebugInfo()
    local info = super.getDebugInfo(self)
    table.insert(info, "Canvas Width: " .. self.canvas:getWidth())
    table.insert(info, "Canvas Height: " .. self.canvas:getHeight())
    return info
end

-- Function I wrote like 4-5 months ago (as of sep 20th 2025) for something
-- I made that was later abandoned
local function _getArc(change_x, change_y, looseness, percentage)
    if change_x == 0 then return 0 end
    local sign = MathUtils.sign(change_x)
    local x = change_x * percentage
    local y = (-x ^ 2 / math.abs(change_x) + x * sign) * looseness + change_y / change_x * x
    return y
end

local function getArc(x1, y1, x2, y2, looseness, percentage)
    local change_x, change_y = x2 - x1, y2 - y1
    return y1 + _getArc(change_x, change_y, looseness, percentage)
end

-- local function _getSlope(change_x, change_y, looseness, percentage)
--     local sign = MathUtils.sign(change_x)
--     local x = change_x * percentage
--     local slope = (-2 * math.abs(change_x) * x + sign) * looseness + change_y / change_x
--     return slope
-- end

-- Makes the light pattern consistent every times the room is loaded
-- (It's good enough)
local function stringToHash(str)
    local numbers = {string.byte(str, 1, #str)}
    local total = 0
    for i, n in ipairs(numbers) do
        total = total + i * n
    end
    return total
end

function ChristmasLight:processLight()
    self.floor = self.floor or self.mask ~= nil or self.floor_layer ~= nil
    if self.floor and not self.floor_obj then
        local mask = self.mask and Game.world.map:getTileLayer(self.mask) or nil
        local layer = self.floor_layer or (Game.world.player.layer - Game.world.map.depth_per_layer / 2)
        if mask then
            layer = mask.layer + Game.world.map.depth_per_layer / 2
        end
        self.floor_obj = ChristmasLightFloor(self, layer, mask)
        Game.world:addChild(self.floor_obj)
        -- local layer = Game.world.map:getTileLayer(self.floor)
        -- if layer then
        --     self.floor_obj = ChristmasLightFloor(self, layer, self.floor_layer or (layer.layer + Game.world.map.depth_per_layer / 2))
        --     Game.world:addChild(self.floor_obj)
        -- else
        --     Kristal.Console:warn(string.format('Tile layer "%s" not found for Christmas light', self.floor))
        -- end
    end

    table.sort(self.points, function (a, b)
        return a.order < b.order
    end)

    local path = GMPath2()
    -- self.path = path
    local segment_length = {}
    for i = 1, #self.points - 1 do
        local p1, p2 = self.points[i], self.points[i + 1]
        local x1, y1, x2, y2 = p1.x, p1.y, p2.x, p2.y
        local change_x = x2 - x1
        local looseness = p1.looseness
        local amount = math.ceil(change_x / self.precision)
        local length = 0
        local sign = MathUtils.sign(change_x)
        if sign ~= 0 then
            for n = (i == 1 and 0 or 1), amount, sign do
                local percentage = n / amount
                local px, py = x1 + change_x * percentage, getArc(x1, y1, x2, y2, looseness, percentage)
                path:addPoint(px, py)

                local p_last = path.points[#path.points - 1]
                if p_last then
                    length = length + MathUtils.dist(p_last.x, p_last.y, px, py)
                end
            end
        else
            if i == 1 then
                path:addPoint(x1, y1)
            end
            path:addPoint(x2, y2)
        end
        table.insert(segment_length, length)
    end

    path:processInternal()

    local density = self.base_density * self.density_multi
    local path_length = path:getTotalLength()
    local bulb_amount = math.floor(path_length / density)
    love.math.setRandomSeed(stringToHash(Game.world.map.id) + self.group)
    local current_length = 0
    local point_index = 1
    local segment_length_copy = TableUtils.copy(segment_length)
    for i = 1, bulb_amount - 1 do
        current_length = current_length + density
        if #segment_length_copy > 0 and current_length >= segment_length_copy[1] then
            current_length = current_length - segment_length_copy[1]
            table.remove(segment_length_copy, 1)
            point_index = point_index + 1
        end
        local value = i * density
        local point = path:getPointAtLength(value)
        local x, y = point.x, point.y

        local color
        if self.bulb_color == "colorful" then
            local hue = MathUtils.random()
            color = {ColorUtils.HSVToRGB(hue, 1, 1)}
        else
            color = ColorUtils.hexToRGB(self.bulb_color)
        end
        -- local color = {ColorUtils.HSVToRGB(hue, 1, 1)}

        local p1, p2 = self.points[point_index], self.points[point_index + 1]
        if p1 ~= nil and p2 ~= nil and current_length / segment_length_copy[1] ~= math.huge then
            local ground_y = MathUtils.lerp(p1.y, p2.y, current_length / segment_length_copy[1]) + MathUtils.lerp(p1.height, p2.height, current_length / segment_length_copy[1])
            -- Log(current_length / segment_length_copy[1], current_length / segment_length_copy[1] ~= math.huge, ground_y, y, ground_y - y)
            table.insert(self.parts_to_draw, {
                type = "bulb",
                x = x, y = y,
                color = color,
                ground_y = ground_y,
                height = ground_y - y,
                index = i
            })
        end
    end

    local line_amount = math.floor(path_length / self.precision)
    local current_length = 0
    local point_index = 1
    local segment_length_copy = TableUtils.copy(segment_length)
    for i = 0, line_amount - 1 do
        current_length = current_length + self.precision
        if #segment_length_copy > 0 and current_length >= segment_length_copy[1] then
            current_length = current_length - segment_length_copy[1]
            table.remove(segment_length_copy, 1)
            point_index = point_index + 1
        end

        local path_p1, path_p2 = path:getPointAtLength(i / line_amount * path_length), path:getPointAtLength((i + 1) / line_amount * path_length)
        local x1, y1, x2, y2 = path_p1.x, path_p1.y, path_p2.x, path_p2.y
        local p1, p2 = self.points[point_index], self.points[point_index + 1]
        if p1 ~= nil and p2 ~= nil then
            local ground_y = MathUtils.lerp(p1.y, p2.y, current_length / segment_length_copy[1]) + MathUtils.lerp(p1.height, p2.height, current_length / segment_length_copy[1])
            table.insert(self.parts_to_draw, {
                type = "line",
                x1 = x1, y1 = y1, x2 = x2, y2 = y2,
                ground_y = ground_y,
                height = ground_y - (y1 + y2) / 2
            })
        end
    end

    table.sort(self.parts_to_draw, function (a, b)
        return a.ground_y < b.ground_y
    end)

    MathUtils.renewRandomSeed()
end

function ChristmasLight:update()
    super.update(self)

    if not self.processed then
        self:processLight()
        self.processed = true
    end

    if self.flicker_stop_timer >= 0 then
        self.flicker_stop_timer = self.flicker_stop_timer - DTMULT
    elseif self.flicker_speed > 0 then
        -- if self.flicker_type == "slow" then
        local add = DTMULT / 16 * self.flicker_speed
        self.flicker_siner = (self.flicker_siner + add) % math.rad(360)
        -- Log(math.deg(self.flicker_siner))
        self.flicker_stop = self.flicker_stop + add
        if self.flicker_stop >= math.rad(180) then
            self.flicker_siner = MathUtils.roundToMultiple(self.flicker_siner, math.rad(180))
            self.flicker_stop = self.flicker_stop - math.rad(180)
            self.flicker_stop_timer = self.flicker_halt * 30
        end
        -- elseif self.flicker_type == "fast" then
        --     self.flicker_siner = (self.flicker_siner + DTMULT / 5) % math.rad(360)
        -- end
    end
end

function ChristmasLight:draw()
    super.draw(self)

    -- Pushes the canvas and clears it
    local function pushCanvas()
        Draw.pushCanvas(self.canvas)
        love.graphics.clear()
    end

    -- Pops the canvas and draws it to the screen
    local function popAndDrawCanvas()
        Draw.popCanvas()
        Draw.setColor(COLORS.white)
        Draw.pushShader("pixelate", {
            size = {self.width, self.height},
            factor = self.pixel_size
        })
        Draw.draw(self.canvas)
        Draw.popShader()
    end

    pushCanvas()

    local used_canvas = true
    for _, part in ipairs(self.parts_to_draw) do
        if part.type == "bulb" then
            if used_canvas == true then
                popAndDrawCanvas()
            end
            used_canvas = false
            -- bulb_index = bulb_index + 1
            local tex_width = self.bulb_texture_base:getWidth()
            local value = MathUtils.rangeMap(math.cos(self.flicker_siner), -1, 1, 0, 1)
            local alpha = 1
            if self.start_fadeout_height and self.end_fadeout_height then
                alpha = MathUtils.rangeMap(part.height, self.start_fadeout_height, self.end_fadeout_height, 1, 0)
            end
            -- if part.height > 200 then Log(alpha) end
            -- Log(part.height)
            if self.flicker_speed > 0 then
                local dark_color = self.realistic_light and {0.1, 0.1, 0.1} or {0.2, 0.2, 0.2}
                Draw.setColor(ColorUtils.mergeColor(part.color, dark_color, (part.index % 2) == 0 and value or 1 - value), alpha)
            else
                Draw.setColor(part.color, alpha)
            end
            love.graphics.draw(self.bulb_texture_base, part.x, part.y, 0, 2, 2, tex_width / 2)
            Draw.setColor(COLORS.white, alpha)
            love.graphics.draw(self.bulb_texture_top, part.x, part.y, 0, 2, 2, tex_width / 2)
        elseif part.type == "line" then
            if used_canvas == false then
                pushCanvas()
            end
            used_canvas = true
            -- local alpha = MathUtils.rangeMap(part.height, self.start_fadeout_height, self.end_fadeout_height, 1, 0) / 2
            local alpha = 0.5
            if self.start_fadeout_height and self.end_fadeout_height then
                alpha = MathUtils.rangeMap(part.height, self.start_fadeout_height, self.end_fadeout_height, 1, 0) / 2
            end
            Draw.setColor(0.25, 0.25, 0.25, alpha)
            love.graphics.setLineWidth(2)
            love.graphics.line(part.x1, part.y1, part.x2, part.y2)

            Draw.setColor(0.35, 0.35, 0.35, alpha)
            love.graphics.setLineWidth(1.5)
            love.graphics.line(part.x1, part.y1, part.x2, part.y2)
        end
    end

    if used_canvas then
        popAndDrawCanvas()
    end

    if self.bulb_glare then
        if not self.realistic_light then
            love.graphics.setBlendMode("add")
            for _, part in ipairs(self.parts_to_draw) do
                if part.type == "bulb" then
                    local value = MathUtils.rangeMap(math.cos(self.flicker_siner), -1, 1, 0, 1)
                    local alpha = (part.index % 2) == 1 and value or 1 - value
                    Draw.setColor(part.color, 0.1 * alpha)
                    local radius = 20
                    love.graphics.circle("fill", part.x, part.y + 18, radius)
                    love.graphics.circle("fill", part.x, part.y + 18, radius * 1.5)
                    love.graphics.circle("fill", part.x, part.y + 18, radius * 2)
                end
            end
            love.graphics.setBlendMode("alpha")
        else
            Draw.setColor(COLORS.white)
            local _, tex_height = self.bulb_texture_base:getDimensions()
            local radius = 128
            local shader = Draw.pushShader("radial_gradient_light", {
                texture_size = {self.width, self.height},
                radius = {radius, radius},
                strength = self.brightness / 150,
            })
            love.graphics.setBlendMode("add")
            -- Draw.popShader()
            for _, part in ipairs(self.parts_to_draw) do
                if part.type == "bulb" then
                    local draw_x, draw_y = part.x, part.y + tex_height + 4
                    shader:send("position", {draw_x, draw_y})
                    local value = MathUtils.rangeMap(math.cos(self.flicker_siner), -1, 1, 0, 1)
                    -- local merge_amount = self.flicker_type ~= "none" and (1.5 * ((part.index % 2) == 0 and value or 1 - value)) or 0
                    local color = (self.flicker_speed > 0) and
                                    ColorUtils.mergeColor(part.color, COLORS.black, 1.5 * ((part.index % 2) == 0 and value or 1 - value)) or
                                    ColorUtils.ensureAlpha(part.color)
                    shader:send("draw_color", color)

                    -- shader:send("draw_color", ColorUtils.ensureAlpha(part.color))
                    love.graphics.draw(self.pixel, 0, 0, 0, self.width, self.height)
                end
            end
            love.graphics.setBlendMode("alpha")
            Draw.popShader()
        end
    end

    if DEBUG_RENDER then
        for _, part in ipairs(self.parts_to_draw) do
            if part.type == "bulb" then
                local font = Assets.getFont("main")
                love.graphics.setFont(font)
                local text = "h: " .. string.format("%.0f", part.height)
                Draw.setColor(COLORS.white)
                love.graphics.print(text, part.x - font:getWidth(text) / 4, part.y - 20, 0, 0.5, 0.5)
                local text_2 = "y: " .. string.format("%.0f", part.ground_y)
                love.graphics.print(text_2, part.x - font:getWidth(text_2) / 4, part.y - 10, 0, 0.5, 0.5)
                Draw.setColor(COLORS.red, 0.5)
                love.graphics.circle("fill", part.x, part.ground_y, 4)
            end
        end
    end
end

return ChristmasLight