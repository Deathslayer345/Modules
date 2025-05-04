local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")


local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local Utils = Modules:WaitForChild("Utils")
local BaseSystems = Modules:WaitForChild("BaseSystems")

local MoverManager = require(Utils:WaitForChild("MoverManager"))
local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))

local CharacterManager = require(GameManagers:WaitForChild("CharacterManager"))
local CalcManager = require(BaseSystems:WaitForChild("CalcManager"))

local Tab = {
	Cooldown = 0,
	Task = nil, 
}

Tab.Func = function(CharConfig, Options)
	if not CharConfig or not Options then
		warn("Invalid CharConfig or Options passed to Tab.Func")
		return
	end


	if Tab.Task then
		task.cancel(Tab.Task)
	end


	if Options.Holding then
		if ConditionalManager:Check({"Combat", "IsStunned"}, CharConfig) or ConditionalManager:Check({"Combat", "IsCharging"}, CharConfig) then
			warn("Cannot charge: Character is stunned or already charging")
			return
		end
		if CharConfig.ChargeCooldown and os.clock() < CharConfig.ChargeCooldown then
			warn("Charge is on cooldown")
			return
		end
	else

		CharConfig.ChargeCooldown = os.clock() + 0.3
	end

	-- Checks if nigga is in a charging state
	if RunService:IsServer() then
		CharConfig.Data.CharStats.Charging.Value = Options.Holding
	end
	CharConfig.Charging = Options.Holding

	-- Checks if the nigga is holding the charge to start the charge process
	if Options.Holding then
		Tab.Task = coroutine.create(function()
			local OldTime = os.clock()
			CharConfig.ChargeCooldown = math.huge -- Prevents nigga from recharging

			local Anim
			if not CharConfig.PlayerServer then
				-- Plays nigga the charging animation
				Anim = AnimManager:PlayAnim(CharConfig.Animator, {
					"Default", "Charge"
				}, {
					Looped = true,
					Priority = Enum.AnimationPriority.Action,
					Weight = 2,
					ID = "Charge",
					Speed = 2
				})

				-- Add niggas movement restrictions
				MoverManager:add(CharConfig.Mover, "Vel", "charge", Vector3.zero, 8)
				MoverManager:add(CharConfig.Mover, "Gyro", "charge", CharConfig.Controller:GetPivot(), 8)
			end

			-- Activatse the nigga charging effect
			RenderService:Charge(CharConfig.Controller, true)


			local function EndCharge()
				if Anim then
					Anim:Stop()
				end
				MoverManager:destroy(CharConfig.Mover, "Vel", "charge")
				MoverManager:destroy(CharConfig.Mover, "Gyro", "charge")
				RenderService:Charge(CharConfig.Controller, false)
			end

			-- Loop
			while CharConfig.Charging do
				if ConditionalManager:Check({"Combat", "IsStunned"}, CharConfig) or not CharConfig.Charging then
					warn("Charging interrupted: Character is stunned")
					EndCharge()
					return
				end


				if RunService:IsServer() then
					local Delta = os.clock() - OldTime
					OldTime = os.clock()
					CharConfig.Data.CharStats.Ki.Value += CalcManager:CalcKiMax(CharConfig.Data.CharStats.Parent.Data) * 0.1 * Delta
				end

				task.wait(0.1)
			end


			EndCharge()
		end)

		coroutine.resume(Tab.Task)
	else
		CharConfig.Charging = false
		if not CharConfig.PlayerServer then
         -- fixed end charge
			AnimManager:StopAnim(CharConfig.Animator, {"Charge"})
			MoverManager:destroy(CharConfig.Mover, "Vel", "charge")
			MoverManager:destroy(CharConfig.Mover, "Gyro", "charge")
			RenderService:Charge(CharConfig.Controller, false)	
		end
	end
end

return Tab