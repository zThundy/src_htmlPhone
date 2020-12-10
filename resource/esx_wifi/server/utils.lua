Reti = {}

function Reti.loadTorriRadio()
	
	torriRadioFunzionanti = {}
	torriRadioRotte = {}
	
	MySQL.Async.fetchAll('SELECT * FROM cell_towers', {}, function(result)
		for i=1, #result do
			if result[i].broken == false then
				torriRadioFunzionanti[i] = result[i]
			else
				torriRadioRotte[i] = result[i]
			end
		end
	end)
	
	return torriRadioFunzionanti, torriRadioRotte
end

function Reti.loadRetiWifi()

	retiWifi = {}
	
	MySQL.Async.fetchAll('SELECT * FROM home_wifi_nets', {}, function(result)
		for i=1, #result do
			retiWifi[i] = result[i]
		end
	end)
	
	return retiWifi
end

function Reti.doesReteExist(retiWifi, owner_id)
	local rete = nil
	for i=1, #retiWifi do
		rete = retiWifi[i]
		if rete.steam_id == owner_id then
			return true
		end
	end

	return false
end

function Reti.addReteWifi(rete)
	MySQL.Async.execute('INSERT IGNORE INTO home_wifi_nets (steam_id, ssid, password, x, y, z) VALUES (@steam_id, @ssid, @password, @x, @y, @z)', {
		['@steam_id'] = rete.owner_id,
		['@label'] = rete.ssid,
		['@password'] = rete.password,
		['@x'] = rete.x,
		['@y'] = rete.y,
		['@z'] = rete.z
	}, function(rowsChanged)
		return "Rete aggiunta con successo"
	end)
end

function Reti.removeReteWifi(rete)
	MySQL.Async.execute('DELETE * FROM home_wifi_nets WHERE steam_id = @steam_id', {
		['@steam_id'] = rete.owner_id
	}, function(rowsChanged)
		return "Rete aggiunta con successo"
	end)
end

function Reti.updateReteWifi(rete, param)
	MySQL.Async.execute('UPDATE home_wifi_nets SET '..param..' = @'..param..' WHERE steam_id = @steam_id', {
		['@steam_id'] = rete.owner_id,
		['@'..param] = rete[param]
	}, function(rowsChanged)
		return "Rete aggiornata con successo"
	end)
end

function Reti.getRandomWiFiSSID()
	ssid = "Hydra-"
	
	for i=1, 8 do
		ssid = ssid..tostring(math.random(0,9))
	end
	
	return ssid
end

function Reti.getRandomChar()
	randomChar = nil
	
	charValue = 0
	charRangeIndex = math.random(1, 3)
	
	if charRangeIndex == 1 then
		randomChar = string.char(math.random(48, 57))
	elseif charRangeIndex == 2 then
		randomChar = string.char(math.random(65, 90))
	elseif charRangeIndex == 3 then
		randomChar = string.char(math.random(97, 122))
	end
	
	return randomChar
end

function Reti.getRandomWiFiPassword()
	password = ""
	
	for i=1, 8 do
		password = password .. Reti.getRandomChar()
	end
	
	return password
end

function Reti.creaReteWifi(identifier, x, y)
	rete = {}
	
	math.randomseed(os.time())
	
	rete.owner_id = identifier
	rete.ssid = Reti.getRandomWiFiSSID()
	rete.password = Reti.getRandomWiFiPassword()
	rete.x = x
	rete.y = y
	
	return rete
end

RegisterServerEvent("esx_wifi:getSharedObject")
AddEventHandler("esx_wifi:getSharedObject", function(cb)
	cb(Reti)
end)