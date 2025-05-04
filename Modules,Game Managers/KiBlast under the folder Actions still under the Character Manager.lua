local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")
local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))


local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))

local Tab = {
	Cooldown = 0,
	Task = nil,
}

Tab.Func = function(CharConfig, Options)
	if not CharConfig or not Options then
		warn("Invalid CharConfig or Options provided.")  
		return
	end

	-- Stop previous task if it exists
	if Tab.Task  then
		task.cancel(Tab.Task)

	end
	if CharConfig.Blocking then
		return 
	end
	if CharConfig.DefCooldown and os.clock() < CharConfig.DefCooldown then
		return
	end
	-- Update server state
	if RunService:IsServer() then
		if CharConfig.Data and CharConfig.Data.CharStats and CharConfig.Data.CharStats.KiBlast then
			CharConfig.Data.CharStats.KiBlast.Value = Options.Holding
		end
	end
	CharConfig.KiBlast = Options.Holding
print(Options)
	-- Start Ki blast task if holding
	if Options.Holding then
		Tab.Task = coroutine.create(function()
			local OldTime = os.clock()
			local LastKiFireTime = 0
			local useLeftHand = CharConfig.Controller:GetAttribute("Hand") or false
			local FIRE_INTERVAL = 0.2

			while CharConfig.KiBlast do
				-- Check stun state
				if ConditionalManager:Check({ "Combat", "IsStunned" }, CharConfig) then
					warn("Ki blast interrupted: Character is stunned.")
					break
				end

				-- Delay between blasts


				if os.clock() - LastKiFireTime >= FIRE_INTERVAL then
					LastKiFireTime = os.clock()

					-- Fire Ki blast
					useLeftHand = not CharConfig.Controller:GetAttribute("Hand")
					CharConfig.Controller:SetAttribute("Hand", useLeftHand)

					-- Play animation on client
					if not CharConfig.PlayerServer then
						if AnimManager and CharConfig.Animator then
							AnimManager:StopAnim(CharConfig.Animator, { "KiBlast" })
							local animID = "KiBlast_" .. (useLeftHand and "L" or "R")
							AnimManager:PlayAnim(CharConfig.Animator,{"KiBlast",(useLeftHand and "Left" or "Right")}, {
								Looped = false,
								Priority = Enum.AnimationPriority.Action,
								Weight = 2,
								ID = "KiBlast"
							})
							
						end
					end
					print("B4")
					-- Create projectile on server
					if RunService:IsServer() then
						print("Server")
						local successCreate, projectilePart = pcall(function()
							local handPartName = useLeftHand and "LeftHand" or "RightHand"
							local HandPart = CharConfig.Controller:FindFirstChild(handPartName)
							local HRP = CharConfig.Controller:FindFirstChild("HumanoidRootPart")
--							print(HandPart,HRP)
							if not HandPart or not HRP then return end
print("Lo mainm")
							local KiPart = Instance.new("Part")
							KiPart.Name = "KiHitbox"
							KiPart.Size = Vector3.one * 3
							KiPart.Transparency = 1
							KiPart.CanCollide = false
							KiPart.Massless = true
							KiPart.Anchored = false
							KiPart.CFrame = HRP.CFrame * CFrame.new((HandPart.Position - HRP.Position)) * CFrame.new(0, 0, -2)
							KiPart.Parent = workspace:FindFirstChild("Effects") or workspace
							game.Debris:AddItem(KiPart, 5)

							local fireDirection = HRP.CFrame.LookVector
							if Options.TargetPosition and typeof(Options.TargetPosition) == "Vector3" then
								local directionToTarget = (Options.TargetPosition - KiPart.Position).Unit
								fireDirection = directionToTarget
							end

							local Vel = Instance.new("BodyVelocity")
							Vel.MaxForce = Vector3.one * 1e7
							Vel.P = 1e6
							Vel.Velocity = fireDirection * 200
							Vel.Parent = KiPart

							local Gyro = Instance.new("BodyGyro")
							Gyro.MaxTorque = Vector3.one * 1e7
							Gyro.P = 1e6
							Gyro.D = 60
							Gyro.CFrame = CFrame.lookAt(KiPart.Position, KiPart.Position + fireDirection)
							Gyro.Parent = KiPart

							-- Use RenderService to apply VFX
							if RenderService then
								pcall(function()
									print("KiBlast")
									RenderService:KiBlast(KiPart, { Direction = fireDirection })
								end)
							end

							return KiPart
						end)

						if not successCreate then
							warn("Failed to create Ki projectile.")
						end
					end
				end
				wait(.03)
				
			end

			-- Cleanup
			if not CharConfig.PlayerServer then
				AnimManager:StopAnim(CharConfig.Animator, { "KiBlast" })
			end

		end)
		coroutine.resume(Tab.Task)
	else
		-- Stop animation if not holding
		CharConfig.KiBlast = false
		if not CharConfig.PlayerServer then
			AnimManager:StopAnim(CharConfig.Animator, { "KiBlast" })
		end
	end
end

return Tab