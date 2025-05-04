local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules  =RepStorage:WaitForChild("Modules")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local CalcManager = require(BaseSystems:WaitForChild("CalcManager"))
local MoverManager = require(Utils:WaitForChild("MoverManager"))
local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
function FlightToggle(CharConfig,Toggle)
	--repeat task.wait() until _G.Loaded
	if CharConfig.FlightLand and os.clock() < CharConfig.FlightLand then
		return
	end
	local MoverManager =  MoverManager
	local AnimManager =  AnimManager
	local CombatService = CombatService
	local Mover = CharConfig.Mover
	local CharTable = CharConfig
	local Controller:Model = CharConfig.Controller
	if Controller:IsA("Player") then
		Controller = Controller.Character
	end
	local Char = Controller
	local Hum:Humanoid = Controller:WaitForChild("Humanoid")
	local Animator = CharConfig.Animator


	if  CombatService:CheckDebounce(Controller,{
		DebounceType = {"lightHit","heavyHit","Blocking","DoingMove"}}) then
		return
	end
	CharConfig.Flying = Toggle ~= nil and Toggle or not CharConfig.Flying
	if Toggle == false then
		if _G.Cam then
			_G.Cam.Offsets.FlightOffset = nil
		end
		CharConfig.Flying = false
	end
	
