-- Configuration
local tunnel = module("modules/TunnelV2")
gcPhoneServerT = tunnel.getInterface("gcphone_server_t", "gcphone_server_t")

menuIsOpen = false
contacts = {}
messages = {}
isDead = false
ignoreFocus = false
hasFocus = false

inCall = false
stoppedPlayingUnreachable = false
secondiRimanenti = 0
NOTIFICATIONS_ENABLED = true
GLOBAL_AIRPLANE = false

currentPlaySound = false

volume = 0.5

segnaleRadio = 0
CAHES_WIFI_MODEMS = {}
WIFI_TEMP_DATA = {}
isConnected = false
myPhoneNumber = ''

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(500)
    end

    ESX.PlayerData = ESX.GetPlayerData()
    gcPhoneServerT.allUpdate()
end)

RegisterNetEvent("esx_ambulancejob:setDeathStatus")
AddEventHandler('esx_ambulancejob:setDeathStatus', function(_isDead) isDead = _isDead end)

--====================================================================================
--  
--====================================================================================
Citizen.CreateThread(function()
    RegisterKeyMapping('+openPhone', Config.Language["SETTINGS_KEY_LABEL"], 'keyboard', Config.KeyToOpenPhone)
    RegisterCommand('+openPhone', function()
        if not IsEntityPlayingAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 3) then
            if not isDead then
                if gcPhoneServerT.getItemAmount(Config.PhoneItemName) > 0 then
                    TogglePhone()
                else
                    ESX.ShowNotification(Config.Language["NO_PHONE_ITEM"])
                end
            else
                ESX.ShowNotification(Config.Language["NO_PHONE_WHILE_DEAD"])
            end
        else
            ESX.ShowNotification(Config.Language["NO_PHONE_WHILE_ARRESTED"])
        end
    end, false)
    RegisterCommand('-openPhone', function() end, false)

    while true do
        Citizen.Wait(0)

        if menuIsOpen then
            while UpdateOnscreenKeyboard() == 0 do
                Citizen.Wait(100)
            end

            for _, value in ipairs(Config.Keys) do
                if IsControlJustPressed(1, value.code) or IsDisabledControlJustPressed(1, value.code) then
                    SendNUIMessage({ keyUp = value.event })
                end
            end

            -- if useMouse == true and hasFocus == ignoreFocus then
            --     local nuiFocus = not hasFocus
            --     SetNuiFocus(nuiFocus, nuiFocus)
            --     hasFocus = nuiFocus
            -- elseif useMouse == false and hasFocus == true then
            if hasFocus then
                SetNuiFocus(false, false)
                hasFocus = false
            end
        else
            if hasFocus then
                SetNuiFocus(false, false)
                hasFocus = false
            end
        end
    end
end)


RegisterNetEvent("gcphone:sendGenericNotification")
AddEventHandler("gcphone:sendGenericNotification", function(data)
    --[[
        Vue.notify({
            message: store.getters.LangString(data.message),
            title: store.getters.LangString(data.title) + ':',
            icon: data.icon,
            backgroundColor: data.color,
            appName: data.appName
        })
    ]]
    SendNUIMessage({ event = "genericNotification", notif = data })
end)


-- utile dal js per l'appstore, non qui :/
--[[
    RegisterNetEvent('gcPhone:setEnableApp')
    AddEventHandler('gcPhone:setEnableApp', function(appName, enable)
        SendNUIMessage({ event = 'setEnableApp', appName = appName, enable = enable })
    end)

    RegisterNetEvent("gcPhone:forceOpenPhone")
    AddEventHandler("gcPhone:forceOpenPhone", function(_myPhoneNumber)
        if menuIsOpen == false then
            TogglePhone()
        end
    end)
]]

--==================================================================================================================
--------  Funzioni per i suoni
--==================================================================================================================

function PlaySoundJS(sound, v)
    local _volume = v and v or volume
    -- print("riproduco suono", sound, _volume)
    SendNUIMessage({ event = 'playSound', sound = sound, volume = _volume })
end

function SetSoundVolumeJS(sound, v)
    local _volume = v and v or volume
    SendNUIMessage({ event = 'setSoundVolume', sound = sound, volume = _volume })
end

function UpdateGlobalVolume(v)
    volume = v
    SendNUIMessage({ event = 'updateGlobalVolume', volume = volume })
end

function StopSoundJS(sound)
    SendNUIMessage({ event = 'stopSound', sound = sound })
end
 
--====================================================================================
--  Events
--====================================================================================

