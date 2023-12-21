--Forms of nodes
export type Node = {
	kind: any
}

export type Type = Node & {

}

export type Variable = Node & {
	type: Type?,
	scope: { Node },
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

--Specific nodes
local node = {
	variable = newproxy(),
	constant = newproxy(),
	list = newproxy(),

	functionDecl = newproxy(),
	tableDecl = newproxy(),

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

local name = {}

for k, v in node do
	name[v] = k
end

return {
	node = node,
	name = name
}