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

local tokenName = {}

for k, v in token do
	tokenName[v] = k
end


export type Token = {
	kind: any,
	value: any?,
}

export type Info = {
	code: string,
	index: number,
}


local function isNotUnescapedChar(code: string, i: number, ending: string)
	return string.sub(code, i, i) ~= ending or (string.sub(code, i - 1, i - 1) == "\\" and string.sub(code, i - 2, i - 1) ~= "\\\\")
end

local function consumeWord(info: Info, tokens: { Token })
	local _, e = string.find(info.code, "%w+", info.index)

	table.insert(tokens, { kind = token.word, value = string.sub(info.code, info.index, e) })
	info.index = e
end

local function consumeNumber(info: Info, tokens: { Token })
	local s, e
	if string.sub(info.code, info.index, info.index + 1) == "0x" then
		s, e = string.find(info.code, "[0-9a-fA-Fx]+", info.index)
	else
		s, e = string.find(info.code, "[0-9]*%.?[0-9]*", info.index)
	end

	info.index = e

	table.insert(tokens, { kind = token.number, value = tonumber(string.sub(info.code, s, e)) })
end

local function consumeWhitespace(info: Info, tokens: { Token })
	local _, e = string.find(info.code, "%s+", info.index)

	info.index = e

	table.insert(tokens, { kind = token.whitespace })
end

local function consumeString(info: Info, tokens: { Token })
	local ending = string.sub(info.code, info.index, info.index)
	local e = info.index + 1

	while isNotUnescapedChar(info.code, e, ending) do
		e += 1
	end

	local value = if info.index - e == 1 then "" else string.sub(info.code, info.index + 1, e - 1)

	info.index = e

	table.insert(tokens, { kind = token.string, value = value })
end

local function consumeMultilineString(info: Info, tokens: { Token })
	local value = ""

	if string.sub(info.code, info.index, info.index) == "=" then
		value = string.match(info.code, "=+", info.index)
	end

	local s, e = string.find(info.code, "%]" .. value .. "%]", info.index)

	table.insert(tokens, { kind = token.string, value = string.sub(info.code, info.index + #value + 1, s - 1) })

	info.index = e
end

local function consumeComment(info: Info, tokens: { Token }) 
	local value = ""

	if string.sub(info.code, info.index + 1, info.index + 1) == "[" then
		value = string.match(info.code, "=+", info.index + 2)
	end

	local ending = "\n"

	if string.find(info.code, "%[" .. value .. "%[", info.index + 1) == info.index + 1 then
		ending = "%]" .. value .. "%]"
	end

	local s, e = string.find(info.code, ending, info.index)

	table.insert(tokens, { kind = token.comment, value = string.sub(info.code, info.index + 3 + #value, s - 1) })

	info.index = e
end

local function errorLex(info: Info, tokens: { Token })
	error("Unrecognized character at " .. info.index)
end

--[""] is the default case if there are no matches

local tree = {
	["\""] = consumeString,
	["\'"] = consumeString,
	["-"] = {
		["-"] = consumeComment,
		[">"] = token.arrow,
		[""] = token.sub,
	},
	["+"] = {
		["="] = token.assignmentAdd,
		[""] = token.add,
	},
	["*"] = {
		["="] = token.assignmentMul,
		[""] = token.mul,
	},
	["/"] = {
		["/"] = {
			["="] = token.assignmentFloorDiv,
			[""] = token.floorDiv,
		},
		["="] = token.assignmentAdd,
		[""] = token.add,
	},
	["<"] = {
		["="] = token.lessThanEqual,
		[""] = token.lessThan,
	},
	[">"] = {
		["="] = token.greaterThanEqual,
		[""] = token.greaterThan,
	},
	["%"] = token.mod,
	["~"] = {
		["="] = token.notEqual,
		[""] = errorLex,
	},
	["^"] = token.pow,
	["{"] = token.braceStart,
	["}"] = token.braceEnd,
	["#"] = token.length,
	["="] = {
		["="] = token.equal,
		[""] = token.assignment
	},
	[":"] = token.colon,
	[","] = token.comma,
	["."] = {
		["."] = {
			["."] = tokens.ellipses
			["="] = token.assignmentConcat,
			[""] = token.concat,
		},
		[""] = token.dot,
	},
	["("] = token.paraStart,
	[")"] = token.paraEnd,
	["["] = {
		["["] = consumeMultilineString,
		["="] = consumeMultilineString,
		[""] = token.bracketStart,
	},
	["]"] = token.bracketEnd,
	["?"] = token.optional,
	[""] = errorLex,
}

for i = 0, 9 do
	tree[tostring(i)] = consumeNumber
	tree["."][tostring(i)] = consumeNumber
end

for i, v in string.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", "") do
	tree[v] = consumeWord
end

for i, v in string.split(" \r\n\t", "") do
	tree[v] = consumeWhitespace
end

local function lexify(info: Info): { Token }
	local tokens = {}

	local result = tree
	local last

	while info.index < #info.code do
		last = result
		result = result[string.sub(info.code, info.index, info.index)]

		if result == nil then
			result = last[""]
			info.index -= 1
		end

		if type(result) == "function" then
			result(info, tokens)
		elseif type(result) == "userdata" then
			table.insert(tokens, { kind = result })
		else --is a table
			info.index += 1
			continue
		end

		result = tree
		info.index += 1
	end

	return tokens
end

return {
	lexify = lexify,
	tokens = {
		token = token,
		name = tokenName
	}
}