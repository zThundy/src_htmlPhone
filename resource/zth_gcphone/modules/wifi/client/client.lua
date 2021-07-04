torriRadio = {}
retiWifi = {}
blips = {}
blips_radius = {}

local playerCaricato = false
local blipCaricati = false

Citizen.CreateThread(function()
	while ESX == nil do Citizen.Wait(100) end
	while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end

	ESX.PlayerData = ESX.GetPlayerData()
	playerCaricato = true

	if Config.EnableRadioTwoers then
		Reti:InitScript()
	else
		Citizen.Wait(5000)
		gcPhoneServerT.updateSegnaleTelefono(4)
	end
end)

-- used only on startup
RegisterNetEvent('esx_wifi:riceviTorriRadio')
AddEventHandler('esx_wifi:riceviTorriRadio', function(torriRadioServer)
	torriRadio = torriRadioServer
	Reti.RefreshBlips()
end)

-- used only on startup
RegisterNetEvent('esx_wifi:riceviRetiWifi')
AddEventHandler('esx_wifi:riceviRetiWifi', function(retiWifiServer) retiWifi = retiWifiServer end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source) playerCaricato = true end)

function Reti:InitScript()
	-- init variabili generali
	self.ped = nil
	self.p_coords = nil
	self.idPlayer = GetPlayerServerId(PlayerId())

	torriRadio, retiWifi = gcPhoneServerT.requestServerInfo()
	-- print(DumpTable(torriRadio))
	while #torriRadio == 0 do Citizen.Wait(100) end

	-- thread per salvataggio coordinate
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1500)
			self.ped = GetPlayerPed(-1)
			self.p_coords = GetEntityCoords(self.ped)
		end
	end)

	-- thread per controllo distanza torri
	Citizen.CreateThread(function()
		local distanza = nil
		self.torre = nil
		self.potenzaSegnale = 0
		self.torrePiuVicina = 0

		self.ped = GetPlayerPed(-1)
		self.p_coords = GetEntityCoords(self.ped)

		self.connectedTorreIndex = nil
		self.agganciato = false
		self.vecchiaPotenzaSegnale = 0

		blipCaricati = self.RefreshBlips()

		while not playerCaricato do Citizen.Wait(500) end
		while not blipCaricati do Citizen.Wait(500) end

		while true do
			self.torrePiuVicina, distanza = Reti.getLowestDistanceTIndex(self.p_coords)

			if self.torrePiuVicina ~= 0 then
				self.torre = torriRadio[self.torrePiuVicina]
				self.potenzaSegnale = self.getPotenzaSegnale(distanza)

				if self.connectedTorreIndex == nil then
					self.agganciato = true
					self.vecchiaPotenzaSegnale = self.potenzaSegnale
					self.connectedTorreIndex = self.torrePiuVicina
					TriggerEvent('gcphone:updateRadioSignal', self.potenzaSegnale)
					-- TriggerServerEvent("esx_wifi:connettiAllaTorre", self.idPlayer, self.torre.tower_label, self.potenzaSegnale)
				else
					if self.torrePiuVicina ~= self.connectedTorreIndex then
						self.vecchiaPotenzaSegnale = self.potenzaSegnale
						-- TriggerServerEvent("esx_wifi:cambiaTorreRadio", self.idPlayer, self.torre.tower_label, self.potenzaSegnale)
					else
						if self.potenzaSegnale ~= self.vecchiaPotenzaSegnale then
							self.vecchiaPotenzaSegnale = self.potenzaSegnale
							-- TriggerServerEvent("esx_wifi:cambiaTorreRadio", self.idPlayer, self.torre.tower_label, self.potenzaSegnale)
						end
					end
				end
			else
				if self.agganciato then
					self.agganciato = false
					TriggerEvent('gcphone:updateRadioSignal', self.potenzaSegnale)
					self.connectedTorreIndex = nil
					self.vecchiaPotenzaSegnale = 0
					self.potenzaSegnale = 0
					-- TriggerServerEvent("esx_wifi:disconnettiDallaTorre", self.idPlayer)
				end
			end

			Citizen.Wait(Config.CheckDistanceWaitTowers * 1000)
		end
	end)

	-- thread per controllo distanza reti wifi
	Citizen.CreateThread(function()
		local distanza = 0
		
		self.ped = GetPlayerPed(-1)
		self.p_coords = GetEntityCoords(self.ped)

		while true do
			self.retiWifiVicine = {}

			for i = 1, #retiWifi do
				distanza = #(self.p_coords - retiWifi[i].pos)
				-- print("retiWifi[i].x, retiWifi[i].y, retiWifi[i].z", retiWifi[i].x, retiWifi[i].y, retiWifi[i].z)
				-- print("distanza", distanza)

				if distanza < Config.RaggioWifi then
					if #self.retiWifiVicine > 0 then
						for reverseI = #self.retiWifiVicine, 1, -1 do
							if distanza > self.retiWifiVicine[reverseI].distanza then
								retiWifi[i].distanza = distanza
								table.insert(self.retiWifiVicine, retiWifi[i])
								break
							else
								if reverseI == #self.retiWifiVicine - 1 then
									retiWifi[i].distanza = distanza
									table.insert(self.retiWifiVicine, reverseI, retiWifi[i])
									break
								end
							end
						end
					else
						retiWifi[i].distanza = distanza
						table.insert(self.retiWifiVicine, retiWifi[i])
					end
				end
			end

			-- print(DumpTable(self.retiWifiVicine))
			-- print("---------------------------------")
			-- print(DumpTable(retiWifi))
			AggiornaRetiWifi(self.retiWifiVicine)

			Citizen.Wait(Config.CheckDistanceWaitWifi * 1000)
		end
	end)
end

if Config.EnableBreakWifiTowers then
	Citizen.CreateThreadNow(function()
		while not playerCaricato do Citizen.Wait(500) end
		while not blipCaricati do Citizen.Wait(500) end

		while true do
			if ESX.PlayerData.job.name == Config.BreakRadioTowersJob then
				for _, v in pairs(retiWifi) do
					if v.broken then
						if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.x, v.y, 1.0, false) <= 5.0 then
							ESX.ShowHelpNotification(Config.Language["HELPNOTIFICATION_WIFI_RADIO_REPAIR"])

							if IsControlJustPressed(0, 38) then
								v.broken = false
								TriggerServerEvent("esx_wifi:repairRadioTower", v)
								Reti.RefreshBlips()
							end
						end
					end
				end
			else
				Citizen.Wait(1000)
			end

			Citizen.Wait(0)
		end
	end)
end