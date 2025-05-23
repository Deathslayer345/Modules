--[[

]]

local RepStorage = game:GetService("ReplicatedStorage")

local Modules = RepStorage:WaitForChild("Modules")

local Utils = Modules:WaitForChild("Utils")


local Networker = require(Utils:WaitForChild("Networker"))

local HitboxObject = {
	Hitboxes = {},
	Funcs = {},
	HitboxIndexes = {},
	UpdateTime = 0,
	SizeMod = Vector3.one * 5,
	FilterFunc = function()
		return true
	end,
}

-- HitboxObject:RestartType: Restart a specific type of hitbox.
-- 
-- Parameters:
--      Type: string - The type of hitbox to restart.
-- Returns:
--      None
function HitboxObject:RestartType(Type:string)
	local Func = HitboxObject.HitboxIndexes[Type] 
	if Func then
		--task.wait()
		Func(HitboxObject)
	end
end

-- HitboxObject:CheckIfHitbox: Check if the given object is a hitbox.
-- 
-- Parameters:
--      Hitbox: any - The object to check.
-- Returns:
--      boolean - True if the object is a hitbox, false otherwise.
function HitboxObject:CheckIfHitbox(Hitbox)
	if typeof(Hitbox) ~= "table" then return false end
	return Hitbox.IsHitbox == true and true or false
end

-- HitboxObject:Filter: Set a filter function for hitboxes.
-- 
-- Parameters:
--      Func: function - The filter function to set.
-- Returns:
--      None
function HitboxObject:Filter(Func)
	if typeof(Func) == "function" then
		HitboxObject.FilterFunc = Func
	end
end

-- HitboxObject:Create: Create a new hitbox with the given function.
-- 
-- Parameters:
--      Func: function - The function to associate with the new hitbox.
-- Returns:
--      None
function HitboxObject:Create(Func)

	if typeof(Func) == "function" then
		local FuncReq = {
			Func = Func,
			Doing = false
		}
		setmetatable(FuncReq,{
			__call = function(tab,...)
				return rawget(tab,"Func")(...)
			end,
		})
		table.insert(HitboxObject.Funcs,FuncReq)
	end



end
local Types = {
	"Character",
	"Area"
}

-- ChangeType: Change the type of a hitbox.
-- 
-- Parameters:
--      tab: table - The table containing the hitbox.
--      index: any - The index of the hitbox.
--      val: any - The new type value.
-- Returns:
--      None
local function ChangeType(tab,index,val)
	--print(typeof(val))
	--print(val)
	--print(_G.HitboxTypes)
	if typeof(val) == "string" and table.find(Types,val) then
		rawset(tab,"Type",val)
		script:SetAttribute("Type",val)
		--task.wait()
		HitboxObject:RestartType(val)
		--HitboxObject("Restart")
	end
end
local CommonMetatable = {
	__index = function(tab,index)
		if rawget(tab,"_DESTROYED") then
			return
		end
		local Hitboxes = rawget(tab,"Hitboxes")
		if Hitboxes[index] then
			return Hitboxes[index]
		else
			return rawget(HitboxObject,index)
		end

	end,
	__newindex = function(tab,index,val)
		if rawget(tab,"_DESTROYED") then
			return
		end
		if index == "_DESTROYED" and val == true then
			rawset(tab,index,true)
			for i,v in rawget(tab,"Hitboxes") do

			end
			for i,v in tab do
				if i ~= "_DESTROYED" then
					rawset(tab,i,nil)
				end
			end
		end
		if index == "Hitboxes" then
			print("Stop yo goofy ass fuckin w the shit")
		elseif index == "Type" then
			local Get = rawget(tab,index)

			if Get ~= val then
				ChangeType(tab,index,val)
			end
		elseif index == "Runtime" then
			local get = rawget(tab,index)
			if get then
				task.cancel(get)
			end
			if typeof(val) == "thread" then
				rawset(tab,index,val)
			end
			return true
		else
			--print(tab,index,val)
			local Index = rawget(tab,index)

			if index == "Running" then
				rawset(tab,index,val)
			elseif index == "CreateFunc" and typeof(val) == "function" then
				return HitboxObject:Create(val)
			elseif index == "CharStorage" then
				rawset(tab,"CharStorage",val)
			else
				rawset(tab,index,val)
			end

		end

	end,
	__call = function(tab,...)
		local Args = {...}
		if Args[1] == "Restart" then
			local Tab = rawget(tab,"Hitboxes")
			for i,v in Tab do
				v["_DESTROYED"] = true
			end
			table.clear(Tab)
		elseif typeof(Args[1]) == "function" then
			return HitboxObject:Create(Args[1])
		end
	end,

}

-- EditMetatable: Edit the metatable of the HitboxObject.
-- 
-- Parameters:
--      Edits: table - The table containing the edits to apply.
-- Returns:
--      None
function EditMetatable(Edits)
	local Clone = table.clone(CommonMetatable)
	--print(Clone)
	--print(Edits)
	setmetatable(HitboxObject,{})

	--task.wait()
	for i,v in Edits do
		Clone[i] = v
	end
	setmetatable(HitboxObject,Clone)
end
HitboxObject.EditMetatable = EditMetatable

-- HitboxObject:Call: Call a hitbox function by name.
-- 
-- Parameters:
--      HitboxName: string - The name of the hitbox function to call.
--      ...: any - Additional arguments to pass to the hitbox function.
-- Returns:
--      None
function HitboxObject:Call(HitboxName:string,...)
	local Hitbox = HitboxObject[HitboxName]
	if Hitbox then
		Hitbox(...)
	else
		print(debug.traceback(`Hitbox {HitboxName} does not exist`,10))

	end
end



if not HitboxObject.Running then
	HitboxObject.Running = true
	EditMetatable({})
	--print(HitboxObject)
	
	local function Added(v:ModuleScript)
		if v:IsA("ModuleScript") then
			local Req = require(v)
			if typeof(Req) == "function" then
				HitboxObject.HitboxIndexes[v.Name] = Req
			else
				HitboxObject[v.Name] = Req
			end
		end
	end
	for i,v in script:GetChildren() do
		Added(v)
	end
	local Ev = script.ChildAdded:Connect(Added)
	HitboxObject.Cleanup = function()
		HitboxObject._DESTROYED = true
	end
	script.Destroying:Once(function()
		Ev:Disconnect()
		HitboxObject.Cleanup()
	end)
	--print(HitboxObject)

end

return HitboxObject
