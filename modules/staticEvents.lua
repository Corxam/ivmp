local staticEvents = {}
local registeredEvents = {}

rawset(_G, "onPlayerCommand",
    function(playerId, text)
        commands.handle(playerId, text)
    end
)

rawset(_G, "onPlayerLeft",
    function(playerId, reason)
        rcon.removeAdmin(playerId)
        carSpawning.removePlayerVehicle(playerId)
    end
)

rawset(_G, "onPlayerCredential",
    function(playerId)
        player.spawnPlayer(playerId)
    end
)

rawset(_G, "onPlayerChat",
    function(playerId, text)
        func.printT(text)
        return true
    end
)

local function registerStaticEvent(event)
    registerEvent(event, event)
    table.insert(registeredEvents, event)
end

registerStaticEvent("onPlayerCommand")
registerStaticEvent("onPlayerLeft")
registerStaticEvent("onPlayerCredential")
registerStaticEvent("onPlayerChat")

moduleLoader.registerModuleUnload("staticEvents", (
    function()
        for _, event in ipairs(registeredEvents) do
            unregisterEvent(event)
            registeredEvents = {}
        end
    end)
)

return staticEvents