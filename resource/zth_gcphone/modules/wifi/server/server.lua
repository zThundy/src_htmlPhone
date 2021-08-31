-- non utilizzate per il momento
CACHED_TOWERS = nil
CACHED_WIFIS = nil

TARIFFS_LOADED = false

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_cell_towers", {}, function(r)
        CACHED_TOWERS = r
        Reti.Debug(Config.Language["WIFI_LOAD_DEBUG_1"])
        MySQL.Async.fetchAll("SELECT * FROM phone_wifi_nets", {}, function(r)
            CACHED_WIFIS = r
            CACHED_WIFIS = Reti.LoadAndSendWifi()
            Reti.Debug(Config.Language["WIFI_LOAD_DEBUG_2"])
            TARIFFS_LOADED = true
        end)
    end)
end)

if Config.EnableRadioTowers then
    Citizen.CreateThread(function()
        while not TARIFFS_LOADED do Citizen.Wait(500) end
        Reti.CheckDueDate()
        if Config.EnableSyncThread then
            while true do
                TriggerClientEvent('esx_wifi:riceviTorriRadio', -1, CACHED_TOWERS)
                TriggerClientEvent('esx_wifi:riceviRetiWifi', -1, CACHED_WIFIS)
                Reti.Debug(Config.Language["WIFI_LOAD_DEBUG_3"])
                Citizen.Wait(Config.SyncThreadWait * 1000)
            end
        end
    end)

    RegisterServerEvent('esx_wifi:repairRadioTower')
    AddEventHandler('esx_wifi:repairRadioTower', function(tower) Reti.UpdateCellTower(tower) end)
    
    if Config.EnableBreakWifiTowers then
        Citizen.CreateThreadNow(function()
            while true do
                for _, v in pairs(CACHED_TOWERS) do
                    if not v.broken then
                        math.randomseed(os.time()); math.randomseed(os.time()); math.randomseed(os.time());
                        if Config.BreakChance > math.random(0, 100) then
                            v.broken = true
                            TriggerClientEvent('esx_wifi:riceviTorriRadio', -1, v)
                            Reti.UpdateCellTower(v)
                        end
                    end
                    -- 10 minutes for each tower
                    Citizen.Wait(10 * 60 * 1000)
                end
                Citizen.Wait(5)
            end
        end)
    end
end

gcPhoneT.requestServerInfo = function()
    while not TARIFFS_LOADED do Citizen.Wait(500) end
    return CACHED_TOWERS, CACHED_WIFIS
end