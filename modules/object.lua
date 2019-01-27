local M = {}
local objects = {}

function M.create(x, y, z, rx, ry, rz, model, virtualWorld, hasOffset, roomKey, alpha)
    virtualWorld = virtualWorld or 1
    hasOffset = hasOffset or false
    roomKey = roomKey or 0
    alpha = alpha or 255

    local qx, qy, qz, qw = geometry.EulerToQuaternion(rx, ry, rz)
    local objectId = createObject(x, y, z, qx, qy, qz, qw, model, virtualWorld, hasOffset, roomKey, alpha)

    objects[objectId] = true
    return objectId
end

function M.delete(objectId)
    objects[objectId] = nil
    deleteObject(objectId)
end

local function deleteAll()
    for objectId, _ in pairs(objects) do
        M.delete(objectId)
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