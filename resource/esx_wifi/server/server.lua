ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

raggioWifi = Config.raggioWifi

distanzaWifi = Config.distanzaWifi

torriRadioFunzionanti = {}
torriRadioRotte = {}
torriRadioCaricate = false
retiWifi = {}
retiWifiCaricate = false

utentiTorriRadio = {}
utentiRetiWifi = {}

Citizen.CreateThread(function()
	t_torriRadioRotte, t_torriRadioCaricate = Reti.loadTorriRadio()
	while true do
		Wait(100)
		if torriRadioCaricate then
			break
		else
			torriRadioRotte = t_torriRadioRotte
			torriRadioCaricate = t_torriRadioCaricate
			torriRadioCaricate = true
		end
	end

	t_retiWifi = Reti.loadRetiWifi()
	while true do
		Wait(100)
		if retiWifiCaricate then
			break
		else
			retiWifi = t_retiWifi
			retiWifiCaricate = true
		end
	end

end)

RegisterServerEvent('esx_wifi:richiediTorriRadio')
AddEventHandler('esx_wifi:richiediTorriRadio', function(player)
	if player ~= nil then
		TriggerClientEvent('esx_wifi:riceviTorriRadio', player, torriRadioFunzionanti)
	end
end)

RegisterServerEvent('esx_wifi:connettiAllaTorre')
AddEventHandler('esx_wifi:connettiAllaTorre', function(player, labelTorreRadio, potenza)
	table.insert(utentiTorriRadio, {player, labelTorreRadio, potenza})
	TriggerClientEvent('gcphone:aggiornameAConnessione', player, potenza)
end)

RegisterServerEvent('esx_wifi:cambiaTorreRadio')
AddEventHandler('esx_wifi:cambiaTorreRadio', function(player, labelTorreRadio, potenza)
	for k, info in pairs(utentiTorriRadio) do
		if info.source == player then
			info.labelTorreRadio = labelTorreRadio
			info.potenza = potenza 
			break
		end
	end

	TriggerClientEvent('gcphone:aggiornameAConnessione', player, potenza)
end)

RegisterServerEvent('esx_wifi:disconnettiDallaTorre')
AddEventHandler('esx_wifi:disconnettiDallaTorre', function(player)
	local utente = nil
	for i=1, #utentiTorriRadio do
		utente = utentiTorriRadio[i]
		if utente.source == player then
			table.remove(utentiTorriRadio, i)
			break
		end
	end

	TriggerClientEvent('gcphone:aggiornameAConnessione', player, 0)
end)

RegisterServerEvent('esx_wifi:richiediRetiWifi')
AddEventHandler('esx_wifi:richiediRetiWifi', function(player, coords)
	local retiWifiVicine = {}
	
	distanza = 0
	for i=1, #retiWifi do
		distanza = ESX.vectorDistance({x = retiWifi[i].x, y = retiWifi[i].y, z = retiWifi[i].z}, coords)
		if distanza < raggioWifi then
			if #retiWifiVicine > 0 then
				for reverseI = #retiWifiVicine, 1, -1 do
					if distanza > retiWifiVicine[reverseI].distanza then
						retiWifi[i].distanza = distanza
						table.insert(retiWifiVicine, retiWifi[i])
						break
					else
						if reverseI == #retiWifiVicine - 1 then
							retiWifi[i].distanza = distanza
							table.insert(retiWifiVicine, reverseI, retiWifi[i])
							break
						end
					end
				end
			else
				retiWifi[i].distanza = distanza
				table.insert(retiWifiVicine, retiWifi[i])
			end
		end
	end
	
	TriggerClientEvent('gcphone:aggiornaRetiWifi', player, retiWifiVicine)
end)

RegisterServerEvent('esx_wifi:connettiAllaTorre')
AddEventHandler('esx_wifi:connettiAllaTorre', function(player, labelTorreRadio, potenza)
	table.insert(utentiTorriRadio, {player, labelTorreRadio, potenza})
	TriggerClientEvent('gcphone:aggiornameAConnessione', player, potenza)
end)