ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

torriRadio = {}
retiWifi = {}
connectedTorreIndex = nil

blipMostrati = false

agganciato = false
vecchiaPotenzaSegnale = 0
potenzaSegnale = 0

playerCaricato = false
idPlayer = nil
distanza = nil
torre = nil

RegisterNetEvent('esx_wifi:riceviTorriRadio')
AddEventHandler('esx_wifi:riceviTorriRadio', function(torriRadioServer)
	torriRadio = torriRadioServer
end)

RegisterNetEvent('esx_wifi:riceviRetiWifi')
AddEventHandler('esx_wifi:riceviRetiWifi', function(retiWifiServer)
	retiWifi = retiWifiServer
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source)
	playerCaricato = true
end)

function mostraBlip()
	for k, v in pairs(torriRadio) do
		local blip = AddBlipForCoord(v.x, v.y, 1.0)

		SetBlipHighDetail(blip, true)
		SetBlipSprite(blip, 459)
		SetBlipColour(blip, 3)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Torre radio")
		EndTextCommandSetBlipName(blip)
	end

	blipMostrati = true
end


local ped = nil
local pedPosition = nil

Citizen.CreateThread(function()

	idPlayer = GetPlayerServerId(PlayerId())
	TriggerServerEvent('esx_wifi:richiediTorriRadio', idPlayer)
	Citizen.Wait(100)

	while true do
		Citizen.Wait(1000)

		if playerCaricato == true then

			if blipMostrati == false then
				if #torriRadio > 0 then
					mostraBlip()
				end
			end
			
			ped = GetPlayerPed(-1)
			pedPosition = GetEntityCoords(ped)
			
			TriggerServerEvent('esx_wifi:richiediRetiWifi', idPlayer, pedPosition)

			torrePiuVicina, distanza = getLowestDistanceTIndex(pedPosition)

			if torrePiuVicina ~= 0 then
				torre = torriRadio[torrePiuVicina]
				potenzaSegnale = getPotenzaSegnale(distanza)
				if connectedTorreIndex == nil then
					checkingTime = 1000
					agganciato = true
					vecchiaPotenzaSegnale = potenzaSegnale
					connectedTorreIndex = torrePiuVicina
					TriggerServerEvent("esx_wifi:connettiAllaTorre", idPlayer, torre.tower_label, potenzaSegnale)
				else
					if torrePiuVicina ~= connectedTorreIndex then
						vecchiaPotenzaSegnale = potenzaSegnale
						TriggerServerEvent("esx_wifi:cambiaTorreRadio", idPlayer, torre.tower_label, potenzaSegnale)
					else
						if potenzaSegnale ~= vecchiaPotenzaSegnale then
							vecchiaPotenzaSegnale = potenzaSegnale
							TriggerServerEvent("esx_wifi:cambiaTorreRadio", idPlayer, torre.tower_label, potenzaSegnale)
						end
					end
				end
			else
				if agganciato then
					agganciato = false
					connectedTorreIndex = nil
					vecchiaPotenzaSegnale = 0
					TriggerServerEvent("esx_wifi:disconnettiDallaTorre", idPlayer)
				end
			end
			
		else
			if ESX.IsPlayerLoaded() then
				playerCaricato = true
			end
		end
	end
end)