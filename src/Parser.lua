local Lexer = require(script.Parent.Lexer)

local function parse(info: Info)
	local ast = {}

	while info.index < #info.tokens do
		local token = info.tokens[info.index]

		if token == Lexer.tokens.enum.word then
			if token.value == "local" then

			elseif token.value == "function"
		elseif then

		end
	end

	return ast
end

return {
	parse = parse,
	nodes = {
		enum = node,
		name = nodeName
	},
}