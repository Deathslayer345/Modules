local RepStorage = game:GetService("ReplicatedStorage")
local UIService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return {}
end

local CharManager = require(RepStorage:WaitForChild("Modules"):WaitForChild("GameManagers"):WaitForChild("CharacterManager"))


local Lib = {}
local Plr = game.Players.LocalPlayer
local Char = Plr.Character  or Plr.CharacterAdded:Wait()
local CharConfig
function charAdded(Char:Model)
	wait(.03)
	Char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
	if Char then
		CharConfig = CharManager:Create(Char)
	end
end

local InputFormats = {
	["Type"] = { "UserInputType", "Name" },
	["Key"] = { "KeyCode", "Name" },
	Name = { "Name" },
}

-- Function to resolve input data into a specific format
local function SolveEntry(Input, Info, Index, Format)
	if not Input or not Info or not Index or not Format then return end
	local Entry = InputFormats[Index]
	local Value = Input

	if type(Entry) == "table" then
		for _, key in pairs(Entry) do
			Value = Value[key]
		end
	else
		Value = Value[Entry]
	end
	Info[Index] = Value
end
--print("B4inp")
-- Function to retrieve input information
local Names = {
	"W",
	"A",
	"S",
	"D",
	"Space",
	"LeftControl",
	"RightControl"
}
local function GetInputInfo(Input)
	if not Input then return end
	local EnumType
	local Success = pcall(function() EnumType = Input.EnumType end)
	local Info = {}

	if Success and EnumType then
		return _G.Enums.Key[Input.Name], Info
	end

	for Index, Format in pairs(InputFormats) do
		SolveEntry(Input, Info, Index, Format)
	end
	--print(_G.Enums,Info)

	--print(_G.Enums.Key.Enums)
	return Info.Key and Info.Key ~= "Unknown" and _G.Enums.Key.Enums[Info.Key] or _G.Enums.Key.Enums[Info.Type], Info
end

