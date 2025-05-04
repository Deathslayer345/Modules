local Lib = {
	Loaded = {},
	Mods = {}
}

--Initializes an added module and adds it to _G
function AddToThing(Mods,Module:ModuleScript)
	--print(Module)
	local Succ,Fail = pcall(function()
	Mods[Module.Name] = require(Module)
	end)
	if not Succ then
		warn("ERROR LOADING LIB OF ",Module.Parent,": ",Fail)
	end
	if typeof(Mods[Module.Name]) == "function" then return end
	if Mods[Module.Name]["Lib"] then
		for IndexName,Value in Mods[Module.Name]["Lib"] do
			Mods[IndexName] = Value
		end
	end

	if typeof(Mods[Module.Name]) == "function" or not Mods[Module.Name]["Start"] then return end
	if Module.Name ~= "CameraShaker" then
		Mods[Module.Name]:Start()	
	end
end
function Added(Module:ModuleScript?,UseG)
	if not Module:IsA("ModuleScript") then return end
	local Success

		--print(Module,"Required...")
		if UseG then
		AddToThing(_G,Module)
		else
		AddToThing(Lib.Mods,Module)
		end
	
end

function Lib:Load(LibScript:Script,UseG)
	
	if not Lib.Loaded[LibScript] then
		Lib.Loaded[LibScript] = true
		LibScript.Destroying:Once(function()
			Lib.Loaded[LibScript] = nil
		end)
		--Connects both script GetChildren and ChildAdded for realtime support
		for _,Module:ModuleScript? in LibScript:GetChildren() do
			task.spawn(function()
				Added(Module)
			end)
		end
		LibScript.ChildAdded:Connect(Added)
		
	end
	
	


	--_G.Loaded = true
end

return Lib
