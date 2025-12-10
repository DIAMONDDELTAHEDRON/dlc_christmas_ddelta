local PlotWall, super = Class(Event)

function PlotWall:init(data)
    super.init(self, data)

	local properties = data.properties or {}
	
    self.solid = true

	self.flag = properties["flag"]
	
	self.solved = Game:getFlag(self.flag)
	
	if self.solved then
		self:remove()
	end
end

function PlotWall:onAdd(parent)
    super.onAdd(self, parent)
	if self.solved then
		self:remove()
	end
end

return PlotWall