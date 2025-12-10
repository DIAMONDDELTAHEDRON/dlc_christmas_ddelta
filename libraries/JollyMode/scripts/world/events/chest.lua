local TreasureChest, super = Class(TreasureChest, "chest")

function TreasureChest:init(data)
    super.init(self, data.x, data.y, data.properties)

    if JollyLib.getJollyConfig("world", "retexture_chest") then
        -- Minecrap chest moment
        self.sprite:setSprite("world/events/treasure_chest_jolly")
    end
end

return TreasureChest