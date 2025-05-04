
return function(Types,OverallEnums)
	repeat wait(.03)

	until OverallEnums.Platform
local Exclusive = {
	ButtonA = "Gamepad",
	ButtonB = "Gamepad",
	ButtonY = "Gamepad",
	ButtonX = "Gamepad",
DPadUp = "Gamepad",
DPadRight = "Gamepad",
DPadDown = "Gamepad",
DPadLeft = "Gamepad"
}



local function CreateEntry(Entries)

	local DefaultEntry = {
		Name = "",
		Value = 0,
			Platform = "Keyboard"
	}
	if not Entries then return DefaultEntry end
	for i,v in Entries do
		DefaultEntry[i] = v
	end
	return DefaultEntry
end

local Enums = {

	

}
local Amount = 0
for i,v in Enum.KeyCode:GetEnumItems() do
	Amount += 1
	local EnumT
		if v.EnumType == Enum.UserInputType.Gamepad1 or v.EnumType == Enum.UserInputType.Gamepad2 or v.EnumType == Enum.UserInputType.Gamepad3 or v.EnumType == Enum.UserInputType.Gamepad4 or v.EnumType == Enum.UserInputType.Gamepad5 or v.EnumType == Enum.UserInputType.Gamepad6 or v.EnumType == Enum.UserInputType.Gamepad7 or v.EnumType == Enum.UserInputType.Gamepad8 then
			EnumT = "Gamepad"
		end
		if v.EnumType == Enum.UserInputType.MouseButton1 or v.EnumType == Enum.UserInputType.MouseButton2 or v.EnumType == Enum.UserInputType.MouseButton3 or v.EnumType == Enum.UserInputType.MouseMovement or v.EnumType == Enum.UserInputType.MouseWheel then
			EnumT = "Mouse"
		end 
	local Entry = CreateEntry({
		Name = v.Name,
		Value = Amount,
		
			Platform = v.EnumType == Enum.UserInputType.Keyboard and "Keyboard"  or EnumT  or "Keyboard"
	})
	if Exclusive[v.Name] then
			Entry.Platform = Exclusive[v.Name]
	end
	Enums[v.Name] = Entry
end

	for i,v in Enum.UserInputType:GetEnumItems() do
		Amount += 1
		local Entry = CreateEntry({
			Name = v.Name,
			Value =Amount,
			Platform = "Mouse"
		})
		if Exclusive[v.Name] then
			Entry.Platform = Exclusive[v.Name]
		end
		Enums[v.Name] = Entry
	end

local Funcs = {
	Construct = function(Name:string)
		return Enums[Name]
		
	end,
	
}
return {
	Enums = Enums,
	Funcs = Funcs
	
}
end