local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local Modules = RepStorage:WaitForChild("Modules")
local Utils = Modules.Utils
local GameManagers = Modules:WaitForChild("GameManagers")
local GameControllers = Modules:WaitForChild("GameControllers")
local BaseSystems = Modules:WaitForChild("BaseSystems")


local MoverManager = require(Utils:WaitForChild("MoverManager"))
local AnimManager = require(Utils:WaitForChild("AnimManager"))
local Networker = require(Utils:WaitForChild("Networker"))
local CharacterManager = require(GameManagers:WaitForChild("CharacterManager"))
return {
	Func = function(CharConfig,Options)
		local MoverManager =  MoverManager
		local AnimManager = AnimManager
		local Mover = CharConfig.Mover
		local Targ:Model
		--print(CharConfig)
		if _G.Cam and Options.Target == nil then
			local UIService = game:GetService("UserInputService")
			local Things = {}
			local CurrentCam = workspace.CurrentCamera
			local MousePos = UIService:GetMouseLocation()
			
			for i,v in workspace:GetChildren() do
				
				if v:IsA("Model") and v ~= CharConfig.Controller  then
					local PrimPart:BasePart = v:FindFirstChild("HumanoidRootPart")
					if PrimPart then
						local ScreenPart = CurrentCam:WorldToScreenPoint(PrimPart.Position)
						--UIService:Get
						--print(Mod,ScreenPart)
						
						if ScreenPart.Z >= 0 and ScreenPart.Z <= 600 then
							table.insert(Things,{
								Mod = v,
								Distance = (Vector2.new(ScreenPart.X,ScreenPart.Y) - MousePos).Magnitude + ScreenPart.Z^.5
							})
						end
					end
				end
			end
			table.sort(Things,function(Part1,Part2)
				return Part1.Distance < Part2.Distance
			end)
--print(Things)
			Options.Target = Things[1] and Things[1].Distance < 700 and Things[1].Mod
			--print(Options.Target)
			if _G.Cam.LockedOn == Options.Target then
				Options.Target = nil
			end
			Networker:SendPortData("PlayerCharManager"..CharConfig.Controller.Name,_G.Enums.NetworkSendType["FastEvent"],"DoAction","LockOn",Options)

		end
		local function CleanLock()
			if _G.LockInst then
				_G.LockInst:Destroy()
			end
			if _G.LockTask then 
				pcall(function()
				task.cancel(_G.LockTask)
				end)
			end
		end
		CleanLock()
_G.PlaySong()
--print("LockOn")
--print(Options)
		if Options.Target then
			
			local Targ:Model = Options.Target
			if typeof(Targ) == "Instance" and Targ:IsA("Model") then
				CharConfig.LockedOn = true
				_G.PlaySong("Lockon")
				CharConfig.LockedTarget = Targ
				if _G.Cam then
					_G.Cam.LockedOn = Targ
					
					local Inst = RepStorage:WaitForChild("lockOn"):Clone()
					_G.LockTask = spawn(function()
						local oldTime = os.clock()
						local Delta = 0
						local Frame = Inst:WaitForChild("Frame")
						local Arrows = Frame:WaitForChild("arrows")
						local Circle = Frame:WaitForChild("circle")
						local X,Y = Frame.Size.X.Scale,Frame.Size.Y.Scale
						local Range = .4
						local Speed = 2
						local TimePassed = os.clock()
						while Targ.Parent do
							wait()
							Delta = os.clock() - oldTime
							oldTime = os.clock()
							local Const = (os.clock() - TimePassed) * math.pi * Speed--Amount per sec
							Frame.Size = UDim2.fromScale(X + math.sin(Const) * X * Range,Y + math.sin(Const) * Y * Range)
							
						end
						CharConfig:DoAction("LockOn",{
							Target = false
						})
					end)
					Inst.Parent = Targ:WaitForChild("HumanoidRootPart")
					
					_G.LockInst = Inst
				end
			else
				CharConfig.LockedOn = nil
				CharConfig.LockedTarget = nil
				if _G.Cam then
					_G.Cam.LockedOn = nil
				end
			end
		else
			CharConfig.LockedOn = nil
			CharConfig.LockedTarget = nil
			if _G.Cam then
				_G.Cam.LockedOn = nil
			end
		end
		--print(_G.Cam)
	end,

	--[[CheckIfUsable = function(CharConfig,Options)
		
	end]]
}