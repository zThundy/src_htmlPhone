ESX.RegisterServerCallback("gcphone:news_requestMyJob", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.job.name)
end)


RegisterServerEvent("gcphone:news_requestEmails")
AddEventHandler("gcphone:news_requestEmails", function()
    local player = source
    local news = GetFetchedNews()
    
    TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
end)


RegisterServerEvent("gcphone:news_sendNewPost")
AddEventHandler("gcphone:news_sendNewPost", function(data)
    local player = source

    MySQL.Async.execute("INSERT INTO phone_news(message, pics) VALUES(@message, @pics)", {
        ['@message'] = data.message,
        ['@pics'] = json.encode(data.pics)
    }, function()
        local news = GetFetchedNews()

        TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
    end)
end)


function GetFetchedNews()
    return MySQL.Sync.fetchAll("SELECT * FROM phone_news ORDER BY id DESC LIMIT 50", {})
end