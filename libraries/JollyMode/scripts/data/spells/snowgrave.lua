local spell, super = Class("snowgrave")

function spell:init()
    super.init(self)

    if JollyLib.getJollyConfig("jolly_spell") then
        self.name = "Jollygrave"
    end
end

return spell