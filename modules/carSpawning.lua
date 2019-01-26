local carSpawning = {}
local spawnedCars = {}
carSpawning.waitToWarp = {}

local function deletePlayerVehicles(playerid)
	if(spawnedCars[playerid] ~= nil) then
		local carId = spawnedCars[playerid]
		if(isVehicle(carId)) then
			deleteVehicle(carId)
		end
	end
end

-- function speedometer(lstring, linteger, ldouble, lbool)
-- 	local players = getPlayers()

-- 	local vehicleId = 0
-- 	local velocityX, velocityY, velocityZ = 0.0, 0.0, 0.0
-- 	local speed = 0

-- 	for i, id in ipairs(players) do
-- 		setPlayeHealth(id, 200)
-- 		vehicleId = isPlayerInAnyVehicle(id)
-- 		if(vehicleId ~= 0 and isVehicle(vehicleId)) then
-- 			velocityX, velocityY, velocityZ = getVehicleVelocity(vehicleId)
-- 			--setVehicleVelocity(vehicleId, velocityX * 1.01 , velocityY* 1.01 , velocityZ/ 1.01 )
-- 			speed = math.ceil(math.sqrt(velocityX * velocityX + velocityY * velocityY + velocityY * velocityY) * 1.609);
-- 			drawInfoText(id, "~b~" ..math.ceil(speed*1.609) .. "km/u", 600)
-- 		end
-- 	end
-- end

function carSpawning.removePlayerVehicle(playerid)
	if(spawnedCars[playerid] ~= nil and isVehicle(spawnedCars[playerid])) then
		deleteVehicle(spawnedCars[playerid])
		spawnedCars[playerid] = nil
	end
end

function carSpawning.spawnCar(playerId, car, colors)
	car = car or "faggio"

	local modelName = string.upper(car or "no vehicle name")
	local modelId = -1

	--match from beginning
	for _, vehicle in pairs(vehicles) do
		if (vehicle:find(modelName) == 1) then
			modelName = vehicle
			modelId = getVehicleModelId(vehicle)
			break
		end
	end

	if (modelId == -1) then
		--match everywhere
		for _, vehicle in pairs(vehicles) do
			if (vehicle:find(modelName) ~= nil) then
				modelName = vehicle
				modelId = getVehicleModelId(vehicle)
				break
			end
		end
	end

	if (modelId == -1) then
		return sendPlayerMsg(playerId, "'" .. modelName .. "' is an invalid vehicle name", color.error)
	end

	local randomColor = math.random(0, 170)
	local _colors = { randomColor, randomColor, randomColor, randomColor}

	local i = 1
	for _, color in ipairs(colors) do
		color = tonumber(color)
		if (color == nil) then
			break;
		end

		for	j = i, 4 do
			_colors[j] = math.floor(math.abs(color))
		end

		i = i + 1
	end

	local x, y, z = getPlayerPos(playerId)
	local rotation = math.floor(player.getRotation(playerId))
	deletePlayerVehicles(playerId)
	local carId = createVehicle(modelId, x, y, z, 0, 0, rotation, _colors[1], _colors[2], _colors[3], _colors[4], getPlayerWorld(playerId))
	local data = {
		warpPlayerId = playerId,
		warpCarId = carId,
	}
	table.insert(carSpawning.waitToWarp, data)
	spawnedCars[playerId] = carId
	sendPlayerMsg(playerId, modelName .. " spawned with color " .. _colors[1] .." ".. _colors[2] .." ".. _colors[3] .." ".. _colors[4], color.info)
end

-- setTimer("speedometer", 1000, 0)

moduleLoader.registerOnLoad("carSpawning",
	function()
		event.register("onPlayerLeft", carSpawning.removePlayerVehicle)
	end
)

moduleLoader.registerOnUnload("carSpawning",
	function()
		event.unregister("onPlayerLeft", carSpawning.removePlayerVehicle)

		for spawnerId, carId in pairs(spawnedCars) do
			if(isVehicle(carId)) then
				deleteVehicle(carId)
			end
		end
	end
)

return carSpawning