local M = {}
local timers = {}
local id = 1

function M.set(interval, repetitions, func)
    local timerId = id
    local timerCallback = "#timer" .. timerId
    if not setTimer(timerCallback, repetitions, func) then
        error("could not create timer " .. interval .. " " .. repetitions .. " " .. tostring(func))
    end

    rawset(_G, timerCallback, func)
    timers[timerId] = true

    id = id + 1
    return timerId
end

function M.delete(timerId)
    local timerCallback = "#timer" .. timerId
    deleteTimer(timerCallback)
    rawset(_G, timerCallback, nil)
    timers[timerId] = nil
end

local function deleteAll()
    for timerId, _ in pairs(timers) do
        M.delete(timerId)
    end
end

moduleLoader.registerOnLoad(string.sub(..., 9),
        function()
            -- add loading code here
        end
)


moduleLoader.registerOnUnload(string.sub(..., 9),
        function()
            deleteAll()
        end
)

return M