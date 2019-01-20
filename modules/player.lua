local player = {}
local spawnInfo = {
	{1367, -218, 19, 180, 0xFF0000FF}
}
local spawnedObjects = {}
local MIN_SKIN_ID = 4
local MAX_SKIN_ID = 345

function player.spawnPlayer(playerid)
	local playerName = getPlayerName(playerid)
	func.printT("Player " .. playerName .. "(" .. playerid .. ") ["..getPlayerIp(playerid).."] credentials arrived")
	local sId = math.random(1, #spawnInfo)
	spawnPlayer(playerid, spawnInfo[sId][1], spawnInfo[sId][2], spawnInfo[sId][3])

	local skinId = utils.stringToHash(playerName)
	setPlayerSkin(playerid, (skinId % MAX_SKIN_ID) + MIN_SKIN_ID)
	setPlayerColor(playerid, spawnInfo[sId][5])
	setPlayerCash(playerid, 0)
	givePlayerWeapon(playerid, 15, 600)

	sendMsgToAll(playerName .. "(" .. playerid .. ") has joined the server", 0xFFFFFFFF)
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


function player.test(playerid, cmd)
	if(cmd == "web") then
		http = require "http"
		result, statuscode, content = http.request("http://vulcanwolfy.be")
	end

	if(cmd == "loop") then
		local x, y, z = getPlayerPos(playerid)
		for we=0,tonumber(360),15 do
			local ox = (math.sin(math.rad(we))*150)
			local oy = -(math.cos(math.rad(we))*150)
			local r = we;

			local rx, ry, rz, rw = geometry.EulerToQuaternion((-15 + r), 0, 0, 0)
			local objectId =  createObject(x, y+10+ox, z+oy+148.3,rx, ry, rz, rw , 1078148491, 1, false, 0, 255)
			table.insert(spawnedObjects, objectId)

		end
	end
end


function player.teleport(playerid, x, y, z)
	setPlayerPos(playerid,  tonumber(x), tonumber(y), tonumber(z))
end


rawset(_G, "dfgdfgdfgdf",
	function(playerid, virtualKey, isKeyUp)
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
)



--function cmdSpawningCommandEvent(playerid, text)
-- 	if(text == "/coords") then
-- 		local x, y, z = getPlayerPos(playerid)
-- 		sendPlayerMsg(playerid, "XYZ: ".. x .. ", " .. y .. ", " .. z,  0xFFFFFFFF)
-- 	end


-- 	if(text == "/blink") then
-- 		if(isPlayerInAnyVehicle(playerid)) then
-- 			setVehicleIndicator(isPlayerInAnyVehicle(playerid), 0, true)
-- 			setVehicleIndicator(isPlayerInAnyVehicle(playerid), 1, true)
-- 		end
-- 	end

-- 	if(text == "/up") then
-- 		local x, y, z = getPlayerPos(playerid)
-- 		setPlayerPos(playerid, x, y, z+10.0)	
-- 	end


-- end


registerEvent("dfgdfgdfgdf", "onPlayerKeyPress")

moduleLoader.registerModuleUnload("player", (
	function()
		unregisterEvent("dfgdfgdfgdf")

		for _, objectId in pairs(spawnedObjects) do
			deleteObject(objectId)
		end
		spawnedObjects = {}
	end)
)

return player