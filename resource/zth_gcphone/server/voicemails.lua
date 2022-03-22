gcPhoneT.newVoicemail = function(data)
    print("called")
    local player = source
    if not data.display then data.display = "Voicemails" end
    print(json.encode(data))

    _addMessage(data.display, data.number, translate("VOICEMAIL_NEW_AUDIO"):format(data.number), 0, function(message)
        TriggerClientEvent("gcPhone:receiveMessage", player, message, true)
    end)
end