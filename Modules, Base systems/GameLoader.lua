local RepStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local Events = RepStorage:WaitForChild("Events")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")

local Networker = require(Utils:WaitForChild("Networker"))
local Array = require(Utils:WaitForChild("Array"))
local CharacterManager = require(GameManagers:WaitForChild("CharacterManager"))
local Config = require(script:WaitForChild("Config"))
local GameLoader = {}

-- Define print function with timestamp and client/server indicator
--[[
local function print(...)
	local isServer = game:GetService("RunService"):IsServer()
	print(`[${tick()}] [${isServer and "Server" or "Client"}]`, ...)
end]]

local Include = {
	"BasePart",
	"Decal",
	"ParticleEmitter",
	"SurfaceAppearance",
	"Animation",
	"AnimationTrack",
	"Light",
	"ColorCorrectionEffect",
	"Material",
	"SpecialMesh",
	"Texture",
	"Trail",
	"Skybox",
	"Bloom",
	"Blur",
	"GUIBase",
	"Beam"
}
local Loaded = {}
local PartAmounts = {}

function CheckWait(num: number)
	if num % 10 == 0 then
		task.wait(0.1)
	end
end

_G.GetGameInfo = function(player, Inst: Instance)
	if Inst and typeof(Inst) == "Instance" then
		print(`GetGameInfo called by ${player and player.Name or "Server"} for ${Inst:GetFullName()}`)
		if PartAmounts[Inst] then
			return PartAmounts[Inst]
		end


		local Count = Array:CountTable(Inst:GetDescendants())
		if not PartAmounts[Inst] then
			PartAmounts[Inst] = 0
		end
		
		PartAmounts[Inst] = Count
		local Events = {}
		
		table.insert(Events, Inst.DescendantAdded:Connect(function()
			PartAmounts[Inst] += 1
		end))
		table.insert(Events, Inst.DescendantRemoving:Connect(function()
			PartAmounts[Inst] -= 1
		end))
		Inst.Destroying:Once(function()
			for i, v in Events do
				v:Disconnect()
			end
			table.clear(Events)
			PartAmounts[Inst] = nil
		end)
		return Count
	end
	end

if game:GetService("RunService"):IsServer() then
	game.ReplicatedStorage:WaitForChild("Events").GetGameInfo.OnServerInvoke = _G.GetGameInfo
end

