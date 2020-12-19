ESX = nil

torriRadioFunzionanti = nil
torriRadioRotte = nil
retiWifi = {}

-- non utilizzate per il momento
utentiTorriRadio = {}
utentiRetiWifi = {}

Citizen.CreateThread(function()
	ESX = exports["es_extended"]:getSharedObject()

	local torriRadioCaricate, retiWifiCaricate = false, false

	while true do
		Citizen.Wait(1000)

		if torriRadioCaricate then
			break
		else
			torriRadioFunzionanti, torriRadioRotte = Reti.loadTorriRadio()
			torriRadioCaricate = true
		end
	end

	Reti.Debug("Finished loading towers from database")

	while true do
		Citizen.Wait(1000)

		if retiWifiCaricate then
			break
		else
			retiWifi = Reti.loadRetiWifi()
			retiWifiCaricate = true
		end
	end

	Reti.CheckDueDate()
	Reti.Debug("Finished loading routers from database")

	if Config.EnableSyncThread then
		while true do
			Citizen.Wait(Config.SyncThreadWait * 1000)

			torriRadioFunzionanti, torriRadioRotte = Reti.loadTorriRadio()
			retiWifi = Reti.loadRetiWifi()

			TriggerClientEvent('esx_wifi:riceviTorriRadio', -1, torriRadioFunzionanti, torriRadioRotte)
			TriggerClientEvent('esx_wifi:riceviRetiWifi', -1, retiWifi)

			Reti.Debug("SyncThread: towers and wifi synced")
		end
	end
end)


RegisterServerEvent('esx_wifi:richiediTorriRadio')
AddEventHandler('esx_wifi:richiediTorriRadio', function()
	local player = source

	while torriRadioFunzionanti == nil do Citizen.Wait(500) end
	while torriRadioRotte == nil do Citizen.Wait(500) end

	TriggerClientEvent('esx_wifi:riceviTorriRadio', player, torriRadioFunzionanti, torriRadioRotte)
end)


RegisterServerEvent('esx_wifi:richiediRetiWifi')
AddEventHandler('esx_wifi:richiediRetiWifi', function()
	local player = source

	if player ~= nil then
		TriggerClientEvent('esx_wifi:riceviRetiWifi', player, retiWifi)
	end
end)


RegisterServerEvent('esx_wifi:connettiAllaTorre')
AddEventHandler('esx_wifi:connettiAllaTorre', function(player, labelTorreRadio, potenza)
	-- table.insert(utentiTorriRadio, {player, labelTorreRadio, potenza})
	utentiTorriRadio[player] = {player, labelTorreRadio, potenza}

	TriggerClientEvent('gcphone:aggiornameAConnessione', player, potenza)
end)


RegisterServerEvent('esx_wifi:cambiaTorreRadio')
AddEventHandler('esx_wifi:cambiaTorreRadio', function(player, labelTorreRadio, potenza)
	utentiTorriRadio[player].labelTorreRadio = labelTorreRadio
	utentiTorriRadio[player].potenza = potenza

	--[[
		for k, info in pairs(utentiTorriRadio) do
			if info.source == player then
				info.labelTorreRadio = labelTorreRadio
				info.potenza = potenza 
				break
			end
		end
	]]

	TriggerClientEvent('gcphone:aggiornameAConnessione', player, potenza)
end)


RegisterServerEvent('esx_wifi:disconnettiDallaTorre')
AddEventHandler('esx_wifi:disconnettiDallaTorre', function(player)
	utentiTorriRadio[player] = nil
	
	--[[
		local utente = nil
		for i=1, #utentiTorriRadio do
			utente = utentiTorriRadio[i]
			if utente.source == player then
				table.remove(utentiTorriRadio, i)
				break
			end
		end
	]]

	TriggerClientEvent('gcphone:aggiornameAConnessione', player, 0)
end)