local Lexer = require(script.Parent.Lexer)


export type State = {
	tokens: { Lexer.Token },
	index: number,

	stack: {}
}


local function peek(state: State, i: number)
	return state.stack[#state.stack - i + 1]
end

local function parse(tokens: { Lexer.Token }})
	local syntax = {}
	local state = {
		tokens = tokens,
		index = 1,
		stack = {},
	}

	while state.index < #state.tokens do
		if peek(state, 1).kind == "block" and peek(state, 2).kind == "typedList" and peek(stack, 3).kind == "function" then

		else		
			table.insert(state.stack, state.tokens[state.index + i - 1])
		end
	end

	return state.stack
end

return {
	parse = parse,
}