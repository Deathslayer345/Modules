--!nonstrict
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")

local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local Array = require(Utils:WaitForChild("Array"))
local MoverManager =  require(Utils:WaitForChild("MoverManager"))
local AnimManager =  require(Utils:WaitForChild("AnimManager"))
local HitboxInfo = require(script:WaitForChild("HitboxInfo"))
local Networker = require(Utils:WaitForChild("Networker"))
local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))
local HitboxManager = require(BaseSystems:WaitForChild("HitboxManager"))
local HitTab = {

	Features = {},
	AllowedFeatures = {},
	Lunges = {}

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}

local function Check(states, config)
	for _, state in ipairs(states) do
		if config[state] then
			return true
		end
	end
	return false
end

HitTab.Check = function(CharConfig, Options)
	return not Check({"Combat", "IsStunned"}, CharConfig)
		and not Check({"Combat", "IsCharging"}, CharConfig)
		and (not CharConfig.HitDebounce or os.clock() >= CharConfig.HitDebounce)
end
HitTab.Highlight = function(Mod:Model)
	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	--spawn(function()
	local Tween = tweenService:Create(Highlight,TweenInfo.new(.07),{
		OutlineTransparency = .1,
		FillTransparency = .3
	})
	Tween:Play()
	--end)
	Highlight.FillColor = Color3.fromRGB(255,0,0)
	Highlight.OutlineColor = Color3.fromRGB(255,255,255)
	Highlight.Parent = Mod
	game.Debris:AddItem(Highlight,.12)
end
HitTab.CamShake = function(CharConfig,Intensity)
	Intensity = Intensity or 1
	if RunService:IsClient() then
		------print("DIDDY")
		CharConfig.Cam:ShakeOnce(2 * Intensity, 2 * Intensity, .1, 1, .9, .2)
	else
		local Plr = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
		if Plr then
			------print("SENDING FENT...")
			--_G.Networker:SendPortData("CamShake"..Plr.Name,_G.Enums.NetworkSendType.FastEvent,Plr,Intensity)
		end
	end
end
HitTab.Vanish = function(CharConfig,Options)
	local mHRP:BasePart = Mod:FindFirstChild("HumanoidRootPart")
	local ID = Options.ID
	--if not mHRP:GetAttribute("PBlock") and not debounceManager.GetDebounce(Char,{"lightHit","heavyHit"},false) then 
	task.delay(.5,function()

		if table.find(require(script.AllowedSoft),ID) and  not mHRP:GetAttribute("PBlock") and not debounceManager.GetDebounce(Char,{"lightHit","heavyHit"},false) then
			if CharConfig.Data.CharStats.targ.Value then

				if CharConfig.changeLockCam then
					CharConfig.changeLockCam()
				end

				Character:SetAttribute("MKnock",os.clock() + .5)


				local CF = CFrame.new()
				local Rand = math.random()
				CF = CFrame.new(CharConfig.Data.CharStats.targ.Value.Position,HumRootPart.Position) * CFrame.Angles(0,math.rad(Rand >= .5 and 60 or -60),0) * CFrame.new(0,0,25)

				--moverPlr:add("pos","snapVanish",((CharConfig.Data.CharStats.targ.Position - CharConfig.Data.CharStats.targ.Value.CFrame.LookVector * 10) - HumRootPart.Position)/.2,5.5)
				local Params = RaycastParams.new()
				Params.RespectCanCollide = true
				Params.FilterDescendantsInstances = {CharConfig.Data.CharStats.targ.Value.Parent}

				local Result = workspace:Raycast(CharConfig.Data.CharStats.targ.Value.Position,(CF.Position - CharConfig.Data.CharStats.targ.Value.Position),Params)
				if Result then
					CF = CFrame.new(Result.Position + Result.Normal * 5) 
				end
				CharTable.CamShaker:ShakeOnce(.5, 1, .1, 1, .9, .2)
				Char:PivotTo(CF)
			end

		end
	end)
	--else

	--	end