RegisterNetEvent("gcPhone:updatePhoneNumber")
AddEventHandler("gcPhone:updatePhoneNumber", function(phone_number)
    myPhoneNumber = phone_number
    SendNUIMessage({ event = 'updateMyPhoneNumber', myPhoneNumber = myPhoneNumber })
end)

RegisterNetEvent("gcPhone:contactList")
AddEventHandler("gcPhone:contactList", function(_contacts)
    contacts = _contacts
    SendNUIMessage({ event = 'updateContacts', contacts = contacts })
end)

RegisterNetEvent("gcPhone:allMessage")
AddEventHandler("gcPhone:allMessage", function(allmessages, notReceivedMessages)
    SendNUIMessage({ event = 'updateMessages', messages = allmessages })
    messages = allmessages

    if not GLOBAL_AIRPLANE then
        if notReceivedMessages ~= nil then
            if notReceivedMessages > 0 then
                if notReceivedMessages == 1 then
                    ESX.ShowNotification(Config.Language["SINGLE_UNREAD_MESSAGE_NOTIFICATION"]:format(notReceivedMessages))
                else
                    ESX.ShowNotification(Config.Language["MULTIPLE_UNREAD_MESSAGES_NOTIFICATION"]:format(notReceivedMessages))
                end

                if NOTIFICATIONS_ENABLED then
                    DrawNotification(false, false)
                    PlaySoundJS('msgnotify.ogg')
                    Citizen.Wait(3000)
                    StopSoundJS('msgnotify.ogg')
                end
            end
        end
    end
end)

--[[
    RegisterNetEvent("gcPhone:getBourse")
    AddEventHandler("gcPhone:getBourse", function(bourse)
        SendNUIMessage({ event = 'updateBourse', bourse = bourse })
    end)
]]

RegisterNetEvent("gcphone:updateValoriDati")
AddEventHandler("gcphone:updateValoriDati", function(table)
    SendNUIMessage({ event = "updateDati", data = table })
end)

RegisterNetEvent("gcphone:aggiornameAConnessione")
AddEventHandler("gcphone:aggiornameAConnessione", function(potenzaSegnale)
    if segnaleRadio == 0 and segnaleRadio ~= potenzaSegnale then
        gcPhoneServerT.allUpdate()
    end

    segnaleRadio = potenzaSegnale
    local data = { potenza = potenzaSegnale }
    SendNUIMessage({ event = "updateSegnale", data = data })
    
    gcPhoneServerT.updateSegnaleTelefono(potenzaSegnale)
end)

RegisterNetEvent("gcPhone:receiveMessage")
AddEventHandler("gcPhone:receiveMessage", function(message)
    if not message then return end
    if not GLOBAL_AIRPLANE then
        SendNUIMessage({ event = 'newMessage', message = message })
        table.insert(messages, message)

        if message.owner == 0 then
            local text = Config.Language["MESSAGE_NOTIFICATION_NO_TRANSMITTER"]
            if Config.ShowNumberNotification then
                text = Config.Language["MESSAGE_NOTIFICATION_TRANSMITTER"]:format(message.transmitter)

                for _, contact in pairs(contacts) do
                    if contact.number == message.transmitter then
                        text = Config.Language["MESSAGE_NOTIFICATION_TRANSMITTER"]:format(contact.display)
                        break
                    end
                end
            end

            ESX.ShowNotification(text)
            if NOTIFICATIONS_ENABLED then
                PlaySoundJS('msgnotify.ogg')
                Citizen.Wait(3000)
                StopSoundJS('msgnotify.ogg')
            end
        end
    end
end)

--====================================================================================
--  Function client | Appels
--====================================================================================

RegisterNetEvent("gcPhone:waitingCall")
AddEventHandler("gcPhone:waitingCall", function(infoCall, initiator)
    if inCall then return end
    SendNUIMessage({ event = 'waitingCall', infoCall = infoCall, initiator = initiator })

    if initiator == true then
        PhonePlayCall()
        if menuIsOpen == false then
            TogglePhone()
        end
    end
end)

RegisterNetEvent("gcPhone:phoneUnreachable")
AddEventHandler("gcPhone:phoneUnreachable", function(infoCall, initiator)
    secondiRimanenti = infoCall.secondiRimanenti
    count = 0

    Citizen.CreateThreadNow(function()
        stoppedPlayingUnreachable = false
        Citizen.Wait(2000)
        SendNUIMessage({ event = 'acceptCall', infoCall = infoCall, initiator = initiator })

        if stoppedPlayingUnreachable == false then
            PlaySoundJS('phoneunreachable.ogg')
            count = 0
                
            while true do
                if count == 11 then TriggerEvent("gcPhone:rejectCall", infoCall) end

                if stoppedPlayingUnreachable == true then
                    stoppedPlayingUnreachable = false
                    StopSoundJS('phoneunreachable.ogg')
                    return
                end

                Citizen.Wait(1000)
                count = count + 1
            end
        else
            stoppedPlayingUnreachable = false
        end
    end)
end)

