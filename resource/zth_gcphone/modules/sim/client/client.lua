local tunnel = module("zth_gcphone", "modules/TunnelV2")
-- gcPhoneServerT = tunnel.getInterface("gcphone_server_t", "gcphone_server_t")
cartesimServerT = tunnel.getInterface("cartesim_server_t", "cartesim_server_t")

Citizen.CreateThread(function()
	while ESX == nil do Citizen.Wait(100) end
	while ESX.GetPlayerData().job == nil do Citizen.Wait(500) end
	
	local coords = Config.TariffsShop
	TriggerEvent('gridsystem:registerMarker', {
		name = "piano_tariffario",
		type = 20,
		pos = coords,
		color = { r = 55, b = 55, g = 255 },
		scale =  vector3(0.8, 0.8, 0.8),
		action = function()
			openOfferteMenu()
		end,
		msg = Config.Language["HELPNOTIFICATION_SIM_SHOP_LABEL"],
	})

	local info = Config.TariffsBlip
	if info.enable then
		local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
		SetBlipHighDetail(blip, true)
		SetBlipSprite(blip, info.sprite)
		SetBlipColour(blip, info.color)
		SetBlipScale(blip, info.scale)
		SetBlipAsShortRange(blip, true)
		-- SetBlipAlpha(blip, 255)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(info.name)
		EndTextCommandSetBlipName(blip)
	end

	RegisterKeyMapping('+openSimMenu', Config.Language["SETTINGS_SIM_KEY_LABEL"], 'keyboard', Config.SimCardKey)
	RegisterCommand('+openSimMenu', function() OpenSimMenu() end, false)
	RegisterCommand('-openSimMenu', function() end, false)
end)

function OpenSimMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	ESX.TriggerServerCallback('esx_cartesim:GetList', function(sim)
        for _, v in pairs(sim) do
            if v.nome_sim ~= '' then
                table.insert(elements, { label = tostring(v.nome_sim), value = v, piano_tariffario = v.piano_tariffario })
            else
                table.insert(elements, { label = tostring(v.number), value = v, piano_tariffario = v.piano_tariffario })
            end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'phone_change', {
			title = Config.Language["SIM_SHOP_TITLE"],
			elements = elements,
		}, function(data, menu)
		  	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_change', {
				title = tostring(data.current.value.number),
				elements = {
					{ label = Config.Language["SIM_MENU_CHOICE_1"], value = 'sim_use' },
					{ label = Config.Language["SIM_MENU_CHOICE_2"], value = 'sim_give' },
					{ label = Config.Language["SIM_MENU_CHOICE_3"], value = 'sim_rename' },
					{ label = Config.Language["SIM_MENU_CHOICE_4"], value = 'sim_delete' }
				},
		  	}, function(data2, menu2)

				if data2.current.value == 'sim_use' then
					ESX.UI.Menu.CloseAll()
					cartesimServerT.usaSim({ number = data.current.value.number, piano_tariffario = data.current.piano_tariffario })
					-- TriggerServerEvent('esx_cartesim:sim_use', {number = data.current.value.number, piano_tariffario = data.current.piano_tariffario})
					ESX.ShowNotification(Config.Language["SIM_USED_MESSAGE_OK"]:format(data.current.value.number))
					Citizen.Wait(2000)
					gcPhoneServerT.allUpdate()
				end

				if data2.current.value == 'sim_give' then
					ESX.UI.Menu.CloseAll()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(Config.Language["SIM_NO_PLAYER_NEARBY"])
					else
						cartesimServerT.daiSim(data.current.value.number, GetPlayerServerId(closestPlayer))
						-- TriggerServerEvent('esx_cartesim:sim_give', data.current.value.number, GetPlayerServerId(closestPlayer))
					end
					Citizen.Wait(2000)
					gcPhoneServerT.allUpdate()
				end

                if data2.current.value == 'sim_rename' then
                    ESX.UI.Menu.CloseAll()
                    local numero = data.current.value.number

                    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'usate_dialog_money', {
                        title = Config.Language["SIM_RENAME_MENU_LABEL"]
                    }, function(data3, menu3)
                        local sim_name = tostring(data3.value)
    
                        if #sim_name > 20 then
                            ESX.ShowNotification(Config.Language["SIM_RENAME_ERROR"])
                            menu3.close()
                            return
                        end

						cartesimServerT.rinominaSim(numero, sim_name)
                        -- TriggerServerEvent('esx_cartesim:sim_rename', numero, sim_name)
						ESX.ShowNotification(Config.Language["SIM_RENAME_OK"])

						ESX.UI.Menu.CloseAll()
                    end, function(data3, menu3)
                        menu3.close()
    
                        ESX.ShowNotification(Config.Language["SIM_RENAME_CANCEL"])
                    end)
                end

				if data2.current.value == 'sim_delete' then
					ESX.UI.Menu.CloseAll()
					cartesimServerT.eliminaSim(data.current.value.number)
					-- TriggerServerEvent('esx_cartesim:sim_delete', data.current.value.number)
					ESX.ShowNotification(Config.Language["SIM_DESTROY_OK"]:format(data.current.value.number))
					Citizen.Wait(2000)
					gcPhoneServerT.allUpdate()
				end

				menu2.close()
			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)
	end)
