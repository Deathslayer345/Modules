
-- Networker module for handling network communication between client and server in Roblox.

-- Services
local HTTPService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Networker table
local Networker = {
	Ports = {}, -- Table to store network ports
	PastSends = {} -- Table to store past sends
}

-- Function to get a port by type
-- @param PortType: string - The type of port to get
-- @return table - The port(s) corresponding to the given type
function GetPort(PortType)
	if PortType == "All" then
		return Networker.Ports
	end
	if Networker.Ports[PortType] then
		return Networker.Ports[PortType]
	end
end

-- Function to create a new port
-- @param Port: string - The name of the port
-- @param Func: function - The function to associate with the port
-- @param Config: table - Configuration options for the port
-- @return table - The created port
function CreatePort(Port, Func, Config)
	if Networker.Ports[Port] then
		if not Config.Replace then
			return Networker.Ports[Port]
		else
			table.clear(Networker.Ports[Port])
			Networker.Ports[Port] = nil
		end
	end
	Config = Config or {}
	local RemoteTypes = {
		"Function",
		"Event",
		"FastEvent"
	}
	local CurrentPort = {
		PortType = Port,
		Type = Networker.Type,
		List = Config.List or {},
		ListType = Config.ListType or "Exclude"
	}

	for i,v in RemoteTypes do
		local Clone = script:FindFirstChild(v)
		if Clone then
			local Fold = script.PortSend:FindFirstChild(v)
			if Fold then
				if RunService:IsClient() then
					--print(Port,"Started")
					Fold:WaitForChild(Port,.1) 
					--print(Port,"Ended")
				end
				if not Fold:FindFirstChild(Port) then

					Clone = Clone:Clone()
					Clone.Name = Port
					Clone.Parent = Fold
				end

			end
		end
	end
	if typeof(Func) == "function" then
		CurrentPort.Func = Func
	else
		return nil
	end
	Networker.Ports[Port] = CurrentPort
	return CurrentPort
end

-- Prefixes for instance types
local Prefixes = {
	Player = "Player",
	Model = "Model"
}

-- Function to convert an instance to an ID
-- @param Inst: Instance - The instance to convert
-- @return string - The ID of the instance
function ConvertInstanceToID(Inst)
	if not Inst then return "" end
	local Prefix = "Inst"
	for i, v in Prefixes do
		if Inst:IsA(i) then
			Prefix = v
			break
		end
	end
	return Prefix .. Inst.Name
end

-- Function to convert an instance to a path
-- @param Inst: Instance - The instance to convert
-- @return table - The path of the instance
function SetUID(Inst:Instance)
	if Inst then
		if not Inst:GetAttribute("UniqueId") then
			Inst:SetAttribute("UniqueId",HTTPService:GenerateGUID())
		end
	end
end
function Networker.ExtendFullName(Inst:Instance)
	local Entries = Inst:GetAttribute("UniqueId") 
	if not Entries then
		SetUID(Inst)
	end
	Entries = Inst:GetAttribute("UniqueId") 
	local NewInst
	local Amnt = 0
	repeat
		if not NewInst then
			NewInst = Inst
		else
			NewInst = NewInst.Parent
			if NewInst and not NewInst:GetAttribute("UniqueId") and RunService:IsServer() then
				SetUID(NewInst)
			end
			if NewInst and NewInst:GetAttribute("UniqueId") then

				Entries = `{NewInst:GetAttribute("UniqueId")}.{Entries}`
			end
		end
Amnt += 1 
if Amnt % 90 ==0 and Amnt > 0 then
			wait(.03)
end
	until not NewInst
	return Entries
end
function InstToPath(Inst)
	SetUID(Inst)
	local UID = Inst:GetAttribute("UniqueId")

	return {
		Path =Networker.ExtendFullName(Inst),
		ID = UID
	}
end

-- Function to convert a path to an instance
-- @param Name: string - The path to convert
-- @return Instance - The instance corresponding to the path
function PathToInst(Name,ID:string)
	--	print(Name)
	local Args = string.split(Name, ".")
	local Current = game
	local Temp = Current
	local CHAdd:RBXScriptSignal
	repeat
		Temp = nil
		if CHAdd then
			CHAdd:Disconnect()
		end
		
		for i,v in Current:GetChildren() do
			--print(v,v:GetAttribute("UniqueId"), Args[1])
			if i % 100 == 0 and i > 0 then
				task.wait(.1)
			end
			if v:GetAttribute("UniqueId") == Args[1] then
				Temp = v
				break
			end
		end

		if Temp then
			Current = Temp
		else
			local Found
			CHAdd =Current.ChildAdded:Connect(function(v)
				if v:GetAttribute("UniqueId") == Args[1] then
					Found = v
				end
			end)
			local OS = os.clock()
			repeat wait(.1) until Found or os.clock() >= OS + 300
			CHAdd:Disconnect()
			Current = Found
		end

		table.remove(Args, 1)
	until #Args == 0 or not Current
	return Current
