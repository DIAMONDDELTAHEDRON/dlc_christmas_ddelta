local Present, super = Class(Event, "present")

function Present:init(data)
    super.init(self, data)

    local properties = data.properties or {}

    self:setOrigin(0.5, 0.5)
    self:setScale(2)

    -- self.base_sprite = Sprite("world/events/present/base")
    -- self.lid_sprite = Sprite("world/events/present/lid", 0, -4)
    -- self:addChild(self.base_sprite)
    -- self:addChild(self.lid_sprite)
    -- self.base = Object()
    -- self.base_box

    local color_wrapper = TiledUtils.parseColorProperty(properties["wrapper"]) or COLORS.red
    local color_ribbon = TiledUtils.parseColorProperty(properties["ribbon"]) or COLORS.yellow
    self.base_sprite = PresentPart("base", color_wrapper, color_ribbon)
    self.lid_sprite = PresentPart("lid", color_wrapper, color_ribbon, 0, -4)
    self:addChild(self.base_sprite)
    self:addChild(self.lid_sprite)

    self:setSize(20, 24)
    self:setHitbox(0, 8, 20, 12)

    self.item = properties["item"]
    self.money = properties["money"]

    self.set_flag = properties["setflag"]
    self.set_value = properties["setvalue"]

    self.solid = true
end

function Present:onAdd(parent)
    super.onAdd(self, parent)

    if self:getFlag("opened") then
        self.lid_sprite:remove()
    end
end

function Present:getDebugInfo()
    local info = super.getDebugInfo(self)
    if self.item then
        table.insert(info, "Item: " .. self.item)
    end
    if self.money then
        if not Game:isLight() then
            table.insert(info, "Money: " .. Game:getConfig("darkCurrencyShort") .. " " .. self.money)
        else
            table.insert(info, Game:getConfig("lightCurrency").. ": " .. Game:getConfig("lightCurrencyShort") .. " " .. self.money)
        end
    end
    table.insert(info, "Opened: " .. (self:getFlag("opened") and "True" or "False"))
    return info
end

--- Handles opening the chest and giving the player their items
function Present:onInteract(player, dir)
    if self:getFlag("opened") then
        self.world:showText("* (The present is empty.)")
    else
        Assets.playSound("wing", 1, 1.4)
        self.lid_sprite.physics.speed_y = MathUtils.random(-4, -6.5)
        self.lid_sprite.speed_x = MathUtils.random(-2, 2)
        self.lid_sprite.physics.gravity = 0.4
        self.lid_sprite.graphics.spin = math.rad(MathUtils.random(-2, 2))
        self.lid_sprite:fadeOutAndRemove(1)
        self:setFlag("opened", true)

        local name, success, result_text
        if self.item then
            local item = self.item
            if type(self.item) == "string" then
                item = Registry.createItem(self.item)
            end
            success, result_text = Game.inventory:tryGiveItem(item)
            name = item:getName()
        elseif self.money then
            name = self.money.." "..Game:getConfig("darkCurrency")
            success = true
            result_text = "* ([color:yellow]"..name.."[color:reset] was added to your [color:yellow]MONEY HOLE[color:reset].)"
            Game.money = Game.money + self.money
        end

        if name then
            self.world:showText({
                "* (You opened the present.)[wait:5]\n* (Inside was [color:yellow]"..name.."[color:reset].)",
                result_text
            }, function()
                if not success then
                    self.sprite:setFrame(1)
                    self:setFlag("opened", false)
                end
            end)
        else
            self.world:showText("* (The present is empty.)")
            success = true
        end

        if success and self.set_flag then
            Game:setFlag(self.set_flag, (self.set_value == nil and true) or self.set_value)
        end
    end

    return true
end

return Present