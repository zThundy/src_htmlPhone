Config = {}

-- questo è il prefisso per una rete wifi
-- che si crea in automatico (non ancora implementato)
Config.DefaultRandomSSID = "Code-"

Config.RaggioTorri = 550.0
Config.RaggioWifi = 25.0

-- questo è il tempo in secondi che lo script aspetta per 
-- controllare la distanza dalla torre di un giocatore
-- ATTENZIONE: minore è il tempo, maggiore sono gli ms
Config.CheckDistanceWaitTowers = 2

-- questo è il tempo in secondi che lo script aspetta per
-- controllare la distanza da un modem wifi a un giocatore
-- ATTENZIONE: minore è il tempo, maggiore sono gli ms
Config.CheckDistanceWaitWifi = 5

-- questo syncThread è un Thread lato server che synca con
-- tutti i giocatori che richiedono le torri i valori presi dal database
-- Non dovrebbe impattare troppo le performance
Config.EnableSyncThread = true

-- questo è il tempo che passa tra un ciclo e l'altro
-- nel syncThread. Il tempo è in secondi
-- default: 900 = 15 minuti
Config.SyncThreadWait = 900

Config.Debug = true
Config.DebugRadiusTowers = false

-- i giorni da aggiungere al modem per la scadenza
Config.AddDaysOnRenewal = 30