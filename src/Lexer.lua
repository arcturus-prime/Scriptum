local Tokens = require(script.Parent.Tokens)
local Token = Tokens.token

export type Info = {
	code: string,
	index: number,
}

--Handlers are externally defined so they can be duplicated for different characters

local function isNotUnescapedChar(code: string, i: number, ending: string)
	return string.sub(code, i, i) ~= ending or (string.sub(code, i - 1, i - 1) == "\\" and string.sub(code, i - 2, i - 1) ~= "\\\\")
end

local function consumeWord(info: Info, tokens: { Tokens.Token })
	local _, e = string.find(info.code, "%w+", info.index)

	table.insert(tokens, { kind = Token.word, value = string.sub(info.code, info.index, e) })
	info.index = e
end

local function consumeNumber(info: Info, tokens: { Tokens.Token })
	local s, e
	if string.sub(info.code, info.index, info.index + 1) == "0x" then
		s, e = string.find(info.code, "[0-9a-fA-Fx]+", info.index)
	else
		s, e = string.find(info.code, "[0-9]*%.?[0-9]*", info.index)
	end

	info.index = e

	table.insert(tokens, { kind = Token.number, value = tonumber(string.sub(info.code, s, e)) })
end

local function consumeWhitespace(info: Info, tokens: { Tokens.Token })
	local _, e = string.find(info.code, "%s+", info.index)

	info.index = e

	table.insert(tokens, { kind = Token.whitespace })
end

local function consumeString(info: Info, tokens: { Tokens.Token })
	local ending = string.sub(info.code, info.index, info.index)
	local e = info.index + 1

	while isNotUnescapedChar(info.code, e, ending) do
		e += 1
	end

	local value = if info.index - e == 1 then "" else string.sub(info.code, info.index + 1, e - 1)

	info.index = e

	table.insert(tokens, { kind = Token.string, value = value })
end

local function consumeMultilineString(info: Info, tokens: { Tokens.Token })
	local value = ""

	if string.sub(info.code, info.index, info.index) == "=" then
		value = string.match(info.code, "=+", info.index)
	end

	local s, e = string.find(info.code, "%]" .. value .. "%]", info.index)

	table.insert(tokens, { kind = Token.string, value = string.sub(info.code, info.index + #value + 1, s - 1) })

	info.index = e
end

local function consumeComment(info: Info, tokens: { Tokens.Token }) 
	local value = ""

	if string.sub(info.code, info.index + 1, info.index + 1) == "[" then
		value = string.match(info.code, "=+", info.index + 2)
	end

	local ending = "\n"

	if string.find(info.code, "%[" .. value .. "%[", info.index + 1) == info.index + 1 then
		ending = "%]" .. value .. "%]"
	end

	local s, e = string.find(info.code, ending, info.index)

	table.insert(tokens, { kind = Token.comment, value = string.sub(info.code, info.index + 3 + #value, s - 1) })

	info.index = e
end

local function errorLex(info: Info, tokens: { Tokens.Token })
	error("Unrecognized character at " .. info.index)
end

--This is the main data structure for parsing
--[""] is the default case if there are no matches

local tree = {
	["\""] = consumeString,
	["\'"] = consumeString,
	["-"] = {
		["-"] = consumeComment,
		[">"] = Token.arrow,
		[""] = Token.sub,
	},
	["+"] = {
		["="] = Token.assignmentAdd,
		[""] = Token.add,
	},
	["*"] = {
		["="] = Token.assignmentMul,
		[""] = Token.mul,
	},
	["/"] = {
		["/"] = {
			["="] = Token.assignmentFloorDiv,
			[""] = Token.floorDiv,
		},
		["="] = Token.assignmentAdd,
		[""] = Token.add,
	},
	["<"] = {
		["="] = Token.lessThanEqual,
		[""] = Token.lessThan,
	},
	[">"] = {
		["="] = Token.greaterThanEqual,
		[""] = Token.greaterThan,
	},
	["%"] = Token.mod,
	["~"] = {
		["="] = Token.notEqual,
		[""] = errorLex,
	},
	["^"] = Token.pow,
	["{"] = Token.braceStart,
	["}"] = Token.braceEnd,
	["#"] = Token.length,
	["="] = {
		["="] = Token.equal,
		[""] = Token.assignment
	},
	[":"] = Token.colon,
	[","] = Token.comma,
	["."] = {
		["."] = {
			["."] = Tokens.ellipses
			["="] = Token.assignmentConcat,
			[""] = Token.concat,
		},
		[""] = Token.dot,
	},
	["("] = Token.paraStart,
	[")"] = Token.paraEnd,
	["["] = {
		["["] = consumeMultilineString,
		["="] = consumeMultilineString,
		[""] = Token.bracketStart,
	},
	["]"] = Token.bracketEnd,
	["?"] = Token.optional,
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

--Our API

local function lexify(info: Info): { Tokens.Token }
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
		else
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
}