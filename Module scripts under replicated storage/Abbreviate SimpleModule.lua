local SuffixList = require(script.Parent:WaitForChild('Suffixes'))
local AddCommas = require(script.Parent:WaitForChild('Add Commas'))
local AddCommasIfUnder = 1000

return function(value : number, idp : number, UseComma) : string
	idp = idp or 0
	if value < AddCommasIfUnder or UseComma then
		
		if UseComma then
		
			local formatted, k = value, nil
				while true do  
				formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
				if (k==0) then
					break
				end
			end
			return formatted
			
		end
		
		local formatted, k = value, nil
		while true do  
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
		
		--return AddCommas(value, UseComma)
	end
	local exp = math.floor(math.log(math.max(1, math.abs(value)), 1000)) 
	--print(value,exp)
	local suffix = SuffixList[exp] or ("e+" .. exp)
	local norm = math.floor(value * ((10 ^ idp) / (1000 ^ exp))) / (10 ^ idp)
	local Val =  math.floor(math.log(math.max(1, math.abs(value)), 10)) 
	return ("%." .. idp .. "f%s"):format(norm, suffix)..(Val > 0 and `({Val - 1} Zeroes)` or "")
end