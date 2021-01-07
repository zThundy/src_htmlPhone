RegisterServerEvent("gcphone:email_requestMyEmail")
AddEventHandler("gcphone:email_requestMyEmail", function()
    local player = source
    local identifier = gcPhone.getPlayerID(player)

    gcPhone.isAbleToSurfInternet(identifier, 0.5, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)
            
            local email = GetUserEmail(identifier)
            
            TriggerClientEvent("gcphone:email_sendMyEmail", player, email)
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter richiedere la tua email")
        end
    end)
end)


RegisterServerEvent("gcphone:email_sendEmail")
AddEventHandler("gcphone:email_sendEmail", function(data)
    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local myEmail = GetUserEmail(identifier)

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


RegisterServerEvent("gcphone:email_requestEmails")
AddEventHandler("gcphone:email_requestEmails", function(email)
    local player = source
    local emails = FetchAllEmails(email)

    gcPhone.isAbleToSurfInternet(identifier, #emails * 0.05, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)

            TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter scaricare le tue email")
        end
    end)
end)


RegisterServerEvent("gcphone:email_deleteEmail")
AddEventHandler("gcphone:email_deleteEmail", function(emailID)
    MySQL.Sync.execute("DELETE FROM phone_emails WHERE id = @id", {['@id'] = emailID})

    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local email = GetUserEmail(identifier)
    local emails = FetchAllEmails(email)

    gcPhone.isAbleToSurfInternet(identifier, #emails * 0.05, function(isAble, mbToRemove)
		if isAble then
            gcPhone.usaDatiInternet(identifier, mbToRemove)

            TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
        else
            TriggerClientEvent("esx:showNotification", player, "~r~Non hai abbastanza giga per poter scaricare le tue email")
        end
    end)
end)


RegisterServerEvent("gcphone:email_registerEmail")
AddEventHandler("gcphone:email_registerEmail", function(email)
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
end)


RegisterServerEvent("gcphone:email_requestSendEmails")
AddEventHandler("gcphone:email_requestSendEmails", function(myEmail)
    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local email = GetUserEmail(identifier)

    MySQL.Async.fetchAll("SELECT * FROM phone_emails WHERE sender = @sender ORDER BY id DESC LIMIT 50", {
        ['@sender'] = email
    }, function(r)
        TriggerClientEvent("gcphone:email_sendRequestedSentEmails", player, r)
    end)
end)


function FetchAllEmails(email)
    if email then
        local emails = {}
        local tempEmails = MySQL.Sync.fetchAll("SELECT * FROM phone_emails WHERE receiver = @email ORDER BY id DESC LIMIT 50", {['@email'] = email})

        for k, v in pairs(tempEmails) do emails[v.id] = v end
        return emails
    end
end


function GetUserEmail(identifier)
    if identifier then
        local result = MySQL.Sync.fetchAll("SELECT email FROM phone_users_emails WHERE identifier = @identifier", {['@identifier'] = identifier})
        return result[1].email or nil
    end
end