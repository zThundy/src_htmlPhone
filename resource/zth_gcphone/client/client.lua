local tunnel = module("modules/TunnelV2")
gcPhoneServerT = tunnel.getInterface("gcphone", "gcphone_server_t", "gcphone_server_t")

menuIsOpen = false
PERSONAL_CONTACTS = {}
messages = {}
isDead = false

inCall = false
NOTIFICATIONS_ENABLED = true
GLOBAL_AIRPLANE = false

volume = 0.5

CAHES_WIFI_MODEMS = {}
WIFI_TEMP_DATA = {}
isConnected = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
    end

    while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end
    -- gcPhoneServerT.allUpdate()
end)

RegisterNetEvent(Config.AmbulanceJobEventName)
AddEventHandler(Config.AmbulanceJobEventName, function(_isDead)
    isDead = _isDead
    if isDead and menuIsOpen then TogglePhone() end
end)

Citizen.CreateThread(function()
    RegisterKeyMapping('+openPhone', translate("SETTINGS_KEY_LABEL"), 'keyboard', Config.KeyToOpenPhone)
    RegisterCommand('+openPhone', function()
        if not IsEntityPlayingAnim(GetPlayerPed(-1), 'mp_arresting', 'idle', 3) then
            if not isDead then
                if gcPhoneServerT.getItemAmount(Config.PhoneItemName) > 0 then
                    TogglePhone()
                else
                    ESX.ShowNotification(translate("NO_PHONE_ITEM"))
                end
            else
                ESX.ShowNotification(translate("NO_PHONE_WHILE_DEAD"))
            end
        else
            ESX.ShowNotification(translate("NO_PHONE_WHILE_ARRESTED"))
        end
    end, false)
    RegisterCommand('-openPhone', function() end, false)

    local idle = 0
    while true do
        idle = 0
        if menuIsOpen then
            while UpdateOnscreenKeyboard() == 0 do Citizen.Wait(100) end
            for _, value in ipairs(Config.Keys) do
                if IsControlJustPressed(1, value.code) or IsDisabledControlJustPressed(1, value.code) then
                    SendNUIMessage({ keyUp = value.event })
                end
            end
        else
            idle = 500
        end
        Citizen.Wait(idle)
    end
end)

RegisterNetEvent("gcphone:sendGenericNotification")
AddEventHandler("gcphone:sendGenericNotification", function(data)
    SendNUIMessage({ halfShow = true })
    SendNUIMessage({ event = "genericNotification", notif = data })
end)

function PlaySoundJS(sound, v, loop)
    local _volume = v and v or volume
    SendNUIMessage({ event = 'playSound', sound = sound, volume = _volume, loop = loop })
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

RegisterNetEvent("gcPhone:updatePhoneNumber")
AddEventHandler("gcPhone:updatePhoneNumber", function(phone_number)
    SendNUIMessage({ event = 'updateMyPhoneNumber', myPhoneNumber = phone_number })
end)

RegisterNetEvent("gcPhone:contactList")
AddEventHandler("gcPhone:contactList", function(_contacts)
    PERSONAL_CONTACTS = _contacts
    SendNUIMessage({ event = 'updateContacts', contacts = PERSONAL_CONTACTS })
end)

RegisterNetEvent("gcPhone:allMessage")
AddEventHandler("gcPhone:allMessage", function(allmessages, notReceivedMessages)
    SendNUIMessage({ event = 'updateMessages', messages = allmessages, volume = volume, received = notReceivedMessages })
    messages = allmessages
    if not GLOBAL_AIRPLANE then
        if notReceivedMessages ~= nil and notReceivedMessages > 0 then
            if notReceivedMessages == 1 then
                ESX.ShowNotification(translate("SINGLE_UNREAD_MESSAGE_NOTIFICATION"):format(notReceivedMessages))
            else
                ESX.ShowNotification(translate("MULTIPLE_UNREAD_MESSAGES_NOTIFICATION"):format(notReceivedMessages))
            end
        end
    end
end)

RegisterNetEvent("gcphone:updateValoriDati")
AddEventHandler("gcphone:updateValoriDati", function(table)
    SendNUIMessage({ event = "updateDati", data = table })
end)

