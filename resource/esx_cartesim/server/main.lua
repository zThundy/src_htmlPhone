ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function GenerateUniquePhoneNumber()
    local query = false
	local numbers = {}
	
	MySQL.Async.fetchAll("SELECT * FROM sim", {}, function(result)
		for index, value in pairs(result) do
			numbers[tostring(value.phone_number)] = true
		end

		query = true
	end)

	while not query do Citizen.Wait(500) end
	
	local rand_number = string.format("555%04d", math.random(0, 99999))
	if numbers[tostring(rand_number)] == nil then
		return rand_number
	end

	GenerateUniquePhoneNumber()
	Citizen.Wait(1)
end


RegisterServerEvent("esx:playerLoaded")
AddEventHandler('esx:playerLoaded', function(source, xPlayer)

	MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = xPlayer.identifier}, function(result)
		if #result > 0 then
			if result[1].phone_number ~= nil then
				MySQL.Async.fetchAll("SELECT * FROM sim WHERE phone_number = @phone_number", {['@phone_number'] = result[1].phone_number}, function(sim)
					if #sim > 0 then

						for _, v in pairs(Config.PianiTariffari["standard"]) do
							if v.label == sim[1].piano_tariffario then
								local data = {
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
								}
								TriggerClientEvent("gcphone:updateValoriDati", xPlayer.source, data)
								return
							end
						end

						for _, v in pairs(Config.PianiTariffari["premium"]) do
							if v.label == sim[1].piano_tariffario then
								local data = {
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
								}

								TriggerClientEvent("gcphone:updateValoriDati", xPlayer.source, data)
								return
							end
						end

					end
				end)
			end
		end
	end)
end)


RegisterServerEvent("esx_cartesim:createNewSim")
AddEventHandler("esx_cartesim:createNewSim", function()
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	
	xPlayer.removeInventoryItem('sim', 1)
	NewSim(player)
end)


function NewSim(source)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	
	MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function(result)
		local phoneNumber = GenerateUniquePhoneNumber() 
		
		MySQL.Async.execute('INSERT INTO sim (phone_number, identifier, piano_tariffario, minuti, messaggi, dati) VALUES (@phone_number, @identifier, @piano_tariffario, @minuti, @messaggi, @dati)', {
			['@phone_number'] = phoneNumber,
			['@identifier'] = xPlayer.identifier,
			['@piano_tariffario'] = "nessuno",
			['@minuti'] = 0,
			['@messaggi'] = 0,
			['@dati'] = 0
		}, function (r)
			TriggerClientEvent('esx:showNotification', source, "La sim è stata registrata con successo", "success")
		end)
	end)
end


--donner la carte sim a un autre joueur
RegisterServerEvent('esx_cartesim:sim_give')
AddEventHandler('esx_cartesim:sim_give', function(number, c_id)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	local xPlayer2 = ESX.GetPlayerFromId(c_id)
			
	if number ~= nil then
		TriggerClientEvent('esx:showNotification', player, "Hai dato la scheda sim ~o~" .. number)
		TriggerClientEvent('esx:showNotification', c_id, "Hai ottenuto una sim~o~" .. number)

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
end)


--supprimer la carte sim
RegisterServerEvent('esx_cartesim:sim_delete')
AddEventHandler('esx_cartesim:sim_delete', function(sim)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)

	MySQL.Async.execute('UPDATE `users` SET phone_number = @phone_number WHERE `identifier` = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@phone_number'] = 0
	})

	MySQL.Async.fetchAll('SELECT * FROM sim WHERE identifier = @identifier', {['@identifier'] = xPlayer.identifier}, function (result)
		for i=1, #result, 1 do
			local simZ = result[i].phone_number

			if simZ == sim then
				MySQL.Async.execute('DELETE FROM sim WHERE phone_number = @phone_number', {['@phone_number'] = result[i].phone_number})
				break
			end
		end
	end)
end)


--changer de carte sim (need change identifier inside phone_users_contacts)
RegisterServerEvent('esx_cartesim:sim_use')
AddEventHandler('esx_cartesim:sim_use', function(sim)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	
	TriggerClientEvent("gcPhone:myPhoneNumber", player, sim.number)
	TriggerClientEvent("gcPhone:UpdateNumber", player, sim.number)

	MySQL.Async.execute('UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.getIdentifier(),
		['@phone_number'] = sim.number
	})
end)


RegisterServerEvent('esx_cartesim:sim_rename')
AddEventHandler('esx_cartesim:sim_rename', function(number, name)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)

	MySQL.Async.execute('UPDATE sim SET nome_sim = @nome_sim WHERE identifier = @identifier AND phone_number = @phone_number', {
		['@identifier'] = xPlayer.identifier,
		['@phone_number'] = number,
		['@nome_sim'] = name
	})
end)


--Recupere les cartes sim
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
	local points = exports["vip_points"]:getPoints(source)

	for k, v in pairs(Config.PianiTariffari["standard"]) do
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

	for k, v in pairs(Config.PianiTariffari["premium"]) do
		if v.label == label and points >= v.price then
			exports["vip_points"]:removePoints(source, v.price)

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
	for k, v in pairs(Config.PianiTariffari["standard"]) do
		if v.label == label then
			cb(v)
			return
		end
	end

	for k, v in pairs(Config.PianiTariffari["premium"]) do
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


ESX.RegisterServerCallback("esx_cartesim:acquistaOffertaCheckPunti", function(source, cb, table, number)
	local xPlayer = ESX.GetPlayerFromId(source)
	local punti = exports["vip_points"]:getPoints(source)

	if punti >= table.price then
		exports["vip_points"]:removePoints(source, table.price)

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