Config = {}

Config.MarkerOfferte = {x = -1080.403, y = -247.197, z = 37.763}
Config.BlipOfferte = {
	x = -1059.33,
	y = -238.72,
	name = "Life invader",
	sprite = 606,
	color = 1,
	scale = 0.8
}

Config.PianiTariffari = {
	["standard"] = {
		{label = "Entry Level", minuti = 5, messaggi = 50, dati = 200, price = 5000},
		{label = "Promozione Young", minuti = 10, messaggi = 100, dati = 250, price = 10000},
		{label = "Imprenditore", minuti = 15, messaggi = 150, dati = 300, price = 15000},
		{label = "ExplicitOffer", minuti = 20, messaggi = 200, dati = 350, price = 20000}
	},
	["premium"] = {
		{label = "Codafone", minuti = 200, messaggi = 1000, dati = 5000, price = 200},
		{label = "Codafone+", minuti = 520, messaggi = 5200, dati = 10500, price = 500},
	}
}