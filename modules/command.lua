local M = {}
local commandMap = {}

function M.handle(playerId, text)
    local args = utils.split(text, " ")
    local command = table.remove(args, 1):sub(2)
    local func = commandMap[command]
    if func then
        func(playerId, args)
    else
        sendPlayerMsg(playerId, "Unknown command", color.error)
    end
end

function M.set(cmds, func)
    if type(cmds) == "table" then
        for _, command in pairs(cmds) do
            commandMap[command] = func
        end
    else
        commandMap[cmds] = func
    end
end

M.set({"h", "help", "?", "cmd", "commands"},
    function(playerId, _)
        for cmd, _ in pairs(commandMap) do
            sendPlayerMsg(playerId, "/" .. cmd, color.info)
        end
    end
)

M.set({"kill"},
    function(playerId, _)
        setPlayeHealth(playerId, 0)
    end
)

M.set({"speedboost", "sb"},
    function(playerId, _)
        setPlayerKeyHook(playerId, 0x10, true)
    end
)


M.set({"v", "veh", "vehicle", "car"},
    function(playerId, args)
        local vehicle = args[1]
        local colors = {args[2],args[3],args[4],args[5]}
        carSpawning.spawnCar(playerId, vehicle, colors)
    end
)

M.set({"cobj"},
    function(playerId, args)
        player.spawnObject(playerId, {args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]})
    end
)

M.set({"ramp"},
    function(playerId, args)
        player.spawnRamp(playerId, args[1], args[2])
    end
)

M.set({"tp", "teleport"},
    function(playerId, args)
        player.teleport(playerId, args[1], args[2], args[3])
    end
)

M.set("rconlogin",
    function(playerId, args)
        local password = args[1]
        rcon.login(playerId, password)
    end
)

M.set("kick",
    function(playerId, args)
        local target = args[1]
        rcon.kick(playerId, target)
    end
)

M.set({"loadmodule", "lm"},
    function(playerId, args)
        local module = args[1]
        rcon.loadModule(playerId, module)
    end
)

M.set({"reloadall", "ra"},
    function(playerId, _)
        rcon.reloadAllModules(playerId)
    end
)

M.set("test",
    function(playerId, args)
        player.test(playerId, args[1], args[2], args[3], args[4], args[5], args[6])
    end
)

M.set("skin",
    function(playerId, args)
        rcon.checkAdmin(playerId,
            function()
                local skinId = tonumber(args[1]) or 1
                setPlayerSkin(playerId, skinId)
            end
        )
    end
)

M.set({"gps", "pos"},
    function(playerId, _)
        local x, y, z = getPlayerPos(playerId)
        local message = "x: " .. x .. " y: " .. y .. " z: " .. z
        sendPlayerMsg(playerId, message, color.info)
        utils.log(string.format("[POS] %s(%d): %.3f,%.3f,%.3f",  getPlayerName(playerId), playerId, x, y, z))
    end
)

M.set("inspect",
    function(playerId, _)
        rcon.checkAdmin(playerId,
            function()
                print(inspect.inspect(_G))
            end
        )
    end
)

moduleLoader.registerOnLoad("commands",
    function()
        event.register("onPlayerCommand", M.handle)
    end
)

moduleLoader.registerOnUnload("commands",
    function()
        event.unregister("onPlayerCommand", M.handle)
    end
)

return M