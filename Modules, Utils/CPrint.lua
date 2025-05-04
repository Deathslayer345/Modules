local RunService = game:GetService("RunService")

function Func(func,...)
	if not RunService:IsStudio() then return end
	func(...)
end

_G.print = function(...)
	Func(print,...)
end

_G.warn = function(...)
	Func(warn,...)
end

_G.error = function(...)
	Func(error,...)
end

return {}