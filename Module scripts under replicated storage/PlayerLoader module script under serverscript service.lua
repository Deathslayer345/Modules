--[[
P4rasail,2/3/25
Manages loading of characters
]]
--Service indexes

local Lib = {}

game.Players.CharacterAutoLoads = false
local RepStorage = game:GetService("ReplicatedStorage")

local Events = RepStorage:WaitForChild("Events")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")

print("PlrLoader")

local CharManager = require(GameManagers:WaitForChild("CharacterManager"))
print("CharManager")
local StatsManager = require(BaseSystems:WaitForChild("StatsManager"))
print("StatsManager")
local RenderService = require(BaseSystems:WaitForChild("RenderService"))
print("RenderService")
local Networker = require(Utils:WaitForChild("Networker"))
warn("ASFSA",Lib)
if not Lib.Running then
	Lib.Running = true
	print("Start!")
	repeat task.wait() until _G.Loaded
	print("Loaded")
	local function plrAdded(Player:Player)
		warn(Player)
		local PlrGui = Player.PlayerGui
		print(Player)
		if not  PlrGui then
			repeat wait(.03)
				PlrGui = Player.PlayerGui	
			until PlrGui
		end

		--[[
		local Scr = script:WaitForChild("Loading"):Clone()
				Scr.Parent = PlrGui
		]]
		print("SFSDFSD")

		if Player.Character then
			Lib:LoadCharacter(Player)
		end
		Player.CharacterAdded:Connect(function()
			
			Lib:LoadCharacter(Player)
		end)
	end
	for i,v in game.Players:GetPlayers() do
		spawn(function()
			plrAdded(v)
		end)
	end
	game.Players.PlayerAdded:Connect(plrAdded)
--[[]
	local function Added(v:Model)
		if not game.Players:GetPlayerFromCharacter(v) then
			if v:IsA("Model") and v:FindFirstChildWhichIsA("Humanoid") then
				Lib:LoadCharacter(v)
			end
		end
	end
	for i,v in workspace:GetChildren() do
		spawn(function()
			Added(v)
		end)
	end
	workspace.ChildAdded:Connect(Added)
	]]
end
function Lib:LoadCharacter(Player:Player|Model)

	local Character = Player
	if Player:IsA("Player") then
		
		if not Player.Character then
			Player:LoadCharacter()
		--	Player.CharacterAppearanceLoaded:Wait()
		end
		Character = Player.Character
		coroutine.wrap(function()
			CharManager:Create(Character)
		end)

		
		repeat wait() until not Character.Parent or Character.Humanoid.Health <= 0
		print("Died")
		task.wait(1)
		Character:Destroy()
		--Player.Character = nil
		
		
	end
	--[[
	spawn(function()
		if not Character:FindFirstChild("HumanoidRootPart") then return end
		if Character.Parent ~= workspace.characters then
			repeat
				Character.Archivable = true
				Character.Parent = workspace.characters
				task.wait(.1)
				--print(Character.Parent)
			until Character.Parent and Character.Parent.Name == "characters" or Character.Parent == nil
		end
		repeat task.wait() until _G.CreateCharacter
		_G.CreateCharacter(Character)
	end)]]


end

local Loads=  {}

_G.LoadChar = function(Player:Player)
	if not Loads[Player] then
		Loads[Player] = true
		Lib:LoadCharacter(Player)
	end
end


return Lib
