local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")

local BaseSystems = Modules:WaitForChild("BaseSystems")

local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))

local Networker = require(Utils:WaitForChild("Networker"))
local CharManager = require(GameManagers:WaitForChild("CharacterManager"))

local RenderService = require(BaseSystems:WaitForChild("RenderService"))
local TimeManager = require(Utils:WaitForChild("TimeManager"))
local Array = require(Utils:WaitForChild("Array"))

local CalcManager = require(BaseSystems:WaitForChild("CalcManager"))
local MoverManager = require(Utils:WaitForChild("MoverManager"))

local AnimManager = require(Utils:WaitForChild("AnimManager"))

local CombatService = {
	ComboValues = require(script:WaitForChild("ComboValues")),
	StunTypes = {
		Light = 1,
		All = 200
	},
	Tasks = {},
	DetermineTasks = {},
	WallTasks = {},
	Destroyers = {},
	InCombats = {},
	DamageTasks = {}
}

local math_exp = math.exp
local os_clock = os.clock

local os_time = os.time
local task_wait = task.wait
local task_delay = task.delay

local table_insert = table.insert

local table_find = table.find
local table_clone = table.clone
local typeof_ = typeof

local game_Players = game.Players

function FindStunMarkers(CharConfig, Keyword)
	if not CharConfig then return end
	local Markers = {}
	local children = CharConfig.Data.CharStats.HitBy:GetChildren()
	for i = 1, #children do
		local v = children[i]
		if v.Name == Keyword or Keyword == "All" then
			table_insert(Markers, v.Name)
		end
	end
	return Markers
end

function FindDebounce(CharConfig, Keyword)
	if not CharConfig then return end
	local Markers = {}
	CharConfig.Data = StatsManager:GetStats(CharConfig.Controller) or StatsManager:CreateStats(CharConfig.Controller)
	local Found = CharConfig.Data:WaitForChild("CharStats").Debounces:FindFirstChild(Keyword)
	local OffSync = 0
	local Plr = game_Players:GetPlayerFromCharacter(CharConfig.Controller)
	if Plr then
		if RunService:IsClient() then
			OffSync = TimeManager:getSync()
		else
			OffSync = TimeManager:getClientSync(Plr)
		end
	end
	return Found and os_clock() + OffSync < Found.Val.Value + Found.Start.Value - Found.OffSync.Value
end

function CombatService:RemoveStunMarker(CharConfig, Marker)
	if not CharConfig then return end
	if Marker == "All" then
		Marker = {}
		local children = CharConfig.Data.CharStats.HitBy:GetChildren()
		for i = 1, #children do
			local v = children[i]
			if not table_find(Marker, v.Name) then
				table_insert(Marker, v.Name)
			end
		end
	elseif typeof_(Marker) == "string" and table_find(CombatService.StunTypes, Marker) then
		Marker = FindStunMarkers(CharConfig, Marker)
	elseif typeof_(Marker) == "table" then
		if Marker.StunType then
			Marker = {Marker}
		end
	end
	if not CharConfig.Data then return end
	if not Marker then return end
	for i = 1, #Marker do
		local MarkerName = Marker[i]
		local children = CharConfig.Data.CharStats.HitBy:GetChildren()
		for j = 1, #children do
			local v = children[j]
			if v.Name == MarkerName then
				v:Destroy()
			end
			break
		end
	end
end

function CombatService:AddStunMarker(CharConfig, Options)
	if not CharConfig then return end
	local Entry = {
		Killer = {
			Type = "Object",
			Value = Options.Killer
		},
		Damage = Options.Damage or 0,
		StunType = Options.StunType or "Light"
	}
	local Fold = Array:arrayToFolder(Entry)
	Fold.Name = Entry.StunType
	Fold.Parent = CharConfig.Data.CharStats.HitBy
	return Entry
end

function CombatService:AddDebounce(CharConfig, Index, Value)
	if not CharConfig then return end
	Value = {
		Val = Value - os_clock(),
		Start = os_clock(),
		OffSync = 0
	}
	local Plr = game_Players:GetPlayerFromCharacter(CharConfig.Controller)
	if Plr then
		Value.OffSync = TimeManager:getClientSync(Plr)
	end
	local Fold = CharConfig.Data.CharStats.Debounces:FindFirstChild(Index)
	if Fold then
		Fold:Destroy()
	end
	Fold = Array:arrayToFolder(Value)
	Fold.Name = Index
	Fold.Parent = CharConfig.Data.CharStats.Debounces
	return Fold
end