if not Lib.Running then
	Lib.Running = true

	local CharConfig = CharManager:Create(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait())
	Plr.CharacterAdded:Connect(function(Char)
		CharConfig = CharManager:Create(Char)
	end)
	--	Lib.InputHandler:SetupChar(CharManager)
	local LastJumped = 0

	-- Input actions
	local InputFuncs = {
		Jump = function(_, Holding)
			if Holding then
				if os.clock() - LastJumped <= 0.5 then
					CharConfig:DoAction("Flight")
					--print("Flight",CharConfig.Flying,CharConfig)
				else
					LastJumped = os.clock()
				end
			end
		end,
		Shift = function(_, Holding)
			local Action = CharConfig.Flying and "ShiftFlight" or "Run"
			--			print(Action)
			CharConfig:DoAction(Action, { Holding = Holding })
		end,
		LockOn = function(_, Holding)
			if Holding then
				--print("Locker")
				CharConfig:DoAction("LockOn", {})
			end
		end,
		Defense = function(_, Holding)
			if Holding then
				CharConfig:DoAction("Defense", {})
			end
		end,
		KiSense = function(_, Holding)
			if Holding then
				CharConfig:DoAction("KiSense", {})
			end
		end,
		Dash = function(_, Holding)
			--print(Holding)
			CharConfig:DoAction("Dash", { Holding = Holding })
		end,
		KiBlast = function(_, Holding)
			CharConfig:DoAction("KiBlast", { Holding = Holding })
		end,
		Charge = function(_, Holding)
			CharConfig:DoAction("Charge", { Holding = Holding })
		end,
		Blocking = function(_, Holding)
			CharConfig:DoAction("Block", { Holding = Holding })
		end,
		M1 = function(_, Holding)

			CharConfig:DoAction("Hit", { Type = "M1", Holding = Holding })
		end,
	}
	--print("B4func")
	Lib.DoFunc = function(Input:string,Holding)
		if InputFuncs[Input] then
			--print(Input,Holding)
			InputFuncs[Input]({},Holding)
		end
	end
	--print("Afterfunc")
	-- Process input
	local function DoInput(Info, Holding)
		for Action, Mappings in pairs(CharConfig.InputMapping) do
			local MapTable = type(Mappings[1]) == "table" and Mappings or { Mappings }
			for _, Mapping in pairs(MapTable) do
				if Mapping.Value == Info.Value then
					if InputFuncs[Action] then
						InputFuncs[Action](Info, Holding)
						return
					end
				end
			end
		end
	end

	-- Global functions for input
	Lib.InputBegan = function(Input, Focused)
		if Focused then return end
		local Info = GetInputInfo(Input)
		print(Info)
		if not Info then return end
		if table.find(Names,Info.Name) then
			CharConfig:DoAction("PressInput", { Holding = true, Key = Info })
		end
		DoInput(Info, true)
	end

	Lib.InputEnded = function(Input, Focused)
		--if Focused then return end
		local Info = GetInputInfo(Input)
		if not Info then return end
		if table.find(Names,Info.Name) then
			CharConfig:DoAction("PressInput", { Holding = false, Key = Info })
		end
		DoInput(Info, false)
	end
	local Players = game:GetService("Players")
	local Player = Players.LocalPlayer
	local PlayerGui = Player.PlayerGui


	--PlayerGui.TouchGui.TouchControlFrame.JumpButton
	local touchGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
	if touchGui then
		PlayerGui.TouchGui.TouchControlFrame.JumpButton.MouseButton1Down:Connect(function()
			Lib.InputBegan(Enum.KeyCode.Space)
		end)
		PlayerGui.TouchGui.TouchControlFrame.JumpButton.MouseButton1Up:Connect(function()
			Lib.InputEnded(Enum.KeyCode.Space)
		end)
	end
	local Ev1 = UIService.InputBegan:Connect(Lib.InputBegan)
	local Ev2 = UIService.InputEnded:Connect(Lib.InputEnded)
	local MobTouching = false
	local CurrentInput
	UIService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local touchGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
			if touchGui then
				local TouchControlFrame:Frame = touchGui:WaitForChild("TouchControlFrame")
				TouchControlFrame = TouchControlFrame:WaitForChild("ThumbstickFrame").OuterImage
				local Dir = Vector2.new(input.Position.X,input.Position.Y)-TouchControlFrame.AbsolutePosition
				--MobTouching = Dir.Magnitude < 200
				--CurrentInput = input
			end
		end
	end)
	local UIService = game:GetService("UserInputService")
	local touchGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
	local thumbstickOuter = touchGui and touchGui.TouchControlFrame.ThumbstickFrame.OuterImage
	local thumbstickCenter =  touchGui and thumbstickOuter.AbsolutePosition + thumbstickOuter.AbsoluteSize / 2 or Vector2.zero
	local thumbstickRadius =  touchGui and thumbstickOuter.AbsoluteSize.X * 1.2
	local activeThumbstickInput = nil
	local function SetThing()
		touchGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
		thumbstickOuter = touchGui and touchGui.TouchControlFrame.ThumbstickFrame.OuterImage
		thumbstickCenter =  touchGui and thumbstickOuter.AbsolutePosition + thumbstickOuter.AbsoluteSize / 2 or Vector2.zero
		thumbstickRadius =  touchGui and thumbstickOuter.AbsoluteSize.X * 1.2

	end
	UIService.InputBegan:Connect(function(input, gameProcessed)
		--if gameProcessed then return end
		SetThing()
		if input.UserInputType == Enum.UserInputType.Touch then
			local touchPos = Vector2.new(input.Position.X, input.Position.Y)
			if (touchPos - thumbstickCenter).Magnitude <= thumbstickRadius then
				activeThumbstickInput = input
			end
		end
	end)

	UIService.InputChanged:Connect(function(input, gameProcessed)
		--if gameProcessed then return end
		SetThing()
		if input == activeThumbstickInput and input.UserInputType == Enum.UserInputType.Touch then
			local touchPos = Vector2.new(input.Position.X, input.Position.Y)
			local relativePos = touchPos - thumbstickCenter
			relativePos = Vector3.new(relativePos.X,0,relativePos.Y)
			--local relativePos = Vector2.new(touchPos.X - thumbstickCenter.X,touchPos.Y - thumbstickCenter.Y)

			if relativePos.Magnitude > .1 then  -- Ensure we have a direction
				local normalizedDir = relativePos.Unit
				Char:SetAttribute("FlightUnit",normalizedDir)
				if normalizedDir.X > 0.5 then
					Lib.InputBegan(Enum.KeyCode.D)
					Lib.InputEnded(Enum.KeyCode.A)
				elseif normalizedDir.X < -0.5 then
					Lib.InputEnded(Enum.KeyCode.D)
					Lib.InputBegan(Enum.KeyCode.A)
				else
					Lib.InputEnded(Enum.KeyCode.D)
					Lib.InputEnded(Enum.KeyCode.A)
				end

				if normalizedDir.Y < -0.5 then
					Lib.InputBegan(Enum.KeyCode.W)
					Lib.InputEnded(Enum.KeyCode.S)
				elseif normalizedDir.Y > 0.5 then
					Lib.InputEnded(Enum.KeyCode.W)
					Lib.InputBegan(Enum.KeyCode.S)
				else
					Lib.InputEnded(Enum.KeyCode.W)
					Lib.InputEnded(Enum.KeyCode.S)
				end
			else
				Char:SetAttribute("FlightUnit",Vector3.zero)
				Lib.InputEnded(Enum.KeyCode.W)
				Lib.InputEnded(Enum.KeyCode.A)
				Lib.InputEnded(Enum.KeyCode.S)
				Lib.InputEnded(Enum.KeyCode.D)
			end
		elseif input.KeyCode == Enum.KeyCode.Thumbstick1 then
			local touchPos = Vector2.new(input.Position.X, input.Position.Y)
			local relativePos = touchPos - thumbstickCenter

			if relativePos.Magnitude > .1 then  -- Ensure we have a direction
				local normalizedDir = relativePos.Unit
				Char:SetAttribute("FlightUnit",normalizedDir)
				if normalizedDir.X > 0.5 then
					Lib.InputBegan(Enum.KeyCode.D)
					Lib.InputEnded(Enum.KeyCode.A)
				elseif normalizedDir.X < -0.5 then
					Lib.InputEnded(Enum.KeyCode.D)
					Lib.InputBegan(Enum.KeyCode.A)
				else
					Lib.InputEnded(Enum.KeyCode.D)
					Lib.InputEnded(Enum.KeyCode.A)
				end

				if normalizedDir.Y > 0.5 then
					Lib.InputBegan(Enum.KeyCode.W)
					Lib.InputEnded(Enum.KeyCode.S)
				elseif normalizedDir.Y < -0.5 then
					Lib.InputEnded(Enum.KeyCode.W)
					Lib.InputBegan(Enum.KeyCode.S)
				else
					Lib.InputEnded(Enum.KeyCode.W)
					Lib.InputEnded(Enum.KeyCode.S)
				end
			else
				Char:SetAttribute("FlightUnit",Vector3.zero)
				Lib.InputEnded(Enum.KeyCode.W)
				Lib.InputEnded(Enum.KeyCode.A)
				Lib.InputEnded(Enum.KeyCode.S)
				Lib.InputEnded(Enum.KeyCode.D)
			end
		end
	end)

	UIService.InputEnded:Connect(function(input, gameProcessed)
		--if gameProcessed then return end
		if input == activeThumbstickInput and input.UserInputType == Enum.UserInputType.Touch then
			activeThumbstickInput = nil
			Char:SetAttribute("FlightUnit",Vector3.zero)
			Lib.InputEnded(Enum.KeyCode.W)
			Lib.InputEnded(Enum.KeyCode.A)
			Lib.InputEnded(Enum.KeyCode.S)
			Lib.InputEnded(Enum.KeyCode.D)
		end
	end)


end
return Lib
