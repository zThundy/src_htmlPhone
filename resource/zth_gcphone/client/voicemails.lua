RegisterNUICallback("newVoicemail", function(data, cb)
    gcPhoneServerT.newVoicemail(data)
    cb("ok")
end)