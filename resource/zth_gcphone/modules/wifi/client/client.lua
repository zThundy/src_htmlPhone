RadioTowers = {}
WifiNets = {}
blips = {}
blips_radius = {}

local PlayerLoaded = false
local BlipsLoaded = false

Citizen.CreateThread(function()
    while ESX == nil do Citizen.Wait(100) end
    while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end

    ESX.PlayerData = ESX.GetPlayerData()
    PlayerLoaded = true

    if Config.EnableRadioTowers then
        Reti:InitScript()
    else
        Citizen.Wait(5000)
        gcPhoneServerT.updateSegnaleTelefono(4)
    end
end)

-- used only on startup
RegisterNetEvent('esx_wifi:riceviTorriRadio')
AddEventHandler('esx_wifi:riceviTorriRadio', function(torriRadioServer)
    RadioTowers = torriRadioServer
    Reti.RefreshBlips()
end)

-- used only on startup
RegisterNetEvent('esx_wifi:riceviRetiWifi')
AddEventHandler('esx_wifi:riceviRetiWifi', function(retiWifiServer) WifiNets = retiWifiServer end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(source) PlayerLoaded = true end)

function Reti:InitScript()
    -- init variabili generali
    self.ped = nil
    self.p_coords = nil
    self.idPlayer = GetPlayerServerId(PlayerId())

    RadioTowers, WifiNets = gcPhoneServerT.getServerData()
    while #RadioTowers == 0 do Citizen.Wait(100) end

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

        BlipsLoaded = self.RefreshBlips()

        while not PlayerLoaded do Citizen.Wait(500) end
        while not BlipsLoaded do Citizen.Wait(500) end

        while true do
            self.torrePiuVicina, distanza = Reti.getLowestDistanceTIndex(self.p_coords)

            if self.torrePiuVicina ~= 0 then
                self.torre = RadioTowers[self.torrePiuVicina]
                self.potenzaSegnale = self.getPotenzaSegnale(distanza)

                if self.connectedTorreIndex == nil then
                    self.agganciato = true
                    self.vecchiaPotenzaSegnale = self.potenzaSegnale
                    self.connectedTorreIndex = self.torrePiuVicina
                    gcPhoneServerT.updateSegnaleTelefono(self.potenzaSegnale)
                else
                    if self.torrePiuVicina ~= self.connectedTorreIndex then
                        self.vecchiaPotenzaSegnale = self.potenzaSegnale
                    else
                        if self.potenzaSegnale ~= self.vecchiaPotenzaSegnale then
                            self.vecchiaPotenzaSegnale = self.potenzaSegnale
                        end
                    end
                end
            else
                if self.agganciato then
                    self.agganciato = false
                    self.connectedTorreIndex = nil
                    self.vecchiaPotenzaSegnale = 0
                    self.potenzaSegnale = 0
                    gcPhoneServerT.updateSegnaleTelefono(self.potenzaSegnale)
                end
            end
            
            SendNUIMessage({ event = "updateSegnale", potenza = self.potenzaSegnale })
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

            for i = 1, #WifiNets do
                distanza = #(self.p_coords - WifiNets[i].pos)
                if distanza < Config.RaggioWifi then
                    if #self.retiWifiVicine > 0 then
                        for reverseI = #self.retiWifiVicine, 1, -1 do
                            if distanza > self.retiWifiVicine[reverseI].distanza then
                                WifiNets[i].distanza = distanza
                                table.insert(self.retiWifiVicine, WifiNets[i])
                                break
                            else
                                if reverseI == #self.retiWifiVicine - 1 then
                                    WifiNets[i].distanza = distanza
                                    table.insert(self.retiWifiVicine, reverseI, WifiNets[i])
                                    break
                                end
                            end
                        end
                    else
                        WifiNets[i].distanza = distanza
                        table.insert(self.retiWifiVicine, WifiNets[i])
                    end
                end
            end
            
            AggiornaRetiWifi(self.retiWifiVicine)
            Citizen.Wait(Config.CheckDistanceWaitWifi * 1000)
        end
    end)
end

-- BETA FEATURE! No animation or shit like that is played while repairing the radio tower
-- TODO: maybe add gridsystem to this marker check
if Config.EnableBreakWifiTowers then
    Citizen.CreateThreadNow(function()
        while not PlayerLoaded do Citizen.Wait(500) end
        while not BlipsLoaded do Citizen.Wait(500) end

        while true do
            if ESX.PlayerData.job.name == Config.BreakRadioTowersJob then
                for index, v in pairs(RadioTowers) do
                    if v.broken then
                        if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), v.x, v.y, 1.0, false) <= 5.0 then
                            ESX.ShowHelpNotification(translate("HELPNOTIFICATION_WIFI_RADIO_REPAIR"))

                            if IsControlJustPressed(0, 38) then
                                v.broken = false
                                TriggerServerEvent("esx_wifi:repairRadioTower", v)
                                Reti.RefreshBlips()
                            end
                        end
                    end
                end
            else
                Citizen.Wait(5000)
            end

            Citizen.Wait(50)
        end
    end)
end