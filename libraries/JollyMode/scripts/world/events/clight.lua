local LightObj, super = Class(Event, "clight")

local function any(tbl, func)
    for index, value in ipairs(tbl) do
        if func(value, index) then return true, value, index end
    end
    return false
end

function LightObj:init(data)
    super.init(self, data)

    local properties = data.properties or {}

    local point_properties = {}
    local properties_check = {"looseness", "height"}
    for key, value in pairs(properties) do
        local rest
        local success, property_success = any(properties_check, function (check)
            local success_, rest_ = StringUtils.startsWith(key, check)
            rest = rest_
            return success_
        end)
        if success and rest ~= "_default" then
            -- point_properties[tosrt]
            local point_index = tonumber(StringUtils.sub(rest, 2))
            assert(point_index, string.format('Expected number for point index for property "%s" of "clight" event', value))
            local str = tostring(point_index)
            if point_properties[str] == nil then
                point_properties[str] = {}
            end
            point_properties[str][property_success] = value
        end
    end

    self.light = nil
    if data.shape == "polyline" or data.shape == "polygon" then
        local points = TableUtils.copy(data[data.shape])
        self.light = ChristmasLightWorld(properties)
        if data.shape == "polygon" then
            table.insert(points, points[1])
            Log(data[data.shape])
        end
        for i, point in ipairs(points) do
            local true_index = i
            if data.shape == "polygon" and i == #points then
                true_index = 1
            end
            self.light:addPoint(self.x + point.x, self.y + point.y, i, point_properties[tostring(true_index)] or {})
        end
    -- elseif data.shape == "rec"
    -- elseif data.shape == "rectangle" then
    --     local points = {
    --         {self.x             , self.y              },
    --         {self.x + self.width, self.y              },
    --         {self.x + self.width, self.y + self.height},
    --         {self.x             , self.y + self.height},
    --         {self.x             , self.y              }
    --     }
    --     for i, point in ipairs(points) do
    --         local true_index = i
    --         if i == #points then
    --             true_index = 1
    --         end
    --         self.light:addPoint(point[1], point[2], i, point_properties[tostring(true_index)] or {})
    --     end
    -- elseif data.shape == "ellipse" then
    --     -- local points = {}
    --     for i = 0, 9, 1 do
    --         local radius = i * math.rad(45)
    --     end
    end
end

function LightObj:onLoad()
    if self.light then
        Game.world:spawnObject(self.light, self.layer)
        self:remove()
    end
end

return LightObj