local Lexer = require(script.Parent.Lexer)

local node = {
	variable = newproxy(),
	constant = newproxy(),
	list = newproxy(),

	functionConstructor = newproxy(),
	tableConstructor = newproxy(),

	whileLoop = newproxy(),
	repeatLoop = newproxy(),
	forNumericLoop = newproxy(),
	forGeneralLoop = newproxy(),
	branchTree = newproxy(),

	ellipses = newproxy(),

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
}

local nodeName = {}

for k, v in node do
	nodeName[v] = k
end


export type Node = {
	kind: any
}

export type TableConstructor = Node & {
	body: { [Node] : Node },
}

export type FunctionConstructor = Node & {
	args: { Node },
	body: { Node },
}

export type Variable = Node & {
	name: string,
}

export type Constant = Node & { value: any }

export type Value = Variable | Constant

export type List = Node & { values: { Value } }

export type Branch = Node & {
	condition: Node,
	body: { Node }
}

export type ForNumericLoop = Node & {
	var: Variable,
	lower: Value,
	upper: Value,
	step: Value,
	body: { Node }
}

export type ForGeneralLoop = Node & {
	vars: List,
	exp: Node,
	body: { Node }
}

export type BranchTree = Node & { 
	branches: { Branch }
}

export type Operation = Node & {
	operands: { Node }
}

export type Info = {
	tokens: { Lexer.Token },
	index: number
}


local function parse(info: Info)
	local ast = {}

	while info.index < #info.tokens do
		if 
	end

	return ast
end

return {
	parse = parse
}