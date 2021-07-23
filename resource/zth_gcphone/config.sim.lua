-- this is the key configured to open the sim cards menù
Config.SimCardKey = "f4"

-- this is the format used by the script to generate new numbers
-- for each sim card
Config.SimFormat = "555%04d"

-- this is the number shown when a player start an anonymus call
Config.HiddenNumberFormat = "555#####"

-- these are the coordinates where the tariffs shop blip and marker
-- will be located
Config.TariffsShop = vector3(53.59, -1584.38, 29.6)
Config.TariffsBlip = {
    enable = true,
    name = "Life invader",
    sprite = 606,
    color = 1,
    scale = 0.8
}

-- this is the list of tariffs plan that the user can buy
-- @label = is the name of that tariffs; keep in mind that the name must be unique for each tariff plan
-- @minuti = are the minutes that a user can use to make calls
-- @messaggi = are the messages that a user can send to others
-- @dati = are the mbs that a user can use to navigate in the internet
-- @price = is the price for that offer (same for renewal)
Config.Tariffs = {
    {label = "Entry Level", minuti = 5, messaggi = 50, dati = 200, price = 5000},
    {label = "Promozione Young", minuti = 10, messaggi = 100, dati = 250, price = 10000},
    {label = "Imprenditore", minuti = 15, messaggi = 150, dati = 300, price = 15000},
    {label = "Super Offer", minuti = 20, messaggi = 200, dati = 350, price = 20000}
}