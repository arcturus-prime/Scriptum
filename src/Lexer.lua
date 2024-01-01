export type Token = {
	kind: any,
	value: any?,
}

export type State = {
	code: string,
	index: number,
}


local function isNotUnescapedChar(code: string, i: number, ending: string)
	return string.sub(code, i, i) ~= ending or (string.sub(code, i - 1, i - 1) == "\\" and string.sub(code, i - 2, i - 1) ~= "\\\\")
end

local function consumeWord(state: State)
	local _, e = string.find(state.code, "%w+", state.index)

	local value = string.sub(state.code, state.index, e)
	state.index = e + 1

	return value
end

local function consumeNumber(state: State)
	local s, e
	if string.sub(state.code, state.index, state.index + 1) == "0x" then
		s, e = string.find(state.code, "[0-9a-fA-Fx]+", state.index)
	else
		s, e = string.find(state.code, "[0-9]*%.?[0-9]*", state.index)
	end

	state.index = e + 1
	return tonumber(string.sub(state.code, s, e))
end

local function consumeWhitespace(state: State)
	local s, e = string.find(state.code, "%s+", state.index)

	state.index = e + 1

	return string.sub(state.code, s, e)
end

local function consumeString(state: State)
	local ending = string.sub(state.code, state.index, state.index)
	local e = state.index + 1

	while isNotUnescapedChar(state.code, e, ending) do
		e += 1
	end

	local value = if state.index - e == 1 then "" else string.sub(state.code, state.index + 1, e - 1)
	state.index = e + 1

	return value
end

local function consumeMultilineString(state: State)
	local value = ""

	if string.sub(state.code, state.index, state.index) == "=" then
		value = string.match(state.code, "=+", state.index)
	end

	local s, e = string.find(state.code, "%]" .. value .. "%]", state.index)
	local value = string.sub(state.code, state.index + #value + 1, s - 1)

	state.index = e + 1

	return value
end

local function consumeComment(state: State) 
	local value = ""

	if string.sub(state.code, state.index + 1, state.index + 1) == "[" then
		value = string.match(state.code, "=+", state.index + 2)
	end

	local ending = "\n"

	if string.find(state.code, "%[" .. value .. "%[", state.index + 1) == state.index + 1 then
		ending = "%]" .. value .. "%]"
	end

	local s, e = string.find(state.code, ending, state.index)
	local value = string.sub(state.code, state.index + 3 + #value, s - 1)

	state.index = e + 1

	return value
end

local function peek(state: State, n: number): string
	if n < 1 then error("Attempted to peek less than 1 character!") end

	return string.sub(state.code, state.index, state.index + n - 1)
end

local function consume(state: State, n: number): string
	local str = peek(state, n)

	state.index += n

	return str
end

local keywords = {
	["local"] = true,
	["function"] = true,
	["do"] = true,
	["end"] = true,
	["while"] = true,
	["for"] = true,
	["else"] = true,
	["elseif"] = true,
	["then"] = true,
	["in"] = true,
	["type"] = true,
	["export"] = true,
	["return"] = true,
}

local operators = {
	["."] = true,
	[","] = true,
	[";"] = true,
	[":"] = true,
	["..."] = true,
	[".."] = true,
	["..="] = true,
	["/"] = true,
	["/="] = true,
	["//"] = true,
	["//="] = true,
	["*"] = true,
	["*="] = true,
	["^"] = true,
	["^="] = true,
	["+"] = true,
	["+="] = true,
	["-"] = true,
	["-="] = true,
	["#"] = true,
	["%"] = true,
	["%="] = true,
	["~="] = true,
	["<"] = true,
	["<="] = true,
	[">"] = true,
	[">="] = true,
	["("] = true,
	[")"] = true,
	["["] = true,
	["]"] = true,
	["{"] = true,
	["}"] = true,
	["?"] = true,
	["->"] = true,
}

local function lex(code: string): { Token }
	local tokens = {}
	local state = {
		code = code,
		index = 1,
	}

	while state.index < #state.code do
		if string.find(peek(state, 1), "%w") then
			local str = consumeWord(state)

			if keywords[str] then
				table.insert(tokens, { kind = str })
				continue
			end

			table.insert(tokens, { kind = "id", value = str })

		elseif string.find(peek(state, 1), "%d") or string.find(peek(state, 2), "%.%d") then
			table.insert(tokens, { kind = "number", value = consumeNumber(state) })

		elseif peek(state, 2) == "--" then
			table.insert(tokens, { kind = "comment", value = consumeComment(state) })

		elseif peek(state, 1) == "'" or peek(state, 1) == "\"" then
			table.insert(tokens, { kind = "string", value = consumeString(state) })

		elseif peek(state, 2) == "[[" or peek(state, 2) == "[=" then
			table.insert(tokens, { kind = "string", value = consumeMultilineString(state) })

		elseif string.find(peek(state, 1), "%s") then
			table.insert(tokens, { kind = "whitespace", value = consumeWhitespace(state) })

		elseif operators[peek(state, 1)] then
			local i = 1
			while operators[peek(state, i + 1)] do i += 1 end

			table.insert(tokens, { kind = consume(state, i) })
		else
			error("Unknown character at location " .. state.index)
		end
	end


	return tokens
end

return {
	lex = lex,
}