local player = {}
local spawnInfo = {
	{1367, -218, 19, 180, 0xFF0000FF}
}
local spawnedObjects = {}
local MIN_SKIN_ID = 4
local MAX_SKIN_ID = 345
local playerRotations = {}

local teleportPlaces = 
{
	["spawn"] = {1361.385,-220.277,20.054},
	["island"] = {-607.932,-826.283,3.843},
	["airport"] = {2600, 400, 6},
}

function player.getPlayer(name_id)
	local out = nil
	local player = tonumber(name_id)
	if(player) then
		out = {
			name = getPlayerName(player),
			id = player,
		}
	else
		local players = getPlayers()
		for i, player in pairs(players) do
			local plyName = getPlayerName(player)
			if (string.lower(plyName):find(string.lower(name_id)) ~= nil) then
				out = {
					name = getPlayerName(player),
					id = player,
				}
				break
			end
		end
	end
	return out
end

function player.spawnPlayer(playerid)
	local playerName = getPlayerName(playerid)
	utils.log("Player " .. playerName .. "(" .. playerid .. ") ["..getPlayerIp(playerid).."] credentials arrived")
	local sId = math.random(1, #spawnInfo)
	spawnPlayer(playerid, spawnInfo[sId][1], spawnInfo[sId][2], spawnInfo[sId][3])

	local playerHash = utils.stringToHash(playerName)
	setPlayerSkin(playerid, (playerHash % MAX_SKIN_ID - MIN_SKIN_ID) + MIN_SKIN_ID)
	--setPlayerSkin(playerid, 4)
	setPlayerColor(playerid, spawnInfo[sId][5])
	setPlayerCash(playerid, 0)
	givePlayerWeapon(playerid, 15, 600)

	sendMsgToAll(playerName .. "(" .. playerid .. ") has joined the server", 0xFFFFFFFF)
end

local function onPlayerLeft(playerId, reason)
	local message = getPlayerName(playerId) .. "(" .. playerId .. ") has left the server"
	sendMsgToAll(message, 0xFFFFFFFF)
	utils.log(message)
end

local function onPlayerChat(playerId, text)
	utils.log("[chat] " .. getPlayerName(playerId) .. ": " .. text)
	return true
end


function player.getRotation(playerId)
	local rotation = 0
	local playerRotation = playerRotations[playerId]
	if playerRotation then
		rotation = playerRotation.rotation or 0
	end
	return rotation
end

function player.spawnObject(playerid, data)
	local x, y, z = getPlayerPos(playerid)

	local rx, ry, rz, rw = geometry.EulerToQuaternion(tonumber(data[5]), tonumber(data[6]), tonumber(data[7]), tonumber(data[8]))
	local objectId = createObject(x+tonumber(data[2]), y+tonumber(data[3]), z+tonumber(data[4]), rx, ry, rz, rw, tonumber(data[1]), 1, false, 0, 255)
	table.insert(spawnedObjects, objectId)
end


function player.spawnRamp(playerid, count, width)
	local x, y, z = getPlayerPos(playerid)
	for i=0,tonumber(count) do
		for we=0,tonumber(width) do
			local objectId = createObject(x+(we*6.72), y+10+(i*10.8), z+(i*2.64), 0, 0, 0, 0, 1078148491, 1, false, 0, 255)
			table.insert(spawnedObjects, objectId)
		end
	end
end


function player.test(playerId, cmd, size, c1, c2, c3, c4)


	if(cmd == "loop") then
		local x, y, z = getPlayerPos(playerId)
		size = tonumber(size) or 15
		c1 = tonumber(c1) or 3 --loops
		c2 = tonumber(c2) or 35 --max objs/loop
		c2 = c2 * c1
		c3 = tonumber(c3) or 0.03 --offset
		c4 = tonumber(c4) or 7 --rot
		local steps = tonumber((c1*360)/c2)
		for we=5,tonumber(c1*360),steps do

			local ox = (math.sin(math.rad(we))*size)
			local oy = -(math.cos(math.rad(we))*size)
			local r = we;

			local rx, ry, rz, rw = geometry.EulerToQuaternion((-15.5 + r), c4, -c4, 0)
			local objectId =  createObject(x+(we*c3), y+10+ox, z+oy+(size-1.5),rx, ry, rz, rw , 1078148491, 1, false, 0, 255)
			table.insert(spawnedObjects, objectId)
		end

		sendPlayerMsg(playerId, string.format("ramp: %d %d %d %0.2f %0.2f",  size, c1, c2, c3, c4), color.info)
	end

	if(cmd == "pipe") then
		local x, y, z = getPlayerPos(playerId)
		size = tonumber(size) or 15
		c1 = tonumber(c1) or 3 --loops
		c2 = tonumber(c2) or 35 --max objs/loop
		c2 = c2 * c1
		c3 = tonumber(c3) or 0.03 --offset
		c4 = tonumber(c4) or 7 --rot
		local steps = tonumber((c1*360)/c2)
		for we=5,tonumber(c1*360),steps do

			local ox = (math.sin(math.rad(we))*size)
			local oy = -(math.cos(math.rad(we))*size)
			local r = we;

			local rx, ry, rz, rw = geometry.EulerToQuaternion(( r), c4, -c4, 0)
			local objectId =  createObject(x+(we*c3), y+10+ox, z+oy+(size-1.5),rx, ry, rz, rw , 1072695029, 1, false, 0, 255)
			table.insert(spawnedObjects, objectId)
		end

		sendPlayerMsg(playerId, string.format("ramp: %d %d %d %0.2f %0.2f",  size, c1, c2, c3, c4), color.info)
	end

	if(cmd == "floor") then
		local x, y, z = getPlayerPos(playerId)

		size = tonumber(size) or 1
		c1 = tonumber(c1) or 1
		c2 = tonumber(c2) or 0
		for i=0,size do
			for we=0,c1 do
				local trees = {3133900175, 106208416}
				local rx, ry, rz, rw = geometry.EulerToQuaternion(0, 0, 0)
				local objectId = createObject(x+(we*11.5), y+10+(i*38.5), (z-2)+(c2*we), rx, ry, rz, rw, 2889572096, 1, false, 0, 255)
				table.insert(spawnedObjects, objectId)
				rx, ry, rz, rw = geometry.EulerToQuaternion(0, 0, math.random(360))
				local objectId = createObject(x+(we*11.5)+5.7, y+10+(i*38.5)+19.4, (z-1)+(c2*we), rx, ry, rz, rw, trees[math.random(2)], 1, false, 0, 255)
				table.insert(spawnedObjects, objectId)
			end
		end

	end

	if(cmd == "ramp") then
		local x, y, z = getPlayerPos(playerId)

		size = tonumber(size) or 0
		c1 = tonumber(c1) or 0
		local rx, ry, rz, rw = geometry.EulerToQuaternion(0, 0, size)
		local objectId =  createObject(x, y+10, z,rx, ry, rz, rw , 1078148491, 1, false, 0, 255)
		table.insert(spawnedObjects, objectId)
	end

	if(cmd == "move") then
		local x, y, z = getPlayerPos(playerId)
		size = tonumber(size) or 0
		c1 = tonumber(c1) or 0
		c2 = tonumber(c2) or 0
		c3 = tonumber(c3) or 0

		sendPlayerMsg(playerId, string.format("ramp: %f %f %f %f %f %f %f",  x, y, z, size, c1, c2, c3), color.info)

		local rx, ry, rz, rw = geometry.EulerToQuaternion(size, c1, c2)
		moveObject(spawnedObjects[#spawnedObjects], x, y, z, rx, ry, rz, rw, c3)
	end

	if(cmd == "velo") then
		size = tonumber(size) or 1
		c1 = tonumber(c1) or 1
		c2 = tonumber(c2) or 1
		setVehicleVelocity(isPlayerInAnyVehicle(playerId), size, c1, c2)
	end

	if(cmd == "dirt") then
		size = tonumber(size) or 0
		setVehicleDirtLevel(isPlayerInAnyVehicle(playerId), size)
	end

	if(cmd == "fix") then
		size = tonumber(size) or 1000
		setVehicleEngineHp(isPlayerInAnyVehicle(playerId), size, true)
	end
	
	if(cmd == "cam") then
		size = tonumber(size) or 0
		c1 = tonumber(c1) or 0
		c2 = tonumber(c2) or 0
		c3 = tonumber(c3) or 0
		setPlayerCamPos(playerId, size, c1, c2, c3)
	end

	if(cmd == "skin") then
		setPlayerSkin(tonumber(size), tonumber(c1))
	end

	if(cmd == "http") then

	end

end


function player.teleport(playerId, ply_place_x, y, z)
	if(ply_place_x == nil) then
		sendPlayerMsg(playerId, "/tp <player>", color.info)
		sendPlayerMsg(playerId, "/tp <x> <y> <z>", color.info)

	elseif(y == nil) then
		
		local teleportPlace = teleportPlaces[string.lower(ply_place_x)]
		if(teleportPlace) then
			setPlayerPos(playerId,  teleportPlace[1], teleportPlace[2], teleportPlace[3])
			sendPlayerMsg(playerId, string.format("You have been teleported to %s", teleportPlace), color.info)

		else
			local ply = player.getPlayer(ply_place_x)
			if(ply and isPlayerOnline(ply.id)) then
				local ply_x, ply_y, ply_z = getPlayerPos(ply.id)
				setPlayerPos(playerId,  ply_x, ply_y, ply_z)
				sendPlayerMsg(playerId, "You have been teleported to " .. ply.name, color.info)
			else
				sendPlayerMsg(playerId, "Player/place not found", color.error)
			end
		end
	elseif(z) then
		local x = tonumber(ply_place_x)
		y = tonumber(y)
		z = tonumber(z)
		if (x and y and z) then
			setPlayerPos(playerId, x, y, z)
			sendPlayerMsg(playerId, string.format("You have been teleported to %.3f,%.3f,%.3f", x, y, z), color.info)
		else
			sendPlayerMsg(playerId, string.format("Invalid coords /tp <x> <y> <z>"), color.info)
		end
	end
end

local function dfgdfgdfgdf(playerid, virtualKey, isKeyUp)
	if(not isKeyUp) then
		local vehicleId = isPlayerInAnyVehicle(playerid)
		if(vehicleId ~= 0 and isVehicle(vehicleId)) then
			local velocityX, velocityY, velocityZ = getVehicleVelocity(vehicleId)
			setVehicleVelocity(vehicleId, velocityX * 1.2 , velocityY* 1.2 , velocityZ* 1.2)
		end
	end
	local vehicleId = isPlayerInAnyVehicle(playerid)
	if(isKeyUp) then
		if(vehicleId > 0) then
			if(virtualKey == 0x45) then
				local toggled = getVehicleIndicator(vehicleId, 1)
				setVehicleIndicator(vehicleId, 1, not toggled)
			elseif(virtualKey == 0x51) then
				local toggled = getVehicleIndicator(vehicleId, 0)
				setVehicleIndicator(vehicleId, 0, not toggled)
			end
		end
	end
end

rawset(_G, "calcPlayerRotation",
	function()
		-- todo move this shit
		for i,data in ipairs(carSpawning.waitToWarp) do
			if isVehicleSpawnedForPlayer(data.warpPlayerId, data.warpCarId) then
				warpPlayerIntoVehicle(data.warpPlayerId, data.warpCarId, 0)
				if(isPlayerInAnyVehicle(data.warpPlayerId)) then
					table.remove(carSpawning.waitToWarp, i)
				end
			end
		end

		for _, playerId in ipairs(getPlayers()) do
			local playerRotation = playerRotations[playerId]
			if playerRotation then
				local x2, y2, _ = getPlayerPos(playerId)
				local x1 = playerRotation.x
				local y1 = playerRotation.y

				local x0 = x2 - x1
				local y0 = y2 - y1

				if (x0 ~= 0 or y0 ~= 0) then
					local rotation = math.deg(math.atan(y0, x0))

					-- offset because actual north is east
					if (rotation < -90) then
						rotation = rotation + 270
					else
						rotation = rotation - 90
					end

					playerRotation.rotation = rotation
				end

				playerRotation.x = x2
				playerRotation.y = y2
			else
				playerRotations[playerId] = {
					x = 0,
					y = 0,
					rotation = 0,
				}
			end
		end
	end
)

setTimer("calcPlayerRotation", 1000, 0)

moduleLoader.registerOnLoad("player",
	function()
		event.register("onPlayerCredential", player.spawnPlayer)
		event.register("onPlayerLeft", onPlayerLeft)
		event.register("onPlayerKeyPress", dfgdfgdfgdf)
		event.register("onPlayerChat", onPlayerChat)
	end
)

moduleLoader.registerOnUnload("player",
	function()
		for _, objectId in pairs(spawnedObjects) do
			deleteObject(objectId)
		end
		spawnedObjects = {}

		deleteTimer("calcPlayerRotation")

		event.unregister("onPlayerCredential", player.spawnPlayer)
		event.unregister("onPlayerLeft", onPlayerLeft)
		event.unregister("onPlayerKeyPress", dfgdfgdfgdf)
		event.unregister("onPlayerChat", onPlayerChat)
	end
)

return player