--!nonstrict

local RunService = game:GetService("RunService")

local Conditions = {}

function CreateBranch(ModTable,Fold:Folder)
	local function Added(v)
		if v:IsA("Folder") then
			local Tab = CreateBranch({},v)
			ModTable[v.Name] = Tab
		elseif v:IsA("ModuleScript") then
			
			local Valid = false
			local Type = v:GetAttribute("Type")
			if Type == "Both" then
				Valid = true
			else
				if Type == "Server" and RunService:IsServer() then
					Valid = true
				elseif Type == "Client" and RunService:IsClient() then
					Valid = true
				end
			end
			if Valid then
				ModTable[v.Name] = require(v)
			end
		end
	end
	for i,v in Fold:GetChildren() do
		Added(v)
	end
	
	Fold.ChildAdded:Connect(Added)
	return ModTable
end

function FindConditionalMod(Tab,Types)
	if #Types == 0 then return end
	local Found = Tab[Types[1]]
	table.remove(Types,1)
	if Found then
		if #Types >= 1 then
			return FindConditionalMod(Found,Types)
		else
			return Found
		end
	else
		return
	end
end

function Conditions:SetupEntries(Object,Entries)
	assert(Object,"Object does not exist")
	assert(Entries,"Entries does not exist")
	
end

function Conditions:Check(Types,...)
	assert(Types,"Types does not exist")
	if typeof(Types) == "string" then
		Types = {"General",Types}
	else
		Types = table.clone(Types)
	end
local Mod = FindConditionalMod(Conditions.Modules,Types)
	if Mod then
		return Mod(...)
	end
end

function Conditions.WaitUntil(...)
	local Current = {...}
	local Type = Current[1]
	table.remove(Current,1)
	local Met = Current[#Current]
	local Args = Current
	if typeof(Met) == "boolean" then
		table.remove(Current,#Current)
	else
		Met = nil
	end
	 
	
	
	
	Met = (Met == true or Met == nil) and true or false
	repeat wait(.02) until Conditions.Check(Type,unpack(Args)) == Met
end

if not Conditions.Running then
	Conditions.Running = true
	Conditions.Modules = CreateBranch({},script)
	Conditions.Check = Conditions["Check"]
	Conditions.WaitUntil = Conditions["WaitUntil"]
end


return Conditions
