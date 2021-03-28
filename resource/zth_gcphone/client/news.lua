RegisterNUICallback("fetchNews", function(data, cb)
    gcPhoneServerT.news_requestEmails()
    cb("ok")
end)


RegisterNetEvent("gcphone:news_sendRequestedNews")
AddEventHandler("gcphone:news_sendRequestedNews", function(news)
    SendNUIMessage({ event = "sendRequestedNews", news = news })
end)


RegisterNUICallback("postNews", function(data, cb)
    gcPhoneServerT.news_sendNewPost(data)
    cb("ok")
end)


RegisterNUICallback("requestJob", function(data, cb)
    local job = gcPhoneServerT.news_requestMyJob()
    SendNUIMessage({ event = "receiveNewsJob", job = job })
    cb("ok")
end)