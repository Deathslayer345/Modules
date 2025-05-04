

local GIndex = {}

setmetatable(_G,{
	__index = function(tab,index)
		if GIndex[index] then
			return GIndex[index]
		end
	end,
	__newindex = function(tab,index,val)
		GIndex[index] = val
		return
	end,
})

return {}