end

-- Function to convert arguments to paths
-- @param ... - The arguments to convert
-- @return table - The converted arguments
function ConvertArgs(...)
	local Args = { ... }
	for i, v in Args do
		if typeof(v) == "Instance" then
			SetUID(v)
			Args[i] = InstToPath(v)
		end
	end
	return Args
end

-- Function to convert arguments from paths to instances
-- @param ... - The arguments to convert
-- @return table - The converted arguments
function ConvertArgsServer(...)
	local Args = { ... }
	for i, v in Args do
		if typeof(v) == "table" and v.Path then
			Args[i] = PathToInst(v.Path,v.ID)
		end
	end
	return Args
end

-- Method to create a port
-- @param Port: string - The name of the port
-- @param Func: function - The function to associate with the port
-- @param Config: table - Configuration options for the port
function Networker:CreatePort(Port, Func, Config)
	if not Port then return end
	Config = Config or {}
	local Result = CreatePort(Port, Func, Config)
	if RunService:IsClient() then
		script:WaitForChild("CreatePort"):FireServer(Port)
	end
	if Result then
		--	print(Port.."Created")
		-- Port created successfully
	end
end

-- Method to modify a port
-- @param Port: string - The name of the port
-- @param Mods: table - Modifications to apply to the port
function Networker:ModifyPort(Port, Mods)
	Mods = Mods or {}
	if not Networker.Ports[Port] then
		return
	end
	local Result = Networker.Ports[Port]
end

-- Client-side method to get port information
-- @param PortType: string - The type of port to get information for
-- @return table - The port information
if RunService:IsClient() then
	function Networker:GetPortInfo(PortType)
		return script.ReturnPortInfo:InvokeServer(PortType)
	end
else
	-- Server-side method to get port information
	-- @param Receiver: Player - The player to receive the information
	-- @param PortType: string - The type of port to get information for
	-- @return table - The port information
	function Networker:GetPortInfo(Receiver, PortType)
		return script.ReturnPortInfo:InvokeClient(Receiver, PortType)
	end
end

-- Server-side method to send port data
-- @param Port: string - The name of the port
-- @param SendType: Enum - The type of send operation
-- @param ... - The data to send
if RunService:IsServer() then
	function Networker:SendPortData(Port, SendType, ...)
		SendType = SendType or _G.Enums.NetworkSendType.Function
		local Args = { ... }
		local Remote = script.PortSend:FindFirstChild(typeof(SendType) == "string" and SendType or SendType.Name)
		if not Remote then

			error("SendType is not valid!")
			return
		end
		local Remote2 = Remote
		--print(Remote:GetChildren(),Port)
		Remote = Remote:FindFirstChild(Port)
		if not Remote then
			task.wait(.1)--error(Port.." Has no valid remote of this type!")
			Remote = Remote2:FindFirstChild(Port)	
		end

		if not Remote then
			error(Port.." Has no valid remote of this type! Type:"..SendType.Name)
			
		end

		if typeof(Args[1]) == "Instance" then
			Args[1] = { Args[1] }
		end
		if not Args[1] then
			Args[1] = game.Players:GetPlayers()
		end
		local NewArgs = { ... }
		local function Send(v)
			local PortInfo = Networker:GetPortInfo(v, Port)
			if PortInfo then
				local Args = ConvertArgs(unpack(NewArgs))
				if Remote:IsA("RemoteFunction") then
					return Remote:InvokeClient(v, Port, unpack(Args))
				elseif Remote:IsA("RemoteEvent") or Remote:IsA("UnreliableRemoteEvent") then
					Remote:FireClient(v, Port, unpack(Args))
				end
			end
		end
		for i, v in Args[1] do
			pcall(function()
				Send(v)
			end)
		end
	end
	script:WaitForChild("CreatePort").OnServerEvent:Connect(function(plr,port)
		if not port then return end
		
		if not script:WaitForChild("PortSend").Function:FindFirstChild(port) then
		Networker:CreatePort(port,function(Player,Options)
			
		end,{},
		{})
		end
		
	end)
