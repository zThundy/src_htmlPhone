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
    UpdateGlobalVolume(data.volume)
    cb("ok")
end)

RegisterNUICallback("sendStartupValues", function(data, cb)
    -- inside this data, you will find:
    -- @volume | the global volume of the phone
    -- @notification | if the notifications are enabled or not
    -- @cover | the current cover of the user
    -- @airplane | if the user is in airplane or not,
    -- @twitterSound | if the twitter notifications sound are enabled or not,
    -- @twitterNotif | the state of the twitter notification
    -- eg. [true, false, false] all notifications
    -- eg. [false, true, false] only mentions
    -- eg. [false, false, true] no notifications

    NOTIFICATIONS_ENABLED = data.notification
    if data.cover ~= nil then
        myCover = string.gsub(data.cover.value, ".png", "")
    end
    GLOBAL_AIRPLANE = data.airplane
    gcPhoneServerT.updateAirplaneForUser(GLOBAL_AIRPLANE)
    UpdateGlobalVolume(data.volume)
    cb("ok")
end)

RegisterNUICallback('connettiAllaRete', function(data, cb)
    if data == false then
        ESX.ShowNotification(translate("MODEM_WRONG_PASSWORD"))
        return
    end
    WIFI_TEMP_DATA = { label = data.label, password = data.password }
    ESX.ShowNotification(translate("MODEM_CORRECT_PASSWORD"))
    UpdateWifiInfo(true, WIFI_TEMP_DATA)
    StartWifiRangeCheck()
    cb("ok")
end)

RegisterNUICallback('startCall', function(data, cb)
    if not GLOBAL_AIRPLANE then
        if data.rtcOffer == nil then data.rtcOffer = '' end
        gcPhoneServerT.startCall(data.numero, data.rtcOffer, data.extraData)
    else
        ESX.ShowNotification(translate("PHONECALLS_AEREO_MODE_ERROR"))
    end
    cb("ok")
end)

RegisterNUICallback('acceptCall', function(data, cb)
    gcPhoneServerT.acceptCall(data.infoCall, data.rtcAnswer)
    cb("ok")
end)

RegisterNUICallback('rejectCall', function(data, cb)
    gcPhoneServerT.rejectCall(data.infoCall)
    cb("ok")
end)

RegisterNUICallback('ignoreCall', function(data, cb)
    gcPhoneServerT.ignoreCall(data.infoCall)
    cb("ok")
end)

RegisterNUICallback('notififyUseRTC', function(use, cb)
    if use then
        -- Citizen.InvokeNative(0xE036A705F989E049)
        NetworkClearVoiceChannel()
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

RegisterNUICallback('sendMessage', function(data, cb)
    if not GLOBAL_AIRPLANE then
        if data.message == '%pos%' then
            local myPos = GetEntityCoords(PlayerPedId())
            data.message = 'GPS: ' .. myPos.x .. ', ' .. myPos.y
        end

        gcPhoneServerT.sendMessage(data.phoneNumber, data.message)
    else
        ESX.ShowNotification(translate("MESSAGES_AEREO_MODE_ERROR"))
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

RegisterNUICallback('updateContactAvatar', function(data, cb)
    gcPhoneServerT.updateAvatarContatto(data)
    cb("ok")
end)

RegisterNUICallback('getContacts', function(data, cb)
    cb(json.encode(PERSONAL_CONTACTS))
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
        -- remove useless data
        data.item.icon = nil
        data.item.subMenu = nil
        -- transfer typed message to the correct place
        if data.text then data.item.message = data.text end
        TriggerEvent(data.eventName, data.item)
    end
    cb("ok")
end)

RegisterNUICallback('deleteALL', function(data, cb)
    gcPhoneServerT.deleteAll()
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
    gcPhoneServerT.deleteAllPhoneHistory()
    cb("ok")
end)