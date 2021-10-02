local module = {
	Binds = {};

}	

module.BindOnBegan = function(inpType, key, func, name, addToContext, contextName)
	
	name = (name or "BeganConnection") .. tostring(#module.Binds)
	inpType = inpType or "Keyboard"
	local uis = game:GetService("UserInputService") 
	
	local function on(inp, gpe)
		if inp.UserInputType == Enum.UserInputType[inpType] and key and inp.KeyCode == Enum.KeyCode[key] and not gpe then
			func()
		elseif inp.UserInputType == Enum.UserInputType[inpType] and not key and not gpe then
			func()
		end
	end
	
	module.Binds[name] = uis.InputBegan:Connect(on)
end

module.BindOnEnded = function(inpType, key, func, name, addToContext, contextName)
	
	name = (name or "EndedConnection") .. tostring(#module.Binds)
	inpType = inpType or "Keyboard"
	local uis = game:GetService("UserInputService")

	local function on(inp, gpe)
		if inp.UserInputType == Enum.UserInputType[inpType] and key and inp.KeyCode == Enum.KeyCode[key] and not gpe then
			func()
		elseif inp.UserInputType == Enum.UserInputType[inpType] and not key and not gpe then
			func()
		end
	end

	module.Binds[name] = uis.InputEnded:Connect(on)
end

module.Unbind = function(name, func, contextName)
	
	module.Binds[name]:Disconnect()
	if func then
		func()
	end
end

module.UnbindAll = function(func)
	for _, bind in pairs(module.Binds) do
		bind:Disconnect()
	end
	if func then
		func()
	end
end

return module