end


function openOfferteMenu()
	ESX.UI.Menu.CloseAll()
	local elementi = {}
	local elementi2 = {}

	ESX.TriggerServerCallback('esx_cartesim:GetList', function(sim)
		for i=1, #sim, 1 do
			table.insert(elementi, {label = sim[i].number, value = sim[i]})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_listasim_numeri', {
			title = Config.Language["SIM_TARIFFS_SHOP_TITLE"],
			elements = elementi
		  }, function(data, menu)
			ESX.TriggerServerCallback("esx_cartesim:GetOffertaByNumber", function(offerta)
				if offerta.piano_tariffario == "nessuno" then
					elementi2 = {
						{label = Config.Language["SIM_TARIFFS_SHOP_NO_OFFER"]},
						{label = Config.Language["SIM_TARIFFS_SHOP_CHOOSE_OFFER"], value = "scegli_offerta", icon = 22}
					}
				else
					for k, v in pairs(Config.Tariffs) do
						if v.label == offerta.piano_tariffario then
							elementi2 = {
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_1"]:format(v.label)},
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_2"]:format(v.minuti)},
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_3"]:format(v.messaggi)},
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_4"]:format(v.dati)},
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_5"], value = "scegli_offerta", icon = 22},
								{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_6"], value = "rinnova_offerta", icon = 22}
							}
						end
					end
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_listasim_piani', {
					title = data.current.value.number,
					elements = elementi2
				  }, function(data2, menu2)
					if data2.current.value == "scegli_offerta" then
						openListaOfferte(data.current.value.number)
					end

					if data2.current.value == "rinnova_offerta" then
						ESX.TriggerServerCallback("esx_cartesim:rinnovaOfferta", function(ok)
							if ok then
								ESX.ShowNotification(Config.Language["SIM_TARIFFS_RENEWED_OK"])
							else
								ESX.ShowNotification(Config.Language["SIM_TARIFFS_RENEWED_ERROR"])
								openOfferteMenu()
							end
						end, offerta.piano_tariffario, data.current.value.number)
					end
				end, function(data2, menu2)
					ESX.UI.Menu.CloseAll()
				end)
			end, data.current.value.number)
		end, function(data, menu)
			ESX.UI.Menu.CloseAll()
		end)
	end)
end

function openListaOfferte(number)
	ESX.UI.Menu.CloseAll()

	local elementi = {}
	for k, v in pairs(Config.Tariffs) do
		table.insert(elementi, {label = v.label, value = v})
	end
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_scegli_piano', {
		title = number,
		elements = elementi
	  }, function(data, menu)
		local val = data.current.value

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_compra_piano', {
			title = number,
			elements = {
				{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_2"]:format(v.minuti)},
				{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_3"]:format(v.messaggi)},
				{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_4"]:format(v.dati)},
				{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_7"]:format(v.price)},
				{label = Config.Language["SIM_TARIFFS_OFFER_LABEL_BUY"], value = "acquista"}
			}
		  }, function(data2, menu2)
			if data2.current.value == "acquista" then
				ESX.TriggerServerCallback("esx_cartesim:acquistaOffertaCheckSoldi", function(ok)
					if ok then
						ESX.ShowNotification(Config.Language["SIM_TARIFFS_BUY_OK"])
					else
						ESX.ShowNotification(Config.Language["SIM_TARIFFS_BUY_ERROR"])
						openListaOfferte(number)
					end
					
					ESX.UI.Menu.CloseAll()
				end, val, number)
			end
		end, function(data2, menu2)
			menu2.close()
		end)

	end, function(data, menu)
		menu.close()
	end)
end