function CombatService:ContinueCombatTimer(Mod, Time)
	if not Mod then return end
	local CharManagerInstance = CharManager:Create(Mod)
	if CombatService.InCombats[Mod] then
		task.cancel(CombatService.InCombats[Mod])
	end
	local Plr = game_Players:GetPlayerFromCharacter(Mod)
	if RunService:IsServer() and Plr then
		Networker:SendPortData("ContinueCombatTimer", nil, Plr, Mod, Time)
	end
	CharManagerInstance.InCombat = true
	CharManagerInstance.Data.CharStats.InCombat.Value = true
	CombatService.InCombats[Mod] = task_delay(Time, function()
		CharManagerInstance.InCombat = false
		if CharManagerInstance.Data then
			CharManagerInstance.Data.CharStats.InCombat.Value = false
		end
	end)
end

function CombatService:Stun(Mod, Options)
	if typeof_(Mod) ~= "Instance" then return end
	local Find = CombatService.Tasks[Mod]
	local CharConfig = CharManager:Create(Mod)
	local HRP = Mod:FindFirstChild("HumanoidRootPart")
	local StunVal = CombatService.StunTypes[Options.StunType] or 0
	if (Find and (Find.Task and coroutine.status(Find.Task) == "running")) and StunVal < Find.Value then
		return
	end
	if Find then
		if Find.Task then
			task.cancel(Find.Task)
		end
	end
	if CombatService.Destroyers[Mod] then
		task.cancel(CombatService.Destroyers[Mod])
	end
	local Start = os_clock()
	local function Determine()
		if Options.TimeLast then
			if os_clock() >= Start + Options.TimeLast then
				return true
			end
		end
		if Options.DestroyOnFunc then
			if Options.DestroyOnFunc(CharConfig) then
				return true
			end
		end
	end
	local CharConfig = CharManager:Create(Mod)
	if RunService:IsServer() then
		if Options.Killer then
			local Marker = CombatService:AddStunMarker(CharConfig, Options)
			local function Destroy()
				CombatService:RemoveStunMarker(CharConfig, Marker)
			end
			if Options.TimeLast then
				if not Options.BlockInCombat then
					CombatService:ContinueCombatTimer(Mod, Options.TimeLast + 5)
				end
				if Options.KillerTime then
					CombatService:ContinueCombatTimer(Options.Killer, Options.TimeLast + 5)
				end
			end
			if Options.DestroyOnFunc or Options.TimeLast then
				CombatService.Destroyers[Mod] = task.spawn(function()
					repeat task_wait(.1) until Determine()
					Destroy()
				end)
			end
		end
		if CombatService.WallTasks[Mod] then
			pcall(function()
				task.cancel(CombatService.WallTasks[Mod])
			end)
		end
		if not Options.WallStunned and Options.Knockback > 150 then
			CombatService.WallTasks[Mod] = task.spawn(function()
				local Params = RaycastParams.new()
				Params.RespectCanCollide = true
				local HumRootPart = HRP
				Params.FilterType = Enum.RaycastFilterType.Exclude
				Params.FilterDescendantsInstances = {Mod, workspace:WaitForChild("Effects")}
				local bench = os_time() + Options.TimeLast
				local OldTime = os_clock()
				local Delta = 0
				while os_time() < bench do
					task_wait(0.1)
					Delta = os_clock() - OldTime
					OldTime = os_clock()
					local Velocity = HumRootPart.AssemblyLinearVelocity
					local Result = workspace:Raycast(HumRootPart.Position, Velocity.Unit * (6 + Velocity.Magnitude * Delta/5), Params)
					if Result and (not HumRootPart:GetAttribute("WallStunCooldown") or os_clock() > HumRootPart:GetAttribute("WallStunCooldown")) then
						local Configs = {CharConfig}
						local KillerConfig = Options.Killer and CharManager:Create(Options.Killer)
						if KillerConfig then
							table_insert(Configs, KillerConfig)
						end
						for i = 1, #Configs do
							local v = Configs[i]
							if v["CamShake"] then
								v.CamShake(v, .3)
							end
						end
						HumRootPart:SetAttribute("WallStunCooldown", os_clock() + .3)
						Options = table_clone(Options)
						Options.WallStunned = true
						Options.TimeLast = 1
						bench = os_clock() + Options.TimeLast
						local Info = {
							Instance = Result.Instance,
							Position = Result.Position,
							Normal = Result.Normal,
							Distance = Result.Distance,
							Material = Result.Material
						}
						RenderService:AddCrater(Mod, Info)
						local LV = HumRootPart.CFrame.LookVector
						Options.Knockback = 0
						if Options.Spike then
							Options.TimeLast = .6
							Options.Knockback = Velocity.Magnitude
							Options.KnockDir = CFrame.new(Vector3.zero, Result.Normal)
						else
							Options.Dir = CFrame.new(Vector3.zero, LV)
						end
						CombatService:Stun(Mod, Options)
						return
					end
				end
			end)
		end
		local Plr = game_Players:GetPlayerFromCharacter(Mod)
		if Plr then
			Mod:SetAttribute("IsStunned", true)
			Networker:SendPortData("Stun", nil, Plr, Options)
			if Options.TimeLast then
				task_wait(Options.TimeLast)
				Mod:SetAttribute("IsStunned", false)
			end
			return
		end
	end

	local Mover = CharConfig.Mover
	local Animator = CharConfig.Animator
	local Killer = Options.Killer
	local KillerRP = Killer and Killer:FindFirstChild("HumanoidRootPart")
	HRP.Anchored = false
	local Dir = Options.Dir or (KillerRP and KillerRP.CFrame * CFrame.Angles(0, math.pi, 0))
	if not Dir then return end
	local KnockDir = Options.KnockDir or Dir * CFrame.Angles(0, math.pi, 0)
	local Knock = Options.Knockback or 10
	CombatService.Tasks[Mod] = {
		Task = task.spawn(function()
			Mod:SetAttribute("IsStunned", true)
			task_wait()
			local Index = Knock < 100 and tostring(math.random(1, 4)) or "Knockback"
			local Anim = AnimManager:PlayAnim(Animator, {"Stun", Index}, {
				Looped = false,
				Priority = Enum.AnimationPriority.Action4,
				ID = "StunAnim",
				FadeTime = .01,
				Speed = 1
			})
			local Delta = 0
			local OldTime = os_clock()
			local Vel = KnockDir.LookVector * Knock
			local Aim = Vel / 3
			repeat
				task_wait()
				Delta = os_clock() - OldTime
				OldTime = os_clock()
				if Index == "Knockback" and Anim.TimePosition >= 5/24 then
					Anim:AdjustSpeed(0.001)
				end
				if not Mod:GetAttribute("IsStunned") then
					break
				end
				if Options.TimeLast then
					Vel += (Aim - Vel) * math_exp(-1 * Delta * 60) / 60 / Options.TimeLast
				end
				MoverManager:add(Mover, "Vel", "Stun", Vel, 10)
				MoverManager:add(Mover, "Gyro", "Stun", Dir, 10)
			until Determine()
			MoverManager:destroy(Mover, "Vel", "Stun")
			MoverManager:destroy(Mover, "Gyro", "Stun")
			Anim:Stop()
			Mod:SetAttribute("IsStunned", false)
		end),
		Value = StunVal
	}
