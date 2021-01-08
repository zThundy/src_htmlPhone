ESX.RegisterServerCallback("gcphone:news_requestMyJob", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.job.name)
end)


RegisterServerEvent("gcphone:news_requestEmails")
AddEventHandler("gcphone:news_requestEmails", function()
    local player = source

    GetFetchedNews(function(news)
        TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
    end)
end)


RegisterServerEvent("gcphone:news_sendNewPost")
AddEventHandler("gcphone:news_sendNewPost", function(data)
    local player = source

    MySQL.Async.execute("INSERT INTO phone_news(message, pics) VALUES(@message, @pics)", {
        ['@message'] = data.message,
        ['@pics'] = json.encode(data.pics)
    }, function()
        
        GetFetchedNews(function(news)
            TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
        end)
    end)
end)


function GetFetchedNews(cb)
    MySQL.Async.fetchAll("SELECT * FROM phone_news ORDER BY id DESC LIMIT 50", {}, function(result)
        for k, v in pairs(result) do
            v.pics = json.decode(v.pics)
        end

        cb(result)
    end)
end