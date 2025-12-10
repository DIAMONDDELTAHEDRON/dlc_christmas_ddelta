local LightMarker, super = Class(Event, "clightpoint")

function LightMarker:init(data)
    super.init(self, data)

    self.properties = data.properties or {}
end

function LightMarker:onLoad()
    local properties = self.properties
    local group = properties["group"] or 0
    local order = properties["order"]
    local light_obj
    -- Log(Game.world:getSize())
    for _, obj in ipairs(Game.world.children) do
        if obj:includes(ChristmasLightWorld) and obj.group == group then
            light_obj = obj
            break
        end
    end
    if not light_obj then
        light_obj = ChristmasLightWorld(properties)
        light_obj.group = group
        -- light_obj:setLayer(self.layer)
        light_obj:setLayer(self.layer)
        Game.world:addChild(light_obj)
    else
        light_obj:setOptions(properties)
    end
    light_obj:addPoint(self.x, self.y, order, properties)

    self:remove()
    -- self.light_obj = light_obj
    -- self.group = group
    -- self.order = order
    -- self.layer = light_obj.layer + 1
end

-- function LightMarker:update()
--     super.update(self)

--     if #self.light_obj.points == 3 then self.light_obj.points = {} end
--     self.light_obj:addPoint(self.x, self.y, self.order)
-- end

-- function LightMarker:draw()
--     super.draw(self)

--     if DEBUG_RENDER then
--         Draw.setColor(COLORS.green)
--         love.graphics.setLineWidth(2)
--         love.graphics.rectangle("line", 0, 0, self.width, self.height)
--         love.graphics.setFont(Assets.getFont("smallnumbers"))
--         love.graphics.print(self.order)
--     end
-- end

return LightMarker