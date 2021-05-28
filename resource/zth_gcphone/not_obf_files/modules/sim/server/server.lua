ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

cartesimT = {}
local tunnel = module("zth_gcphone", "modules/TunnelV2")
tunnel.bindInterface("cartesim_server_t", cartesimT)

ESX.RegisterUsableItem("sim", function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	xPlayer.removeInventoryItem('sim', 1)
	NewSim(source)
end)

-- RegisterServerEvent("esx_cartesim:createNewSim")
-- AddEventHandler("esx_cartesim:createNewSim", function()
-- 	local player = source
-- 	local xPlayer = ESX.GetPlayerFromId(player)
-- 	xPlayer.removeInventoryItem('sim', 1)
-- 	NewSim(player)
-- end)

function GenerateUniquePhoneNumber(result)
    local query = false
	local numbers = {}
	
	for index, value in pairs(result) do
		numbers[tostring(value.phone_number)] = true
	end
	
	-- ensure that a 5 digit number is created
	-- local first_random_part = math.random(11111, 99999)
	-- if tostring(first_random_part):length() < 5 then
	-- 	first_random_part = first_random_part .. math.random(1, 9)
	-- 	first_random_part = tonumber(first_random_part)
	-- end
	math.randomseed(os.time()); math.randomseed(os.time()); math.randomseed(os.time())
	local rand_number = string.format("555%04d", math.random(11111, 99999))
	if numbers[tostring(rand_number)] == nil then
		return rand_number
	end

	return GenerateUniquePhoneNumber(result)
end

RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)
	MySQL.Async.fetchAll("SELECT phone_number FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
		gcPhoneT.updateCachedNumber(result[1].phone_number, xPlayer.identifier, false)

		if #result > 0 then
			if result[1].phone_number ~= nil then
				MySQL.Async.fetchAll("SELECT * FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = result[1].phone_number}, function(sim)
					if #sim > 0 then

						for _, v in pairs(Config.Tariffs) do
							if v.label == sim[1].piano_tariffario then
								TriggerClientEvent("gcphone:updateValoriDati", xPlayer.source, {
									{
										current = tonumber(math.floor(sim[1].minuti / 60)),
										max = tonumber(v.minuti),
										icon = "phone",
										suffix = "Minuti"
									},
									{
										current = tonumber(sim[1].messaggi),
										max = tonumber(v.messaggi),
										icon = "message",
										suffix = "Messaggi"
									},
									{
										current = tonumber(sim[1].dati),
										max = tonumber(v.dati),
										icon = "discovery",
										suffix = "Gigabyte"
									}
								})
								return
							end
						end

					end
				end)
			end
		end
	end)
end)

function NewSim(source)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function(result)
		local result = MySQL.Sync.fetchAll("SELECT * FROM sim", {})
		local phoneNumber = GenerateUniquePhoneNumber(result) 
		
		if phoneNumber ~= nil then
			MySQL.Async.execute('INSERT INTO sim (phone_number, identifier, piano_tariffario, minuti, messaggi, dati) VALUES (@phone_number, @identifier, @piano_tariffario, @minuti, @messaggi, @dati)', {
				['@phone_number'] = phoneNumber,
				['@identifier'] = xPlayer.identifier,
				['@piano_tariffario'] = "nessuno",
				['@minuti'] = 0,
				['@messaggi'] = 0,
				['@dati'] = 0
			}, function (r)
				xPlayer.showNotification("~g~Sim creata con successo")
				-- TriggerClientEvent('esx:showNotification', source, "~g~La sim è stata registrata con successo")

				gcPhoneT.updateCachedNumber(phoneNumber, xPlayer.identifier, false)
			end)
		else
			xPlayer.showNotification("~r~Creazione della sim non riuscita")
		end
	end)
end

-- RegisterServerEvent('esx_cartesim:sim_give')
-- AddEventHandler('esx_cartesim:sim_give', function(number, c_id)
-- end)

cartesimT.daiSim = function(number, c_id)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	local xPlayer2 = ESX.GetPlayerFromId(c_id)
			
	if number ~= nil then
		xPlayer.showNotification("Hai dato la scheda sim " .. number)
		xPlayer2.showNotification("Hai ottenuto la sim " .. number)
		-- TriggerClientEvent('esx:showNotification', player, "Hai dato la scheda sim " .. number)
		-- TriggerClientEvent('esx:showNotification', c_id, "Hai ottenuto una sim " .. number)

		gcPhoneT.updateCachedNumber(number, xPlayer2.identifier, false)

		MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
			if result[1].phone_number == number then
				MySQL.Async.execute('UPDATE `users` SET phone_number = @phone_number WHERE `identifier` = @identifier', {
					['@identifier']   = xPlayer.identifier,
					['@phone_number'] = 0
				})
			end
		end)

		MySQL.Async.execute('UPDATE sim SET identifier = @identifier WHERE phone_number = @phone_number', {
			['@identifier'] = xPlayer2.identifier,
			['@phone_number'] = number
		})
    end
