--[[
	ConfigSetup Module
	Initializes and configures character settings and behaviors.

	CharConfig table structure:
	  - Modifications: table
	  - Remotes: table
	  - Controller: Instance
	  - PastActions: table
	  - ActionMods: table
	  - Script: Instance
	  - Childs: table
	  - Events: table
	  - PlayerServer: boolean
	  - Signal: table
	  - Animator: Instance
	  - Mover: Instance
	  - MovementAnim: Instance
	  - JumpAnim: Instance
	  - JumpTask: thread
	  - RunBoost: number
	  - Inputs: table
	  - Data: table
	  - Loaded: boolean

	Functions:
	  - CharScriptConnect(Script: Instance, Index: string)
	  - SetupFolder(v: Folder)
	  - DoAction(ActionName: string, Options: table)
	  - Cleanup()
	  - Animation functions: PlayJumpAnim, PlayFallAnim, StopFallJump, ChangeMovementAnim, Run
	  - Server networking callbacks
--]]

local Lib = {
	Configs = {},
	Funcs = {},
	PlayerFuncs = {} 
}
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")

local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local Array = require(Utils.Array)

local Networker = require(Utils:WaitForChild("Networker"))
local MoverManager = require(Utils:WaitForChild("MoverManager"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local Signal = require(Utils:WaitForChild("Signal"))
function CallFunc(Tab,...)
	local Args = {...}
	spawn(function()
		local Succ,Fail = pcall(function()
			Tab.Func(unpack(Args))
		end)
		if not Succ then
			error("ADDED FAIL: ",Fail)
		end
	end)
end
function LoopThing(Tab,...)
	for i,v in Tab do

		CallFunc(v,...)
	end
end
function CallController(CharConfig)
	local Controller = CharConfig.Controller
	if  Controller:GetAttribute("AddedEvent") then
		return
	end

	Controller:SetAttribute("AddedEvent",true)
	local Player = game.Players:GetPlayerFromCharacter(CharConfig.Controller)
	LoopThing(Lib.Funcs,Controller,CharConfig)
	local Tab = CharConfig.Player and Lib.Funcs[CharConfig.Player]
	if Tab then
		Tab.Func(Controller,CharConfig)
	end
end
-- Helper: Connect child scripts and events
function CharScriptConnect(CharConfig, Script, Index)

	if not Script or CharConfig.Childs[Script] then
		return
	end
	CharConfig.Childs[Script] = true

	local originalConfig = CharConfig
	local InitFunc
	local function ScriptAdded(config, child)
		local entry = {
			CurrentTab = config,
			CharConfig = originalConfig,
			Instance = child,
		}

		if child:IsA("ModuleScript") then
			spawn(function()
				local req = require(child)
				if InitFunc then
					entry.Req = req
				else
					if typeof(req) == "function" then
						req(originalConfig)
					else
						originalConfig[child.Name] = req
					end
				end
			end)
		elseif child:IsA("RemoteEvent") or child:IsA("UnreliableRemoteEvent") or child:IsA("RemoteFunction") then
			if not InitFunc then
				CharConfig.Remotes[child.Name] = child
			end
		end
		if InitFunc then
			InitFunc(entry)
		end
	end
	if Index == "Actions" then
		CharConfig[Index] = CharConfig[Index] or {}
		local function start(child:ModuleScript)
			if child:IsA("ModuleScript") then
				spawn(function()
					--print(child)
					CharConfig[Index][child.Name] = require(child)
					if CharConfig[Index][child.Name]["Start"] then
						CharConfig[Index][child.Name]:Start(CharConfig)
					end
				end)
			end
		end
		for _, child in ipairs(Script:GetChildren()) do
			start(child)

		end
		local Ev = Script.ChildAdded:Connect(start)
		Script.Destroying:Once(function()
			Ev:Disconnect()
		end)
	else

		-- Process current children and listen for new ones
		for _, child in ipairs(Script:GetChildren()) do
			spawn(function()
				ScriptAdded(originalConfig, child)
			end)
		end
		table.insert(originalConfig.Events, Script.ChildAdded:Connect(function(child)
			ScriptAdded(originalConfig, child)
		end))
	end
	if not CharConfig[Index] then
		local initModule = Script:FindFirstChild("_INIT")
		CharConfig[Index] = { Childs = {}, Events = {} }
		if initModule and initModule:IsA("ModuleScript") then
			local init = require(initModule)
			--print(typeof(init))
			if typeof(init) == "function" then
				init(CharConfig, Index)
			elseif typeof(init) == "table" then
				if init.Init then
					init.Init(CharConfig, Index)
				end
				InitFunc = init.ChildAdded
				if typeof(init.ScriptAddedFunc) == "function" then
					ScriptAdded = init.ScriptAddedFunc
				end
				for key, val in pairs(init) do
					if key ~= "Init" and key ~= "ScriptAddedFunc" then
						CharConfig[Index][key] = val
					end
				end
			end
		end
	end




end

function SetupFolder(CharConfig, folder)
	if folder and folder:IsA("Folder") and not folder:GetAttribute("DontConnect") then
		CharScriptConnect(CharConfig, folder, folder.Name)
	end
end

function Lib:Connect(Func:(Model)->any)
	if typeof(Func) ~= "function" then
		error("Connection not a function bru",10)
		return
	end
	local NewFunc = {
		Func = Func

	}
	function NewFunc:Disconnect()
		for i,v in Lib.Funcs do
			if v == NewFunc then
				table.remove(Lib.Funcs,i)
				break
			end
		end
		table.clear(NewFunc)
	end
	table.insert(Lib.Funcs,NewFunc)
	for i,v in Lib.Configs do
		CallFunc(NewFunc,v.Controller,v)
	end
	return NewFunc
end

function Lib:ConnectPlayerAdded(Player:Player,Func:(Model))
	if typeof(Player) ~= "Instance" and not Player:IsA(Player) then
		error(Player,"isnt a player bru",10)
		return
	end
	if not Lib.PlayerFuncs[Player] then
		Lib.PlayerFuncs[Player] = {}
		Player.Destroying:Once(function()
			table.clear(Lib.PlayerFuncs[Player])
			Lib.PlayerFuncs[Player] = nil
		end)
	end
	local NewFunc = {
		Func = Func
	}
	function NewFunc:Disconnect()
		for i,v in Lib.PlayerFuncs[Player] do
			if v == NewFunc then
				table.remove(Lib.PlayerFuncs[Player],i)
				break
			end
		end
		table.clear(NewFunc)
	end
	table.insert(Lib.PlayerFuncs[Player],NewFunc)
	if Player.Character and Lib.Configs[Player.Character] then
		CallController(Lib.Configs[Player.Character])
	end
	return NewFunc
end

function Lib:Find(Name:string,ReturnMultiple)
	local MultTable = {}
	for i,v in Lib.Configs do
		if v.Name == Name then
			if not ReturnMultiple then
				return v
			end
			table.insert(MultTable,v)
		end
	end
	return MultTable
end

-- Main function: Create and setup character configuration
function Lib:Create(Controller, Config)
	-- Return existing config if available
	self = Lib
if not Controller then return end
	if Lib.Configs[Controller] then
		CallController(Lib.Configs[Controller])
		return Lib.Configs[Controller]
	end
	Config = Config or {}

	-- Initialize base configuration
	local CharConfig = {
		Modifications = {},
		Remotes = {},
		Controller = Controller,
		PastActions = {},
		ActionMods = {},
		Script = script,
		Childs = {},
		Events = {},
	}
	if not Controller then return end
	Lib.Configs[Controller] = CharConfig

	-- Server flag check
	if RunService:IsServer() and game.Players:GetPlayerFromCharacter(Controller) then
		CharConfig.PlayerServer = true
	end

	-- Connect child folders from the script
	for _, child in ipairs(script:GetChildren()) do
		spawn(function()
			SetupFolder(CharConfig, child)
		end)
	end
	table.insert(CharConfig.Events, script.ChildAdded:Connect(function(v)
		SetupFolder(CharConfig,v)
	end))

	-------------------------------
	-- Character Action Function --
	-------------------------------
	--	print("Action")
	local RepStorage = game:GetService("ReplicatedStorage")
	local Modules = RepStorage:WaitForChild("Modules")
	local Utils = Modules.Utils
	local GameManagers = Modules:WaitForChild("GameManagers")
	local GameControllers = Modules:WaitForChild("GameControllers")
	local BaseSystems = Modules:WaitForChild("BaseSystems")


	local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")
	local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))

	function CharConfig:DoAction(ActionName, Options)
		spawn(function()
			Options = Options or {}
			CharConfig.Data = StatsManager:GetStats(CharConfig.Controller)
			local actionType = CharConfig.Actions and CharConfig.Actions[ActionName]

			-- Debounce/cooldown system to prevent spamming
			self._actionCooldowns = self._actionCooldowns or {}
			local now = os.clock()
			if actionType then
				if Options.Holding then
					--print("Attpypep",ActionName)
				end
				if RunService:IsClient() then
					--print(ActionName,Options)
					Options.Clock = os.clock()
					Networker:SendPortData(
						"PlayerCharManager",
						_G.Enums.NetworkSendType["FastEvent"],
						"DoAction", ActionName, Options
					)
				end
				-- Call the action's function
				actionType.Func(CharConfig, Options)
			end
		end)
	end

	----------------------
	-- Cleanup Handling --
	----------------------
	local function Cleanup()
		if CharConfig.Events then
			for _, conn in ipairs(CharConfig.Events) do
				conn:Disconnect()
			end
		end
	end

	function CharConfig:Cleanup()
		Cleanup()
	end

	spawn(function()
		Array:AddCleanupFunc(CharConfig, Cleanup)
	end)
	CharConfig.Controller.Destroying:Once(function()
		CharConfig:Cleanup()
		Lib.Configs[CharConfig.Controller] = nil
	end)

	-------------------------------
	-- Animation & Movement Setup
	-------------------------------
	local Humanoid = Controller:WaitForChild("Humanoid")
	local HRP = Controller:WaitForChild("HumanoidRootPart")
	--repeat task.wait() until _G.Loaded
	if RunService:IsServer() then 
		Humanoid.Died:Once(function()
			Controller:Destroy()
		end)
	end
	CharConfig.Signal = Signal(script)
	if not CharConfig.PlayerServer then
		-- Ensure an Animator exists
		if not game.Players:GetPlayerFromCharacter(Controller) then
			local animator = Humanoid:FindFirstChild("Animator") or Instance.new("Animator")
			animator.Name = "Animator"
			animator.Parent = Humanoid
		end
		CharConfig.Animator = AnimManager:createConstructor(Humanoid:WaitForChild("Animator"))
		CharConfig.Mover = MoverManager:create(HRP)

		local AnimManager = AnimManager
		local function SetTask(speed)
			if CharConfig.MoveAnimTask then task.cancel(CharConfig.MoveAnimTask) end
			if speed then
				CharConfig.MoveAnimTask = spawn(function()
					while Controller.Parent do
						task.wait(0.1)
						if CharConfig.MovementAnim then
							local vel = HRP.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
							CharConfig.MovementAnim:AdjustSpeed(vel.Magnitude / speed)
						end
					end
				end)
			end
		end

		local Anims = {
			Idle = {},
			Walk = { Speed = 8 },
			Run = { Speed = 26 },
		}
		local oldMovement = nil
		--print("Movement")
		CharConfig.Signal.ChangeMovementAnim = function(movement)
			if movement == oldMovement then return end
			local animData = Anims[movement]
			if animData then
				if CharConfig.MovementAnim then
					CharConfig.MovementAnim:Stop()
				end
				CharConfig.MovementAnim = AnimManager:PlayAnim(
					CharConfig.Animator,
					{"Default", "Movement", movement},
					{ Looped = true, Priority = Enum.AnimationPriority.Core, ID = movement }
				)
				SetTask(animData.Speed)
				oldMovement = movement
			end
		end

		CharConfig.Signal.Run = function(toggle)
			if toggle then
				CharConfig.Signal.ChangeMovementAnim("Run")
			elseif Humanoid.MoveDirection.Magnitude >= 0.1 then
				CharConfig.Signal.ChangeMovementAnim("Walk")
			else
				CharConfig.Signal.ChangeMovementAnim("Idle")
			end
		end

		CharConfig.Signal.ChangeMovementAnim("Idle")
		Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if Humanoid.MoveDirection.Magnitude < 0.1 then
				CharConfig:DoAction("Run", { Holding = false })
			elseif CharConfig.MovementAnim and CharConfig.MovementAnim.Name == "Idle" then
				CharConfig.Signal.ChangeMovementAnim("Walk")
			end
		end)

		-- Jump and Fall animations
		function CharConfig.PlayJumpAnim()
			AnimManager:StopAnim(CharConfig.Animator, {"Jump", "Fall"})
			CharConfig.JumpAnim = AnimManager:PlayAnim(
				CharConfig.Animator,
				{"Default", "Movement", "Jump"},
				{ Looped = true, Priority = Enum.AnimationPriority.Idle, ID = "Jump" }
			)
			if CharConfig.JumpTask then task.cancel(CharConfig.JumpTask) end
			CharConfig.JumpTask = spawn(function()
				repeat task.wait(.02) until CharConfig.JumpAnim.TimePosition >= (CharConfig.JumpAnim.Length - 0.06)
				CharConfig.JumpAnim:AdjustSpeed(0)
			end)
		end

		function CharConfig.PlayFallAnim()
			if CharConfig.JumpTask then task.cancel(CharConfig.JumpTask) end
			AnimManager:StopAnim(CharConfig.Animator, {"Jump", "Fall"})
			CharConfig.JumpAnim = AnimManager:PlayAnim(
				CharConfig.Animator,
				{"Default", "Movement", "Fall"},
				{ Looped = true, Priority = Enum.AnimationPriority.Idle, ID = "Fall" }
			)
			CharConfig.JumpTask = spawn(function()
				repeat task.wait() until CharConfig.JumpAnim.TimePosition >= (CharConfig.JumpAnim.Length - 0.06)
				CharConfig.JumpAnim:AdjustSpeed(0)
			end)
		end

		function CharConfig.StopFallJump()
			if CharConfig.JumpTask then task.cancel(CharConfig.JumpTask) end
			AnimManager:StopAnim(CharConfig.Animator, {"Jump", "Fall"})
		end
		--print("State")
		local perms = RaycastParams.new()
		perms.FilterType = Enum.RaycastFilterType.Exclude
		perms.FilterDescendantsInstances = {workspace:WaitForChild("characters"), workspace:WaitForChild("Effects")}
		Humanoid.StateChanged:Connect(function(oldState, newState)
			if newState == Enum.HumanoidStateType.Jumping then
				CharConfig.PlayJumpAnim()
			elseif newState == Enum.HumanoidStateType.Freefall then
				CharConfig.PlayFallAnim()
			elseif oldState == Enum.HumanoidStateType.Freefall and newState == Enum.HumanoidStateType.Landed then
				CharConfig.StopFallJump()
				local result = workspace:Raycast(HRP.Position, Vector3.new(0, -Humanoid.HipHeight - 7, 0), perms)
				if result then
					local valid = false
					for _, input in ipairs(CharConfig.Inputs.CurrentInputs) do
						if input.Name == "LeftControl" then
							valid = true
							break
						end
					end
					if valid then
						CharConfig:DoAction("Flight", { Toggle = false })
					end
				end
			end
		end)

		CharConfig.RunBoost = 1
		spawn(function()
			local oldTime = os.clock()
			while Controller.Parent do
				task.wait()
				local delta = os.clock() - oldTime
				oldTime = os.clock()
				
				Humanoid.WalkSpeed = Humanoid.WalkSpeed + (16 * CharConfig.RunBoost *(CharConfig.Blocking and .1 or 1) - Humanoid.WalkSpeed) * (0.15^(1 - delta))
				Humanoid.UseJumpPower = true
				Humanoid.JumpPower = Humanoid.JumpPower + ((60 + Humanoid.WalkSpeed/2) - Humanoid.JumpPower) * (0.15^(1 - delta))
			end
		end)
	end
	--print("Inputs")
	--------------------------
	-- Input & Look Handling
	--------------------------
	CharConfig.Inputs = { CurrentInputs = {} }
	--CharConfig.InputMapping = {}
	spawn(function()
		while Controller.Parent do
			task.wait()
			local targetHum = CharConfig.LockedTarget and CharConfig.LockedTarget:FindFirstChildWhichIsA("Humanoid")
			if CharConfig.LockedTarget and CharConfig.LockedTarget:FindFirstChild("HumanoidRootPart") and targetHum and targetHum.Health > 0 then
				CharConfig.Inputs.Look = CFrame.new(HRP.Position, CharConfig.LockedTarget.HumanoidRootPart.Position)
			elseif RunService:IsClient() then
				CharConfig.Inputs.Look = workspace.CurrentCamera.CFrame
			else 
				CharConfig.Inputs.Look = HRP.CFrame * CFrame.new(0,0,-20)
			end
		end
	end)

	--------------------------
	-- Server-Side Networking
	--------------------------
	--print("Networking ss")

	--print("Done")


	CharConfig.Loaded = true
	CallController(CharConfig)
	return CharConfig

end
if not Lib.Running then
	Lib.Running = true
	if RunService:IsServer() then
		spawn(function()
			--repeat task.wait() until _G.Loaded
			Networker:CreatePort("PlayerCharManager", function(Player, TypeAction, ...)
				local Char:Model = Player.Character
				if not Char then return end
				--print(TypeAction,Char)
				local CharConfig = Lib:Create(Char)
				--print(CharConfig)
				if not CharConfig then return end
				if TypeAction == "DoAction" then
					local args = {...}
					spawn(function()
						CharConfig:DoAction(table.unpack(args))
					end)
				end
			end)

		end)
	end
end
-- Expose a helper for creating a character configuration
Lib.Lib = {
	CreateCharacter = function(...)
		return Lib:Create(...)
	end,
}
_G.CreateCharacter = function(...)
	return Lib:Create(...)
end
return Lib