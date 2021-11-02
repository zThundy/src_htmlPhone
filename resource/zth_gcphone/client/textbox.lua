RegisterNUICallback('reponseText', function(data, cb)
    local resp = GetResponseText(data)
    cb(json.encode({ text = resp }))
end)

RegisterNUICallback("setNuiFocus", function(data, cb)
    SetNuiFocus(data, false)
    cb("ok")
end)

function GetResponseText(d)
    local limit = d.limit or 255
    local text = d.text or ''
    local title = d.title or "NO_LABEL_DEFINED"
    
    AddTextEntry('CUSTOM_PHONE_TITLE', title)
    DisplayOnscreenKeyboard(1, "CUSTOM_PHONE_TITLE", "", text, "", "", "", limit)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)
        Wait(0)
    end

    if GetOnscreenKeyboardResult() then
        text = GetOnscreenKeyboardResult()
    end

    return text
end