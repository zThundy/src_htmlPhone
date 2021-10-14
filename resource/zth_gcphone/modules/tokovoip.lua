function TokovoipEnstablishCall(callId)
    exports["tokovoip_script"]:addPlayerToPhone(callId)
end

function TokovoipEndCall(callId)
    exports["tokovoip_script"]:removePlayerFromPhone(callId)
end