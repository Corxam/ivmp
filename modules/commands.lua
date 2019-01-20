local commands = {}

local commandMap = {}

function commands.handle(playerId, text)
    local args = utils.split(text, " ")
    local command = table.remove(args, 1):sub(2)
    local func = commandMap[command]
    if func then
        func(playerId, args)
    else
        sendPlayerMsg(playerId, "Unknown command", color.error)
    end
end

function commands.set(cmds, func)
    if type(cmds) == "table" then
        for _, command in pairs(cmds) do
            commandMap[command] = func
        end
    else
        commandMap[cmds] = func
    end
end

commands.set({"h", "help", "?", "cmd", "commands"},
    function(playerId, _)
        for cmd, _ in pairs(commandMap) do
            sendPlayerMsg(playerId, "/" .. cmd, color.info)
        end
    end
)

commands.set({"kill"},
    function(playerId, _)
        setPlayeHealth(playerId, 0)
    end
)

commands.set({"speedboost", "sb"},
    function(playerId, _)
        setPlayerKeyHook(playerId, 0x10, true)
    end
)


commands.set({"v", "veh", "vehicle", "car"},
    function(playerId, args)
        local vehicle = args[1]
        local colors = {args[2],args[3],args[4],args[5]}
        carSpawning.spawnCar(playerId, vehicle, colors)
    end
)

commands.set({"cobj"},
    function(playerId, args)
        player.spawnObject(playerId, {args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]})
    end
)

commands.set({"ramp"},
    function(playerId, args)
        player.spawnRamp(playerId, args[1], args[2])
    end
)

commands.set({"tp", "teleport"},
    function(playerId, args)
        player.teleport(playerId, args[1], args[2], args[3])
    end
)

commands.set("rconlogin",
    function(playerId, args)
        local password = args[1]
        rcon.login(playerId, password)
    end
)

commands.set("kick",
    function(playerId, args)
        local target = args[1]
        rcon.kick(playerId, target)
    end
)

commands.set({"loadmodule", "lm"},
    function(playerId, args)
        local module = args[1]
        rcon.loadModule(playerId, module)
    end
)

commands.set({"reloadall", "ra"},
    function(playerId, _)
        rcon.reloadAllModules(playerId)
    end
)

commands.set("test",
    function(playerId, args)
        player.test(playerId, args[1])
    end
)

commands.set("skin",
    function(playerId, args)
        rcon.checkAdmin(playerId,
            function()
                local skinId = tonumber(args[1]) or 1
                setPlayerSkin(playerId, skinId)
            end
        )
    end
)

return commands