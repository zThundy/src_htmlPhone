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

local function CheckForDispatchScript()
    if Config.HasDispatchScript then
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
end

--[[
    TUTORIAL

    To create an event for an emergency call you will need:
    1) Define the job label and name in the config.json inside the /html/config folder
    2) Go to your script code and add the event name below using these arugments as data
        @coords are the coordinates where the service call will be sent; you can use the
        table format or the vector3 format, it doesn't matter
        @text will be the message that will be sent to the choosen emergency number
        if you leave the text field as nil, the script will open the text box to let the user
        write his own message
        @services is an internal table reveived by the nui. Just use the example below
        @type will be a table containing some informations
        @type.number will be the number (or in this case the job name) that will be used to send
        the emergency call

    Example (client-side):
        TriggerEvent("esx_addons_gcphone:call", {
            coords = GetEntityCoords(GetPlayerPed(-1)),
            job = "police",
            text = "Help i'm beeing robbed"
        })
    
    Example (server-side):
        TriggerClientEvent("esx_addons_gcphone:call", source, {
            coords = GetEntityCoords(GetPlayerPed(-1)),
            job = "police",
            text = "Help i'm beeing robbed"
        })
]]

RegisterNetEvent('esx_addons_gcphone:call')
AddEventHandler('esx_addons_gcphone:call', function(data)
    if not data.coords then data.coords = GetEntityCoords(GetPlayerPed(-1)) end
    if not data.job then return gcPhone.debug(Config.Language["CHECK_JOB_NAME_EMERGENCY_CALLS"]) end 

    if data.message == nil then
        DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 200)
        while UpdateOnscreenKeyboard() == 0 do
            DisableAllControlActions(0)
            Wait(0)
        end

        if GetOnscreenKeyboardResult() then
            data.message = GetOnscreenKeyboardResult()
        end
    end

    CheckForDispatchScript()

    if data.message ~= nil and data.message ~= "" then
        gcPhoneServerT.servicesStartCall(data, false)
    end
end)