end

-- RegisterServerEvent('esx_cartesim:sim_delete')
-- AddEventHandler('esx_cartesim:sim_delete', function(sim)
-- end)

cartesimT.eliminaSim = function(sim)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)

	MySQL.Async.execute('UPDATE `users` SET phone_number = @phone_number WHERE `identifier` = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@phone_number'] = 0
	})

	MySQL.Async.fetchAll('SELECT phone_number FROM sim WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function (result)
		for i=1, #result, 1 do
			local simZ = result[i].phone_number

			if simZ == sim then
				MySQL.Async.execute('DELETE FROM sim WHERE phone_number = @phone_number', {['@phone_number'] = simZ})
				gcPhoneT.updateCachedNumber(sim, false, false)
				break
			end
		end
	end)
end

-- RegisterServerEvent('esx_cartesim:sim_use')
-- AddEventHandler('esx_cartesim:sim_use', function(sim)
-- end)

cartesimT.usaSim = function(sim)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	
	TriggerClientEvent("gcPhone:myPhoneNumber", player, sim.number)
	TriggerClientEvent("gcPhone:UpdateNumber", player, sim.number)
	gcPhoneT.updateCachedNumber(sim.number, xPlayer.identifier, true)

	MySQL.Async.execute('UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getIdentifier(),
		['@phone_number'] = sim.number
	})
end

-- RegisterServerEvent('esx_cartesim:sim_rename')
-- AddEventHandler('esx_cartesim:sim_rename', function(number, name)
-- end)

cartesimT.rinominaSim = function(number, name)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)

	MySQL.Async.execute('UPDATE sim SET nome_sim = @nome_sim WHERE identifier = @identifier AND phone_number = @phone_number', {
		['@identifier'] = xPlayer.identifier,
		['@phone_number'] = number,
		['@nome_sim'] = name
	})
end

ESX.RegisterServerCallback('esx_cartesim:GetList', function(source, cb)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	local cartesim = {}

	MySQL.Async.fetchAll("SELECT * FROM sim WHERE identifier = @identifier", {['@identifier'] = xPlayer.getIdentifier()}, function(data) 
		for _, v in pairs(data) do
			table.insert(cartesim, {number = v.phone_number, nome_sim = v.nome_sim, info = {label = v.piano_tariffario, minuti = v.minuti, messaggi = v.messaggi, dati = v.dati}})
		end
		cb(cartesim)
	end)
end)

ESX.RegisterServerCallback("esx_cartesim:GetOffertaByNumber", function(source, cb, number)
	MySQL.Async.fetchAll("SELECT * FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = number}, function(result)
		if #result > 0 then
			cb(result[1])
		end
	end)
end)

ESX.RegisterServerCallback("esx_cartesim:rinnovaOfferta", function(source, cb, label, number)
	local xPlayer = ESX.GetPlayerFromId(source)
	local moneys = xPlayer.getAccount("bank").money

	for k, v in pairs(Config.Tariffs) do
		if v.label == label and moneys >= v.price then
			xPlayer.removeAccountMoney("bank", v.price)

			MySQL.Async.execute("UPDATE sim SET minuti = @minuti, messaggi = @messaggi, dati = @dati WHERE phone_number = @phone_number", {
				['@phone_number'] = number,
				['@minuti'] = v.minuti * 60,
				['@messaggi'] = v.messaggi,
				['@dati'] = v.dati
			})

			cb(true)
			return
		else
			cb(false)
		end
	end
end)

ESX.RegisterServerCallback("esx_cartesim:getPianoTariffario", function(source, cb, label)
	for k, v in pairs(Config.Tariffs) do
		if v.label == label then
			cb(v)
			return
		end
	end
end)

ESX.RegisterServerCallback("esx_cartesim:acquistaOffertaCheckSoldi", function(source, cb, table, number)
	local xPlayer = ESX.GetPlayerFromId(source)
	local moneys = xPlayer.getAccount("bank").money

	if moneys >= table.price then
		xPlayer.removeAccountMoney("bank", table.price)

		MySQL.Async.execute("UPDATE sim SET piano_tariffario = @piano_tariffario, minuti = @minuti, messaggi = @messaggi, dati = @dati WHERE phone_number = @phone_number", {
			['@phone_number'] = number,
			['@piano_tariffario'] = table.label,
			['@minuti'] = table.minuti * 60,
			['@messaggi'] = table.messaggi,
			['@dati'] = table.dati
		})

		cb(true)
		return
	else
		cb(false)
	end
end)