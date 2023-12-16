local opcode = {
	move = newproxy(),

	add = newproxy(),
	sub = newproxy(),
	neg = newproxy(),
	mul = newproxy(),
	div = newproxy(),
	pow = newproxy(),
	mod = newproxy(),
	concat = newproxy(),

	tabnew = newproxy(),
	tabget = newproxy(),
	tabset = newproxy(),
	
	len = newproxy(),

	closure = newproxy(),
	capture = newproxy(),
	prop = newproxy(),

	upget = newproxy(),
	upset = newproxy(),
	
	load = newproxy(),

	jump = newproxy(),
	jumpn = newproxy(),
	jumpa = newproxy(),

	land =  newproxy(),
	lor = newproxy(),
	lnot = newproxy(),
	eq = newproxy(),
	lt = newproxy(),
	lte = newproxy(),

	call = newproxy(),
	ret = newproxy(),
}

local mnemonic = {}

for k, v in opcode do
	mnemonic[v] = k
end

return {
	opcode = opcode,
	mnemonic = mnemonic
}