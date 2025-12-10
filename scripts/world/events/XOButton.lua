local XOButton, super = Class(TileButton, "xobutton")

function XOButton:init(data)
    super.init(self, data.x, data.y, { data.width, data.height, data.polygon }, data.properties)
	
    self.idle_sprite = "world/events/xo/switch_idle"
    self.pressed_sprite = "world/events/xo/switch_pressed"
    self:setSprite(self.idle_sprite, 5/30)
    self:setHitbox(4, 10, 30, 20)
	self.on_sound = "switchpull_n"
	local properties = data.properties or {}

	self.dont_attach = properties["dontattach"]
end

function XOButton:onPressed()
    self:setSprite(self.pressed_sprite)
    if self.on_sound and self.on_sound ~= "" then
        Assets.stopAndPlaySound(self.on_sound)
    end
	local solved = true
	if not Game:getFlag(self.world.map:getEvents("xo")[1].flag) then
		for k,v in ipairs(self.world.map:getEvents("xo")) do
			if v.state ~= 1 then
				solved = false
			end
		end
	end
	
	if solved then
		for k,v in ipairs(self.world.map:getEvents("xo")) do
			v.state = 3
			v:setSprite("world/events/xo/win")
		end	
		for k,v in ipairs(self.world.map:getEvents("plotwall")) do
			if self.world.map:getEvents("xo")[1].flag == v.flag then
				v:remove()
			end
		end
		for k,v in ipairs(self.world.map:getEvents("no_follow_area")) do
			if self.world.map:getEvents("xo")[1].flag == v.flag then
				if not self.dont_attach then
					v:remove()
					Game.world:attachFollowers(8)
				end
			end
		end
		Game:setFlag(self.world.map:getEvents("xo")[1].flag, true)
	else
		for k,v in ipairs(self.world.map:getEvents("xo")) do
			v.state = 0
			v:setSprite("world/events/xo/x")
		end
	end
end

return XOButton