local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")

local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")
local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))


local TimeManager = require(Utils:WaitForChild("TimeManager"))
local MoverManager = require(Utils:WaitForChild("MoverManager"))
local CombatService = require(BaseSystems:WaitForChild("CombatService"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local ConditionalManager = require(GameManagers:WaitForChild("ConditionalManager"))


local CalcManager = require(BaseSystems:WaitForChild("CalcManager"))


local Dir = {
	W = (Vector3.FromAxis(Enum.Axis.Z)),
	S = -(Vector3.FromAxis(Enum.Axis.Z)),
	D = Vector3.FromAxis(Enum.Axis.X),
	A = -Vector3.FromAxis(Enum.Axis.X),
	Space = Vector3.FromAxis(Enum.Axis.Y),
	LeftControl = -Vector3.FromAxis(Enum.Axis.Y)
}

local function GetYCF(CF:CFrame)
	return CFrame.Angles(0,math.atan2(-CF.LookVector.X,-CF.LookVector.Z),0)

end
function Dash(CharConfig,Options)
	local CXlock = os.clock()
	if ConditionalManager:Check({
		"Combat",
		"IsCharging"},CharConfig) then return end

	if RunService:IsServer() then

		if Options.Clock then
			local plr = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
			CXlock =  Options.Clock + TimeManager:getClientSync(plr) 
			Options.Clock = nil
		end
	end
	print("Dash")
	local Diff = CXlock - os.clock()
	if CharConfig.DashCooldown and os.clock() < CharConfig.DashCooldown - Diff then return end
	local DashKiDrain = .02 * CharConfig.Data.CharStats.Parent.Data.Stats.Suppression.Value/100
	local Amnt = CalcManager:CalcKiMax(CharConfig.Data.CharStats.Parent.Data) * DashKiDrain
	if CharConfig.Data.CharStats.Ki.Value < Amnt and Options.Holding then
		return
	end
	if CharConfig.DefCooldown and os.clock() < CharConfig.DefCooldown then
		return
	end 
	--[[CharConfig:DoAction("ShiftFlight",{
		Holding = false
	})]]
	CharConfig.DashCooldown = os.clock() + .7
	if RunService:IsServer() then

		CharConfig.Data.CharStats.Ki.Value -=  Amnt
	end
	if RunService:IsServer() or RunService:IsClient() then

			RenderService:Dash(CharConfig.Controller)
		--if RunService:IsClient() then
		if CharConfig.LockedTarget then
			if CombatService:CheckStun(CharConfig.LockedTarget,{
				StunType = "All"}) then

				--	repeat task.wait() until not CharConfig.Data.CharStats.InCombat.Value
			end
		end
		--end
		if CharConfig.PlayerServer then
			print("PlayerDash")
print(Options)
			CombatService:RemoveStun(CharConfig.Controller,"All")
			if CharConfig.Data.CharStats.LockedOnTarget.Value or CharConfig.LockedTarget then
				print("LOCKED")
				if CharConfig.Data.CharStats.LockedOnTarget.Value then
					CharConfig.LockedOn = CharConfig.Data.CharStats.LockedOnTarget.Value
				end
				if CombatService:CheckStun(CharConfig.LockedTarget,{
					Marker = "All"}) then
					print("Stunned")
					CombatService:Stun(CharConfig.LockedTarget,{
						TimeLast =.5,
						Killer = Char,
						Knockback = .01,
						StunType = "Light",
						KillerTime = false
					})

				end
			end
			wait(Options.TimeLast or .5)
			return
		end
	end
	if CharConfig.DashReset then
		task.cancel(CharConfig.DashReset)
	end
	CharConfig.DashReset = delay(.8,function()
		CharConfig.PressDir = nil
	end)
	local Controller:Model = CharConfig.Controller
	local HumRootPart:BasePart = Controller:WaitForChild("HumanoidRootPart")
	local Hum:Humanoid = Controller:FindFirstChildWhichIsA("Humanoid")
	local MoverManager = MoverManager
	local AnimManager =  AnimManager
	local Mover = CharConfig.Mover

	local function getInputs(PrevDir)
		local Inputs = {
			W = false,
			A = false,
			S = false,
			D = false,
			Space = false,
			LeftControl = false
		}
		local CurrDir = Vector3.zero
		for i,v in CharConfig.Inputs.CurrentInputs do
			if Inputs[v.Name] ~= nil then
				Inputs[v.Name] = true
			end
		end
		for i,v in Inputs do
			if v then
				CurrDir += Dir[i]
			end
		end
		if CurrDir.Magnitude == 0 then
			CurrDir = PrevDir
		end
		CurrDir = CurrDir and CurrDir.Unit or Vector3.new(0,0,1)

		--print(Inputs)
		return CurrDir
	end
	local Vel = 120 + HumRootPart.AssemblyLinearVelocity.Magnitude * .6
	--print(CFrame.new(Vector3.zero,GetDirection()).LookVector)
	local Dir = getInputs(CharConfig.PressDir or Vector3.FromAxis(Enum.Axis.Z))
	CharConfig.PressDir = Dir
	local CF = CharConfig.Inputs.Look
	if not CharConfig.Flying then
		CF = GetYCF(CF)
	end
	local TimeTake = .3

	local Delta = 0
	local OldTime = os.clock()
	local Aim = Vel*.3
	local EndGoal = os.clock() + TimeTake
	local function Set()
		Dir = getInputs(CharConfig.PressDir)
		CharConfig.PressDir = Dir
		Controller:SetAttribute("DashDir",Dir)
		CF = CharConfig.Inputs.Look
		if not CharConfig.Flying then
			CF = GetYCF(CF)
		end
		CombatService:RemoveStun(CharConfig.Controller,"All")
		CharConfig.CurrCF = CF
		CharConfig.TargCF = CF
		--print(CharConfig.InCombat)
		if CharConfig.InCombat then
			CharConfig.InCombat = false
			if CharConfig.LockedTarget then
				if RunService:IsClient() then
					--if CharConfig.In then
					CombatService:RemoveStun(CharConfig.Controller,"All")

					--repeat task.wait() until not CharConfig.Data.CharStats.InCombat.Value
					--end
				end
				if RunService:IsServer() then
					if CombatService:CheckStun(CharConfig.LockedTarget) then
						CombatService:Stun( CharConfig.LockedTarget,{
							TimeLast =.8,
							Killer = CharConfig.Controller,
							Knockback = 0.1,
							StunType = "Light",
							KillerTime = false

						})
						local Rand = math.random()
						--(math.random() - .5)
						local function Thing()
							return (math.random() - .5)
						end
						local CF = CFrame.Angles( Thing() * math.pi/3,Thing() * math.pi/3,0 ) * CFrame.new(0,0,-25) * CFrame.Angles(0,math.pi,0)
						if Rand then
							CF = CF:Inverse()
						end
						CharConfig.Controller:PivotTo(CharConfig.LockedTarget:GetPivot() * CF)
					end
					CharConfig.Data.CharStats.InCombat.Value = false	
				end




			end
		else


		end
		local Magn = CharConfig.LockedTarget and (CharConfig.LockedTarget:GetPivot().Position - CharConfig.Controller:GetPivot().Position).Magnitude
		if CharConfig.LockedTarget and Magn <= Vel then
			local Point = CharConfig.LockedTarget:GetPivot().Position
			local Unit = (CharConfig.Controller:GetPivot().Position - CharConfig.LockedTarget:GetPivot().Position).Unit
			CharConfig.Controller:PivotTo(CFrame.new(Point + Unit * Magn,Point) )
			EndGoal = 0
		end
		MoverManager:add(Mover, "Vel","dash",((CF).LookVector * Dir.Z + CF.RightVector * Dir.X + CF.UpVector * Dir.Y) * Vel,4.4)
		--print(CurrC0)
		MoverManager:add(Mover,"Gyro","dash",CF,4.4)

	end
	Set()
	
	CharConfig.FinishedDashing = false
	CharConfig.DashEnd = EndGoal
	repeat
		task.wait()
		Delta = os.clock() - OldTime
		OldTime = os.clock()
		Vel += (Aim-Vel) * (.03/TimeTake)^(1-Delta/2)
		Set()
	until os.clock() >= EndGoal
	MoverManager:destroy(Mover,"Gyro","dash")
	MoverManager:destroy(Mover,"Vel","dash")
	CharConfig.FinishedDashing = true
end
return {
	Func = function(CharConfig,Options)
		local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
		local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))
		CharConfig.Data = StatsManager:GetStats(CharConfig.Controller)
--print("luh lol")
		if CharConfig.Data.CharStats.Blocking.Value then return end
		local MoverManager = MoverManager
		local AnimManager =  AnimManager
		local Mover = CharConfig.Mover
		--if Options.Holding then
		--	print(CharConfig)
		--	print(Options)
		
		CharConfig.DashCooldown = CharConfig.DashCooldown or 0
		if CharConfig.DashTask then
			task.cancel(CharConfig.DashTask)
			if os.clock() < CharConfig.DashEnd then
			repeat task.wait() 
--				print("Waiting")	
			until os.clock() >= CharConfig.DashEnd
			end
			CharConfig.Dashing = false
			
			CharConfig.DashEnd = 0
		end
		MoverManager:destroy(Mover,"Gyro","dash")
		MoverManager:destroy(Mover,"Vel","dash")
		--print(CharConfig.DashCooldown and CharConfig.DashCooldown - os.clock())
		--print(Options)
		if Options.Holding then
			if os.clock() < CharConfig.DashCooldown then
				return
			end
			CharConfig.Dashing = false
			CharConfig.DashEnd = 0
			CharConfig.DashTask = task.spawn(function()
				CharConfig.IsDashing = true
				while true  do
					print(CharConfig.DashCooldown )
					CharConfig.Dashing = true
					Dash(CharConfig,Options)
					CharConfig.Dashing = false
					if not CharConfig.IsDashing then
						return
					end
					repeat wait() until os.clock() >= CharConfig.DashCooldown
				end
			end)
		else
			CharConfig.IsDashing = false
		end
		--end
	end

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}