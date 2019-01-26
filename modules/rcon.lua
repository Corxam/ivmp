local rcon = {}

local rconPassword = "test"
local admins = {}

function rcon.checkAdmin(playerId, func)
	if admins[playerId] then
		func()
	else
		sendPlayerMsg(playerId, "Nice try... now donate 5 bucks", color.error)
	end
end

local function sendAdminMsg(message)
	for playerId, _ in pairs(admins) do
		sendPlayerMsg(playerId, message, color.green)
	end
	utils.log("[admin] " .. message)
end

function rcon.loadModule(playerId, moduleName)
	rcon.checkAdmin(playerId,
		function()
			if(moduleLoader.isModuleLoaded(moduleName)) then
				moduleLoader.unloadModule(moduleName)
			end

			if(moduleLoader.loadModule(moduleName)) then
				sendAdminMsg(moduleName .. " was loaded")
			end
		end
	)
end

function rcon.reloadAllModules(playerId)
	rcon.checkAdmin(playerId,
		function()
			sendAdminMsg("Reloading all modules, hold tight")
			moduleLoader.reloadAll()
		end
	)
end

function rcon.login(playerId, password)
	print(getPlayerName(playerId) .. " attempted to rconlogin with pw: " .. password)
	if(password == rconPassword) then
		admins[playerId] = true
		sendPlayerMsg(playerId, "Admin status activated", color.info)
	end
end

function rcon.kick(playerId, target)
	rcon.checkAdmin(playerId,
		function()
			if(target == nil or isPlayerOnline(target) ~= true) then
				return sendPlayerMsg(playerId, "Invalid player ID", color.error)
			end

			local message = getPlayerName(target) .. " was kicked out the server"
			sendAdminMsg(message)
			kickPlayer(target)
		end
	)
end

function rcon.removeAdmin(playerid)
	if(admins[playerid] ~= nil) then
		--Player was authed as admin, now we remove his status
		admins[playerid] = nil
		print(getPlayerName(playerid) .. " rcon was freed")
	end
end

moduleLoader.registerOnLoad("rcon",
	function()
		event.register("onPlayerLeft", rcon.removeAdmin)
	end
)

moduleLoader.registerOnUnload("rcon",
	function()
		event.unregister("onPlayerLeft", rcon.removeAdmin)
	end
)

return rcon