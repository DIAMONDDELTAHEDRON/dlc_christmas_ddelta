local spell, super = Class("rude_buster")

function spell:init()
    super.init(self)

    if JollyLib.getJollyConfig("jolly_spell") then
        self.name = "Jolly Buster"
        self.effect = "Jolly\ndamage"
        self.description = "Deals moderate Jolly-elemental damage to\none foe. Depends on Attack & Magic."
    end
end

return spell