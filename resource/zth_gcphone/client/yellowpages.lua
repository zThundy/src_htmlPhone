
RegisterNetEvent("gcphone:yellow_receivePosts")
AddEventHandler("gcphone:yellow_receivePosts", function(data)
    SendNUIMessage({ event = "receiveYellowPosts", posts = data })
end)

RegisterNUICallback("createYellowPost", function(data, cb)
    gcPhoneServerT.createYellowPost(data)
    cb("ok")
end)

RegisterNUICallback("requestYellowPosts", function(data, cb)
    SendNUIMessage({ event = "receiveYellowPosts", posts = gcPhoneServerT.getYellowPosts() })
end)