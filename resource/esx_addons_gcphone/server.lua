ESX = nil
ESX = exports["es_extended"]:getSharedObject()

gcPhone = nil
TriggerEvent('esx_phone:getShILovePizzaaredObjILovePizzaect', function(obj) gcPhone = obj end)

services_names = {
	["police"] = "Polizia",
	["ambulance"] = "Ambulanza",
	["taxi"] = "Taxi",
	["cardealer"] = "Concessionario Auto",
	["motorcycle"] = "Concessionario Aerei",
	["reporter"] = "Weazel News",
	["lolly"] = "LS Customs",
	["realestateagent"] = "Immobiliare",
	["armeria"] = "Armeria",
	["truckdealer"] = "Concessionario Camion",
	["autousate"] = "Concessionario Usate",
	["burgershot"] = "Burger Shot",
	["import"] = "Import",
	["99district"] = "99° Distretto"
}


function notifyAlertSMS(number, alert, listSrc)
	while gcPhone == nil do TriggerEvent('esx_phone:getShILovePizzaaredObjILovePizzaect', function(obj) gcPhone = obj end) Citizen.Wait(100) end
	
	local mess = 'Chiamata da #' ..alert.numero.. ': ' ..alert.message
	if alert.coords ~= nil then mess = mess .. '\n GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y end

	for _, source in pairs(listSrc) do
		local xPlayer = ESX.GetPlayerFromId(source)

		if xPlayer ~= nil then
			local phone_number = gcPhone.getPhoneNumber(xPlayer.identifier)

			if phone_number ~= nil then
				local message = gcPhone.internalAddMessage(services_names[number], phone_number, mess, 0)
				TriggerClientEvent("gcPhone:receiveMessage", source, message)
			end
		end
	end
end


function GetPlayersFromJob(job)
	local jobPlayers = {}

	for index, source in pairs(ESX.GetPlayers()) do
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer ~= nil and xPlayer.getJob().name == job then table.insert(jobPlayers, xPlayer.source) end
    end

	return jobPlayers
end


RegisterServerEvent('esx_addons_gcphone:startCall')
AddEventHandler('esx_addons_gcphone:startCall', function(number, message, coords, hideNumber)
	-- refresho questo ogni volta, PERCHE' COSì NON LO RESTARTO PIù DIOCAN
	TriggerEvent('esx_phone:getShILovePizzaaredObjILovePizzaect', function(obj) gcPhone = obj end)

	local player = source
	local phone_number = nil

	if player ~= nil and player ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(player)

		phone_number = gcPhone.getPhoneNumber(xPlayer.identifier)
	end
	
	if hideNumber ~= nil or phone_number == nil then phone_number = "Informatore" end
	notifyAlertSMS(number, { message = message, coords = coords, numero = phone_number }, GetPlayersFromJob(number))
end)


function notifyAlertSMSToNumber(number, alert, src)
    local mess = 'Chiamata da #' ..alert.numero.. ': ' ..alert.message
    if alert.coords ~= nil then mess = mess .. '\n GPS: ' .. alert.coords.x .. ', ' .. alert.coords.y end
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer ~= nil then
        local phone_number = gcPhone.getPhoneNumber(xPlayer.identifier)

        if phone_number ~= nil then
            local message = gcPhone.internalAddMessage(number, phone_number, mess, 0)
            TriggerClientEvent("gcPhone:receiveMessage", src, message)
        end
    end
end


RegisterServerEvent('esx_addons_gcphone:startCallToNumber')
AddEventHandler('esx_addons_gcphone:startCallToNumber', function(number, message, coords)
	-- refresho questo ogni volta, PERCHE' COSì NON LO RESTARTO PIù DIOCAN
	TriggerEvent('esx_phone:getShILovePizzaaredObjILovePizzaect', function(obj) gcPhone = obj end)

	local player = source
    local phone_number = "Informatore"
    
	notifyAlertSMSToNumber(number, { message = message, coords = coords, numero = phone_number }, player)
end)