RegisterNetEvent("gcPhone:phoneNoSignal")
AddEventHandler("gcPhone:phoneNoSignal", function(infoCall, initiator)
    secondiRimanenti = infoCall.secondiRimanenti
    count = 0

    Citizen.CreateThreadNow(function()
        stoppedPlayingUnreachable = false
        Citizen.Wait(2000)

        if stoppedPlayingUnreachable == false then
            PlaySoundJS('phonenosignal.ogg')
            count = 0
            
            while true do
                if count == 1 then
                    gcPhoneServerT.rejectCall(infoCall)
                end

                if stoppedPlayingUnreachable == true then
                    stoppedPlayingUnreachable = false
                    StopSoundJS('phonenosignal.ogg')
                    return
                end
                
                Citizen.Wait(1000)
                count = count + 1
            end
        else
            stoppedPlayingUnreachable = false
        end
    end)
end)

-- questo evento viene chiamato dal server quando un giocatore
-- entra in chiamata con un altro. Questo permette allo script di rimuovere
-- i minuti mentre si è in chiamata
RegisterNetEvent("gcPhone:acceptCall")
AddEventHandler("gcPhone:acceptCall", function(infoCall, initiator)
    if not inCall then
        inCall = true

        Citizen.CreateThread(function()
            local coords, distance = nil, nil
            secondiRimanenti = infoCall.secondiRimanenti
            if not infoCall.updateMinuti then secondiRimanenti = 1000000 end
            -- print("Accetto la chiamata chicco, infoCall.updateMinuti", infoCall.updateMinuti, "secondiRimanenti", secondiRimanenti)

            while inCall do
                Citizen.Wait(1000)
                if initiator then
                    secondiRimanenti = secondiRimanenti - 1

                    if secondiRimanenti == 0 then 
                        gcPhoneServerT.rejectCall(infoCall)
                    end
                end

                if Config.PhoneBoxes[infoCall.receiver_num] then
                    if not initiator then
                        coords = GetEntityCoords(GetPlayerPed(-1))
                        distance = Vdist(infoCall.coords.x, infoCall.coords.y, infoCall.coords.z, coords.x, coords.y, coords.z)
                        if distance > 1.0 then gcPhoneServerT.rejectCall(infoCall) end
                    end
                else
                    if segnaleRadio == 0 then
                        gcPhoneServerT.rejectCall(infoCall)
                    end
                end
            end
        
            PlaySoundJS('callend.ogg')
            Wait(1500)
            StopSoundJS('callend.ogg')
        end)
        
        if Config.EnableTokoVoip then
            -- print("aggiungo in canale "..infoCall.id)
            TokovoipEnstablishCall(infoCall.id)
        elseif Config.EnableSaltyChat then
            if infoCall then
                gcPhoneServerT.setEndpointSource(infoCall.receiver_src)
                gcPhoneServerT.EstablishCall(infoCall.receiver_src)
            end
        end
    end

    if menuIsOpen == false then 
        TogglePhone()
    end

    PhonePlayCall()
    SendNUIMessage({ event = 'acceptCall', infoCall = infoCall, initiator = initiator })
end)

RegisterNetEvent("gcPhone:rejectCall")
AddEventHandler("gcPhone:rejectCall", function(infoCall)
    -- print("--------------- call ended")
    -- print(ESX.DumpTable(infoCall))

    if infoCall and infoCall.updateMinuti then
        if not inCall then secondiRimanenti = infoCall.secondiRimanenti end
        -- print("Sto nel reject da parte del chiamante", infoCall.secondiRimanenti, secondiRimanenti, infoCall.updateMinuti)
        gcPhoneServerT.updateParametroTariffa(infoCall.transmitter_num, "minuti", secondiRimanenti)
    end

    if stoppedPlayingUnreachable == false then
        stoppedPlayingUnreachable = true
    end

    if inCall then
        inCall = false
        -- Citizen.InvokeNative(0xE036A705F989E049)
        -- NetworkClearVoiceChannel
        -- NetworkSetTalkerProximity(2.5)
        -- print("rimuovo canale "..TokoVoipID)
        if Config.EnableTokoVoip then
            -- print("aggiungo in canale "..infoCall.id)
            TokovoipEndCall(TokoVoipID)
        elseif Config.EnableSaltyChat then
            local endPoint = gcPhoneServerT.getEndpointSource()
            -- print(endPoint, GetPlayerServerId(PlayerId()))
            if endPoint then
                gcPhoneServerT.EndCall(endPoint)
                gcPhoneServerT.removeEndpointSource()
            end
        end
    end

    PhonePlayText()
    SendNUIMessage({ event = 'rejectCall', infoCall = infoCall })
end)

