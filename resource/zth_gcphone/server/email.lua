RegisterServerEvent("gcphone:email_requestMyEmail")
AddEventHandler("gcphone:email_requestMyEmail", function()
    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local email = GetUserEmail(identifier)
    
    TriggerClientEvent("gcphone:email_sendMyEmail", player, email)
end)


RegisterServerEvent("gcphone:email_sendEmail")
AddEventHandler("gcphone:email_sendEmail", function(data)
    --[[
        transmitter: this.myEmail,
        receiver: '',
        title: '',
        message: '',
        pic: '/html/static/img/app_email/defaultpic.png'
    ]]

    MySQL.Async.execute("INSERT INTO phone_emails(sender, receiver, title, message, pic) VALUES(@sender, @receiver, @title, @message, @pic)", {
        ['@sender'] = data.receiver,
        ['@receiver'] = data.transmitter,
        ['@title'] = data.title,
        ['@message'] = data.message,
        ['@pic'] = data.pic,
    })
end)


RegisterServerEvent("gcphone:email_requestEmails")
AddEventHandler("gcphone:email_requestEmails", function(email)
    local player = source
    local emails = FetchAllEmails(email)

    TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
end)


RegisterServerEvent("gcphone:email_deleteEmail")
AddEventHandler("gcphone:email_deleteEmail", function(emailID)
    MySQL.Sync.execute("DELETE FROM phone_emails WHERE id = @id", {['@id'] = emailID})

    local player = source
    local identifier = gcPhone.getPlayerID(player)
    local email = GetUserEmail(identifier)
    local emails = FetchAllEmails(email)

    TriggerClientEvent("gcphone:email_sendRequestedEmails", player, emails)
end)


function FetchAllEmails(email)
    if email then
        return MySQL.Sync.fetchAll("SELECT * FROM phone_emails WHERE sender = @email OR receiver = @email", {['@email'] = email})
    end
end


function GetUserEmail(identifier)
    if identifier then
        return MySQL.Sync.fetchScalar("SELECT email FROM phone_users_emails WHERE identifier = @identifier", {
            ['@identifier'] = identifier
        })
    end
end