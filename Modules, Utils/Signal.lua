return function(Object:Instance,Index)
	if typeof(Object) ~= "Instance" then 
		error(debug.traceback("Object must be an instance"))
		return
	end
	Index = typeof(Index) == "string" and Object:FindFirstChild(Index) or Index
	if Index and typeof(Index) == "Instance" then
		if not Index:IsA("ModuleScript") then
			Index = script.SignalObject
		end
	end
	if not Index then
		Index = script.SignalObject
	end
	local SignalObject = Object:FindFirstChild("SignalObject")
	if not SignalObject then
		SignalObject = Index:Clone()
		SignalObject.Name = "SignalObject"
		SignalObject.Parent = Object
		
	end
	if SignalObject.Name ~= "SignalObject" then
		SignalObject.Name = "SignalObject"
	end
	local Mod = require(SignalObject)

	return Mod,SignalObject
end