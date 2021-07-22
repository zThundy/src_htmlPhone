RegisterNUICallback("updateNotifications", function(data, cb)
    NOTIFICATIONS_ENABLED = data
    cb("ok")
end)

RegisterNUICallback("updateAirplane", function(data, cb)
    GLOBAL_AIRPLANE = data
    gcPhoneServerT.updateAirplaneForUser(data)
    cb("ok")
end)

RegisterNUICallback("sendErrorMessage", function(data, cb)
    ESX.ShowNotification("~r~"..data.message)
    cb("ok")
end)

RegisterNUICallback("updateVolume", function(data, cb)
    -- volume = data.volume
    UpdateGlobalVolume(data.volume)
    cb("ok")
end)

RegisterNUICallback("sendStartupValues", function(data, cb)
    NOTIFICATIONS_ENABLED = data.notification
    if data.cover ~= nil then
        myCover = string.gsub(data.cover.value, ".png", "")
    end
    GLOBAL_AIRPLANE = data.airplane
    gcPhoneServerT.updateAirplaneForUser(GLOBAL_AIRPLANE)
    -- volume = data.volume
    UpdateGlobalVolume(data.volume)
    cb("ok")
end)

RegisterNUICallback('connettiAllaRete', function(data, cb)
    if data == false then
        ESX.ShowNotification(Config.Language["MODEM_WRONG_PASSWORD"])
        return
    end
    WIFI_TEMP_DATA = { label = data.label, password = data.password }
    ESX.ShowNotification(Config.Language["MODEM_CORRECT_PASSWORD"])
    UpdateWifiInfo(true, WIFI_TEMP_DATA)
    StartWifiRangeCheck()
    cb("ok")
end)

RegisterNUICallback('startCall', function(data, cb)
    if not GLOBAL_AIRPLANE then
        if data.rtcOffer == nil then data.rtcOffer = '' end
        gcPhoneServerT.startCall(data.numero, data.rtcOffer, data.extraData)
    else
        ESX.ShowNotification(Config.Language["PHONECALLS_AEREO_MODE_ERROR"])
    end
    cb("ok")
end)

RegisterNUICallback('acceptCall', function(data, cb)
    -- print(data.infoCall)
    -- print(DumpTable(data))
    gcPhoneServerT.acceptCall(data.infoCall, data.rtcAnswer)
    cb("ok")
end)

RegisterNUICallback('rejectCall', function(data, cb)
    gcPhoneServerT.rejectCall(data.infoCall)
    cb("ok")
end)

RegisterNUICallback('ignoreCall', function(data, cb)
    -- print(DumpTable(data.infoCall))
    -- print("AOOOOOOOOOOOOOOOOOOOOOO")
    gcPhoneServerT.ignoreCall(data.infoCall)
    cb("ok")
end)

RegisterNUICallback('notififyUseRTC', function(use, cb)
    if use and inCall then
        inCall = false
        Citizen.InvokeNative(0xE036A705F989E049)
        NetworkSetTalkerProximity(2.5)
    end
    cb("ok")
end)

RegisterNUICallback('onCandidates', function (data, cb)
    gcPhoneServerT.candidates(data.id, data.candidates)
    cb("ok")
end)

RegisterNUICallback("requestOfferta", function(data, cb)
    gcPhoneServerT.requestOfferFromCache()
    cb("ok")
end)

RegisterNUICallback('log', function(data, cb)
    print(data)
    cb("ok")
end)

RegisterNUICallback('focus', function(data, cb)
    cb("ok")
end)

RegisterNUICallback('blur', function(data, cb)
    cb("ok")
end)

RegisterNUICallback('reponseText', function(data, cb)
    local resp = GetResponseText(data)
    cb(json.encode({ text = resp }))
end)

RegisterNUICallback('getMessages', function(data, cb)
    cb(json.encode(messages))
end)

RegisterNUICallback('sendMessage', function(data, cb)
    if not GLOBAL_AIRPLANE then
        if data.message == '%pos%' then
            local myPos = GetEntityCoords(PlayerPedId())
            data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
        end

        gcPhoneServerT.sendMessage(data.phoneNumber, data.message)
    else
        ESX.ShowNotification(Config.Language["MESSAGES_AEREO_MODE_ERROR"])
    end
    cb("ok")
end)

RegisterNUICallback('deleteMessage', function(data, cb)
    gcPhoneServerT.deleteMessage(data.id)
    for k, v in ipairs(messages) do
        if v.id == data.id then
            table.remove(messages, k)
            SendNUIMessage({ event = 'updateMessages', messages = messages, received = 0 })
            return
        end
    end
    cb("ok")
end)

RegisterNUICallback('deleteMessageNumber', function(data, cb)
    gcPhoneServerT.deleteMessageNumber(data.number)
    cb("ok")
end)

RegisterNUICallback('deleteAllMessage', function(data, cb)
    gcPhoneServerT.deleteAllMessage() 
    cb("ok")
end)

RegisterNUICallback('setReadMessageNumber', function(data, cb)
    gcPhoneServerT.setReadMessageNumber(data.number)
    for k, v in ipairs(messages) do
        if v.transmitter == data.number then v.isRead = 1 end
    end
    cb("ok")
end)

RegisterNUICallback('addContact', function(data, cb)
    gcPhoneServerT.addContact(data.display, data.phoneNumber, data.email, data.icon) 
    cb("ok")
end)

RegisterNUICallback('updateContact', function(data, cb)
    gcPhoneServerT.updateContact(data.id, data.display, data.phoneNumber, data.email)
    cb("ok")
end)

RegisterNUICallback('deleteContact', function(data, cb)
    gcPhoneServerT.deleteContact(data.id) 
    cb("ok")
end)

RegisterNUICallback('aggiornaAvatarContatto', function(data, cb)
    -- data.id
    -- data.number
    -- data.display
    -- data.icon
    gcPhoneServerT.updateAvatarContatto(data)
    cb("ok")
end)

RegisterNUICallback('getContacts', function(data, cb)
    cb(json.encode(contacts))
end)

RegisterNUICallback('setGPS', function(data, cb)
    SetNewWaypoint(tonumber(data.x), tonumber(data.y))
    cb("ok")
end)

RegisterNUICallback('callEvent', function(data, cb)
    local eventName = data.eventName or ''
    if string.match(eventName, 'gcphone') then
        if data.data ~= nil then 
            TriggerEvent(data.eventName, data.data)
        else
            TriggerEvent(data.eventName)
        end
    end
    cb("ok")
end)

RegisterNUICallback('chiamataEmergenza', function(data, cb)
    local eventName = data.eventName or ''
    if string.match(eventName, 'gcphone') then
        TriggerEvent(data.eventName, data.item)
    end
    cb("ok")
end)

RegisterNUICallback('deleteALL', function(data, cb)
    gcPhoneServerT.deleteAll()
    cb("ok")
end)

RegisterNUICallback('faketakePhoto', function(data, cb)
    menuIsOpen = false
    SendNUIMessage({ show = false })
    TriggerEvent('camera:open')
    cb("ok")
end)

RegisterNUICallback('closePhone', function(data, cb)
    menuIsOpen = false
    SendNUIMessage({ show = false })
    PhonePlayOut()
    if Config.EnsurePropCleanup then doCleanup() end
    cb("ok")
end)

RegisterNUICallback('deletePhoneHistory', function(data, cb)
    gcPhoneServerT.deletePhoneHistory(data.numero)
    cb("ok")
end)

RegisterNUICallback('deleteAllPhoneHistory', function(data, cb)
    gcPhoneServerT.deleteAllPhoneHistory(data.infoCall)
    cb("ok")
end)