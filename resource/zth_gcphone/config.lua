Config = {}

Config.AuthKey = "YOUR_KEY_HERE"

-- for tokovoip addon ask zthundy on discord for a custom version of
-- the voip
-- ONLY ONE CAN BE TRUE
Config.EnableTokoVoip = false
Config.EnableSaltyChat = false
Config.EnableVoiceRTC = true

-- this is the key used to open the phone
Config.KeyToOpenPhone = "k"

-- If true, the phone will auto generate an iban string
-- that will be used in the bank app
Config.ShouldUseIban = false
-- This is the iban string length generated for
-- each user on login
Config.IbanStringLength = 7

Config.PhoneDebug = false

-- if enabled this will check if you have the phone item
-- in your inventory
Config.EnablePhoneItem = true
-- this is the name assigned to the phone item
Config.PhoneItemName = "phone"
-- this is the name assigned to the sim item
Config.SimItemName = "sim"
-- this is the name assigned to the modem item
Config.ModemItemName = "modem"

-- this will be the maximum range for bluetooth
-- picture sharing between players
Config.BluetoothRange = 5.0
Config.MaxSunoeriaDistance = 10.0

-- Discord webhook for photo uploading
Config.DiscordWebhook = "YOUR_WEBHOOK_HERE"

-- ATTENCTION: IF YOU DON'T KNOW WHAT YOU'RE DOING, DO NOT CHANGE THIS VALUE
-- if enabled and if second jobs are present in the server (as array in jobs named
-- job2.<varius info>) then this will show the second job in the settings app
Config.EnableSecondJobs = false

-- if this is enabled, the script will spawn a prop representic the
-- static phones configured in the array down here
-- ATTENCTION: a loop in a thread created to check if the phoneboxes are beeing called
-- will start and this may cause lag if a lot of them are used at the same time
Config.EnablePhoneBoxes = true
-- this is the array representing all static phones created in the server
-- [@phone_number] is the phone number that will be assinged to the phone box
--                 try using more than 5 number (or create a string of number not
--                 starting with 555) to make the phone box unique from the sim numbers
-- @name is the name of the phone box (unused by the scirpt logic) this is just a label
-- @coords MUST be a vector3 and is used by the script to check distance and coords for the
-- phone
Config.PhoneBoxes = {
    ['555889280'] = { name = "Gewlery", coords = vector3(-630.271, -230.216, 38.047) },
    ['555621458'] = { name = "Fleeca", coords = vector3(-2958.855, 479.614, 15.790) },
}
-- this is the max range where the ring of the static phone can be heard by anyone
Config.MaxPhoneBoxesRingRange = 8.0
-- This is the configured key that you'll need to press to
-- answer a fixed phone
Config.KeyTakeCall = 46
Config.KeyLabel = "~INPUT_CONTEXT~"
-- this is the prop name for the fixed phone
Config.PhonePropModel = "prop_cs_phone_01"

-- You can edit the keys if you want, but DO NOT CHANGE
-- THE EVENT NAMES because they're used by the phone NUI to
-- receive messages and move the cursor in the phone
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
-- These are the arguments for the covers shop blip
Config.CoverShopBlip = {
    enable = true,
    name = "Cover shop",
	sprite = 606,
	color = 1,
	scale = 0.8
}

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
-- These are the arguments for the modem shop blip
Config.ModemManagementBlip = {
    enable = true,
    name = "Modem shop",
	sprite = 606,
	color = 1,
	scale = 0.8
}

-- this are self explainatory. But i will do it anyway ;)
-- BuyModemPrice is the price the user will need to pay to buy a
-- single modem from the shop
Config.BuyModemPrice = 501
-- RenewModemPrice is the price the user will need to pay to
-- renew the modem for the value in days defined in Config.AddDaysOnRenewal
Config.RenewModemPrice = 501
Config.AddDaysOnRenewal = 30
-- ChangePasswordPoints is the price the user will need to pay to change
-- the password of the modem
Config.ChangePasswordPoints = 50
-- WaitBeforeCreatingAgaing is the time (in seconds) that will need to pass
-- before allowing the user to create a new modem
Config.WaitBeforeCreatingAgaing = 600

Config.MinAziendaGrade = {
    ["police"] = {
        [15] = {"salary", "employes", "chat", "calls"},
        [14] = {"salary", "employes", "chat", "calls"},
        [13] = {"salary", "employes", "chat", "calls"},
        [12] = {"salary", "chat", "calls"},
        [11] = {"salary", "chat", "calls"},
        [10] = {"salary", "chat", "calls"},
        [9] = {"salary", "chat", "calls"},
        [8] = {"salary", "chat", "calls"},
        [7] = {"salary", "chat", "calls"},
        [6] = {"chat", "calls"},
        [5] = {"chat", "calls"},
        [4] = {"chat", "calls"},
        [3] = {"chat", "calls"},
        [2] = {"chat", "calls"},
        [1] = {"chat", "calls"},
        [0] = {"chat", "calls"}
    },
    ["ambulance"] = {
        [3] = {"salary", "employes", "chat", "calls"},
        [2] = {"salary", "chat", "calls"},
        [1] = {"chat", "calls"},
        [0] = {"chat", "calls"}
    }
}