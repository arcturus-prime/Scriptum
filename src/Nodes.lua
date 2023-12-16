local Lexer = require(script.Parent.Lexer)

export type Node = {
	kind: any,
	[number]: { Token }
}

local concrete = {
	expression = newproxy(),
	statement = newproxy(),
	block = newproxy(),
}

local astract = {

}

local name = {}

for k, v in node do
	name[v] = k
end

return {
	concrete = concrete,
	abstract = abstract
	name = name,
}