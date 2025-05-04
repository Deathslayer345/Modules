local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local UserInputService = game:GetService("UserInputService")
local TimeManager = require(Utils:WaitForChild("TimeManager"))
local MoverManager = require(Utils:WaitForChild("MoverManager"))
local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local CalcManager = require(BaseSystems:WaitForChild("CalcManager"))


local Dir = {
	W = Vector3.FromAxis(Enum.Axis.Z),
	S = -Vector3.FromAxis(Enum.Axis.Z),
	D = Vector3.FromAxis(Enum.Axis.X),
	A = -Vector3.FromAxis(Enum.Axis.X),
	Space = Vector3.FromAxis(Enum.Axis.Y),
	LeftControl = -Vector3.FromAxis(Enum.Axis.Y)
}


local function GetYCF(CF: CFrame)
	return CFrame.Angles(0, math.atan2(-CF.LookVector.X, -CF.LookVector.Z), 0)
end


return {
	Func = function(CharConfig, Options)

		if not CharConfig or not Options then
			warn("Invalid CharConfig or Options provided.")
			return
		end


		local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))
		local success, stats = pcall(function()
			return StatsManager:GetStats(CharConfig.Controller)
		end)
		if not success or not stats then
			warn("Failed to retrieve stats for CharConfig.")
			return
		end
		CharConfig.Data = stats

		if CharConfig.IsFlying and CharConfig.IsCharging and CharConfig.IsUsingKiBlast then
			warn("Stop defense while flying.")
			return
		end


		CharConfig.DefCooldown = CharConfig.DefCooldown or 0
		if os.clock() < CharConfig.DefCooldown then
			return
		end


		if CharConfig.Data.CharStats and CharConfig.Data.CharStats.Blocking and CharConfig.Data.CharStats.Blocking.Value then
			return
		end


		CharConfig.DefCooldown = os.clock() + 2


		if CharConfig.Animator then
		--	warn("CharConfig.Animator is missing.")
			
	
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			return
		end
		CharConfig.MovementAnim = AnimManager:PlayAnim(
			CharConfig.Animator,
			{ "Defense", "1" },
			{ Looped = false, Priority = Enum.AnimationPriority.Action2, ID = "Defense" }
		)
end
		print("Def")



		if CharConfig.Mover then
			MoverManager:add(Mover, "Vel","Defense",Vector3.zero,4)
			--print(CurrC0)
			MoverManager:add(Mover,"Gyro","Defense",CharConfig.Controller:GetPivot(),4)
task.delay(1,function()

				MoverManager:destroy(CharConfig.Mover, "Gyro", "Defense")
				MoverManager:destroy(CharConfig.Mover, "Vel", "Defense")
end)
		end

		-- Example of handling dashing (currently commented out)
		--[[if Options.Holding then
			if os.clock() < CharConfig.DashCooldown then
				return
			end
			CharConfig.Dashing = false
			CharConfig.DashEnd = 0
			CharConfig.DashTask = task.spawn(function()
				CharConfig.IsDashing = true
				while true do
					CharConfig.Dashing = true
					Dash(CharConfig, Options) -- Assuming Dash is implemented elsewhere
					CharConfig.Dashing = false
					if not CharConfig.IsDashing then
						return
					end
					repeat task.wait() until os.clock() >= CharConfig.DashCooldown
				end
			end)
		else
			CharConfig.IsDashing = false
		end]]
	end

	-- Unused function (can be implemented if necessary)
	--[[CheckIfUsable = function(CharConfig, Options)
		
	end]]
}