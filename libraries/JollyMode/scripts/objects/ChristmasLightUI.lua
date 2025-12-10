---@diagnostic disable: redefined-local
local ChristmasLight, super = Class(Object)

function ChristmasLight:init(x, y, width, height, options)
    super.init(self, x, y, width, height)
    self.debug_select = false

    options = options or {}

    self.canvas = love.graphics.newCanvas(width, height)
    self.points = {}
    self.pixel_size = 2
    self.line_width = 2

    -- self.current_flicker_type = "none" -- slow/fast
    self.seed = nil

    self.bulb_density = 1

    self.base_density = 40
    self.drop_length = 25
    self.precision = 10

    self.processed = false
    self.parts_to_draw = {}

    self.bulb_texture_base = Assets.getTexture("world/bulb/light_base")
    self.bulb_texture_top = Assets.getTexture("world/bulb/light_top")
    self.pixel = Assets.getTexture('misc/pixel')

    self.realistic_light = JollyLib.getJollyConfig("ui", "light", "realistic")
    self.bulb_glare = JollyLib.getJollyConfig("ui", "light", "glare")
    self.bulb_color = JollyLib.getJollyConfig("ui", "light", "color")
    self.density_multi = 1
end

-- function ChristmasLight:onAdd(parent)
--     local width, height = Game.world.map.width * Game.world.map.tile_width, Game.world.map.height * Game.world.map.tile_height
--     self:setSize(width, height)
--     self.canvas = love.graphics.newCanvas(width, height)
-- end

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

function ChristmasLight:processLight()
    table.sort(self.points, function (a, b)
        return a.order < b.order
    end)

    local path = GMPath2() -- Prob should've used Love2D's BezierCurve instead but oh well
    -- local path = love.math.newBezierCurve()
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
    love.math.setRandomSeed(self.seed)
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

        table.insert(self.parts_to_draw, {
            type = "bulb",
            x = x, y = y,
            color = color,
            index = i
        })
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
        -- Log(segment_length_copy)
        table.insert(self.parts_to_draw, {
            type = "line",
            x1 = x1, y1 = y1, x2 = x2, y2 = y2
        })
    end

    MathUtils.renewRandomSeed()
end

function ChristmasLight:update()
    super.update(self)

    if not self.processed then
        self:processLight()
        self.processed = true
    end
end

function ChristmasLight:addPoint(x, y, order, properties)
    properties = properties or {}
    table.insert(self.points, {
        x = x,
        y = y,
        order = (order or #self.points),
        looseness = properties["looseness"] or 0.5
    })
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
            local value = MathUtils.rangeMap(math.cos(Game:getLightTimer()), -1, 1, 0, 1)
            local alpha = 1
            -- if part.height > 200 then Log(alpha) end
            -- Log(part.height)
            if self.flicker_type ~= "none" then
                Draw.setColor(ColorUtils.mergeColor(part.color, {0.2, 0.2, 0.2}, (part.index % 2) == 0 and value or 1 - value), alpha)
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
            local alpha = 0.5
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
                    local value = MathUtils.rangeMap(math.cos(Game:getLightTimer()), -1, 1, 0, 1)
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
            local radius = 256
            local shader = Draw.pushShader("radial_gradient_light", {
                texture_size = {self.width, self.height},
                radius = {radius, radius},
                strength = 1
            })
            love.graphics.setBlendMode("add")
            -- Draw.popShader()
            for _, part in ipairs(self.parts_to_draw) do
                if part.type == "bulb" then
                    local draw_x, draw_y = part.x, part.y + tex_height + 6
                    shader:send("position", {draw_x, draw_y})
                    local value = MathUtils.rangeMap(math.cos(Game:getLightTimer()), -1, 1, 0, 1)
                    local color = ColorUtils.mergeColor(part.color, COLORS.black, 0.4 + 0.6 * ((part.index % 2) == 0 and value or 1 - value))
                    shader:send("draw_color", color)
                    -- shader:send("draw_color", ColorUtils.ensureAlpha(part.color))
                    love.graphics.draw(self.pixel, 0, 0, 0, self.width, self.height)
                end
            end
            love.graphics.setBlendMode("alpha")
            Draw.popShader()
        end
    end
end

return ChristmasLight