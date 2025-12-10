local spell, super = Class("red_buster")

function spell:init()
    super.init(self)

    if JollyLib.getJollyConfig("jolly_spell") then
        self.name = "Jollier Buster"
        self.effect = "Jollier\ndamage"
        self.description = "Deals large Jolly-elemental damage to\none foe. Depends on Attack & Magic."
    end
end

return spell