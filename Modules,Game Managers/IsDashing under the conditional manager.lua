
return function(CharConfig)
	if not CharConfig then return end
	local Data = CharConfig.Data
	if not Data or not Data.CharStats then return end
	return  CharConfig.IsDashing
	end
