local moduleLoader = {}
local _modules = {}

local function unloadedModuleWarning(_, _)
	print("Error: accessing an unloaded or empty module")
end

local unloadedModule = setmetatable({}, {
	__index = unloadedModuleWarning,
    __newindex = unloadedModuleWarning
})

function moduleLoader.loadModule(name)
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

function moduleLoader.loadModules(modules)
	-- predefine globals
	for _, module in ipairs(modules) do
		rawset(_G, module, unloadedModule)
	end

	for _, module in ipairs(modules) do
		moduleLoader.loadModule(module)
	end
end

function moduleLoader.isModuleLoaded(name)
	return (_modules[name] ~= nil)
end

function moduleLoader.unloadModule(name)
	local canUnload = moduleLoader.isModuleLoaded(name) and _modules[name].unload ~= nil
	if(canUnload) then
		_modules[name].unload()
	end
	_modules[name] = nil
	package.loaded["modules/" .. name] = nil
	rawset(_G, name, unloadedModule)
	print("Module unloaded: " .. name)
end

function moduleLoader.registerModuleUnload(name, func)
	_modules[name].unload = func
end

function moduleLoader.reload(name)
	if moduleLoader.isModuleLoaded(name) then
		moduleLoader.unloadModule(name)
	end
	return moduleLoader.loadModule(name)
end

-- todo keep order of modules
function moduleLoader.reloadAll()
	print("Reloading all modules")
	for name, _ in pairs(_modules) do
		moduleLoader.reload(name)
	end
end

return moduleLoader