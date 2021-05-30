Config = {}

Config.AuthKey = "YOUR_KEY"

-- for tokovoip addon ask zthundy on discord for a custom version of
-- the voip
Config.EnableTokoVoip = false
Config.EnableSaltyChat = true

-- This is the configured key that you'll need to press to
-- answer a static phone
Config.KeyTakeCall = 46
Config.KeyLabel = "~INPUT_CONTEXT~"
-- This is the iban string length generated for
-- each user on login
Config.IbanStringLength = 7

Config.PhoneDebug = false

-- if enabled this will check if you have the phone item
-- in your inventory
Config.EnablePhoneItem = true
-- this is the name assigned to the phone item
Config.PhoneItemName = "phone"

-- this is the key used to open the phone
Config.KeyToOpenPhone = "k"

-- this will be the maximum range for bluetooth
-- picture sharing between players
Config.BluetoothRange = 5.0
Config.MaxSunoeriaDistance = 10.0

Config.StaticPhones = {
    ['555889280'] = { name = "Gewlery", coords = { x = -630.271, y = -230.216, z = 38.047 } },
    ['555621458'] = { name = "Fleeca", coords = { x = -2958.855, y = 479.614, z = 15.790 } },
}

-- you should not need to edit this: these are the keys that when phone is
-- opened, when pressed, will move focus on each element on the screen
Config.Keys = {
    { code = 172, event = 'ArrowUp' },
    { code = 173, event = 'ArrowDown' },
    { code = 174, event = 'ArrowLeft' },
    { code = 175, event = 'ArrowRight' },
    { code = 176, event = 'Enter' },
    { code = 177, event = 'Backspace' },
}

-- this will enable the message notification called
-- using the function ESX.ShowNotification()
Config.ShowNumberNotification = false
-- this will ensure the prop cleanup everytime the player will
-- close the phone (not so efficient. not recommended)
Config.EnsurePropCleanup = false

-- this will be the coordinates where you'll find the cover
-- shop for your phone
Config.CoverShop = vector3(59.89, -1579.18, 29.6)

-- this will be the default cover that your phone will have
-- on firstlogin of a user. Keep in mind that the prop need to exists in
-- the stream folder of this resource
Config.BaseCover = {prop = "prop_amb_phone", label = "Nessuna cover"}

--[[
    EDIT THE LINES WITH THE * AT THE END ONLY IF YOU KNOW
    WHAT YOU'RE DOING

    @nomecover = will be the name of the png file without the ending .png
    [nomecover] = {
        @price = the price your user will need to pay to purchase this cover
        set @price to 0 if you want the cover to be free
        @prop = the name of the prop that the player will hold in his hand *
        @label = what label will be shown to the user when browsing in the cover shop
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
}

-- These are the coords where the modem shop will be located
Config.ModemManagement = vector3(68.31, -1569.53, 29.6)

-- this are self explainatory. But i will do it anyway ;)
-- BuyModemPrice is the price the user will need to pay to buy a
-- single modem from the shop
Config.BuyModemPrice = 501
-- RenewModemPrice is the price the user will need to pay to
-- renew the modem for the value in days defined in Config.AddDaysOnRenewal
Config.RenewModemPrice = 501
Config.AddDaysOnRenewal = 30
-- ChangePasswordPrice is the price the user will need to pay to change
-- the password of the modem
Config.ChangePasswordPrice = 50
-- WaitBeforeCreatingAgaing is the time (in seconds) that will need to pass
-- before allowing the user to create a new modem
Config.WaitBeforeCreatingAgaing = 600

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
    ["pearl"] = {
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
    ["lostbar"] = {
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
        [5] = {"salary", "employes", "chat"},
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
    ["truckdealer"] = {
        [3] = {"salary", "employes", "chat"},
        [2] = {"salary", "chat"},
        [1] = {"chat"},
        [0] = {"chat"}
    },
    ["police"] = {
        [15] = {"salary", "employes", "chat"},
        [14] = {"salary", "employes", "chat"},
        [13] = {"salary", "employes", "chat"},
        [12] = {"salary", "chat"},
        [11] = {"salary", "chat"},
        [10] = {"salary", "chat"},
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
    ["99district"] = {
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
}