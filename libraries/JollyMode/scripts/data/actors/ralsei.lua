local actor, super = Class("ralsei")

function actor:init(style)
    super.init(self, style)

    self.christmas_hat_offset = {
        ["walk"] = {10, 8}
    }
    -- Log({"asdvgnjiefsjngiwenrks"})
    -- This doesnt get ran for some reason?????
    Kristal.Console:log("ralsei test")
end

return actor