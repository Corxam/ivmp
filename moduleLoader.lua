local moduleLoader = {}
local _modules = {}

local function unloadedModuleWarning(_, _)
	print("Error: accessing an unloaded or empty module")
end

local unloadedModule = setmetatable({}, {
	__index = unloadedModuleWarning,
    __newindex = unloadedModuleWarning
})

local function loadModule(name)
	_modules[name] = {}
	local success, module = pcall(require, "modules/" .. name)
	if (not success) or module == nil then
		_modules[name] = nil
		print(module)
		return false
	end
	_modules[name].Module = module
	rawset(_G, name, module or unloadedModule)
	print("Module loaded: " .. name)
	return true
end

function moduleLoader.loadModule(name)
	if loadModule(name) then
		local onLoad = _modules[name].onLoad
		if type(onLoad) == "function" then
			onLoad()
		end

		return true
	end

	return false
end

function moduleLoader.loadModules(modules)
	-- predefine globals
	for _, module in ipairs(modules) do
		rawset(_G, module, unloadedModule)
	end

	for _, module in ipairs(modules) do
		loadModule(module)
	end

	for _, module in pairs(_modules) do
		local onLoad = module.onLoad
		if type(onLoad) == "function" then
			onLoad()
		end
	end
end

function moduleLoader.isModuleLoaded(name)
	return (_modules[name] ~= nil)
end

function moduleLoader.unloadModule(name)
	local canUnload = moduleLoader.isModuleLoaded(name) and type(_modules[name].onUnload) == "function"
	if(canUnload) then
		_modules[name].onUnload()
	end
	_modules[name] = nil
	package.loaded["modules/" .. name] = nil
	--rawset(_G, name, unloadedModule)
	print("Module unloaded: " .. name)
end

function moduleLoader.registerOnUnload(name, func)
	_modules[name].onUnload = func
end

function moduleLoader.registerOnLoad(name, func)
	_modules[name].onLoad = func
end

function moduleLoader.reload(name)
	moduleLoader.unloadModule(name)
	return moduleLoader.loadModule(name)
end

function moduleLoader.reloadAll()
	print("Reloading all modules")
	local modules = {}
	for name, _ in pairs(_modules) do
		table.insert(modules, name)
		moduleLoader.unloadModule(name)
	end

	moduleLoader.loadModules(modules)
end

return moduleLoader