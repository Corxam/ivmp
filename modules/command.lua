local M = {}
local commands = {}
local aliasMap = {}

local function handle(playerId, text)
	local args = utils.split(text, " ")
	local cmd = table.remove(args, 1):sub(2)
	local command = commands[cmd]
    local alias = aliasMap[cmd]
    if command then
        return command.func(playerId, args)
    elseif alias then
        return commands[alias].func(playerId, args)
    end

	sendPlayerMsg(playerId, "Unknown command", color.error)
end

function M.register(cmd, aliases, description, func)
	if (type(cmd) ~= "string") then
		error("expected string for cmd")
	end

	if (type(aliases) ~= "table") then
		error("expected string for aliases")
	end

	if (type(description) ~= "string") then
		error("expected string for description")
	end

	if (type(func) ~= "function") then
		error("expected string for function")
	end

	if commands[cmd] then
		error(cmd .. " is already registered")
	else
		commands[cmd] = {func = func, aliases = aliases, description = description}
		print("registered command: " .. cmd)
	end

	for _, alias in ipairs(aliases) do
		if commands[alias] or aliasMap[alias] then
			error("alias" .. alias .. " is already registered")
		else
            aliasMap[alias] = cmd
			print("registered alias for " .. cmd ..": " .. alias)
		end
	end
end

function M.unregister(cmd)
	if type(cmd) ~= "string" then
		error("expected string for cmd")
	end

	local command = commands[cmd]
	if command then
        for _, alias in ipairs(command.aliases) do
            aliasMap[alias] = nil
            print("Unregistered alias for " .. cmd .. ": " .. alias)
        end

		commands[cmd] = nil
        print("Unregistered command " .. cmd)
	end
end

local function unloadAll()
	for cmd, _ in pairs(commands) do
		M.unregister(cmd)
	end
end

moduleLoader.registerOnLoad(string.sub(..., 9),
	function()
		event.register("onPlayerCommand", handle)

		local help = "Shows all commands and shows extra information if a command is given as argument."
		M.register("help", { "h", "?", "cmd", "commands" }, help,
			function(playerId, args)
                local cmd = args[1]
                if cmd then
                    local command = commands[cmd]
                    local alias = aliasMap[cmd]
                    if command then
                        sendPlayerMsg(playerId, command.description, color.info)
                    elseif alias then
                        sendPlayerMsg(playerId, commands[alias].description, color.info)
                    end
                else
                    for cmd, command in pairs(commands) do
                        local message = "/" .. cmd

                        for _, alias in ipairs(command.aliases) do
                            message = message .. " /" .. alias
                        end

                        sendPlayerMsg(playerId, message, color.info)
                    end
                end
			end
		)

		local kill = "Kills the player."
		M.register("kill", {}, kill,
			function(playerId, _)
				setPlayeHealth(playerId, 0)
			end
		)

		local speedboost = "Enables speedboost, press shift to get a small boost."
		M.register("speedboost", { "sb" }, speedboost,
			function(playerId, _)
				setPlayerKeyHook(playerId, 0x10, true)
			end
		)

		local vehicle = "Spawns a vehicle. Example: /vehicle inf 0 125"
		M.register("vehicle", { "v", "veh", "car" }, vehicle,
			function(playerId, args)
				local vehicle = args[1]
				local colors = { args[2], args[3], args[4], args[5] }
				carSpawning.spawnCar(playerId, vehicle, colors)
			end
		)

		local cobj = "Spawns some stuff, ask vulcan for more information."
		M.register("cobj", {}, cobj,
			function(playerId, args)
				player.spawnObject(playerId, { args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8] })
			end
		)

		local ramp = "Spawns a ramp in front of you."
		M.register("ramp", {}, ramp,
			function(playerId, args)
				player.spawnRamp(playerId, args[1], args[2])
			end
		)

		local teleport = "Teleports the player to another player, location or to specific coordinates."
		M.register("teleport", { "tp" }, teleport,
			function(playerId, args)
				player.teleport(playerId, args[1], args[2], args[3])
			end
		)

		local rconlogin = "Login as administrator, gives you access to administrator commands."
		M.register("rconlogin", {}, rconlogin,
			function(playerId, args)
				local password = args[1]
				rcon.login(playerId, password)
			end
		)

		local kick = "Kicks the player from the server."
		M.register("kick", {}, kick,
			function(playerId, args)
				local target = args[1]
				rcon.kick(playerId, target)
			end
		)

		local loadmodule = "Loads or reloads a server module."
		M.register("loadmodule", { "lm" }, loadmodule,
			function(playerId, args)
				local module = args[1]
				rcon.loadModule(playerId, module)
			end
		)

		local reloadall = "Reloads all server modules. (is almost like a restart of the server)"
		M.register("reloadall", { "ra" }, reloadall,
			function(playerId, _)
				rcon.reloadAllModules(playerId)
			end
		)

		local test = "Executes experimental stuff, ask vulcan for more info."
		M.register("test", {}, test,
			function(playerId, args)
				player.test(playerId, args[1], args[2], args[3], args[4], args[5], args[6])
			end
		)

		local skin = "Changes your skin to the given id."
		M.register("skin", {}, skin,
			function(playerId, args)
				rcon.checkAdmin(playerId,
					function()
						local skinId = tonumber(args[1]) or 1
						setPlayerSkin(playerId, skinId)
					end
				)
			end
		)

		local gps = "Prints your coordinates."
		M.register("gps", { "pos" }, gps,
			function(playerId, _)
				local x, y, z = getPlayerPos(playerId)
				local message = "x: " .. x .. " y: " .. y .. " z: " .. z
				sendPlayerMsg(playerId, message, color.info)
				utils.log(string.format("[POS] %s(%d): %.3f,%.3f,%.3f", getPlayerName(playerId), playerId, x, y, z))
			end
		)

		local inspect = "Dumps the entire global environment into the server log."
		M.register("inspect", {}, inspect,
			function(playerId, _)
				rcon.checkAdmin(playerId,
					function()
						print(inspect.inspect(_G))
					end
				)
			end
		)
	end
)

moduleLoader.registerOnUnload(string.sub(..., 9),
	function()
		event.unregister("onPlayerCommand", handle)
		unloadAll()
	end
)

return M