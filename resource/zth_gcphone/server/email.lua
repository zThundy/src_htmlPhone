gcPhoneT.email_requestMyEmail = function()
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)
            
            GetUserEmail(identifier, function(email)
                if not email then email = false end
                TriggerClientEvent("gcphone:email_sendMyEmail", player, email)
            end)
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter richiedere la tua email")
        end
    end)
end

gcPhoneT.email_sendEmail = function(data)
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    GetUserEmail(identifier, function(myEmail)
        gcPhone.isAbleToSurfInternet(identifier, 1.0, function(isAble, mbToRemove)
            if isAble then
                gcPhone.usaDatiInternet(identifier, mbToRemove)

                --[[
                    transmitter: this.myEmail,
                    receiver: '',
                    title: '',
                    message: '',
                    pic: '/html/static/img/app_email/defaultpic.png'
                ]]

                MySQL.Async.execute("INSERT INTO phone_emails(sender, receiver, title, message, pic) VALUES(@sender, @receiver, @title, @message, @pic)", {
                    ['@sender'] = myEmail,
                    ['@receiver'] = data.receiver,
                    ['@title'] = data.title,
                    ['@message'] = data.message,
                    ['@pic'] = data.pic,
                })
            else
                TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter inviare questa email")
            end
        end)
    end)
end

gcPhoneT.email_requestEmails = function()
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    GetUserEmail(identifier, function(email)
        FetchAllEmails(email, function(emails)
            gcPhone.isAbleToSurfInternet(identifier, #emails * 0.05, function(isAble, mbToRemove)
                if isAble then
                    gcPhone.usaDatiInternet(identifier, mbToRemove)

                    TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
                else
                    TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter scaricare le tue email")
                end
            end)
        end)
    end)
end

gcPhoneT.email_deleteEmail = function(emailID)
    MySQL.Async.execute("DELETE FROM phone_emails WHERE id = @id", {['@id'] = emailID}, function()
        local player = source
        local identifier = gcPhone.getPlayerID(player)

        GetUserEmail(identifier, function(email)
            FetchAllEmails(email, function(emails)
                gcPhone.isAbleToSurfInternet(identifier, #emails * 0.05, function(isAble, mbToRemove)
                    if isAble then
                        gcPhone.usaDatiInternet(identifier, mbToRemove)

                        TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
                    else
                        TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter scaricare le tue email")
                    end
                end)
            end)
        end)
    end)
end

gcPhoneT.email_registerEmail = function(email)
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)

            MySQL.Async.insert("INSERT INTO phone_users_emails(identifier, email) VALUES(@identifier, @email)", {
                ['@identifier'] = identifier,
                ['@email'] = email
            })
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter registrare la tua email")
        end
    end)
end

gcPhoneT.email_requestSentEmails = function(myEmail)
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    GetUserEmail(identifier, function(email)
        MySQL.Async.fetchAll("SELECT * FROM phone_emails WHERE sender = @sender ORDER BY id DESC LIMIT 50", {
            ['@sender'] = email
        }, function(r)
            local temp = {}
            for k, v in pairs(r) do table.insert(temp, v) end

            TriggerClientEvent("gcphone:email_sendRequestedSentEmails", player, temp)
        end)
    end)
end

function FetchAllEmails(email, cb)
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

function GetUserEmail(identifier, cb)
    if identifier then
        MySQL.Async.fetchAll("SELECT email FROM phone_users_emails WHERE identifier = @identifier", {['@identifier'] = identifier}, function(result)
            if #result == 0 or result[1] == nil then
                cb(nil)
            else
                cb(result[1].email)
            end
        end)
    end
end