RegisterNetEvent("gcPhone:receiveMessage")
AddEventHandler("gcPhone:receiveMessage", function(message, displayNotification)
    if not message then return end
    if not GLOBAL_AIRPLANE then
        SendNUIMessage({ event = 'newMessage', message = message })
        if displayNotification then
            TriggerEvent("gcphone:sendGenericNotification", {
                message = message.message,
                title = "APP_MESSAGE_TITLE",
                icon = "envelope",
                color = "rgb(255, 140, 30)",
                appName = translate("APP_MESSAGE_TITLE"),
                sound = NOTIFICATIONS_ENABLED and "msgnotify.ogg" or nil
            })
        end
        table.insert(messages, message)
        if message.owner == 0 then
            local text = translate("MESSAGE_NOTIFICATION_NO_TRANSMITTER")
            if Config.ShowNumberNotification then
                text = translate("MESSAGE_NOTIFICATION_TRANSMITTER"):format(message.transmitter)
                for _, contact in pairs(PERSONAL_CONTACTS) do
                    if contact.number == message.transmitter then
                        text = translate("MESSAGE_NOTIFICATION_TRANSMITTER"):format(contact.display)
                        break
                    end
                end
            end
            ESX.ShowNotification(text)
        end
    end
end)

RegisterNetEvent("gcPhone:waitingCall")
AddEventHandler("gcPhone:waitingCall", function(infoCall, initiator)
    if inCall then return end
    SendNUIMessage({ event = 'waitingCall', infoCall = infoCall, initiator = initiator })
    if initiator then
        PhonePlayCall()
        if not menuIsOpen then TogglePhone() end
    end
end)

RegisterNetEvent("gcPhone:phoneVoiceMail")
AddEventHandler("gcPhone:phoneVoiceMail", function(infoCall, initiator)
    Citizen.CreateThreadNow(function()
        Citizen.Wait(2000)
        infoCall.volume = volume
        SendNUIMessage({ event = 'initVoiceMail', infoCall = infoCall, initiator = initiator })
    end)
end)

RegisterNetEvent("gcPhone:phoneNoSignal")
AddEventHandler("gcPhone:phoneNoSignal", function(infoCall, initiator)
    SendNUIMessage({ event = 'noSignal', infoCall = infoCall })
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
            while inCall do
                Citizen.Wait(1000)
                if initiator then
                    infoCall.secondiRimanenti = infoCall.secondiRimanenti - 1
                    if infoCall.secondiRimanenti == 0 then gcPhoneServerT.rejectCall(infoCall) end
                end
                if Config.PhoneBoxes[infoCall.receiver_num] then
                    if not initiator then
                        coords = GetEntityCoords(GetPlayerPed(-1))
                        distance = Vdist(infoCall.coords.x, infoCall.coords.y, infoCall.coords.z, coords.x, coords.y, coords.z)
                        if distance > 1.0 then gcPhoneServerT.rejectCall(infoCall) end
                    end
                else
                    if Reti.potenzaSegnale == 0 then gcPhoneServerT.rejectCall(infoCall) end
                end
            end
        end)
        if Config.VOIPType == "tokovoip" then
            TokovoipEnstablishCall(infoCall.id)
        elseif Config.VOIPType == "saltychat" then
            if infoCall then
                gcPhoneServerT.setEndpointSource(infoCall.receiver_src)
                gcPhoneServerT.EstablishCall(infoCall.receiver_src)
            end
        elseif Config.VOIPType == "pmavoice" then
            PMAVoiceEnstablishCall(infoCall.id)
        elseif Config.VOIPType == "voicertc" then
            -- noting for now :P
        end
    end
    if not menuIsOpen then  TogglePhone() end
    PhonePlayCall()
    SendNUIMessage({ event = 'acceptCall', infoCall = infoCall, initiator = initiator })
end)

