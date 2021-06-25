local function GetPlayersFromJob(job)
	local jobPlayers = {}

	for index, source in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer ~= nil and xPlayer.getJob().name == job then table.insert(jobPlayers, xPlayer.source) end
    end

	return jobPlayers
end

function notifyAlertSMS(number, alert, listSrc)
	local mess = Config.Language["EMERGENCY_CALL_MESSAGE"]:format(alert.numero, alert.message)
	if alert.coords ~= nil then mess = mess .. '\n GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y end

	for _, source in pairs(listSrc) do
		if not Config.EnableAziendaAppCalls then
			local xPlayer = ESX.GetPlayerFromId(source)

			if xPlayer ~= nil then
				local phone_number = gcPhoneT.getPhoneNumber(xPlayer.identifier)

				if phone_number ~= nil then
					if Config.ServicesNames[number] then
						_internalAddMessage(Config.ServicesNames[number], phone_number, mess, 0, function(message)
							-- local message = gcPhoneT.internalAddMessage(Config.ServicesNames[number], phone_number, mess, 0)
							TriggerClientEvent("gcPhone:receiveMessage", source, message)
						end)
					else
						xPlayer.showNotification(Config.Language["EMERGENCY_CALL_MESSAGE_ERROR"])
					end
				end
			end
		else
			alert.newMessage = mess
			alert.coords.x = tonumber(string.format("%.3f", alert.coords.x))
			alert.coords.y = tonumber(string.format("%.3f", alert.coords.y))
			alert = gcPhoneT.azienda_sendAziendaCallNotification(alert)
			TriggerClientEvent("gcphone:azienda_sendEmergencyCall", source, alert)
		end
	end
end

gcPhoneT.servicesStartCall = function(number, message, coords, hideNumber)
	local player = source
	local phone_number = nil

	if player ~= nil and player ~= 0 then
		local identifier = gcPhoneT.getPlayerID(player)
		phone_number = gcPhoneT.getPhoneNumber(identifier)
	end
	
	if hideNumber or not phone_number then phone_number = Config.Language["EMERGENCY_CALL_NO_NUMBER"] end
	notifyAlertSMS(number, { message = message, coords = coords, numero = phone_number }, GetPlayersFromJob(number))
end