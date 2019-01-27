moduleLoader = require("moduleLoader")

setmetatable(_G, {
    __index = function(_, v)
    print("WARING: attempt to read undeclared global variable: " .. v)
    end,
    __newindex = function(_, v)
    print("WARNING: attempt to write undeclared global variable: " .. v)
    end
})

local modulesToLoad = {
    -- library modules
    "utils",
    "bezier",
    "color",
    "inspect",
    "geometry",
    "vehicles",

    -- game mode modules
    "rcon",
    "timer",
    "object",
    "player",
    "carSpawning",
    "weapons",
    "test",
    "command",
    "event",
}

moduleLoader.loadModules(modulesToLoad)
