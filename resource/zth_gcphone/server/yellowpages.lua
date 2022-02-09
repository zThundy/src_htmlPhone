local CACHED_YELLOWS = {}

local function YellowNotification(player, title, message)
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

gcPhoneT.deleteYellowPost = function(id)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        id = tonumber(id)
        MySQL.Async.execute("DELETE FROM phone_yellow_pages WHERE id = @id", { ['@id'] = id  })
        for k, v in pairs(CACHED_YELLOWS) do
            if tonumber(v.id) == id then
                table.remove(CACHED_YELLOWS, k)
                break
            end
        end
    else
        YellowNotification(-1, "ERROR", "APP_YELLOW_NO_TARIFF")
    end
end

gcPhoneT.createYellowPost = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        local phone_number = gcPhoneT.getPhoneNumber(identifier)
        data.author  = phone_number
        data.identifier = identifier
        data.description = data.message
        data.number = data.author
        data.date = os.time()
        MySQL.Async.insert("INSERT INTO phone_yellow_pages(identifier, number, description) VALUES(@identifier, @number, @description)", {
            ['@identifier'] = identifier,
            ['@number'] = data.author,
            ['@description'] = data.message
        })
        -- add the incremental id to local table using the last element of the
        -- table CACHED_YELLOWS
        data.id = CACHED_YELLOWS[#CACHED_YELLOWS].id + 1
        table.insert(CACHED_YELLOWS, data)
        YellowNotification(-1, "APP_YELLOW_NEW_POST_TITLE", data.message)
        TriggerClientEvent("gcphone:yellow_receivePost", player, data)
    else
        YellowNotification(-1, "ERROR", "APP_YELLOW_NO_TARIFF")
    end
end

gcPhoneT.getYellowPosts = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, #CACHED_YELLOWS * 0.01)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        return CACHED_YELLOWS
    else
        YellowNotification(-1, "ERROR", "APP_YELLOW_NO_TARIFF")
    end
end