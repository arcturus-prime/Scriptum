local Tokens = require(script.Parent.Tokens)
local Token = Tokens.token

export type Token = {
	kind: any,
	value: any?,
}

export type Info = {
	code: string,
	index: number,
}

--Some handlers are externally defined so they can be duplicated for different characters

local function consumeSingleComment (code: string, i: number)
	local _, e = string.find(code, "\n", i)

	return { kind = Token.comment.single, value = string.sub(code, i, e) }, e
end

local function consumeWord(code: string, i: number)
	local _, e = string.find(code, "%w+", i)

	return { kind = Token.word, value = string.sub(code, i, e) }, e
end

local function consumeNumber(code: string, i: number)
	local s, e
	if string.sub(code, i, i + 1) == "0x" then
		s, e = string.find(code, "[0-9a-fA-Fx]+", i)
	else
		s, e = string.find(code, "[0-9]+%.?[0-9]*", i)
	end

	return { kind = Token.literal.number, value = tonumber(string.sub(code, s, e)) }, e
end

local function consumeWhitespace(code: string, i: number)
	local _, e = string.find(code, "%s+", i)

	return Token.whitespace, e
end

local function consumeString(code: string, i: number)
	local ending = string.sub(code, i, i)
	local e = i + 1

	while string.sub(code, e, e) ~= ending or (string.sub(code, e - 1, e - 1) == "\\" and string.sub(code, e - 2, e - 1) ~= "\\\\") do
		e += 1
	end

	local value = if i - e == 1 then "" else string.sub(code, i + 1, e - 1)
	return { kind = Token.literal.stringSingle, value = value }, e
end

local function consumeMultiline(code: string, i: number) 
	local char = string.sub(code, i, i)

	local value, _, n

	if char == "=" then
		 _, n = string.find(code, "=*", i)
		 value = string.sub(code, i, n)
	else
		value = ""
	end

	local e, _ = string.find(code, "%]" .. value .. "%]", m)
	return string.sub(code, i + #value + 1, e - 1), e
end

local function consumeMultilineComment(code: string, i: number)
	local v, e = consumeMultiline(code, i)
	return { kind = Token.comment.multi, value = v }, e
end

local function consumeMultilineString(code: string, i: number)
	local v, e = consumeMultiline(code, i)
	return { kind = Token.literal.stringSingle, value = v }, e
end

--This is the main data structure for parsing
--[""] is the default case if there are no matches

local tree = {
	["\""] = consumeString,
	["\'"] = consumeString,
	["-"] = {
		["-"] = {
			["["] = {
				["["] = consumeMultilineComment,
				["="] = consumeMultilineComment,
				[""] = consumeSingleComment
			},
			[""] = consumeSingleComment,
		},
		[">"] = Token.operator.assignmentSub,
		[""] = Token.operator.sub,
	},
	["+"] = {
		["="] = Token.operator.assignmentAdd,
		[""] = Token.operator.add,
	},
	["*"] = {
		["="] = Token.operator.assignmentMul,
		[""] = Token.operator.mul,
	},
	["/"] = {
		["/"] = {
			["="] = Token.operator.assignmentFloorDiv,
			[""] = Token.operator.floorDiv,
		},
		["="] = Token.operator.assignmentAdd,
		[""] = Token.operator.add,
	},
	["<"] = {
		["="] = Token.operator.lessThanEqual,
		[""] = Token.operator.lessThan,
	},
	[">"] = {
		["="] = Token.operator.greaterThanEqual,
		[""] = Token.operators.greaterThan,
	},
	["%"] = Token.operator.mod,
	["~"] = {
		["="] = Token.operator.notEqual,
		[""] = function (code, i)
			error("Invalid character at " .. i)
		end,
	},
	["^"] = Token.operator.pow,
	["{"] = Token.seperator.braceStart,
	["}"] = Token.seperator.braceEnd,
	["#"] = Token.operator.length,
	["="] = Token.operator.assignment,
	[":"] = Token.operator.colon,
	[","] = Token.seperator.comma,
	["."] = {
		["."] = {
			["="] = Token.operator.assignmentConcat,
			[""] = Token.operator.concat,
		},
		[""] = Token.operator.dot,
	},
	["("] = Token.seperator.paraStart,
	[")"] = Token.seperator.paraEnd,
	["["] = {
		["["] = consumeMultilineString,
		["="] = consumeMultilineString,
		[""] = Token.seperator.bracketStart,
	},
	["]"] = Token.seperator.bracketEnd,
	["?"] = Token.operator.optional,
	[""] = function (code, i)
		error("Unrecognized character at " .. i)
	end,
}

for i = 0, 9 do
	tree[tostring(i)] = consumeNumber
end

for i, v in string.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", "") do
	tree[v] = consumeWord
end

for i, v in string.split(" \r\n\t", "") do
	tree[v] = consumeWhitespace
end

--Our API

local function peek(info: Info, n: number): ({Token}, number)
	local i = info.index

	local tokens = {}

	while #tokens < n and i < #info.code do
		local result = tree[string.sub(info.code, i, i)]
		local last = tree
		while true do
			if type(result) == "function" then
				local token, j = result(info.code, i)
				i = j

				if token then table.insert(tokens, token) end
				break

			elseif result == nil then
				result = last[""]
				i -= 1
				continue

			elseif type(result) == "userdata" then
				table.insert(tokens, { kind = result })
				break

			end

			i += 1
			last = result
			result = result[string.sub(info.code, i, i)]
		end

		i += 1
	end

	return tokens, i
end

local function consume(info: Info, n: number): {Token}
	local t, i = peek(info, n)

	info.index = i + 1

	return t
end

return {
	peek = peek,
	consume = consume,
}