end
HitTab.Func = function(CharConfig,Options)
	if CharConfig.Blocking then
		return 
	end
	if CharConfig.DefCooldown and os.clock() < CharConfig.DefCooldown then
		return
	end
	if Options.Holding then
		HitTab.PressTime = os.clock()

	elseif RunService:IsServer() or HitTab.PressTime and os.clock() <= HitTab.PressTime + .2 then
		Options = Options or {}
		Options = table.clone(Options)
		local CharStats = CharConfig.Data.CharStats
		----print(#(CharStats.Combo))
		--[[if #(CharStats.Combo:GetChildren()) == 3 and  CharStats.LockedOnTarget.Value  then
			----print(CharConfig.Data.CharStats.HitSomeone )
			if not CharConfig.Data.CharStats.HitSomeone.Value then
				if CharStats.ResetTask then
					task.cancel(CharStats.ResetTask)
				end
				--CharStats.ResetTask = task.delay(.5,function()
				Indexes.Modules.GameManagers.CombatService:ResetCombo(CharConfig,Options)
				--end)
				return
			end
		end]]
		------print(HitTab.PressTime and os.clock() - HitTab.PressTime)

		------print(Options)
		------print(HitTab)
		------print(CharConfig)
		Options.OriginType = Options.Type 
		------print(CharConfig.Data.CharStats.Combo,#(CharConfig.Data.CharStats.Combo))
		if #(CharConfig.Data.CharStats.Combo:GetChildren()) >= 8 then
			Options.Type = "Knockback"
		end
		------print(Options.Type)
		local Feature = HitTab.Features[Options.Type]
		--print(Options.Type)
		if not Feature then return end
		------print(Options)
		--print(Feature)
		local Check =   HitTab.Check
		if not Check( CharConfig,Options) then
			--print("False")
			return end
		----print("RegCheck")
		if Feature.Check and not Feature.Check(HitTab,CharConfig,Options) then
			--print("Not check ity")
			return
		end
		--print("FeatCheck")
		--print(Feature)
		if Feature["Func"] then
			--print("EYOOOO")
			Feature.Func(HitTab,CharConfig,Options)
		end

		--if Options.Holding then
		--	----print(CharConfig)
		--	----print(Options)


		--end
	end
end

HitTab.Hit = function(CharConfig,Options)
	if typeof(Options) ~= "table" then return end
	--local Calculations = Indexes.Modules.Combat.Calculations
	CharConfig.Data = StatsManager:GetStats(CharConfig.Controller)
	if CharConfig.Data.CharStats.Blocking.Value then return end
	if RunService:IsClient() then
		Networker:SendPortData("Hit"..CharConfig.Controller.Name,nil,Options)
	else
		local List = HitTab.Validify(CharConfig.Controller,Options)
		List = Options.List
		if not List then return end
		local Tab = HitTab.Features[Options.HitType] 
		if not Tab then return end

		------print(List)
		if #List > 0 then

			--	CharConfig.Controller:SetAttribute("CombatTimer",os.clock() + Calculations:CalcCombatTimer(1))

		end
		for i,v:Model in List do

			if v:IsA("Model") then

				local Hum:Humanoid = v:FindFirstChildWhichIsA("Humanoid")
				if Hum then
					CharConfig.Data.CharStats.HitSomeone.Value =true

					local EnemyStats
					local EPlr = game.Players:GetPlayerFromCharacter(v)
					if EPlr then
						EnemyStats =_G.StatsManager:GetStats(EPlr)
					else

						EnemyStats =_G.StatsManager:GetStats(v)
					end
					local Stats
					local Plr = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
					if Plr then
						Stats =_G.StatsManager:GetStats(Plr)
					else

						Stats =_G.StatsManager:GetStats(CharConfig.Controller)
					end
					--PunchTrain
					--	--print(Stats,EnemyStats)
					if Stats then
						--[[local TrainAmount = _G.CalcManager:PunchTrain({
							Giver = Stats.Data,
							Enemy = EnemyStats and EnemyStats.Data
						})
						Stats.Data.Stats.Exp.Value += TrainAmount]]
					end
					--_G.Modules.Systems.CalcManager:CalcLevelAmount()
					--v:SetAttribute("CombatTimer",os.clock() + Calculations:CalcCombatTimer(1))
					if Tab["CharHit"] then
						spawn(function()
							Tab.CharHit(HitTab,CharConfig,v)
							--[[
							CharConfig:DoAction("LockOn",{
								Target = v
							})
							]]
							
						end)
					end
				end
			end
		end
		return #List > 0
	end
end

function GetYCF(CF:CFrame)
	return CFrame.Angles(0,math.atan2(-CF.LookVector.X,-CF.LookVector.Z),0)

end
HitTab.Lunge = function(CharConfig,Options)
	local Mover,Animator

	if not CharConfig.PlayerServer then
		if HitTab.Lunges[CharConfig.Controller] then
			task.cancel(HitTab.Lunges[CharConfig.Controller])
		end
		local Controller:Model = CharConfig.Controller
		local HumRootPart:BasePart = Controller:WaitForChild("HumanoidRootPart")
		local Hum:Humanoid = Controller:FindFirstChildWhichIsA("Humanoid")

		local Mover = CharConfig.Mover
		Options.BaseVel = Options.BaseVel or 120
		Options.VelocityTrack = Options.VelocityTrack or 1/1.8
		local Dir = Options.Dir or Vector3.new(0,0,1)
		local Vel = Options.BaseVel + HumRootPart.AssemblyLinearVelocity.Magnitude*Options.VelocityTrack
		------print(CFrame.new(Vector3.zero,GetDirection()).LookVector)
		--MoverManager = MoverManager
		local CF = CharConfig.Inputs.Look
		if not CharConfig.Flying then
			CF = GetYCF(CF)
		end
		local Aim = 0

		local function Set()
			CF = CharConfig.Inputs.Look
			if not CharConfig.Flying then
				--	CF = GetYCF(CF)
			end
			local LockedRP:BasePart?
			if CharConfig.Data.CharStats.LockedOnTarget.Value then
				LockedRP = CharConfig.Data.CharStats.LockedOnTarget.Value:FindFirstChild("HumanoidRootPart")
			end
			if LockedRP then
				CF = CFrame.new(HumRootPart.Position,LockedRP.Position)
				if (HumRootPart.Position- LockedRP.Position).Magnitude < 40 then
					Vel =(HumRootPart.Position- LockedRP.Position).Magnitude-40
					Aim  =0

				end
			end
			CharConfig.CurrCF = CF
			CharConfig.TargCF = CF
			MoverManager:add(Mover, "Vel","lunge",((CF).LookVector * Dir.Z + CF.RightVector * Dir.X + CF.UpVector * Dir.Y) * Vel,7)
			------print(CurrC0)
			MoverManager:add(Mover,"Gyro","lunge",CF,7)
		end
		Set()
		local TimeTake = Options.TimeTake or .3
		local EndGoal = os.clock() + TimeTake
		local Delta = 0
		local OldTime = os.clock()
		HitTab.Lunges[CharConfig.Controller] = spawn(function()
			repeat
				if HitTab.Check(CharConfig) then break end
				task.wait()
				Delta = os.clock() - OldTime
				OldTime = os.clock()
				Vel += (Aim-Vel) * (.07/TimeTake)^(1-Delta/2)
				Set()
			until os.clock() >= EndGoal
			MoverManager:destroy(Mover,"Gyro","lunge")
			MoverManager:destroy(Mover,"Vel","lunge")
		end)

	end
end
HitTab.ResetAnims = function(CharConfig,Type)
	if not CharConfig.PlayerServer then
		if Type == "All" then
			table.clear(CharConfig.AnimList)
		else

			CharConfig.AnimList[Type] = {}
		end
	end
end
HitTab.PlayAnim = function(CharConfig,Options)
	if not CharConfig.PlayerServer then
		local AnimManager =  AnimManager
		local Animator = CharConfig.Animator
		local Type = Options.Type or "M1"
		CharConfig.CombatStyle = CharConfig.CombatStyle or "Default"
		local Pick = Options.Pick
		if not CharConfig.AnimList then
			CharConfig.AnimList = {}
		end
		local SearchIndex = {
			CharConfig.CombatStyle,
			"Combat",
			Type
		}
		if not CharConfig.AnimList[Type] then
			CharConfig.AnimList[Type] = {}
		end
		if not Pick then
			local Children = AnimManager:GetAnims(SearchIndex)
			if #Children == 0 then
				----print("No children found")
				return
			end
			if #Children >= #(CharConfig.AnimList[Type]) then
				for i = 1, math.min(#(CharConfig.AnimList[Type]),3) do
					table.remove(CharConfig.AnimList[Type],1)
				end
			end
			------print(CharConfig.AnimList[Type])
			local Amnt = 0
			repeat 
				Pick = Children[math.random(1,#Children)]
				Amnt += 1
			until not table.find(CharConfig.AnimList[Type],Pick) or Amnt >= #(CharConfig.AnimList)
			--task.wait()
			Pick = Children[math.random(1,#Children)]

		end
		if not Pick then return end
		table.insert(CharConfig.AnimList[Type],Pick)
		table.insert(SearchIndex,Pick)
		local Anim = AnimManager:PlayAnim(Animator,SearchIndex,{
			Priority = Options.Priority or Enum.AnimationPriority.Action,
			Speed = Options.Speed or 1,
			FadeTime = .03
		})
		spawn(function()
			repeat wait() until HitTab.Check(CharConfig)
				or not Anim.IsPlaying
			Anim:Stop()
		end)
		------print(Type)
		local HitboxType = HitboxInfo.Hitboxes[CharConfig.CombatStyle][Type][Pick]
		return HitboxType,Anim



	end
end

HitTab.Validify = function(Controller:Model,Options)
	if not Controller then return end
	if typeof(Options) ~= "table" then return {} end
	local Plr = game.Players:GetPlayerFromCharacter(Controller)
	local HRP:BasePart = Controller:WaitForChild("HumanoidRootPart")
	for i,v:Model in Options.List do
		if v:IsA("Model") then
			local vPart:BasePart = v:FindFirstChild("HumanoidRootPart")
			if vPart then
				if (vPart.Position - HRP.Position).Magnitude > 40 then
					table.remove(Options.List,i)
				end
			end
		end
	end
	return Options.List
end

function HitDetect(CharConfig,Options)
	------print(Options)
	--if RunService:IsServer() then
	if CharConfig.PlayerServer then 
	if typeof(Options) ~= "table" then return end

	local Controller:Model = CharConfig.Controller
	Options.ExcludeChildren = true
	Options.ID = "Hit"
	Options.FilterFunc = function(Part:BasePart,Tab)
		local Mod = Part:FindFirstAncestorWhichIsA("Model") 
		if Mod and Mod ~= CharConfig.Controller then
			local Hum = Mod:FindFirstChildWhichIsA("Humanoid")
			if Hum then
				return Mod
			end
		end
	end

	local Mod = HitboxManager(Options.Model,"Character",Options.ID,
		Options.Extensions
	)
	------print(Mod)
	Mod.ExcludeChildren = Options.ExcludeChildren
	Mod:Filter(Options.FilterFunc)
	Mod.CreateFunc = function(List)
		------print(List)
		local Found = {}
		for i,Part in List do
			local Mod = Part 
			if Mod and Mod ~= CharConfig.Controller then
				local Hum = Mod:FindFirstChildWhichIsA("Humanoid")
				if Hum then
					if not table.find(Found,Mod) then
						table.insert(Found,Mod)
					end
				end
			end
		end
		------print(Found)
		return Options.HitFunc(Found,List)
	end
	Mod.CharStorage = {}
	table.insert(Mod.CharStorage,Options.Model)
	------print(Mod)
	local function Destroy()
		HitboxManager("Destroy",Options.Model,"Character",Options.ID)
	end
	if Options.TimeLast then
		task.delay(Options.TimeLast,function()
			Destroy()
		end)
	end
	if Options.DestroyOnFunc then
		spawn(function()
			repeat wait() until Options.DestroyOnFunc(Mod) or Mod["_DESTROYED"]
			Destroy()
		end)
	end
	
	end
	return Mod
	--end
end
HitTab.HitDetect = function(CharConfig,Options)

	if typeof(Options) ~= "table" then return end
	------print(Options)
	if not Options.HitboxTimes or not Options.Anim then
		return HitDetect(CharConfig,Options)
	else
		local Anim:AnimationTrack = Options.Anim
		spawn(function()
			for i,v in Options.HitboxTimes do
				if HitTab.Check(CharConfig) then break end
				repeat wait()
					if HitTab.Check(CharConfig) then break end
				until Anim.TimePosition >= v.Start or not Anim.IsPlaying
				local function Decide()
					if not Anim.IsPlaying then
						return true
					end
					if Anim.TimePosition >= v.End then
						return true
					end
				end
				if  HitTab.Check(CharConfig) then return end
				Options.DestroyOnFunc = Decide
				HitDetect(CharConfig,table.clone(Options))
				repeat wait()
					if HitTab.Check(CharConfig) then return end	
				until Decide()
			end
		end)
	end
end
--print("HitStart")
function FeatureAdded(v:ModuleScript)
	if v:IsA("ModuleScript") then
		--print(v)
		local Req = require(v)
		--print(v)
		local Tab = HitTab.Features[v.Name] or {}
		Array:Override(Tab,Req)

		HitTab.Features[v.Name] = Tab
		--print(HitTab)
	end
end
for i,v in script:WaitForChild("Features"):GetChildren() do
	FeatureAdded(v)
end
script.Features.ChildAdded:Connect(FeatureAdded)
function HitTab:Start(CharConfig)



end

if not HitTab.Running then
	HitTab.Running = true
	if RunService:IsClient() then
		Networker:CreatePort("HitDetect",function(Options)
			local Char = game.Players.LocalPlayer.Character 
			if not Char then return end
			local CharConfig = _G.CreateCharacter(Char)
			HitTab.CamShake(CharConfig,Options)
		end)
	else

			------print("Server")
					--repeat wait() until Networker
					Networker:CreatePort("Hit",function(Player,Options)
						local Char = Player.Character 
						if not Char then return end
						local CharConfig = _G.CreateCharacter(Char)
						------print(CharConfig)
for i,v  in Options.List do
	if (v:GetPivot().Position - Char:GetPivot().Position).Magnitude > 15 then 
		table.remove(Options.List,i)
	end
end

						HitTab.Hit(CharConfig,Options)
					end)

			--Indexes.Modules.Systems.Networker:CreatePort("")

	end
end

return HitTab
