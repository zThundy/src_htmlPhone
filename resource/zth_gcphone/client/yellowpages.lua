
RegisterNetEvent("gcphone:yellow_receivePost")
AddEventHandler("gcphone:yellow_receivePost", function(data)
    SendNUIMessage({ event = "yellow_receivePost", post = data })
end)

RegisterNUICallback("createYellowPost", function(data, cb)
    gcPhoneServerT.createYellowPost(data)
    cb("ok")
end)

RegisterNUICallback("requestYellowPosts", function(data, cb)
    SendNUIMessage({ event = "receiveYellowPosts", posts = gcPhoneServerT.getYellowPosts() })
    cb("ok")
end)