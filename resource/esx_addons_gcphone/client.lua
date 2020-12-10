RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
    local coords = data.coords
    if coords == nil then
        coords = GetEntityCoords(GetPlayerPed(-1))
    end
    
    local message = data.testo
    local number = data.type.number

    if message == nil then
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 200)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(0)
        end

        if GetOnscreenKeyboardResult() then
            message = GetOnscreenKeyboardResult()
        end
    end

    if message ~= nil and message ~= "" then
        TriggerServerEvent('esx_addons_gcphone:startCall', number, message, {
            x = coords.x,
            y = coords.y,
            z = coords.z
        })
    end
end)
