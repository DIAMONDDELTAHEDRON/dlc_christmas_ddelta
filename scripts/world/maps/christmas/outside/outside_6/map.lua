---@class Map.dark_place : Map
local map, super = Class(Map, "christmas/outside/outside_6")

function map:init(world, data)
    super.init(self, world, data)
end

function map:onEnter()
	self.reveal_shortcut = Game:getFlag("xo_3", false)
	if not self.reveal_shortcut then
		self:getTileLayer("shortcut_path").alpha = 0
		self:getTileLayer("shortcut_trees").alpha = 0
		self:getTileLayer("shortcut_trees_top").alpha = 0
	end
end
function map:update()
	super.update(self)
	if not self.reveal_shortcut and Game:getFlag("xo_3", false) then
		self.reveal_shortcut = true
		Assets.playSound("screenshake")
		self:getTileLayer("shortcut_path").alpha = 1
		self:getTileLayer("shortcut_trees").alpha = 1
		self:getTileLayer("shortcut_trees_top").alpha = 1
		Game.world:shakeCamera()
		if Game.world.player.y < 240 then
			self.world:startCutscene(function (cutscene)
				cutscene:detachFollowers()
				for i,follower in ipairs(Game.world.followers) do
					follower.returning = false
					follower:resetPhysics()
					follower:setPosition(Game.world.map:getMarker("f"..i.."_marker_start"))
				end
				cutscene:wait(0.5)
				for i,follower in ipairs(Game.world.followers) do
					if i == #Game.world.followers then
						cutscene:wait(cutscene:walkToSpeed(follower, "f"..i.."_marker_end", 8))
					else
						cutscene:walkToSpeed(follower, "f"..i.."_marker_end", 8)
					end
				end
				for i,follower in ipairs(Game.world.followers) do
					follower:interpolateHistory()
					follower:updateIndex()
					follower:returnToFollowing()
				end
			end)
		end
	end
end

return map