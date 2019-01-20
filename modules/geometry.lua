local geometry = {}

function geometry.quaternionToEuler(x, y, z, w)
    local sinroll_cospitch = 2 * (w * x + y * z)
    local cosroll_cospitch = 1 - 2 * (x * x + y * y)
    local roll = math.atan(sinroll_cospitch, cosroll_cospitch)

    local sinpitch = 2 * (w * y - z * x)
    local pitch
    if math.abs(sinpitch) >= 1 then
        sinpitch = sinpitch - sinpitch // 1
    end
    pitch = math.asin(sinpitch)

    local sinyaw_cospitch = 2 * (w * z + x * y)
    local cosyaw_cospitch = 1 - 2 * (y * y + z * z)
    local yaw = math.atan2(sinyaw_cospitch, cosyaw_cospitch)

    return math.deg(roll), math.deg(pitch), math.deg(yaw)
end

function geometry.EulerToQuaternion(roll, pitch, yaw)
    roll = math.rad(roll)
    pitch = math.rad(pitch)
    yaw = math.rad(yaw)

    local cy = math.cos(yaw * 0.5)
    local sy = math.sin(yaw * 0.5)
    local cp = math.cos(pitch * 0.5)
    local sp = math.sin(pitch * 0.5)
    local cr = math.cos(roll * 0.5)
    local sr = math.sin(roll * 0.5)

    local x = cy * cp * sr - sy * sp * cr
    local y = sy * cp * sr + cy * sp * cr
    local z = sy * cp * cr - cy * sp * sr
    local w = cy * cp * cr + sy * sp * sr

    return x, y, z, w;
end

return geometry