end

function CombatService:RemoveStun(Mod, Options)
	if Options == "All" or not Options then
		Options = {StunType = "All"}
	end
	local Find = CombatService.Tasks[Mod]
	local HRP = Mod:FindFirstChild("HumanoidRootPart")
	local StunVal = CombatService.StunTypes[Options.StunType] or 0
	local CharConfig = CharManager:Create(Mod)
	if Find and Find.Task then
		task.cancel(Find.Task)
		local Mover = CharConfig.Mover
		local Animator = CharConfig.Animator
		MoverManager:destroy(Mover, "Vel", "Stun")
		MoverManager:destroy(Mover, "Gyro", "Stun")
		AnimManager:StopAnim(Animator, {"StunAnim"}, {})
		Mod:SetAttribute("IsStunned", false)
	end
	if CombatService.Destroyers[Mod] then
		task.cancel(CombatService.Destroyers[Mod])
	end
	Mod:SetAttribute("IsStunned", false)
	if RunService:IsServer() then
		CombatService:RemoveStunMarker(CharConfig, Options.StunType)
		local Plr = game_Players:GetPlayerFromCharacter(Mod)
		if Plr then
			Networker:SendPortData("RemoveStun", nil, Plr, Options)
			return
		end
	end
end

function CombatService:CheckStun(Mod, Options)
	Options = Options or {}
	if not Mod then return end
	local CharConfig = CharManager:Create(Mod)
	return FindStunMarkers(CharConfig, Options.Marker or "All")
end

function CombatService:CheckDebounce(Mod, Options)
	if not Mod then return end
	local CharConfig = CharManager:Create(Mod)
	if typeof_(Options.DebounceType) == "string" then
		return FindDebounce(CharConfig, Options.DebounceType)
	else
		for i = 1, #Options.DebounceType do
			if FindDebounce(CharConfig, Options.DebounceType[i]) then
				return true
			end
		end
	end
end

function CombatService:AddCombatVal(CharConfig, Type, Options)
	Options = Options or {}
	if not CharConfig then return end
	local Data = CharConfig.Data
	local CharStats = Data.CharStats
	local Entry = CombatService.ComboValues[Type]
	if Entry then
		Entry = Array:arrayToFolder(Entry)
		Entry.Parent = CharStats.Combo
		if CharConfig.ResetTask then
			task.cancel(CharConfig.ResetTask)
		end
		CharConfig.ResetTask = task_delay(3, function()
			CombatService:ResetCombo(CharConfig, Options)
		end)
	end
