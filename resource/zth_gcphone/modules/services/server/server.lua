local function GetPlayersFromJob(job)
	local jobPlayers = {}
	for index, source in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer and xPlayer.getJob().name == job then table.insert(jobPlayers, xPlayer.source) end
    end
	return jobPlayers
end

local function SendEmergencyCall(data, listSrc)
	local _message = Config.Language["EMERGENCY_CALL_MESSAGE"]:format(data.phone_number, data.message)
	if data.coords then _message = _message .. '\n GPS: ' .. data.coords.x .. ', ' .. data.coords.y end

	for _, source in pairs(listSrc) do
		if not Config.EnableAziendaAppCalls then
			data.identifier = gcPhoneT.getPlayerID(source)
			data.phone_number = gcPhoneT.getPhoneNumber(data.identifier)

			if data.phone_number then
				_addMessage(data.display, data.phone_number, _message, 0, function(message)
					TriggerClientEvent("gcPhone:receiveMessage", source, message)
				end)
			end
		else
			data.newMessage = _message
			data.coords.x = tonumber(string.format("%.3f", data.coords.x))
			data.coords.y = tonumber(string.format("%.3f", data.coords.y))
			data = gcPhoneT.azienda_sendAziendaCallNotification(data)
			TriggerClientEvent("gcphone:azienda_sendEmergencyCall", source, data)
		end
	end
end

gcPhoneT.servicesStartCall = function(data, hideNumber)
	local player = source
	if player then
		local identifier = gcPhoneT.getPlayerID(player)
		data.phone_number = gcPhoneT.getPhoneNumber(identifier)
	end
	if hideNumber or not data.phone_number then data.phone_number = Config.Language["EMERGENCY_CALL_NO_NUMBER"] end
	SendEmergencyCall(data, GetPlayersFromJob(data.job))
end

--[[
	OLD AND DEPRECATED EVENT
]]

RegisterServerEvent("esx_phone:send")
AddEventHandler("esx_phone:send", function(job, message, _, coords)
	print("^1[ZTH_Phone] ^0[^3" + GetInvokingResource() + "^0] The esx_phone:send event is deprecated, please use the client event esx_addons_gcphone:call")
	local player = source
	if player then
		TriggerClientEvent("esx_addons_gcphone:call", player, {
            coords = coords,
            job = job,
            text = message
        })
	end
end)