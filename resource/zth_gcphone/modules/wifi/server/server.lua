radioTowers = nil
retiWifi = {}

-- non utilizzate per il momento
utentiTorriRadio = {}
utentiRetiWifi = {}

Citizen.CreateThread(function()
	radioTowers = Reti.loadTorriRadio()
	Reti.Debug("Finished loading towers from database")

	retiWifi = Reti.loadRetiWifi()
	Reti.Debug("Finished loading routers from database")

	Reti.CheckDueDate()

	if Config.EnableSyncThread then
		while true do
			Citizen.Wait(Config.SyncThreadWait * 1000)

			radioTowers = Reti.loadTorriRadio()
			retiWifi = Reti.loadRetiWifi()

			TriggerClientEvent('esx_wifi:riceviTorriRadio', -1, radioTowers)
			TriggerClientEvent('esx_wifi:riceviRetiWifi', -1, retiWifi)

			Reti.Debug("SyncThread: towers and wifi synced")
		end
	end
end)

gcPhoneT.richiediTorriRadio = function()
	return radioTowers
end

gcPhoneT.richiediRetiWifi = function()
	return retiWifi
end

--[[
	RegisterServerEvent('esx_wifi:richiediTorriRadio')
	AddEventHandler('esx_wifi:richiediTorriRadio', function()
		local player = source
		while radioTowers == nil do Citizen.Wait(500) end

		TriggerClientEvent('esx_wifi:riceviTorriRadio', player, radioTowers)
	end)

	RegisterServerEvent('esx_wifi:richiediRetiWifi')
	AddEventHandler('esx_wifi:richiediRetiWifi', function()
		local player = source
		while retiWifi == nil do Citizen.Wait(500) end

		TriggerClientEvent('esx_wifi:riceviRetiWifi', player, retiWifi)
	end)
]]

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

RegisterServerEvent('esx_wifi:repairRadioTower')
AddEventHandler('esx_wifi:repairRadioTower', function(tower) Reti.updateCellTower(tower) end)

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

if Config.EnableBreakWifiTowers then
	Citizen.CreateThreadNow(function()
		while true do
			for _, v in pairs(radioTowers) do
				if not v.broken then
					math.randomseed(os.time()); math.randomseed(os.time()); math.randomseed(os.time());

					if Config.BreakChance > math.random(0, 100) then
						v.broken = true
						TriggerClientEvent('esx_wifi:riceviTorriRadio', -1, v)
						Reti.updateCellTower(v)
					end
				end

				-- 10 minutes for each tower
				Citizen.Wait(10 * 60 * 1000)
			end

			Citizen.Wait(5)
		end
	end)
end