end

function CombatService:ResetCombo(CharConfig, Options)
	Options = Options or {}
	if not CharConfig then return end
	local Data = CharConfig.Data
	if not Data then return end
	local CharStats = Data.CharStats
	CharStats.HitSomeone.Value = false
	CharStats.Combo:ClearAllChildren()
end

function CombatService:Train(Char, Enemy, Options)
	Options = Options or {}
	local Plr = game_Players:GetPlayerFromCharacter(Char)
	local EnemyPlr = game_Players:GetPlayerFromCharacter(Enemy)
	local Stats, EnemyStats
	if Plr then
		Stats = StatsManager:GetStats(Plr)
	else
		Stats = StatsManager:GetStats(Char)
	end
	if EnemyPlr then
		EnemyStats = StatsManager:GetStats(EnemyPlr)
	else
		EnemyStats = StatsManager:GetStats(Enemy)
	end
	local EXPEarn = CalcManager:Train({
		Giver = Stats,
		Enemy = EnemyStats
	})
	Stats.Exp.Value += EXPEarn
end

function CombatService:Damage(Char, Mod, Damage)
	if not RunService:IsServer() then return end
	if not Char or not Mod then return end
	Damage = Damage or 0
	local CharManagerInstance = CharManager:Create(Char)
	local Plr = game_Players:GetPlayerFromCharacter(Char)
	if not Plr then
		Plr = Char
	end
	local Giver = StatsManager:GetStats(Plr)
	if Giver then
		Giver = Giver.Data
	end
	local EPlr = game_Players:GetPlayerFromCharacter(Mod)
	if not EPlr then
		EPlr = Mod
	end
	local Enemy = StatsManager:GetStats(EPlr)
	if Enemy then
		Enemy = Enemy.Data
	end
	if Enemy and Enemy.Parent.CharStats.Blocking.Value then
		RenderService:HitEffect(Mod:FindFirstChild("HumanoidRootPart"), {Type = "Block"})
		return 0
	end
	if CombatService.DamageTasks[Char] then
		pcall(function()
			task.cancel(CombatService.DamageTasks[Char])
		end)
	end
	local DMG = CalcManager:CalcDamage({
		Giver = Giver,
		Enemy = Enemy
	}) * Damage
	local ModHum = Mod:FindFirstChildWhichIsA("Humanoid")
	if ModHum then
		ModHum:TakeDamage(DMG)
	end
	CharManagerInstance.Data.CharStats.Damage.Value += math.floor(DMG)
	CombatService.DamageTasks[Char] = task_delay(10, function()
		if not CharManagerInstance.Data then return end
		if not Char.Parent then return end
		CharManagerInstance.Data.CharStats.Damage.Value = 0
	end)
	return DMG
end

if not CombatService.Running then
	CombatService.Running = true
	if RunService:IsClient() then
		function CombatService:Start()
			Networker:CreatePort("Stun", function(Options)
				local Char = game_Players.LocalPlayer.Character
				if not Char then return end
				CombatService:Stun(Char, Options)
			end, {})
			Networker:CreatePort("RemoveStun", function(Options)
				local Char = game_Players.LocalPlayer.Character
				if not Char then return end
				local CharConfig = CharManager:Create(Char)
				CombatService:RemoveStunMarker(CharConfig, Options)
			end, {})
			Networker:CreatePort("ContinueCombatTimer", function(Mod, Time)
				local Char = game_Players.LocalPlayer.Character
				if not Char then return end
				return CombatService:ContinueCombatTimer(Char, Time)
			end, {})
			Networker:CreatePort("CheckStun", function(Options)
				local Char = game_Players.LocalPlayer.Character
				if not Char then return end
				return CombatService:CheckStun(Char, Options)
			end, {})
			Networker:CreatePort("CheckDebounce", function(Options)
				local Char = game_Players.LocalPlayer.Character
				if not Char then return end
				return CombatService:CheckDebounce(Char, Options)
			end, {})
		end
	else
		function CombatService:Start()
			repeat task_wait(.1) until Networker
			Networker:CreatePort("Stun", function(Options)
			end, {})
			Networker:CreatePort("RemoveStun", function(Options)
			end, {})
			Networker:CreatePort("ContinueCombatTimer", function(Mod, Time)
			end, {})
			Networker:CreatePort("CheckStun", function(Options)
			end, {})
			Networker:CreatePort("CheckDebounce", function(Options)
			end, {})
		end
	end
end

return CombatService