RegisterNetEvent("gcPhone:historiqueCall")
AddEventHandler("gcPhone:historiqueCall", function(historique)
    SendNUIMessage({ event = 'historiqueCall', historique = historique })
end)

--====================================================================================
--  Event NUI - Appels
--====================================================================================

RegisterNetEvent("gcPhone:sendRequestedOfferta")
AddEventHandler("gcPhone:sendRequestedOfferta", function(dati, label)
    ESX.TriggerServerCallback("esx_cartesim:getPianoTariffario", function(massimo)
        -- print("Tariffa telefono", massimo.minuti, massimo.messaggi, massimo.dati)
        local info = {
            current = dati,
            max = {
                massimo.minuti,
                massimo.messaggi,
                massimo.dati
            }
        }
        SendNUIMessage({ event = "updateOfferta", data = info })
    end, label)
end)

RegisterNetEvent("gcPhone:candidates")
AddEventHandler("gcPhone:candidates", function(candidates)
    SendNUIMessage({ event = 'candidatesAvailable', candidates = candidates })
end)

function GetResponseText(d)
    local limit = d.limit or 255
    local text = d.text or ''
    local title = d.title or "NO_LABEL_DEFINED"
    
    AddTextEntry('CUSTOM_PHONE_TITLE', title)
    DisplayOnscreenKeyboard(1, "CUSTOM_PHONE_TITLE", "", text, "", "", "", limit)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)
        Wait(0)
    end

    if GetOnscreenKeyboardResult() then
        text = GetOnscreenKeyboardResult()
    end

    return text
end

function TogglePhone()
    ESX.PlayerData = ESX.GetPlayerData()

    menuIsOpen = not menuIsOpen
    SendNUIMessage({ show = menuIsOpen })

    if needAuth then
        gcPhoneServerT.authServer()
    end
    
    local firstname, lastname = gcPhoneServerT.getFirstnameAndLastname()
    local firstjob, secondjob = gcPhoneServerT.getFirstAndSecondJob()
    SendNUIMessage({
        event = "sendParametersValues",
        job = firstjob.label,
        job2 = secondjob and secondjob.label or "None",
        firstname = firstname,
        lastname = lastname
    })

    if menuIsOpen == true then 
        PhonePlayIn()
    else
        PhonePlayOut()
    end
end

---------------------------------------------------------------------------------
-- CALLBACK DELLE RETI WIFI
---------------------------------------------------------------------------------

function AggiornaRetiWifi(r)
    -- print("sto aggiornando retiwifi")
    -- print(json.encode(retiWifiServer))
    CAHES_WIFI_MODEMS = r

    -- aggiorna la lista del wifi
    SendNUIMessage({ event = "updateRetiWifi", data = CAHES_WIFI_MODEMS })
    -- aggiorna l'icona del wifi
    SendNUIMessage({ event = "updateWifi", data = { hasWifi = isConnected } })
end

RegisterNetEvent("gcphone:updateWifi")
AddEventHandler("gcphone:updateWifi", function(connected, rete)
    -- print("updating isConnected")
    isConnected = connected
    SendNUIMessage({ event = "updateWifi", data = {hasWifi = isConnected} })
    gcPhoneServerT.updateReteWifi(isConnected, rete)
end)

-- funzione che controlla se sei nel range o no
-- quando ti connetti al wifi
function StartWifiRangeCheck()
    local found = false

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(2000)
            found = false

            if isConnected then
                -- print("sei connesso")
                for k, v in pairs(CAHES_WIFI_MODEMS) do
                    -- print(v.label, WIFI_TEMP_DATA.label, v.password, WIFI_TEMP_DATA.password)
                    if v.label == WIFI_TEMP_DATA.label and v.password == WIFI_TEMP_DATA.password then
                        found = true
                        -- print("rete trovata")
                        break
                    end
                end
                -- print(found)
                if not found then
                    isConnected = false
                    WIFI_TEMP_DATA = {}
                    gcPhoneServerT.updateReteWifi(isConnected, nil)
                end
            else
                return
            end
        end
    end)
end