RegisterNetEvent("gcPhone:rejectCall")
AddEventHandler("gcPhone:rejectCall", function(infoCall, callDropped)
    infoCall.callDropped = callDropped or infoCall.forcedCallDrop
    if infoCall and infoCall.updateMinuti then
        if infoCall.startCall_time and infoCall.endCall_time then infoCall.callTime = infoCall.endCall_time - infoCall.startCall_time end
        if not inCall then infoCall.callTime = 0 end
        gcPhoneServerT.updateParametroTariffa(infoCall.transmitter_num, "minuti", (infoCall.secondiRimanenti - infoCall.callTime))
    end

    if inCall then
        inCall = false
        if Config.VOIPType == "tokovoip" then
            TokovoipEndCall(TokoVoipID)
        elseif Config.VOIPType == "saltychat" then
            local endPoint = gcPhoneServerT.getEndpointSource()
            if endPoint then
                gcPhoneServerT.EndCall(endPoint)
                gcPhoneServerT.removeEndpointSource()
            end
        elseif Config.VOIPType == "pmavoice" then
            PMAVoiceEndCall(0)
        elseif Config.VOIPType == "voicertc" then
            -- nothing for now :P
        end
    end

    PhonePlayText()
    SendNUIMessage({ event = 'rejectCall', infoCall = infoCall })
end)

RegisterNetEvent("gcPhone:historyCalls")
AddEventHandler("gcPhone:historyCalls", function(history)
    SendNUIMessage({ event = 'historyCalls', history = history })
end)

RegisterNetEvent("gcPhone:sendRequestedOfferta")
AddEventHandler("gcPhone:sendRequestedOfferta", function(dati, label)
    if label == "nessuno" then
        SendNUIMessage({ event = "updateOfferta", data = {
            current = dati,
            max = { 0, 0, 0 }
        } })
    else
        for k, v in pairs(Config.Tariffs) do
            if v.label == label then
                SendNUIMessage({ event = "updateOfferta", data = {
                    current = dati,
                    max = { v.minuti, v.messaggi, v.dati }
                } })
                break
            end
        end
    end
end)

RegisterNetEvent("gcPhone:candidates")
AddEventHandler("gcPhone:candidates", function(candidates)
    SendNUIMessage({ event = 'candidatesAvailable', candidates = candidates })
end)

function TogglePhone()
    menuIsOpen = not menuIsOpen
    SendNUIMessage({ show = menuIsOpen })
    local firstname, lastname = gcPhoneServerT.getFirstnameAndLastname()
    local firstjob, secondjob = gcPhoneServerT.getFirstAndSecondJob()
    SendNUIMessage({
        event = "sendParametersValues",
        job = firstjob.label,
        job2 = secondjob and secondjob.label or "None",
        firstname = firstname,
        lastname = lastname
    })
    SendNUIMessage({ event = "sendTranslations", language = getAllScopes("nui"), type = Config.ChosenLanguage })
    if menuIsOpen then 
        PhonePlayIn()
    else
        PhonePlayOut()
    end
end

function AggiornaRetiWifi(r)
    CAHES_WIFI_MODEMS = r
    -- aggiorna la lista del wifi
    SendNUIMessage({ event = "updateRetiWifi", data = CAHES_WIFI_MODEMS })
    -- aggiorna l'icona del wifi
    SendNUIMessage({ event = "updateWifi", data = isConnected })
end

function UpdateWifiInfo(connected, rete)
    isConnected = connected
    SendNUIMessage({ event = "updateWifi", data = isConnected })
    gcPhoneServerT.updateReteWifi(isConnected, rete)
end

-- funzione che controlla se sei nel range o no
-- quando ti connetti al wifi
function StartWifiRangeCheck()
    Citizen.CreateThread(function()
        local found = false
        while true do
            found = false
            if not isConnected then return end
            for k, v in pairs(CAHES_WIFI_MODEMS) do
                if v.label == WIFI_TEMP_DATA.label and v.password == WIFI_TEMP_DATA.password then
                    found = true
                    break
                end
            end
            if not found then
                isConnected = false
                WIFI_TEMP_DATA = {}
                gcPhoneServerT.updateReteWifi(isConnected, nil)
            end
            Citizen.Wait(2000)
        end
    end)
end