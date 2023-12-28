--!native

export type Closure = {
	func: {},
	up_stack: { {}? },
	up_index: { number? },
}

export type Chunk = { {} }


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

local function execute(chunk: Chunk, env: {})
	local stacks = {}
	local stack = {}

	local funcs = {}
	local func = chunk[1]

	local up_stacks = {}
	local up_stack = {}

	local up_indexes = {}
	local up_index = {}

	local counters = {}
	local counter = 1

	while (true) do
		local op = func[counter]

		print("Executing instruction " .. mnemonics[op] .. " at " .. counter)

		if op == opcode.move then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = stack[b]

			counter += 3

		elseif op == opcode.add then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] + stack[c]

			counter += 4

		elseif op == opcode.sub then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] - stack[c]

			counter += 4
		
		elseif op == opcode.mul then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] * stack[c]

			counter += 4

		elseif op == opcode.div then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] / stack[c]

			counter += 4
		
		elseif op == opcode.neg then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = - stack[b]

			counter += 3

		elseif op == opcode.pow then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] ^ stack[c]

			counter += 4
		
		elseif op == opcode.mod then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] % stack[c]

			counter += 4
		elseif op == opcode.concat then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] .. stack[c]

			counter += 4
		
		elseif op == opcode.tabnew then
			local a = func[counter + 1]

			stack[a] = {}

			counter += 2
		
		elseif op == opcode.tabget then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b][stack[c]]

			counter += 4

		elseif op == opcode.tabset then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a][stack[b]] = stack[c]

			counter += 4
		
		elseif op == opcode.len then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = #stack[b]

			counter += 3

		elseif op == opcode.closure then
			local a, b = func[counter + 1], func[counter + 2]

			local new_closure: Closure = { func = chunk[b], up_stack = {}, up_index = {} }

			table.freeze(new_closure)

			stack[a] = new_closure

			counter += 3
		
		elseif op == opcode.capture then
			local a, b = func[counter + 1], func[counter + 2]

			table.insert(stack[a].up_stack, stack)
			table.insert(stack[a].up_index, b)

			counter += 3

		elseif op == opcode.prop then
			local a, b = func[counter + 1], func[counter + 2]

			table.insert(stack[a].up_stack, up_stack[b])
			table.insert(stack[a].up_index, up_index[b]) 

			counter += 3

		elseif op == opcode.upset then
			local a, b = func[counter + 1], func[counter + 2]

			up_stack[a][up_index[a]] = stack[b]


			counter += 3

		elseif op == opcode.upget then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = up_stack[b][up_index[b]]

			counter += 3
		
		elseif op == opcode.load then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = b

			counter += 3

		elseif op == opcode.jump then
			local a, b = func[counter + 1], func[counter + 2]

			counter += 3

			if stack[a] then counter += b end
		
		elseif op == opcode.jumpn then
			local a, b = func[counter + 1], func[counter + 2]

			counter += 3
			
			if not stack[b] then counter += a end

		elseif op == opcode.jumpa then
			local a = func[counter + 1]

			counter += a + 3
		
		elseif op == opcode.land then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] and stack[c]

			counter += 4
		
		elseif op == opcode.lor then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] or stack[c]

			counter += 4

		elseif op == opcode.lnot then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = not stack[b]

			counter += 4
		
		elseif op == opcode.eq then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] == stack[c]

			counter += 4

		elseif op == opcode.lt then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] < stack[c]

			counter += 4

		elseif op == opcode.lte then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] <= stack[c]

			counter += 4

		elseif op == opcode.call then
			local a, b = func[counter + 1], func[counter + 2]

			local new_closure = stack[a]
			local new_stack = {}

			for i = 3, b + 2 do
				table.insert(new_stack, stack[func[counter + i]])
			end

			table.insert(stacks, stack)
			table.insert(up_stacks, up_stack)
			table.insert(up_indexes, up_index)
			table.insert(funcs, func)
			table.insert(counters, counter + b + 3)

			stack = new_stack
			up_stack = new_closure.up_stack
			up_index = new_closure.up_index
			func = new_closure.func
			counter = 1
		
		elseif op == opcode.ret then
			local a = func[counter + 1]

			local old_stack = stack
			local old_func = func
			local old_counter = counter

			stack = table.remove(stacks)
			func = table.remove(funcs)
			up_stack = table.remove(up_stacks)
			up_index = table.remove(up_indexes)
			counter = table.remove(counters)

			if not (stack and func and up_stack and up_index and counter) then return end

			for i = 2, a + 1 do
				table.insert(stack, old_stack[old_func[old_counter + i]])
			end
		end
	end
end


return  {
	opcodes = {
		enum = opcode,
		name = mnemonic
	}
	execute = execute
}