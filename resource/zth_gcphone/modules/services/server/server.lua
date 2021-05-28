local function GetPlayersFromJob(job)
	local jobPlayers = {}

	for index, source in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer ~= nil and xPlayer.getJob().name == job then table.insert(jobPlayers, xPlayer.source) end
    end

	return jobPlayers
end

function notifyAlertSMS(number, alert, listSrc)
	local mess = 'Chiamata da #' ..alert.numero.. ': ' ..alert.message
	if alert.coords ~= nil then mess = mess .. '\n GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y end

	for _, source in pairs(listSrc) do
		local xPlayer = ESX.GetPlayerFromId(source)

		if xPlayer ~= nil then
			local phone_number = gcPhoneT.getPhoneNumber(xPlayer.identifier)

			if phone_number ~= nil then
				if Config.ServicesNames[number] then
					local message = gcPhoneT.internalAddMessage(Config.ServicesNames[number], phone_number, mess, 0)
					TriggerClientEvent("gcPhone:receiveMessage", source, message)
				else
					xPlayer.showNotification("~r~Il numero non è presente nel database del centralino")
				end
			end
		end
	end
end

gcPhoneT.servicesStartCall = function(number, message, coords, hideNumber)
	local player = source
	local phone_number = nil

	if player ~= nil and player ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(player)
		phone_number = gcPhoneT.getPhoneNumber(xPlayer.identifier)
	end
	
	if hideNumber ~= nil or phone_number == nil then phone_number = "Informatore" end
	notifyAlertSMS(number, { message = message, coords = coords, numero = phone_number }, GetPlayersFromJob(number))
end

--[[
	NOT USED SO NO NEED TO KEEP THIS

	function notifyAlertSMSToNumber(number, alert, src)
		local mess = 'Chiamata da #' ..alert.numero.. ': ' ..alert.message
		if alert.coords ~= nil then mess = mess .. '\n GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y end
		local xPlayer = ESX.GetPlayerFromId(src)

		if xPlayer ~= nil then
			local phone_number = gcPhoneT.getPhoneNumber(xPlayer.identifier)

			if phone_number ~= nil then
				local message = gcPhoneT.internalAddMessage(number, phone_number, mess, 0)
				TriggerClientEvent("gcPhone:receiveMessage", src, message)
			end
		end
	end

	RegisterServerEvent('esx_addons_gcphone:startCallToNumber')
	AddEventHandler('esx_addons_gcphone:startCallToNumber', function(number, message, coords)
		local player = source
		local phone_number = "Informatore"
		
		notifyAlertSMSToNumber(number, { message = message, coords = coords, numero = phone_number }, player)
	end)
]]