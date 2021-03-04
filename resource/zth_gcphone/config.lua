Config = {}

Config.KeyTakeCall = 46

Config.Debug = false

Config.BluetoothRange = 5.0
Config.MaxSunoeriaDistance = 10.0

Config.TelefoniFissi = {
    -- Telefono Fisso Gioielleria
    ['555889280'] = { name = "Gioielleria", coords = { x = -630.271, y = -230.216, z = 38.047 } },
    
    -- Telefono Fisso Fleeca
    ['555621458'] = { name = "Fleeca Autostrada", coords = { x = -2958.855, y = 479.614, z = 15.790 } },
}

Config.Keys = {
    { code = 172, event = 'ArrowUp' },
    { code = 173, event = 'ArrowDown' },
    { code = 174, event = 'ArrowLeft' },
    { code = 175, event = 'ArrowRight' },
    { code = 176, event = 'Enter' },
    { code = 177, event = 'Backspace' },
}

Config.ShowNumberNotification = false
Config.SurePropCleanup = false

Config.CoverShop = vector3(45.04, -1768.76, 29.61)

Config.BaseCover = {prop = "prop_amb_phone", label = "Nessuna cover"}

--[[
    @nomecover = è il nome dell'immagine senza il .png finale NON MODIFICARE
    [nomecover] = {
        @price = il prezzo da pagare in punti per comperare quella cover
        @prop = il nome del prop della cover da mostrare in gioco. NON MODIFICARE
        @label = cosa verrà mostrato sul telefono e sullo shop
    }
]]
Config.Covers = {
    ["aquagreen"] = {price = 101, prop = "prop_acquagreen_phone", label = "Verde acqua"},
    ["aquagreen_dark"] = {price = 101, prop = "prop_acquagreen_dark_phone", label = "Verde acqua scuro"},
    ["aquagreen_pastel"] = {price = 101, prop = "prop_acquagreen_pastel_phone", label = "Verde acqua pastello"},
    ["black"] = {price = 101, prop = "prop_dark_phone", label = "Nera"},
    ["blu"] = {price = 101, prop = "prop_blu_phone", label = "Blu"},
    ["blu_dark"] = {price = 101, prop = "prop_blu_dark_phone", label = "Blu scuro"},
    ["blu_pastel"] = {price = 101, prop = "prop_blu_pastel_phone", label = "Blu pastello"},
    ["darkblu"] = {price = 101, prop = "prop_darkblue_phone", label = "Blu notte"},
    ["darkblu_pastel"] = {price = 101, prop = "prop_darkblue_pastel_phone", label = "Blu notte pastello"},
    ["darkgrey"] = {price = 101, prop = "prop_darkgrey_phone", label = "Grigio scuro"},
    ["fuxia"] = {price = 101, prop = "prop_fuxia_phone", label = "Fuxia"},
    ["fuxia_pastel"] = {price = 101, prop = "prop_fuxia_pastel_phone", label = "Fuxia pastello"},
    ["green"] = {price = 101, prop = "prop_green_phone", label = "Verde"},
    ["green_dark"] = {price = 101, prop = "prop_greendark_phone", label = "Verde scuro"},
    ["green_pastel"] = {price = 101, prop = "prop_green_pastel_phone", label = "Verde pastello"},
    ["grey"] = {price = 101, prop = "prop_grey_phone", label = "Grigio"},
    ["lightblu"] = {price = 101, prop = "prop_lightblu_phone", label = "Azzurro"},
    ["lightblu_pastel"] = {price = 101, prop = "prop_lightblu_pastel_phone", label = "Azzurro pastello"},
    ["lightgreen"] = {price = 101, prop = "prop_lightgreen_phone", label = "Verde chiaro"},
    ["lightgreen_pastel"] = {price = 101, prop = "prop_lightgreen_pastel_phone", label = "Verde chiaro pastello"},
    ["orange"] = {price = 101, prop = "prop_orange_phone", label = "Arancione"},
    ["orange_pastel"] = {price = 101, prop = "prop_orange_pastel_phone", label = "Arancione pastello"},
    ["pink"] = {price = 101, prop = "prop_pink_phone", label = "Rosa"},
    ["pink_pastel"] = {price = 101, prop = "prop_pink_pastel_phone", label = "Rosa pastello"},
    ["pinkneon_pastel"] = {price = 101, prop = "prop_pinkneon_pastel_phone", label = "Rosa neon"},
    ["purple"] = {price = 101, prop = "prop_purple_phone", label = "Viola"},
    ["purple_dark"] = {price = 101, prop = "prop_purple_dark_phone", label = "Viola scuro"},
    ["purple_pastel"] = {price = 101, prop = "prop_purple_pastel_phone", label = "Viola pastello"},
    ["red"] = {price = 101, prop = "prop_red_phone", label = "Rosso"},
    ["red_dark"] = {price = 101, prop = "prop_red_dark_phone", label = "Rosso scuro"},
    ["violet"] = {price = 101, prop = "prop_violet_phone", label = "Violetto"},
    ["violet_dark"] = {price = 101, prop = "prop_violet_dark_phone", label = "Violetto scuro"},
    ["violet_pastel"] = {price = 101, prop = "prop_violet_pastel_phone", label = "Violetto pastello"},
    ["white"] = {price = 101, prop = "prop_white_phone", label = "Bianca"},
    ["yellow"] = {price = 101, prop = "prop_yellow_phone", label = "Gialla"},
    ["yellow_pastel"] = {price = 101, prop = "prop_yellow_pastel_phone", label = "Gialla pastello"},
    ["luke4316"] = {price = 101, prop = "prop_luke_phone", label = "Luke4316"},
    -- ["test"] = {price = 0, prop = "prop_amb_phone", label = "Test"},
}

Config.BuyModemPoints = 501
Config.RinnovaModemPoints = 501
Config.ChangePasswordPoints = 50
Config.AddDaysOnRenewal = 30

-- in secondi
Config.WaitBeforeCreatingAgaing = 600

Config.ModemManagement = vector3(-1083.502, -248.6952, 37.76329)

Config.MinAziendaGrade = {
    ["cardealer"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["realestateagent"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["ambulance"] = {
        [4] = {"salary", "employes", "chat"},
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["mecano"] = {
        [4] = {"salary", "employes", "chat"},
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["armeria"] = {
        [5] = {"salary", "employes", "chat"},
        [4] = {"salary", "employes", "chat"},
        [3] = {"salary", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["import"] = {
        [6] = {"salary", "employes", "chat"},
        [5] = {"salary", "employes", "chat"},
        [4] = {"salary", "chat"},
        [3] = {"salary", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["tequila"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["unicorn"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["bahama_mamas"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["burgershot"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["crucialfix"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["bayviewlodge"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["central"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["yellow"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["galaxy"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["casino"] = {
        [4] = {"salary", "employes", "chat"},
        [3] = {"salary", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["motorcycle"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["police"] = {
        [11] = {"salary", "employes", "chat"},
        [10] = {"salary", "employes", "chat"},
        [9] = {"salary", "chat"},
        [8] = {"salary", "chat"},
        [7] = {"salary", "chat"},
        [6] = {"chat"},
        [5] = {"chat"},
        [4] = {"chat"},
        [3] = {"chat"},
        [2] = {"chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["reporter"] = {
        [2] = {"salary", "employes", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["autousate"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["tribunale"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["lolly"] = {
        [4] = {"salary", "employes", "chat"},
        [3] = {"salary", "employes", "chat"},
        [2] = {"chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["wallmart"] = {
        [1] = {"salary", "employes", "chat"},
        [0] = {"salary", "chat"}
    },
}