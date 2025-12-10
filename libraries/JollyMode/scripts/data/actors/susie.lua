local actor, super = Class("susie")

function actor:init()
    super.init(self)

    self.christmas_hat_offset = {
        ["walk"] = {10, 8}
    }
end

return actor