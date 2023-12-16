--!native

export type Closure = {
	func: {},
	up_stack: { {}? },
	up_index: { number? },
}

export type Chunk = { {} }


local Operations = require(script.Parent.Operations)

local Opcodes = Operations.opcode
local Mnemonics = Operations.mnemonic


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

		print("Executing instruction " .. Mnemonics[op] .. " at " .. counter)

		if op == Opcodes.move then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = stack[b]

			counter += 3

		elseif op == Opcodes.add then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] + stack[c]

			counter += 4

		elseif op == Opcodes.sub then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] - stack[c]

			counter += 4
		
		elseif op == Opcodes.mul then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] * stack[c]

			counter += 4

		elseif op == Opcodes.div then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] / stack[c]

			counter += 4
		
		elseif op == Opcodes.neg then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = - stack[b]

			counter += 3

		elseif op == Opcodes.pow then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] ^ stack[c]

			counter += 4
		
		elseif op == Opcodes.mod then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] % stack[c]

			counter += 4

		elseif op == Opcodes.concat then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] .. stack[c]

			counter += 4
		
		elseif op == Opcodes.tabnew then
			local a = func[counter + 1]

			stack[a] = {}

			counter += 2
		
		elseif op == Opcodes.tabget then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b][stack[c]]

			counter += 4

		elseif op == Opcodes.tabset then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a][stack[b]] = stack[c]

			counter += 4
		
		elseif op == Opcodes.len then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = #stack[b]

			counter += 3

		elseif op == Opcodes.closure then
			local a, b = func[counter + 1], func[counter + 2]

			local new_closure: Closure = { func = chunk[b], up_stack = {}, up_index = {} }

			table.freeze(new_closure)

			stack[a] = new_closure

			counter += 3
		
		elseif op == Opcodes.capture then
			local a, b = func[counter + 1], func[counter + 2]

			table.insert(stack[a].up_stack, stack)
			table.insert(stack[a].up_index, b)

			counter += 3

		elseif op == Opcodes.prop then
			local a, b = func[counter + 1], func[counter + 2]

			table.insert(stack[a].up_stack, up_stack[b])
			table.insert(stack[a].up_index, up_index[b]) 

			counter += 3

		elseif op == Opcodes.upset then
			local a, b = func[counter + 1], func[counter + 2]

			up_stack[a][up_index[a]] = stack[b]


			counter += 3

		elseif op == Opcodes.upget then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = up_stack[b][up_index[b]]

			counter += 3
		
		elseif op == Opcodes.load then
			local a, b = func[counter + 1], func[counter + 2]

			stack[a] = b

			counter += 3

		elseif op == Opcodes.jump then
			local a, b = func[counter + 1], func[counter + 2]

			counter += 3

			if stack[a] then counter += b end
		
		elseif op == Opcodes.jumpn then
			local a, b = func[counter + 1], func[counter + 2]

			counter += 3
			
			if not stack[b] then counter += a end

		elseif op == Opcodes.jumpa then
			local a = func[counter + 1]

			counter += a + 3
		
		elseif op == Opcodes.land then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] and stack[c]

			counter += 4
		
		elseif op == Opcodes.lor then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] or stack[c]

			counter += 4

		elseif op == Opcodes.lnot then
			local a, b, c = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = not stack[b]

			counter += 4
		
		elseif op == Opcodes.eq then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] == stack[c]

			counter += 4

		elseif op == Opcodes.lt then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] < stack[c]

			counter += 4

		elseif op == Opcodes.lte then
			local a, b, c  = func[counter + 1], func[counter + 2], func[counter + 3]

			stack[a] = stack[b] <= stack[c]

			counter += 4

		elseif op == Opcodes.call then
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
		
		elseif op == Opcodes.ret then
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
	execute = execute
}