TokoVoipID = nil

function TokovoipEnstablishCall(callId)
    exports["tokovoip_script"]:addPlayerToPhone(callId)
    TokoVoipID = callId
end

function TokovoipEndCall(callId)
    exports["tokovoip_script"]:removePlayerFromPhone(callId)
    TokoVoipID = nil
end