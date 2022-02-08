local CACHED_YELLOWS = {}

local function YellowShowSuccess(player, title, message)
    TriggerClientEvent("gcphone:sendGenericNotification", player, {
        message = message,
        title = title,
        icon = "user",
        color = "rgb(210, 166, 5)",
        appName = "Yellow pages"
    })
end

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT * FROM phone_yellow_pages", {}, function(yellows)
        for k, v in pairs(yellows) do
            table.insert(CACHED_YELLOWS, v)
        end
    end)
end)

gcPhoneT.createYellowPost = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    data.identifier = identifier
    data.description = data.message
    data.number = data.author
    data.date = os.time()
    MySQL.Async.insert("INSERT INTO phone_yellow_pages(identifier, number, description) VALUES(@identifier, @number, @description)", {
        ['@identifier'] = identifier,
        ['@number'] = data.author,
        ['@description'] = data.message
    })
    table.insert(CACHED_YELLOWS, data)
    YellowShowSuccess(-1, "APP_YELLOW_NEW_POST_TITLE", data.message)
    TriggerClientEvent("gcphone:yellow_receivePost", player, data)
end

gcPhoneT.getYellowPosts = function()
    return CACHED_YELLOWS
end