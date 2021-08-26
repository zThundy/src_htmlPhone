-- if enabled this will enable the towers, tariffs plan and
-- wifi system for the phone. Keep in mind that server with over
-- 500 players will maybe lag a bit
Config.EnableRadioTowers = true

-- this is the default prefix that a new
-- automatically generated modem will have
Config.DefaultRandomSSID = "Phone-"

Config.RaggioTorri = 550.0
Config.RaggioWifi = 25.0

-- if a user has a job included in this list, every call
-- made by them will not consume minutes
Config.IgnoredPlanJobs = {
    ["police"] = true,
    ["ambulance"] = true
}

-- this is the wait time in seconds that the script
-- wait before checking the distance between the user
-- and the single towers
-- ATTENCTION: bigger is the number less are the fps
Config.CheckDistanceWaitTowers = 2

-- this is the wait time in seconds that the script wait
-- before checking the distance between the user
-- and the single wifi modem
-- ATTENCTION: bigger is the number less are the fps
Config.CheckDistanceWaitWifi = 5

-- this variable enables a server sided thread that
-- syncs all towers and player coords
-- This variable should not impact performances
Config.EnableSyncThread = true

-- if Config.EnableSyncThread is enabled, this is the
-- time betweem cycles
-- default: 900 = 15 minutes
Config.SyncThreadWait = 900

Config.WifiDebug = false
Config.DebugRadiusTowers = false

-- i giorni da aggiungere al modem per la scadenza
Config.AddDaysOnRenewal = 30

-- if enabled this will create a thread that will break random
-- radio towers and disable them from work;
-- this will also enable a job designed to repair those radio towers
Config.EnableBreakWifiTowers = false

-- if Config.EnableBreakWifiTowers is enabled this will be the name
-- of the job restricted to fix radio towers
Config.BreakRadioTowersJob = "vodafone"

-- if Config.EnableBreakWifiTowers is eanbled this is the
-- break chance value for a single radio tower
Config.BreakChance = 5

-- Config.TimeToSaveTariffs is the time (in seconds) that the server will wait to
-- save the whole cache of sims for the phone. Keep in mind that more is this time, less the server
-- will perform on saving of this (default should be 1800 or 30 minutes)
-- Keep in mind that the server will save only one sim at time every 50 milliseconds so the server will need some time
Config.TimeToSaveTariffs = 1800