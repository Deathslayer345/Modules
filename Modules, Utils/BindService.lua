local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
--local Networker = _G.Networker
local Modules = RepStorage:WaitForChild("Modules")
local Networker = require(Modules:WaitForChild("Utils"):WaitForChild("Networker"))

local BindService = {
	List = {},
	Types = {}
}

function SetUID(Inst:Instance)
	if Inst and typeof(Inst.SetAttribute) == "function" then
		local existingId = Inst:GetAttribute("UniqueId")
		if not existingId then
			local success, guid = pcall(function() return HTTPService:GenerateGUID() end)
			if success and guid then
				Inst:SetAttribute("UniqueId", guid)
				return guid
			else
				warn("BindService SetUID: Failed to generate GUID")
				return nil
			end
		end
		return existingId
	end
	return nil
end

function ExtendFullName(Inst:Instance)
	local currentId = SetUID(Inst)
	if not currentId then return nil end

	local pathSegments = {currentId}
	local currentAncestor = Inst.Parent

	while currentAncestor and currentAncestor ~= game do
		local ancestorId = SetUID(currentAncestor)
		if ancestorId then
			table.insert(pathSegments, 1, ancestorId)
		else
			warn("BindService ExtendFullName: Could not get/set UniqueId for ancestor:", currentAncestor:GetFullName())
			return table.concat(pathSegments, ".")
		end
		currentAncestor = currentAncestor.Parent
	end
	return table.concat(pathSegments, ".")
end

function InstToPath(Inst)
	if not Inst then return nil end
	local pathString = ExtendFullName(Inst)
	local uid = Inst:GetAttribute("UniqueId")

	if not pathString or not uid then
		warn("BindService InstToPath: Failed to generate path/UID for", Inst:GetFullName())
		return nil
	end

	return {
		Path = pathString,
		ID = uid
	}
end

function PathToInst(Name,ID:string)
	if not Name or not ID then return nil end
	local Args = string.split(Name, ".")
	if #Args == 0 then return nil end

	local Current = game
	local Temp = nil
	local CHAdd

	for index, segmentId in ipairs(Args) do
		Temp = nil
		if CHAdd then
			CHAdd:Disconnect()
			CHAdd = nil
		end

		for _, child in ipairs(Current:GetChildren()) do
			if typeof(child.GetAttribute) == "function" and child:GetAttribute("UniqueId") == segmentId then
				Temp = child
				break
			end
		end

		if Temp then
			Current = Temp
		else
			local Found = nil
			local timeout = 50
			local attempts = 0

			CHAdd = Current.ChildAdded:Connect(function(child)
				if typeof(child.GetAttribute) == "function" and child:GetAttribute("UniqueId") == segmentId then
					Found = child
				end
			end)

			repeat
				task.wait(0.1)
				if Found then break end

				for _, child in ipairs(Current:GetChildren()) do
					if typeof(child.GetAttribute) == "function" and child:GetAttribute("UniqueId") == segmentId then
						Found = child
						break
					end
				end
				if Found then break end

				attempts = attempts + 1
			until Found or attempts >= timeout

			if CHAdd then
				CHAdd:Disconnect()
				CHAdd = nil
			end

			if not Found then
				warn("BindService PathToInst: Could not find instance with UniqueId", segmentId, "in path", Name)
				return nil
			end
			Current = Found
		end
	end

	if Current and typeof(Current.GetAttribute) == "function" and Current:GetAttribute("UniqueId") == ID then
		return Current
	else
		warn("BindService PathToInst: Final instance ID mismatch or not found. Path:", Name, "Expected ID:", ID, "Found:", Current and Current:GetFullName())
		return nil
	end
end

function ConvertArgs(...)
	local Args = { ... }
	for i, v in ipairs(Args) do
		if typeof(v) == "Instance" then
			local pathData = InstToPath(v)
			if pathData then
				Args[i] = pathData
			else
				warn("BindService ConvertArgs: Failed to convert instance to path:", v:GetFullName())
			end
		elseif typeof(v) == "table" then
			-- Args[i] = {ConvertArgs(unpack(v))}
		end
	end
	return Args
end

function ConvertArgsServer(...)
	local Args = { ... }
	for i, v in ipairs(Args) do
		if typeof(v) == "table" and v.Path and v.ID then
			local instanceRef = PathToInst(v.Path, v.ID)
			if instanceRef then
				Args[i] = instanceRef
			else
				warn("BindService ConvertArgsServer: Could not resolve instance from path:", v.Path)
			end
		elseif typeof(v) == "table" then
			-- Optionally recurse?
		end
	end
	return Args
