local token = {
	word = newproxy(),
	literalNumber = newproxy(),
	literalString = newproxy(),
	comment = newproxy(),
	multilineComment = newproxy(),
	multilineString = newproxy(),

	arrow = newproxy(),
	comma = newproxy(),
	optional = newproxy(),
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
	angledEnd = newproxy(),
	angledStart = newproxy(),
	lessThanEqual = newproxy(),
	greaterThanEqual = newproxy(),

	braceStart = newproxy(),
	braceEnd = newproxy(),
	paraStart = newproxy(),
	paraEnd = newproxy(),
	bracketStart = newproxy(),
	bracketEnd = newproxy(),

	assignment = newproxy(),
	assignmentAdd = newproxy(),
	assignmentSub = newproxy(),
	assignmentMul = newproxy(),
	assignmentDiv = newproxy(),
	assignmentMod = newproxy(),
	assignmentPow = newproxy(),
	assignmentConcat = newproxy(),
}

local name = {}

for k, v in token do
	name[v] = k
end

return {
	token = token,
	name = name
}