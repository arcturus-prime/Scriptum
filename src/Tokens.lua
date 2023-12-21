export type Token = {
	kind: any,
	value: any?,
}

local token = {
	word = newproxy(),
	whitespace = newproxy(),
	
	string = newproxy(),
	number = newproxy(),

	comment = newproxy(),

	colon = newproxy(),
	length = newproxy(),
	dot = newproxy(),
	concat = newproxy(),
	ellipses = newproxy(),
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

	comma = newproxy(),
	braceStart = newproxy(),
	braceEnd = newproxy(),
	paraStart = newproxy(),
	paraEnd = newproxy(),
	bracketStart = newproxy(),
	bracketEnd = newproxy(),
	arrow = newproxy(),
}

local name = {}

for k, v in token do
	name[v] = k
end


return {
	token = token,
	name = name
}