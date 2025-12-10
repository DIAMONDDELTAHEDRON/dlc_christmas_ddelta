local Rudinn, super = Class(Encounter)

function Rudinn:init()
    super.init(self)

    self.text = "* Rudinn drew near!\n* ([color:#00AEFF]FROSTBITE[color:reset] in effect, dealing damage over time to those ill-prepared...)"

    self.music = "battle"
    self.background = true

    self:addEnemy("rudinn")
	
	self.first_turn = true

    -- Enables the purple grid battle background
    self.background = false
	self.hide_world = true
end

function Rudinn:onBattleInit()
	self.bg = FrostBG({1, 1, 1})
	Game.battle:addChild(self.bg)
end

function Rudinn:onTurnStart()
	if not self.first_turn then
		for _,battler in ipairs(Game.battle.party) do
			if not (battler.chara:checkArmor("heatarmor") or battler.chara.frost_resist) then
				if battler.chara.health > math.ceil(battler.chara:getStat("health") / 10) then
					battler:hurt(math.ceil(battler.chara:getStat("health") / 10), true, {167/255, 255/255, 255/255})
					Assets.stopSound("hurt")
					Assets.stopAndPlaySound("frostdamage", 0.8)
					local x, y = battler:getRelativePos(battler.width/2, battler.height/2, Game.battle)
					Game.battle:addChild(IceSpellBurst(x, y))
					for i = 0, 5 do
						local effect = IceSpellEffect(x, y)
						effect:setScale(0.75)
						effect.physics.direction = math.rad(60 * i)
						effect.physics.speed = 8
						effect.physics.friction = 0.2
						effect.layer = BATTLE_LAYERS["above_battlers"] - 1
						Game.battle:addChild(effect)
					end
					battler.hit_count = battler.hit_count + 1
				else
					if battler.chara.health > 1 then
						battler:hurt(battler.chara.health - 1, true, {167/255, 255/255, 255/255})
						Assets.stopSound("hurt")
						Assets.stopAndPlaySound("frostdamage", 0.8)
						local x, y = battler:getRelativePos(battler.width/2, battler.height/2, Game.battle)
						Game.battle:addChild(IceSpellBurst(x, y))
						for i = 0, 5 do
							local effect = IceSpellEffect(x, y)
							effect:setScale(0.75)
							effect.physics.direction = math.rad(60 * i)
							effect.physics.speed = 8
							effect.physics.friction = 0.2
							effect.layer = BATTLE_LAYERS["above_battlers"] - 1
							Game.battle:addChild(effect)
						end
						battler.hit_count = battler.hit_count + 1
					end
				end
			end
		end
		-- This sucks
		if Game.battle.back_row then
			local battler = Game.battle.back_row
			if not (battler.chara:checkArmor("heatarmor") or battler.chara.frost_resist) then
				if battler.chara.health > math.ceil(battler.chara:getStat("health") / 10) then
					battler:hurt(math.ceil(battler.chara:getStat("health") / 10), true, {167/255, 255/255, 255/255})
					Assets.stopSound("hurt")
					Assets.stopAndPlaySound("frostdamage", 0.8)
					local x, y = battler:getRelativePos(battler.width/2, battler.height/2, Game.battle)
					Game.battle:addChild(IceSpellBurst(x, y))
					for i = 0, 5 do
						local effect = IceSpellEffect(x, y)
						effect:setScale(0.75)
						effect.physics.direction = math.rad(60 * i)
						effect.physics.speed = 8
						effect.physics.friction = 0.2
						effect.layer = BATTLE_LAYERS["above_battlers"] - 1
						Game.battle:addChild(effect)
					end
					battler.hit_count = battler.hit_count + 1
				else
					if battler.chara.health > 1 then
						battler:hurt(battler.chara.health - 1, true, {167/255, 255/255, 255/255})
						Assets.stopSound("hurt")
						Assets.stopAndPlaySound("frostdamage", 0.8)
						local x, y = battler:getRelativePos(battler.width/2, battler.height/2, Game.battle)
						Game.battle:addChild(IceSpellBurst(x, y))
						for i = 0, 5 do
							local effect = IceSpellEffect(x, y)
							effect:setScale(0.75)
							effect.physics.direction = math.rad(60 * i)
							effect.physics.speed = 8
							effect.physics.friction = 0.2
							effect.layer = BATTLE_LAYERS["above_battlers"] - 1
							Game.battle:addChild(effect)
						end
						battler.hit_count = battler.hit_count + 1
					end
				end
			end
		end
	end
	self.first_turn = false
end

return Rudinn