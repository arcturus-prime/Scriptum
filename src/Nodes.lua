export type Node = {}

local node = {
	operatorUnary = newproxy(),
	operatorBinary = newproxy(),
	operatorTernary = newproxy(),

	assignment = newproxy(),
}

local name = {}

for k, v in node do
	name[v] = k
end

return {
	node = node,
	name = name,
}