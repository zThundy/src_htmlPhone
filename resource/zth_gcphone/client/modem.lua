Citizen.CreateThread(function()
    while ESX == nil do Citizen.Wait(1000) end

    TriggerEvent('gridsystem:registerMarker', {
		name = "modem_management",
		type = 20,
		coords = Config.ModemManagement,
		colour = { r = 55, b = 255, g = 55 },
		size =  vector3(0.8, 0.8, 0.8),
        action = function()
            OpenModemManagement()
		end,
		msg = "Premi ~INPUT_CONTEXT~ per acquistare un modem",
	})
end)


RegisterNetEvent("gcphone:modem_chooseCredentials")
AddEventHandler("gcphone:modem_chooseCredentials", function()
	local data = {limit = 255, title = "Scegli il nome della rete"}
	local label = GetResponseText(data)
	data.title = "Scegli la password della rete"
    local password = GetResponseText(data)

    TriggerServerEvent("gcphone:modem_createModem", label, password, GetEntityCoords(GetPlayerPed(-1)))
end)


RegisterNetEvent("gcphone:modem_updateMenu")
AddEventHandler("gcphone:modem_updateMenu", function()
	OpenModemManagement()
end)


function OpenModemManagement()
	ESX.UI.Menu.CloseAll()

	ESX.TriggerServerCallback("gcphone:modem_getMenuInfo", function(elements)
		onMenuSelect = function(data, _)
			if data.current.value == "aggiorna_password" then
				local password = GetResponseText({limit = 255, title = "Cambia la password della rete in:"})
				
				TriggerServerEvent("gcphone:modem_cambiaPassword", password)
			end

			if data.current.value == "rinnova_modem" then
				TriggerServerEvent("gcphone:modem_rinnovaModem")
			end

			if data.current.value == "buy_modem" then
				-- TriggerServerEvent("gcphone:modem_compraModem")
				
				TriggerServerEvent("nfesx_mall:buyGift", "modem", "Modem Wifi", 'item', Config.BuyModemPoints)
				TriggerEvent("gcphone:modem_updateMenu")
			end

			if data.current.value ~= nil then
				OpenModemManagement()
			end
		end

		onMenuClose = function(data, _)
			ESX.UI.Menu.CloseAll()
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'modem_management', {
			title = "Informazioni modem",
			elements = elements
		}, onMenuSelect, onMenuClose)
	end)
end


AddEventHandler("gridsystem:hasExitedMarker", function(marker)
    if marker == nil then return end
    if marker.name == "modem_management" then ESX.UI.Menu.CloseAll() end
end)