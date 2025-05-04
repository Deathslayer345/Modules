return function (number : number, CanUseComma) : string
	
	local default = "%1.%2"
	

	local Amount = math.floor(math.log(number,1000))
	local Str = ""
	
	Str = Str..tostring(math.floor(number/ 1000^(Amount)))
	number -= math.floor(number/ 1000^(Amount))
	for i = 1,Amount - 1 do
		Str = Str..","..tostring(math.floor(number - (number/ 1000^(Amount - i)) ))
		print(Str)
		number -= (number/ 1000^(Amount - i))
	end
	
    return Str--tostring(number):gsub("(%d)(%d%d%d)$", default)
end