RegisterNUICallback("requestMyEmail", function(data, cb)
    TriggerServerEvent("gcphone:email_requestMyEmail")
    cb("ok")
end)


RegisterNetEvent("gcphone:email_sendMyEmail")
AddEventHandler("gcphone:email_sendMyEmail", function(email)
    SendNUIMessage({ event = "receiveMyEmail", email = email })
end)


RegisterNetEvent("gcphone:email_sendRequestedEmails")
AddEventHandler("gcphone:email_sendRequestedEmails", function(emails)
    SendNUIMessage({ evend = "receiveEmails", emails = emails })
end)


RegisterNUICallback("sendEmail", function(data, cb)
    TriggerServerEvent("gcphone:email_sendEmail", data)
    cb("ok")
end)


RegisterNUICallback("requestEmails", function(data, cb)
    TriggerServerEvent("gcphone:email_requestEmails", data.email)
    cb("ok")
end)


RegisterNUICallback("deleteEmail", function(data, cb)
    TriggerServerEvent("gcphone:email_deleteEmail", data.emailID)
    cb("ok")
end)