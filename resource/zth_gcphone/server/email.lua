local function FetchAllEmails(email, cb)
    if email then
        MySQL.Async.fetchAll("SELECT * FROM phone_emails WHERE receiver = @email ORDER BY id DESC LIMIT 50", {
            ['@email'] = email
        }, function(r)
            local temp = {}
            for k, v in pairs(r) do table.insert(temp, v) end
            cb(temp)
        end)
    end
end

local function GetUserEmail(identifier, cb)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        if identifier then
            MySQL.Async.fetchAll("SELECT email FROM phone_users_emails WHERE identifier = @identifier", {['@identifier'] = identifier}, function(result)
                if #result == 0 or result[1] == nil then
                    cb(nil)
                else
                    cb(result[1].email)
                end
            end)
        end
    else
        TriggerClientEvent("gcphone:sendGenericNotification", player, {
            message = "APP_EMAIL_ERROR_INTERNET",
            title = "Email",
            icon = "envelope",
            color = "rgb(216, 71, 49)",
            appName = "Email"
        })
    end
end

gcPhoneT.email_requestMyEmail = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GetUserEmail(identifier, function(email)
        if not email then email = false end
        TriggerClientEvent("gcphone:email_sendMyEmail", player, email)
    end)
end

gcPhoneT.email_sendEmail = function(data)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GetUserEmail(identifier, function(myEmail)
        local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 1.0)
        if isAble then
            gcPhoneT.useInternetData(identifier, mbToRemove)
            MySQL.Async.execute("INSERT INTO phone_emails(sender, receiver, title, message, pic) VALUES(@sender, @receiver, @title, @message, @pic)", {
                ['@sender'] = myEmail,
                ['@receiver'] = data.receiver,
                ['@title'] = data.title,
                ['@message'] = data.message,
                ['@pic'] = data.pic,
            })
        else
            TriggerClientEvent("gcphone:sendGenericNotification", player, {
                message = "APP_EMAIL_ERROR_INTERNET",
                title = "Email",
                icon = "envelope",
                color = "rgb(216, 71, 49)",
                appName = "Email"
            })
        end
    end)
end

gcPhoneT.email_requestEmails = function()
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GetUserEmail(identifier, function(email)
        FetchAllEmails(email, function(emails)
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, #emails * 0.05)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
            else
                TriggerClientEvent("gcphone:sendGenericNotification", player, {
                    message = "APP_EMAIL_ERROR_INTERNET",
                    title = "Email",
                    icon = "envelope",
                    color = "rgb(216, 71, 49)",
                    appName = "Email"
                })
            end
        end)
    end)
end

gcPhoneT.email_deleteEmail = function(emailID)
    MySQL.Async.execute("DELETE FROM phone_emails WHERE id = @id", {['@id'] = emailID}, function()
        local player = source
        local identifier = gcPhoneT.getPlayerID(player)
        GetUserEmail(identifier, function(email)
            FetchAllEmails(email, function(emails)
                local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, #emails * 0.05)
                if isAble then
                    gcPhoneT.useInternetData(identifier, mbToRemove)
                    TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
                else
                    TriggerClientEvent("gcphone:sendGenericNotification", player, {
                        message = "APP_EMAIL_ERROR_INTERNET",
                        title = "Email",
                        icon = "envelope",
                        color = "rgb(216, 71, 49)",
                        appName = "Email"
                    })
                end
            end)
        end)
    end)
end

gcPhoneT.email_registerEmail = function(email)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, 0.5)
    if isAble then
        gcPhoneT.useInternetData(identifier, mbToRemove)
        MySQL.Async.insert("INSERT INTO phone_users_emails(identifier, email) VALUES(@identifier, @email)", {
            ['@identifier'] = identifier,
            ['@email'] = email
        })
    else
        TriggerClientEvent("gcphone:sendGenericNotification", player, {
            message = "APP_EMAIL_ERROR_INTERNET",
            title = "Email",
            icon = "envelope",
            color = "rgb(216, 71, 49)",
            appName = "Email"
        })
    end
end

gcPhoneT.email_requestSentEmails = function(myEmail)
    local player = source
    local identifier = gcPhoneT.getPlayerID(player)
    GetUserEmail(identifier, function(email)
        MySQL.Async.fetchAll("SELECT * FROM phone_emails WHERE sender = @sender ORDER BY id DESC LIMIT 50", {
            ['@sender'] = email
        }, function(r)
            local temp = {}
            for k, v in pairs(r) do table.insert(temp, v) end
            local isAble, mbToRemove = gcPhoneT.isAbleToSurfInternet(identifier, #temp * 0.1)
            if isAble then
                gcPhoneT.useInternetData(identifier, mbToRemove)
                TriggerClientEvent("gcphone:email_sendRequestedSentEmails", player, temp)
            else
                TriggerClientEvent("gcphone:sendGenericNotification", player, {
                    message = "APP_EMAIL_ERROR_INTERNET",
                    title = "Email",
                    icon = "envelope",
                    color = "rgb(216, 71, 49)",
                    appName = "Email"
                })
            end
        end)
    end)
end