function GameLoader:Load()
	print("GameLoader:Load started")
	if GameLoader.Loading or GameLoader.Loaded then
		print("Loading already in progress or already loaded")
		return
	end
	GameLoader.Loading = true

	if game:GetService("RunService"):IsServer() then
        --[[repeat task.wait()
        --print(_G)	
        until _G.GetGameInfo ]]
	end

	local function LoadTab(Tab, Skippable: boolean?)
		print(`LoadTab started for ${#Tab} instances, Skippable: ${Skippable or false}`)
		if (GameLoader.Skipped) then
			print("Loading skipped")
			_G.Loaded = true
			return
		end
		local Amounts = {}
		local Utilized = {}
		for i, v in Tab do
			if game:GetService("RunService"):IsClient() then
				Amounts[v] = Events:WaitForChild("GetGameInfo"):InvokeServer(v) or #(v:GetDescendants())
				print(`Instance ${v:GetFullName()} has ${Amounts[v]} descendants`)
			else
				Amounts[v] = _G.GetGameInfo(nil, v)
				print(`Instance ${v:GetFullName()} has ${Amounts[v]} descendants (server-side)`)
			end
		end
		for i, v in Amounts do
			spawn(function()
				print(`Waiting for ${i:GetFullName()} to load 70% of ${v} descendants`)
				repeat task.wait(0.1)
					if (Skippable and GameLoader.Skipped) then
						print(`Skipped waiting for ${i:GetFullName()}`)
						break
					end
				until #(i:GetDescendants()) >= v * 0.7
				print(`${i:GetFullName()} has loaded 70% of descendants`)
				Utilized[i] = true
			end)
		end

		local function AllLoaded()
			local Valid = true
			for i, v in Amounts do
				if not Utilized[i] then
					return false
				end
			end
			return true
		end

		local lastPrintTime = tick()
		repeat task.wait(0.1)
			if tick() - lastPrintTime > 1 then
				print("Waiting for all instances to load 70%...")
				lastPrintTime = tick()
			end
		until AllLoaded() or (Skippable and GameLoader.Skipped)
		if AllLoaded() then
			print("All instances have loaded at least 70% of descendants")
		else
			print("Loading skipped for instances")
		end

		if not (Skippable and GameLoader.Skipped) then
			local Loaders = {}
			local Total = 0
			local LoadAtTime = 0
			local AmountCurrent = 0
			local Confirmation = false
			local Amount = 0
			local LoadTab = {}

			local function AddTab(Child: Instance)
				local Valid = false
				for a, k in Include do
					if Child:IsA(k) then
						Valid = true
						break
					end
				end
				if not Valid then return end
				Total += 1
				print(`Adding ${Child:GetFullName()} to preload, Total now ${Total}`)

				spawn(function()
					if (Skippable and GameLoader.Skipped) then
						print(`Skipped preloading ${Child:GetFullName()}`)
						return
					end
					if LoadAtTime >= 500 then
						repeat task.wait()
						until LoadAtTime <= 100 or (Skippable and GameLoader.Skipped)
					end
					LoadAtTime += 1
					local success, fail = pcall(function()
						if game:GetService("RunService"):IsClient() then
							ContentProvider:PreloadAsync({Child}, function(status)

							end)
						end
						LoadAtTime -= 1
						AmountCurrent += 1
						if AmountCurrent % 500 == 0 then
							print(`${AmountCurrent} assets marked as loaded (note: may not be actually preloaded yet)`)
						end
					end)
					if not success then
						print(`Failed to start preloading ${Child:GetFullName()}: ${fail}`)
						Total -= 1
						LoadAtTime -= 1
					end
				end)
			end

			for i, v in Tab do
				for e, x in v:GetDescendants() do
					if (Skippable and GameLoader.Skipped) then break end
					AddTab(x)
					if Total % 200 == 0 and Total > 0 then
						task.wait(0.02)
					end
				end
				local Desc = v.DescendantAdded:Connect(AddTab)
				spawn(function()
					repeat task.wait(0.3) until _G.Loaded
					Desc:Disconnect()
				end)
			end

			local lastPrintTime = tick()
			repeat task.wait(0.1)
				if tick() - lastPrintTime > 1 then
					print(`Preloading progress: ${AmountCurrent} / ${Total} marked as loaded`)
					lastPrintTime = tick()
				end
				GameLoader.AmountCurrent = AmountCurrent
				GameLoader.Total = Total
				print(Total)
			until Total == 0 or (Skippable and GameLoader.Skipped) or AmountCurrent >= Total * 0.7
			if AmountCurrent >= Total * 0.7 then
				print("Marked as preloaded (note: actual preloading may still be in progress)")
			elseif Skippable and GameLoader.Skipped then
				print("Preloading skipped")
			else
				print("No assets to preload")
			end
		end
		print("LoadTab finished")
	end

if not GameLoader.Skipped then
		LoadTab(Config.Important)
	end

	if not GameLoader.Skipped then
		LoadTab(Config.Skippable, true)
	end

	if game:GetService("RunService"):IsClient() then
		require(script:WaitForChild("Client"))(GameLoader)
	elseif game:GetService("RunService"):IsServer() then
		require(script:WaitForChild("Server"))(GameLoader)
	end

	GameLoader.Loaded = true
	_G.Loaded = true
	print("GameLoader:Load finished, GameLoader.Loaded and _G.Loaded set to true")
end

if not GameLoader.Running and game:GetService("RunService"):IsServer() then
	GameLoader.Running = true
	Networker:CreatePort("GameLoad", function(Player: Player, Type)
		print(`Player ${Player.Name} connected to GameLoad`)
		if not Player.Character then
			Player:LoadCharacter()
			repeat task.wait() until Player.Character
			CharacterManager:Create(Player.Character)
			print(`Player ${Player.Name} loaded`)
		end
	end)
end

return GameLoader