else
	-- Client-side method to send port data
	-- @param Port: string - The name of the port
	-- @param SendType: Enum - The type of send operation
	-- @param ... - The data to send
	function Networker:SendPortData(Port, SendType, ...)
		SendType = SendType or _G.Enums.NetworkSendType.FastEvent
		local Args = { ... }
		local Remote = script:WaitForChild("PortSend"):FindFirstChild(typeof(SendType) == "string" and SendType or SendType.Name)
		--print(Remote,Port,SendType,Remote:GetChildren())
		if not Remote then
			error("SendType is not valid!")
			return
		end
		local Remote2 = Remote
		--print("Pt2")
		Remote = Remote:FindFirstChild(Port)

		if not Remote  then
			--task.wait(.1)--error(Port.." Has no valid remote of this type!")
			if RunService:IsClient() then
				--print(Remote,"Dont exist")
				pcall(function()
				Remote = Remote2:WaitForChild(Port,.5)

				end)
			else
				error(Port.." Has no valid remote of this type! Type:"..SendType.Name)
				return	
			end
		end

if not Remote then 
--	error("No remote of "..Port)
	return end
		if Remote:IsA("RemoteFunction") then
			local Args = { ... }
			local Success, result = xpcall(function()
				return Remote:InvokeServer(Port, unpack(Args))
			end, function(Error)
				if Error then
					warn(debug.traceback(Error, 10))
				end
			end)
			if not Success then
				warn(result)
			end
			return result
		elseif Remote:IsA("RemoteEvent") or Remote:IsA("UnreliableRemoteEvent") then
			Remote:FireServer(Port, ...)
		end
	end
end

-- Initialization of the Networker module
if not Networker.Running then
	Networker.Running = true
	if RunService:IsServer() then
		Networker.Type = "Server"
	else
		Networker.Type = "Client"
	end
	if Networker.Type == "Server" then
		local Amount = 0
--[[
		for i,v in game:GetDescendants() do
			Amount += 1
			if Amount >= 1000 then
				task.wait(.03)
				Amount = 0
			end
			pcall(function()
				SetUID(v)
			end)
		end
		game.DescendantAdded:Connect(function(v)
			pcall(function()
				SetUID(v)
			end)
		end)
]]
		script:WaitForChild("ReturnPortInfo").OnServerInvoke = function(Player, PortType, ...)
			local PortInfo = GetPort(PortType)
			if not PortInfo then
				return nil, "ERROR:NO PORT"
			end
			return PortInfo
		end
		local function RemoteSend(v, Player, Port, ...)
			local PortInfo = GetPort(Port)
			if not PortInfo or not PortInfo.Func then
				return
			end
			local Result = table.find(PortInfo.List, Player)
			if Result and PortInfo.ListType == "Exclude" or not Result and PortInfo.ListType == "Include" then
				return
			end
			local Args = ConvertArgsServer(...)
			local Results = { PortInfo.Func(Player, unpack(Args)) }
			Args = table.clone(Args)
			if v:IsA("RemoteFunction") then
				return unpack(Results)
			end
		end
		local function RemAdded(v)
			if v:IsA("RemoteFunction") then
				v.OnServerInvoke = function(...)
					--	print(v:GetFullName(),...)
					return RemoteSend(v, ...)
				end
			elseif v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
				v.OnServerEvent:Connect(function(...)
					RemoteSend(v, ...)
				end)
			end
		end
		for i, v in script:WaitForChild("PortSend"):GetDescendants() do

			RemAdded(v)
		end
		script:WaitForChild("PortSend").DescendantAdded:Connect(RemAdded)
	elseif RunService:IsClient() then
		script:WaitForChild("ReturnPortInfo").OnClientInvoke = function(PortType, ...)
			local PortInfo = GetPort(PortType)
			if not PortInfo then
				return nil, "ERROR:NO PORT"
			end
			return PortInfo
		end
		local function RemoteSend(v, Port, PortId, ...)
			local PortInfo = GetPort(Port)
			--print(PortInfo)
			if not PortInfo or not PortInfo.Func then
				return
			end
			local Result = table.find(PortInfo.List, PortId)
			if Result and PortInfo.ListType == "Exclude" or not Result and PortInfo.ListType == "Include" then
				return
			end
			local Results = { PortInfo.Func(...) }
			if v:IsA("RemoteFunction") then
				return unpack(Results)
			end
		end
		local function Added(v:Instance)

			if v:IsA("RemoteFunction") then
				v.OnClientInvoke = function(...)
					local Args = ConvertArgsServer(...)
					return RemoteSend(v, unpack(Args))
				end
			elseif v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") then
				v.OnClientEvent:Connect(function(...)
					local Args = ConvertArgsServer(...)
					task.spawn(function()
						RemoteSend(v, unpack(Args))
					end)
				end)
			end

		end
		for i, v in script:WaitForChild("PortSend"):GetDescendants() do
			Added(v)
		end
		script:WaitForChild("PortSend").DescendantAdded:Connect(Added)
	end
end

-- Return the Networker module
return Networker
