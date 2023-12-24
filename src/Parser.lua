local Lexer = require(script.Parent.Lexer)
local Tokens = require(script.Parent.Tokens)
local Nodes = require(script.Parent.Nodes)

local Token = Tokens.token

export type Info = {
	tokens: { Lexer.Token },
	index: number
}

local function parse(info: Info)
	local tree = {}
	local temp = {}

	while info.index < #info.tokens do
		local token = info.tokens[info.index]

		if token.kind == token.word and token.value == "while" then

		end
	end
end

return {}