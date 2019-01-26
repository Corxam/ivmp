local M = {}
local registeredEvents = {}

local function handleEvent(event, ...)
    local registeredEvent = registeredEvents[event]
    if type(registeredEvent) == "table" then
        for func, _ in pairs(registeredEvent) do
            func(...)
        end

    else
        error(event .. " is not registered")
    end
end

function M.register(event, func)
    if  type(event) ~= "string" then
        error("event must be a string")
    end

    if  type(func) ~= "function" then
        error("func must be a function")
    end

    if registerEvent(event, event) then
        local eventHandler = rawget(_G, event)
        if type(eventHandler) ~= "function" then
            print("creating event handler for: " .. event)
            rawset(_G, event,
                function(...)
                    handleEvent(event, ...)
                end
            )
        end

        print("adding " .. tostring(func) .. " to " .. event .. " event handler")
        local registeredEvent = registeredEvents[event]
        if type(registeredEvent) == "table" then
            registeredEvent[func] = true
        else
            registeredEvents[event] = {[func] = true}
        end

    else
        error("could not register event: " .. event)
    end
end

function M.unregister(event, func)
    if  type(event) ~= "string" then
        error("event must be a string")
    end

    if  type(func) ~= "function" then
        error("func must be a function")
    end

    local registeredEvent = registeredEvents[event]
    if registeredEvent then
        print("removing " .. tostring(func) .. " from " .. event .. " event handler")
        registeredEvent[func] = nil

        if not next(registeredEvent) then
            print(event .. " has no more functions, removing handler")
            unregisterEvent(event)
            registeredEvents[event] = nil
            rawset(_G, event, nil)
        end
    end
end

local function unregisterAll()
    for event, functions in pairs(registeredEvents) do
        for func, _ in pairs(functions) do
            M.unregister(event, func)
        end
    end
    registeredEvents = {}
end

moduleLoader.registerOnUnload("event",
    function()
        unregisterAll()
    end
)

return M