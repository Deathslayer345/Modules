
local Array = {
	TableIndexes = {}
}

local convertTypes = {
	["number"] = "NumberValue",
	["string"] = "StringValue",
	["boolean"] = "BoolValue",
	["Instance"] = "ObjectValue",
	["CFrame"] = "CFrameValue"
}

function CheckWait(num:number)
	if num % 100 == 0 and num > 0 then
		task.wait(.1)
	end
end
function Array:CountTable(Table:{},Settings)
	assert(typeof(Array) == "table","Array val not table")
	Settings = Settings or {}

	local NumbersOnly = Settings.NumbersOnly or false
	local NonRecursive = Settings.NonRecursive or false
	local Count = 0
	for i,v in Table do
		if NumbersOnly and typeof(i) == "number" or not NumbersOnly then
			Count += 1

			CheckWait(Count)
		end
		if typeof(v) == "table" and not NonRecursive then
			Count += Array:CountTable(v,Settings)
		end
	end
	return Count
end

function Array:Compare(Array1:{any},Array2:{any})
	if Array1 == Array2 then return true end
	if typeof(Array1) ~= typeof(Array2) then return false end
	if typeof(Array1) == "table" then
		local IndexesChecked=  {}
		local Valid = true
		for i,v in Array1 do
			IndexesChecked[i] = true
			Valid = Array:Compare(v,Array2[i])
			if not Valid then return false end
		end
		for i,v in Array2 do
			if not IndexesChecked[i] then
				return false
			end
		end
		if Valid then return true end
	end
	return false
end

function Array:Override(Array1,Array2)
	if typeof(Array1) ~= "table" then
		return Array2
	end
	if typeof(Array2) ~= "table" then
		return Array1
	end
	for i,v in Array2 do
		if typeof(Array1[i]) == "table" then
			Array:Override(Array1[i],v)

		elseif typeof(Array1[i]) == "function" and typeof(v) == "function" then
			Array1[i] = function(...)
				Array1[i](...)
				v(...)
			end
		else
			Array1[i] = v
		end
	end

end



function Array:AddCleanupFunc(Array2,Cleanups)
	if not Array2 or not Cleanups then return end
	if typeof(Cleanups) == "function" then
		Cleanups = {Cleanups}
	end
	if typeof(Cleanups) ~= "table" then return end
	local Cleanup = Array2.Cleanup
	if typeof(Cleanup) == "table" then
		for i,v in Cleanups do
			table.insert(Cleanup,v)
		end
	elseif typeof(Cleanup) == "function" then
		table.insert(Cleanups,Cleanup)
		Array.Cleanup = Cleanups
	else
		Array.Cleanup = Cleanups
	end
end


function Array:GetCleanup(Array2)
	if not Array2 then return end
	local Funcs = {}
	for i,v in Array2 do
		if typeof(v) == "table" then
			local NewFuncs = Array:GetCleanup(v)
			for i,v in NewFuncs do
				table.insert(Funcs,v)
			end
		elseif i == "Cleanup" and (typeof(v) == "function" or typeof(v) == "table") then
			if typeof(v) == "table" then
				local NewFuncs = Array:GetCleanup(v)
				for i,v in NewFuncs do
					table.insert(Funcs,v)
				end
			else
				table.insert(Funcs,v)
			end

		end
	end
	return Funcs
end
function Array:Cleanup(Array2,Cleaning)
	if not Array2 then return end
	local ReportedFunc


	if typeof(Array2) == "table" then
		if Array2.Cleaning then return end
		Array2.Cleaning = true
		if not Cleaning then
			local Funcs = Array:GetCleanup(Array2)
			for i,v in Funcs do
				v()
			end
		end
		for i,v in Array2 do
			if typeof(v) == "table" then
				Array:Cleanup(Array2,true)
			elseif typeof(v) == "RBXScriptConnection" then
				v:Disconnect()
			elseif typeof(v) == "Instance" then
				if v:IsA("AnimationTrack") then
					v:Stop()
				end
				pcall(function()
					v:Destroy()
				end)
			elseif i == "Cleanup" and (typeof(v) == "function" or typeof(v) == "table") then
				ReportedFunc = v
			end
		end


		table.clear(Array)
		Array.Cleaned = true
	end
end



function Array:SetIndex(ArrayInst:{},Index:string,Value,Func)
	if not Index  then
		--print("Index doesnt exist",Index)
		return
	end
	if not ArrayInst then
		--print("Array doesnt exist")
		return
	end

	local function FindInst()
		local Found
		local Index2 

		for i,v in Array.TableIndexes do
			if v.Table == ArrayInst and v.Index == Index then
				Found = v 
				Index2 = i
			end
		end
		return Found,Index2
	end
	local Found = FindInst()
	if Found and Found.Task then
		task.cancel(Found.Task)
	end

	if not Found then
		Found = {
			Table = ArrayInst,
			Index =  Index
		}
		table.insert(Array.TableIndexes,Found)
	end
	if Func then
		Found.Task = spawn(function()
			if not Func() then
				repeat task.wait(.04) until Func()
			end
			ArrayInst[Index] = Value
			local Found,Index = FindInst()
			if Index then
				Array.TableIndexes[Index] = nil
			end
			return
		end)
	else
		ArrayInst[Index] = Value
		local Found,Index = FindInst()
		if Index then
			Array.TableIndexes[Index] = nil
		end
	end
end
function Array:arrayToFolder(array:{}):Folder?
	--assert(typeof(array) == "table","array is not an array like it should be")
	if not array then return end
	if convertTypes[typeof(array)] then
		local newInstance:NumberValue = Instance.new(convertTypes[typeof(array)])
		newInstance.Value = array
		return newInstance
	end
	local folder:Folder = Instance.new("Folder")
	for i,v in array do
		if typeof(v) == "table" then
			if v.Type == "Object" then
				local newInstance:NumberValue = Instance.new("ObjectValue")
				newInstance.Name = i 
				if v.Value  then
					newInstance.Value = v.Value
				end
				newInstance.Parent = folder
				continue
			end
			local tempFolder = Array:arrayToFolder(v)
			tempFolder.Name = i
			tempFolder.Parent = folder
		elseif typeof(v) == "Color3" then
			local V1,V2,V3 = Instance.new("NumberValue"),Instance.new("NumberValue"),Instance.new("NumberValue")
			V1.Name = i.."_r"
			V1.Value = v.R
			V2.Name = i.."_g"
			V2.Value = v.G
			V3.Name = i.."_b"
			V3.Value = v.B
			V1.Parent = folder
			V2.Parent = folder
			V3.Parent = folder
		elseif convertTypes[typeof(v)] then
			local newInstance:NumberValue = Instance.new(convertTypes[typeof(v)])
			newInstance.Name = i 
			newInstance.Value = v
			newInstance.Parent = folder
		end
	end
	return folder
end

function Array:folderToArray(folder:Folder)
	assert(typeof(folder) == "Instance","folder argument is not a Folder")
	local array1 = {}
	for i,v in folder:GetChildren() do
		if #(v:GetChildren()) ~= 0 or v:IsA("Folder") then
			array1[v.Name] = Array:folderToArray(v)
		elseif convertTypes[typeof(v.Value)] then
			array1[v.Name] = v.Value
		end
	end
	return array1
end
return Array
