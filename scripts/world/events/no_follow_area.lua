local NoFollowArea, super = Class(Event, "no_follow_area")

function NoFollowArea:init(data)
    super.init(self, data)
	
	local properties = data.properties or {}

	self.flag = properties["flag"]
	self.facing = properties["facing"] or "down"
	
	self.solved = Game:getFlag(self.flag)
end

function NoFollowArea:onAdd(parent)
    super.onAdd(self, parent)
	if self.solved then
		self:remove()
	end
end

function NoFollowArea:onEnter(chara)
    if chara.is_player then
		Game.world:detachFollowers()
		for i,follower in ipairs(Game.world.followers) do
			follower.returning = false
			follower:resetPhysics()
			follower:walkToSpeed("f"..i.."_marker", 8, self.facing)
		end
    end
end

function NoFollowArea:onExit(chara)
    if chara.is_player then
		for i,follower in ipairs(Game.world.followers) do
			follower:resetPhysics()
		end
		Game.world:attachFollowers(8)
		if Game:getFlag(self.flag) then
			self:remove()
		end
    end
end

return NoFollowArea