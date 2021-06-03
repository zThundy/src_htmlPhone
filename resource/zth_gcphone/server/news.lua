local function GetFetchedNews(cb)
    MySQL.Async.fetchAll("SELECT * FROM phone_news ORDER BY id DESC LIMIT 50", {}, function(result)
        for k, v in pairs(result) do
            v.pics = json.decode(v.pics)
            v.description = v.message
            v.message = nil
        end

        cb(result)
    end)
end

local function NewsShowSuccess(player, title, message)
	TriggerClientEvent("gcphone:sendGenericNotification", player, {
		message = message,
		title = title,
		icon = "book",
		color = "rgb(124, 122, 255)",
		appName = "News"
	})
end

gcPhoneT.news_requestMyJob = function()
    local player = source
    local xPlayer = ESX.GetPlayerFromId(player)
    return xPlayer.job.name
end

gcPhoneT.news_requestNews = function()
    local player = source
    GetFetchedNews(function(news)
        TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
    end)
end

gcPhoneT.news_sendNewPost = function(data)
    local player = source

    if data.message == "" or #data.pics == 0 then
        NewsShowSuccess(player, "APP_NEWS_POST_ERROR_TITLE", "APP_NEWS_POST_ERROR_DESCRIPTION")
        return
    end

    MySQL.Async.execute("INSERT INTO phone_news(message, pics) VALUES(@message, @pics)", {
        ['@message'] = data.message,
        ['@pics'] = json.encode(data.pics)
    }, function()
        GetFetchedNews(function(news)
            TriggerClientEvent("gcphone:news_sendRequestedNews", player, news)
            NewsShowSuccess(player, "APP_NEWS_NEW_POST_TITLE", "APP_NEWS_NEW_POST_DESCRIPTION")
        end)
    end)
end