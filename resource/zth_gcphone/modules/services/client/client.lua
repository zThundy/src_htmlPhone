if Config.HasDispatchScript then
    function GetStreetAndZone()
        local plyPos = GetEntityCoords(PlayerPedId(), true)
        local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
        local street1 = GetStreetNameFromHashKey(s1)
        local street2 = GetStreetNameFromHashKey(s2)
        local zone = GetLabelText(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
        local street = street1 .. ", " .. zone
        return street
    end
end

local ids = 0

RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
    local coords = data.coords
    if coords == nil then
        coords = GetEntityCoords(GetPlayerPed(-1))
    end
    
    local message = data.testo
    if not message then message = data.text end

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

    if Config.HasDispatchScript and number == "police" then
        ids = ids + 1

        TriggerServerEvent("dispatch:svNotify", {
			code = Config.Language["EMERGENCY_CALL_CODE"],
			street = GetStreetAndZone(),
			id = ids,
			priority = 3,
			title = Config.Language["EMERGENCY_CALL_LABEL"],
			position = {
				x = coords.x,
				y = coords.y,
				z = coords.z
			},
            blipname = Config.Language["EMERGENCY_CALL_BLIP_LABEL"],
            color = 2,
            sprite = 304,
            fadeOut = 30,
            duration = 10000,
            officer = Config.Language["EMERGENCY_CALL_CALLER_LABEL"]
		})
    end

    if message ~= nil and message ~= "" then
        gcPhoneServerT.servicesStartCall(number, message, {
            x = coords.x,
            y = coords.y,
            z = coords.z
        })
    end
end)