end

function BindTo(Model:Model,Target:Model,BindInfo,PastFirst,Parent)
	local Valid = Parent
	for i,v in ipairs(Model:GetChildren()) do
		if not Valid then
			Parent = v
		end
		local FindConnection
		if BindInfo["FindConnection"] then
			local success, result = pcall(BindInfo.FindConnection, v, Target)
			if success then FindConnection = result end
		end

		if not FindConnection then
			FindConnection = Target:FindFirstChild(v.Name)
		end

		if not PastFirst and not FindConnection then
			continue
		end

		if PastFirst then
			FindConnection = Target
		end

		for typeName,typeModule in pairs(BindService.Types) do
			if v:IsA(typeName) then
				if typeModule and typeModule.Init then
					local initParent = Valid and Parent or v.Parent
					local success, err = pcall(typeModule.Init, BindInfo, v, FindConnection, initParent)
					if not success then warn("BindService Error in Type Init [", typeName, "]:", err) end
				end
				break
			end
		end

		if #v:GetChildren() > 0 then
			BindTo(v, FindConnection, BindInfo, true, Parent)
		end
	end

	if not Valid then
		local renderer = script:FindFirstChild("Renderer")
		if renderer and renderer:IsA("ModuleScript") then
			local success, req = pcall(require, renderer)
			if success and typeof(req) == "function" then
				pcall(req, Target, Model)
			elseif not success then
				warn("BindService: Failed to require Renderer module:", req)
			end
		else
			warn("BindService: Renderer module script not found.")
		end
	end
end

