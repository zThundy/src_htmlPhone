function GetStreetAndZone()
	local plyPos = GetEntityCoords(PlayerPedId(), true)
	local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, plyPos.x, plyPos.y, plyPos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
	local street1 = GetStreetNameFromHashKey(s1)
	local street2 = GetStreetNameFromHashKey(s2)
	local zone = GetLabelText(GetNameOfZone(plyPos.x, plyPos.y, plyPos.z))
	local street = street1 .. ", " .. zone
	return street
end

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

    if Config.HasDispatchScript and number == "police" then
        math.randomseed(GetCloudTimeAsInt())
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        local uuid = string.gsub(template, '[xy]', function (c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)

        TriggerServerEvent("dispatch:svNotify", {
			code = "911",
			street = GetStreetAndZone(),
			id = uuid,
			priority = 2,
			title = "Chiamata di emergenza",
			position = {
				x = coords.x,
				y = coords.y,
				z = coords.z
			},
            blipname = "Emergenza",
            color = 2,
            sprite = 304,
            fadeOut = 30,
            duration = 10000,
            officer = "Ufficio 911"
		})
    end

    if message ~= nil and message ~= "" then
        TriggerServerEvent('esx_addons_gcphone:startCall', number, message, {
            x = coords.x,
            y = coords.y,
            z = coords.z
        })
    end
end)
