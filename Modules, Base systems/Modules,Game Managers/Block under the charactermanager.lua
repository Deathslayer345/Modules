local RunService = game:GetService("RunService")

local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))

local Modules = RepStorage:WaitForChild("Modules")

local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))

local MoverManager = require(Utils:WaitForChild("MoverManager"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))

local Tab = {
	Cooldown = 0
}

Tab.Func = function(CharConfig,Options)

	local MoverManager =  MoverManager
	local AnimManager =  AnimManager
	local Mover = CharConfig.Mover

	----print(CharConfig.ShiftCooldown-os.clock() )
	if not CharConfig.PlayerServer then
		if Options.Holding then
			if ConditionalManager:Check({
				"Combat",
				"IsStunned"},CharConfig) then return end
			if RunService:IsServer() then
				local Stats = StatsManager:GetStats(CharConfig.Controller)
				Stats.CharStats.Blocking.Value = true
			end
			
			if not CharConfig.PlayerServer then
				AnimManager:PlayAnim(CharConfig.Animator, {
					"Block"
				},{
					Looped = true,
					Priority = Enum.AnimationPriority.Action,
					Weight = 3,
					ID = "Block"
				}
				)

				CharConfig:DoAction("ShiftFlight",{
					Holding = false
				})
			end
		else
			if RunService:IsServer() then
				local Stats = StatsManager:GetStats(CharConfig.Controller)
				Stats.CharStats.Blocking.Value = true
			end
			AnimManager:StopAnim(CharConfig.Animator,{ "Block"})
		end
	end
	if Options.Holding then
		if ConditionalManager:Check({
			"Combat",
			"IsStunned"},CharConfig) then return end
	end
	if RunService:IsServer() then
		CharConfig.Data.CharStats.Blocking.Value = Options.Holding
	end	
	CharConfig.Blocking = Options.Holding
end


return Tab