function BindService:Bind(Model:Model, Target:Model, Config)
	Config = Config or {}
	local Tag = Config.Tag or "Default"
	local Unbind = Config.Unbind

	if Target and BindService.List[Target] and BindService.List[Target][Tag] then
		local existingBindInfo = BindService.List[Target][Tag]
		if existingBindInfo and existingBindInfo.Model then
			existingBindInfo.Model:SetAttribute("Stopped", true)
		else
			BindService.List[Target][Tag] = nil
			if next(BindService.List[Target]) == nil then
				BindService.List[Target] = nil
			end
		end
	end

	if Unbind or not Model then
		return
	end

	if typeof(Target) ~= "Instance" then
		warn("BindService:Bind: Invalid Target provided.")
		return
	end

	if not BindService.List[Target] then
		BindService.List[Target] = {}
		local targetDestroyConn

		local function targetCleanup()
			if BindService.List[Target] then
				local bindsToCleanup = {}
				for tag, bindInfo in pairs(BindService.List[Target]) do
					table.insert(bindsToCleanup, bindInfo)
				end
				BindService.List[Target] = nil

				for i, bindInfo in ipairs(bindsToCleanup) do
					if bindInfo.Model and bindInfo.Model.Parent then
						bindInfo.Model:SetAttribute("Stopped", true)
					else
						if bindInfo.Events then
							for j, eventConn in ipairs(bindInfo.Events) do
								pcall(eventConn.Disconnect)
							end
						end
					end
				end
			end
			if targetDestroyConn then targetDestroyConn:Disconnect() end
		end
		targetDestroyConn = Target.Destroying:Once(targetCleanup)
	end

	local clonedModel = Model:Clone()

	for i,v in ipairs(clonedModel:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Anchored = false
			v.Massless = true
			v.CanCollide = false
			v.CanQuery = false
			v.CanTouch = false
		elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Light") or v:IsA("Trail") then
			v:SetAttribute("OGEnabled", v.Enabled)
		elseif v:IsA("Decal") and v.Name == "face" then
			v.Transparency = 1
		elseif v:IsA("Humanoid") or v:IsA("Script") or v:IsA("LocalScript") then
			v:Destroy()
		end
		if i % 500 == 0 then task.wait(.1) end
	end
	for i,v in ipairs(clonedModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end

	local BindInfo = {
		Target = Target,
		Model = clonedModel,
		Origins = {},
		Events = {},
		Offset = Config.Offset or CFrame.new(),
		Emit = Config.Emit,
		Tag = Tag,
		MaxTime = nil
	}
	if typeof(BindInfo.Offset) == "Vector3" then
		BindInfo.Offset = CFrame.new(Vector3.zero,BindInfo.Offset)
	end

	local BindOptionsModule = clonedModel:FindFirstChild("BindOptions")
	if BindOptionsModule and BindOptionsModule:IsA("ModuleScript") then
		local success, result = pcall(require, BindOptionsModule)
		if success and typeof(result) == "function" then
			local optSuccess, optErr = pcall(result, BindInfo)
			if not optSuccess then warn("BindService: Error executing BindOptions function:", optErr) end
		elseif not success then
			warn("BindService: Error requiring BindOptions:", result)
		end
	end

	clonedModel.Name = Tag
	clonedModel:SetAttribute("Delay",0)
	clonedModel:SetAttribute("BindService",true)
	clonedModel:SetAttribute("Stopped", false)

	local modelCleanupConn
	local function modelCleanup()
		if BindInfo.Events then
			for i, eventConn in ipairs(BindInfo.Events) do
				pcall(eventConn.Disconnect)
			end
			BindInfo.Events = nil
		end

		table.clear(BindInfo.Origins or {})
		BindInfo.Origins = nil
		BindInfo.Model = nil
		BindInfo.Target = nil

		if Target and BindService.List[Target] and BindService.List[Target][Tag] == BindInfo then
			BindService.List[Target][Tag] = nil
			if next(BindService.List[Target]) == nil then
				BindService.List[Target] = nil
			end
		end

		local delayTime = clonedModel:GetAttribute("DelayOverride") or (clonedModel:GetAttribute("DoDelay") and clonedModel:GetAttribute("Delay")) or 0
		task.delay(delayTime, function()
			if clonedModel and clonedModel.Parent then
				clonedModel:Destroy()
			end
		end)

		if modelCleanupConn then modelCleanupConn:Disconnect() end
	end
	modelCleanupConn = clonedModel:GetAttributeChangedSignal("Stopped"):Connect(function()
		if clonedModel:GetAttribute("Stopped") == true then
			modelCleanup()
		end
	end)
	clonedModel.Destroying:Once(modelCleanup)


	for i,v in ipairs(clonedModel:GetChildren()) do
		if v:IsA("Clothing") then
			v:SetAttribute("BindService",true)
			v.Name = Tag
			v.Parent = Target
			local clothingCleanupConn
			local function clothingCleanup()
				if v and v.Parent then v:Destroy() end
				if clothingCleanupConn then clothingCleanupConn:Disconnect() end
			end
			clothingCleanupConn = Target.Destroying:Once(clothingCleanup)
			table.insert(BindInfo.Events, clothingCleanupConn)
		end
	end

	local successBindTo, errBindTo = pcall(BindTo, clonedModel, Target, BindInfo)
	if not successBindTo then
		warn("BindService: Error during BindTo recursion:", errBindTo)
		modelCleanup()
		return nil
	end

	clonedModel.Parent = Target
	if not BindService.List[Target] then
		BindService.List[Target] = {}
	end
	BindService.List[Target][Tag] = BindInfo

	if BindInfo.Emit and BindInfo.MaxTime and BindInfo.MaxTime > 0 then
		task.delay(BindInfo.MaxTime, function()
			if BindInfo.Model and BindInfo.Model.Parent and BindInfo.Model:GetAttribute("Stopped") == false then
				BindInfo.Model:SetAttribute("Stopped", true)
			end
		end)
	end

	return BindInfo
end

if not BindService.Running then
	BindService.Running = true
	local function Added(v:ModuleScript)
		if v and v:IsA("ModuleScript") then
			local success, result = pcall(require, v)
			if success then
				BindService.Types[v.Name] = result
			else
				warn("BindService: Failed to require Type module:", v.Name, result)
			end
		end
	end
	local typesFolder = script:WaitForChild("Types")
	for i,v in ipairs(typesFolder:GetChildren()) do
		Added(v)
	end
	typesFolder.ChildAdded:Connect(Added)

	if RunService:IsClient() then
		local bindRenderEvent = script:FindFirstChild("BindRender")
		if bindRenderEvent and (bindRenderEvent:IsA("RemoteEvent") or bindRenderEvent:IsA("UnreliableRemoteEvent")) then
			bindRenderEvent.OnClientEvent:Connect(function(...)
				local Args = ConvertArgsServer(...)
				local success, err = pcall(BindService.Bind, BindService, unpack(Args))
				if not success then
					warn("BindService: Error processing BindRender event:", err)
				end
			end)
		else
			warn("BindService: BindRender RemoteEvent not found.")
		end
	end
end

return BindService