--	print(CharConfig.Flying)
	if RunService:IsServer() then
		CharConfig.Data.CharStats.Flight.IsFlying.Value = CharConfig.Flying
	end
	if CharConfig.PlayerServer then
		if CharTable.FlightTask then
			task.cancel(CharTable.FlightTask)
		end

		return
	end
	
	--print(CharConfig.Flying)
	if CharConfig.Flying then
		CharConfig.StopFallJump()
		if Hum then
			if CharTable.FlightTask then
				task.cancel(CharTable.FlightTask)
			end
			local HumRootPart:BasePart = Char:WaitForChild("HumanoidRootPart")

			--if Args.Hold then
			local AnimWeights = {
				flightLeft = 0.001,
				flightRight = 0.001,
				flightForward= 0.001,
				flightIdle = 0.001,
				flightBack= 0.001,
				flightUp = 0.001,
				flightDown = 0.001
			}
			local AnimObjects = {

			}
			AnimObjects.flightIdle = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Idle"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightIdle * 2,
				ID = "flightIdle"
			}
			)
			AnimObjects.flightForward = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Forward"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightForward * 2,
				ID = "flightForward"
			}
			)
			AnimObjects.flightBack= AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Back"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightBack * 2,
				ID = "flightBack"
			}
			)
			AnimObjects.flightLeft = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Left"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightLeft * 2,
				ID = "flightLeft"
			}
			)
			AnimObjects.flightRight = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Right"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightRight * 2,
				ID = "flightRight"
			}
			)
			AnimObjects.flightUp = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Up"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightUp * 2,
				ID = "flightUp"
			}
			)
			AnimObjects.flightDown = AnimManager:PlayAnim(CharConfig.Animator, {
				"Flight","Down"
			},{
				Looped = true,
				Priority = Enum.AnimationPriority.Movement,
				Weight = AnimWeights.flightDown * 2,
				ID = "flightDown"
			}
			)
			--print(CharConfig)
			local Inputs = {
				W = false,
				A = false,
				S = false,
				D = false,
				Space = false,
				LeftControl = false
			}
			local function getInputs()
				for i,v in Inputs do
					Inputs[i] = false
				end
				for i,v in CharConfig.Inputs.CurrentInputs do
					if Inputs[v.Name] ~= nil then
						Inputs[v.Name] = true
					end
				end

				--print(Inputs)
				return Inputs
			end

			local function DetermineTravel()
				--print(CharTable)
				local Vec = Vector3.zero
				local Inputs = getInputs()
				local FlightUnit = Char:GetAttribute("FlightUnit") 
				if FlightUnit and FlightUnit.Magnitude ~= 0 then
					FlightUnit *= Vector3.new(1,1,-1)
					FlightUnit += Vector3.new(0,1 * (Inputs["Space"] and 1 or Inputs["LeftControl"] and -1 or 0),0)
					FlightUnit = FlightUnit.Unit
					return FlightUnit
				end
				if RunService:IsServer() then

					CharConfig.Data.CharStats.KeysPressed:ClearAllChildren() 
					for i,v in Inputs do
						local Val = Instance.new("BoolValue")
						Val.Name = i
						Val.Value = v
						Val.Parent = CharConfig.Data.CharStats.KeysPressed
					end
				end
				--print(Inputs)
				Vec += Vector3.new(0,0,1 * (Inputs["W"] and 1 or Inputs["S"] and -1 or 0))
				Vec += Vector3.new(1 * (Inputs["D"] and 1 or Inputs["A"] and -1 or 0),0,0)
				Vec += Vector3.new(0,1 * (Inputs["Space"] and 1 or Inputs["LeftControl"] and -1 or 0),0)
					--[[if Vec.Magnitude == 0 then
						Vec = Vector3.new(0,0,1)
					end]]
				if Vec.Magnitude ~= 0 then
					Vec = Vec.Unit
				end

				--	print(Vec)
				return Vec
			end
			local function DetermineFlightKey()
				local Inputs =getInputs()
				local Vec =DetermineTravel()
				--print(Vec)
				--print(AnimObjects.flightLeft)
				AnimWeights.flightForward = Vec.Z > .1 and Vec.Z * 4 or 0.001
				AnimWeights.flightBack  = Vec.Z < -.1 and Vec.Z * -4 or 0.001
				AnimWeights.flightRight = Vec.X > .1 and Vec.X * 4 or  0.001
				AnimWeights.flightLeft= Vec.X < -.1  and Vec.X * -4 or  0.01
				AnimWeights.flightUp = Vec.Y > .1  and Vec.Y * 4 or  0.001
				AnimWeights.flightDown = Vec.Y < -.1  and Vec.Y * -4 or  0.001

				--print(Vec.Magnitude)
				AnimWeights.flightIdle = Vec.Magnitude > .1 and 0.001 or 41
				--					print(AnimWeights)
			end
			local HRP:BasePart = Controller:WaitForChild("HumanoidRootPart")
			local function GetTilt()
				local FlightInputs =getInputs()
				local RV = CharConfig.Inputs.Look.RightVector
				--print(RV)
				if HRP.AssemblyLinearVelocity.Magnitude < 5 or FlightInputs.S then
					return 0
				end
				return math.clamp( HRP.AssemblyLinearVelocity.Unit:Dot(RV)*math.pi*(shiftFlight and 2 or 1) * 1.4,-math.pi/2,math.pi/2) * -1
			end
			local function GetCam()
				local FlightInputs =getInputs()
				local RV = CharConfig.Inputs.Look.RightVector
				--print(RV)
				if HRP.AssemblyLinearVelocity.Magnitude < 5 or FlightInputs.S then
					return 0
				end
				return math.clamp( HRP.AssemblyLinearVelocity.Unit:Dot(RV)*math.pi*(shiftFlight and 2 or 1.2) * .3 * .6,-math.pi/6,math.pi/6) * .1 * .5
			end
			local function DetermineCF()
				local Vec = DetermineTravel()
				if Vec.Magnitude == 0 then
					return Vector3.new(0,0,1)
				else
					return (Vec) * Vector3.new(1,1,FlightInputs.W and -1 or 1)
				end
			end
			CharTable.FlightTask = task.spawn(function()
				local DeltaTime =0
				local Move = Vector3.new(0,0,1)
				local TargC0 = 0
				local CurrC0 = 0
				local TargVel = Vector3.zero
				local CurrentVel = Vector3.zero
				CharTable.TargCF = CFrame.new()
				CharTable.CurrCF = CFrame.new()
				CharTable.BoostMulti = 1
				CharTable.CurrentVel = 0
				local BlockVel = CharConfig.Data.CharStats.Blocking.Value and .1 or 1
				local OldTime = os.clock()
				local Face=  Move
				--print(CharTable.Inputs)
				local Params = RaycastParams.new()
				Params.FilterType = Enum.RaycastFilterType.Exclude
				Params.IgnoreWater = true
				Params.RespectCanCollide = true
				Params.FilterDescendantsInstances = {CharTable.Character}
				local Result:RaycastResult
				local LockRoot:BasePart
				local CurrCam = 0
				local TargCam = 0
				CharTable.CurrentBoost = 1
				while true do
					if game:GetService("RunService"):IsClient() then
						task.wait()
					else 
						wait()
					end
					DeltaTime = os.clock() - OldTime
					OldTime = os.clock()
					DetermineFlightKey()
					Move = DetermineTravel()
					Face = Move
					TargCam = GetCam()
					CurrCam += (TargCam - CurrCam) * .32^(1- DeltaTime)
					if _G.Cam then
						_G.Cam.Offsets.FlightOffset = CFrame.Angles(0,0,CurrCam)
					end
					if Face.Magnitude == 0  then
						Face = Vector3.new(0,0,1)
						--[[if CharConfig.ShiftFlight then 
							CharConfig:DoAction("ShiftFlight",{
								Holding = false
							})
						end]]
					end
					Char:SetAttribute("FlightTravel",Face)
					--	print(Face)
					local DistCheck = 1
					if CharConfig.LockedTarget then
						local Magn = (CharConfig.LockedTarget:GetPivot().Position - HRP.Position).Magnitude
						if Magn < 10 then
							if Move.Z > 0 then
								Move *= Vector3.new(1,1,0)
							end
						end
					end
					if HumRootPart.AssemblyLinearVelocity.Magnitude > 2 and DetermineTravel().Z ~= 0 then
						TargC0 = GetTilt()
					else
						TargC0 = 0							
					end

					--print(TargC0)

					CurrC0 = (TargC0 - CurrC0) * .2 ^(1-DeltaTime)
					if not CharConfig.BoostMulti then
						CharConfig.BoostMulti = 1
					end
					if Move.Magnitude ~= 0 then
						--print(CurrC0)
						CharConfig.TargCF = CharTable.Inputs.Look * CFrame.Angles(0,0,CurrC0)

					else
						--TargCF = CharTable.Inputs.Look * CFrame.Angles(0,0,CurrC0)
						TargC0 = 0

					end
					BlockVel = CharConfig.Data.CharStats.Blocking.Value and .02 or 1
					--* 70 * CharTable.BoostMulti * CharTable.DashMulti
					CharTable.FlightSmooth = CharTable.FlightSmooth or .25
					CharTable.CurrentVel += (20 * CharTable.BoostMulti * BlockVel - CharTable.CurrentVel) * CharTable.FlightSmooth^(1-DeltaTime)
					TargVel = (CharTable.Inputs.Look.LookVector * Move.Z + CharTable.Inputs.Look.RightVector * Move.X + CharTable.Inputs.Look.UpVector * Move.Y) * CharTable.CurrentVel 
					--CharTable.CurrentVel = nil
					if CharTable.BoostMulti > 1 then
						TargVel *= CalcManager:CalcSpeed(CharConfig.Controller)
					end
					if CharConfig.DefCooldown and os.clock() < CharConfig.DefCooldown then
						TargVel = Vector3.zero
					end
					CurrentVel += (TargVel - CurrentVel) * .34^(1-DeltaTime)
					--print(AnimWeights)
					if not Char:GetAttribute("IsStunned") then

						for i,v in AnimObjects do
							local WGH = AnimWeights[i] 
							WGH = math.clamp(WGH,.01,math.huge)
							v:AdjustWeight(v.WeightCurrent + (WGH * 1 - v.WeightCurrent) * .26 ^ (1-DeltaTime/2),.02)
							if math.abs((WGH * 1 - v.WeightCurrent)) > .98 then
								AnimWeights[i] = v.WeightCurrent
							end
						end
					end
					CharTable.CurrCF = CharTable.CurrCF:Lerp(CharConfig.TargCF,.23^(1-DeltaTime))
					MoverManager:add(Mover, "Vel","flight",CurrentVel * DistCheck,4)
					--print(CurrC0)
					MoverManager:add(Mover,"Gyro","flight",CharTable.CurrCF* CFrame.Angles(0,0,CurrC0),4)
				end
			end)





		end
		--end
	else
		if CharTable.FlightTask then
			task.cancel(CharTable.FlightTask)
		end
		CharConfig:DoAction("ShiftFlight",{
			Holding = false
		})
		AnimManager:StopAnim(CharConfig.Animator,{ "flightIdle",
			"flightForward",
			"flightLeft",
			"flightRight",
			"flightBack",
			"flightUp",
			"flightDown"
		})
		MoverManager:destroy(Mover,"Gyro","flight")
		MoverManager:destroy(Mover,"Vel","flight")
		if Hum.FloorMaterial == Enum.Material.Air then
			CharConfig.PlayFallAnim()
		end
	end	
end

return {
	Func = function(CharConfig,Options)
		local MoverManager =  MoverManager
		local AnimManager =  AnimManager
		local Mover = CharConfig.Mover
		--if Options.Holding then
		--	print(CharConfig)
		--	print(Options)
		FlightToggle(CharConfig,Options.Toggle)
		--end
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}