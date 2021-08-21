--====================================================================================
--  Telefoni Fissi
--====================================================================================

FIXED_PHONES_INFO = {}

local function isNumberInCall(phone_number)
    for _, infoCall in pairs(Chiamate) do
        if infoCall.receiver_num == phone_number then return true end
    end
    return false
end

function CallStaticPhone(player, phone_number, rtcOffer, extraData)
    local indexCall = CALL_INDEX
    CALL_INDEX = CALL_INDEX + 1
    local hidden = string.sub(phone_number, 1, 1) == '#'
    if hidden == true then
        phone_number = string.sub(phone_number, 2)
    end
	local identifier = gcPhoneT.getPlayerID(player)
    local srcPhone = ''
    if extraData ~= nil and extraData.useNumber ~= nil then
        srcPhone = extraData.useNumber
    else
        srcPhone = gcPhoneT.getPhoneNumber(identifier)
    end
    local canCall = not isNumberInCall(phone_number)
    if canCall then
        Chiamate[indexCall] = {
            id = indexCall,
            transmitter_src = player,
            transmitter_num = srcPhone,
            receiver_src = nil,
            receiver_num = phone_number,
            is_valid = false,
            is_accepts = false,
            hidden = hidden,
            rtcOffer = rtcOffer,
            extraData = extraData,
            coords = Config.PhoneBoxes[phone_number].coords
        }
        FIXED_PHONES_INFO[indexCall] = Chiamate[indexCall]
        TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, FIXED_PHONES_INFO)
        TriggerClientEvent('gcPhone:waitingCall', player, Chiamate[indexCall], true)
    else
        TriggerClientEvent("esx:showNotification", player, Config.Language["PHONEBOX_PHONE_OCCUPIED"])
    end
end

function onAcceptStaticPhone(player, infoCall, rtcAnswer)
    local id = infoCall.id
    if Chiamate[id] ~= nil then
        Chiamate[id].receiver_src = player
        ACTIVE_CALLS[Chiamate[id].transmitter_src] = true
        ACTIVE_CALLS[Chiamate[id].receiver_src] = true
        if Chiamate[id].transmitter_src ~= nil and Chiamate[id].receiver_src ~= nil then
            Chiamate[id].is_accepts = true
            Chiamate[id].forceSaveAfter = true
            Chiamate[id].rtcAnswer = rtcAnswer
            FIXED_PHONES_INFO[id] = nil
            TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, FIXED_PHONES_INFO)
            TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].transmitter_src, Chiamate[id], true)
            if Chiamate[id] ~= nil then
                SetTimeout(0, function() TriggerClientEvent('gcPhone:acceptCall', Chiamate[id].receiver_src, Chiamate[id], false) end)
            end
            SavePhoneCall(Chiamate[id])
        end
    end
end

function onRejectFixePhone(player, infoCall, rtcAnswer)
    local id = infoCall.id
    FIXED_PHONES_INFO[id] = nil
    TriggerClientEvent('gcPhone:notifyFixePhoneChange', -1, FIXED_PHONES_INFO)
    TriggerClientEvent('gcPhone:rejectCall', Chiamate[id].transmitter_src, "TEST")
    if Chiamate[id].is_accepts == false then SavePhoneCall(Chiamate[id]) end
    Chiamate[id] = nil 
end

RegisterServerEvent('gcPhone:register_FixePhone')
AddEventHandler('gcPhone:register_FixePhone', function(phone_number, coords)
	Config.PhoneBoxes[phone_number] = {name = "TEST"..phone_number, coords = {x = coords.x, y = coords.y, z = coords.z}}
	TriggerClientEvent('gcPhone:register_FixePhone', -1, phone_number, Config.PhoneBoxes[phone_number])
end)