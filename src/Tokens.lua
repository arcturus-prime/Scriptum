local token = {
	word = newproxy(),
	whitespace = newproxy(),

	literal = {
		stringSingle = newproxy(),
		stringMulti = newproxy(),
		number = newproxy(),
	},

	comment = {
		single = newproxy(),
		multi = newproxy(),
	},

	operator = {
		colon = newproxy(),
		length = newproxy(),
		dot = newproxy(),
		concat = newproxy(),
		add = newproxy(),
		sub = newproxy(),
		mul = newproxy(),
		div = newproxy(),
		mod = newproxy(),
		pow = newproxy(),
		floorDiv = newproxy(),
		equal = newproxy(),
		notEqual = newproxy(),
		lessThan = newproxy(),
		lessThanEqual = newproxy(),
		greaterThan = newproxy(),
		greaterThanEqual = newproxy(),
		assignment = newproxy(),
		assignmentAdd = newproxy(),
		assignmentSub = newproxy(),
		assignmentMul = newproxy(),
		assignmentDiv = newproxy(),
		assignmentMod = newproxy(),
		assignmentPow = newproxy(),
		assignmentConcat = newproxy(),
		optional = newproxy(),
	},

	seperator = {
		comma = newproxy(),
		braceStart = newproxy(),
		braceEnd = newproxy(),
		paraStart = newproxy(),
		paraEnd = newproxy(),
		bracketStart = newproxy(),
		bracketEnd = newproxy(),
		arrow = newproxy(),
	},
}

local name = {}

for k, v in token do

	if type(v) == "userdata" then
		name[v] = k
		continue
	end
	for l, m in v do
		name[m] = l
	end
end

return {
	token = token,
	name = name
}