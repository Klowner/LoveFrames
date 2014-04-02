-- love version library
loveframes.loveversion = {}

local _love_version
local _version_conditions = {} -- for caching LoveVersionIs expressions, they're somewhat costly

--[[---------------------------------------------------------
	- func: loveframes.loveversion.LoveVersion()
	- desc: returns major, minor, revision values for current love version
--]]---------------------------------------------------------
function loveframes.loveversion.GetLoveVersion()
	local getVersion = love.getVersion
	local version = _love_version

	if version then
	    return unpack(version)
	end

	if getVersion then
		version = {getVersion()}
	else
		version = {}
		for v, _ in string.gmatch(love._version, "(%d)") do
			table.insert(version, tonumber(v))
		end
	end

	_love_version = version -- cache result
	return unpack(version)
end


--[[---------------------------------------------------------
	- func: loveframes.loveversion.LoveVersionIs(expression)
	- desc: returns boolean result of version matching expression.
			Expression examples: "0.9.0", ">0.9.0", "0.8.*"
--]]---------------------------------------------------------
function loveframes.loveversion.LoveVersionIs(expr)
	local cache = _version_conditions
	local match = cache[expr]

	if match ~= nil then
		return match
	end

	local version
	local curr_version_t = {loveframes.loveversion.GetLoveVersion()}
	local op = string.sub(expr, 0, 1)
	local comparitor

	if op == '>' or op == '<' then
		version = string.sub(expr, 1)
		if op == '>' then
			comparitor = function (a,b) return a == b and 0 or a > b and 1 or -1 end
		else
			comparitor = function (a,b) return a == b and 0 or a < b and 1 or -1 end
		end
	else
		version = expr
		comparitor = function (a,b) return ('*' == b or a == b) and 1 or -16 end
	end

	-- split version from expression into numeric parts
	local expr_version_t = {}
	for v, _ in string.gmatch(version, "(%d)") do
		table.insert(expr_version_t, tonumber(v) or '*')
	end

	local result = 0
	for i = 1, #expr_version_t do
		result = result + comparitor(curr_version_t[i], expr_version_t[i]) * (2^(3-i))
	end

	result = result > 0
	cache[expr] = result
	return result
end
