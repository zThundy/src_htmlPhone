ESX = nil

local tunnel = module("zth_gcphone", "modules/TunnelV2")
gcPhoneServerT = tunnel.getInterface("gcphone_server_t", "gcphone_server_t")
cartesimServerT = tunnel.getInterface("cartesim_server_t", "cartesim_server_t")

Citizen.CreateThread(function() --ok
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(1)
	end

	TriggerEvent('tcm_grids:registerMarker', {
		name = "piano_tariffario",
		type = 20,
		coords = vector3(Config.MarkerOfferte["x"], Config.MarkerOfferte["y"], Config.MarkerOfferte["z"]),
		colour = { r = 55, b = 55, g = 255 },
		size =  vector3(0.8, 0.8, 0.8),
		action = function()
			openOfferteMenu()
		end,
		msg = "Premi ~INPUT_CONTEXT~ per acquistare un piano tariffario",
	})

	local info = Config.BlipOfferte
	local blip = AddBlipForCoord(info.x, info.y, 5.0)
	SetBlipHighDetail(blip, true)
	SetBlipSprite(blip, info.sprite)
	SetBlipColour(blip, info.color)
	SetBlipScale(blip, info.scale)
	SetBlipAsShortRange(blip, true)
	-- SetBlipAlpha(blip, 255)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(info.name)
	EndTextCommandSetBlipName(blip)
end)

RegisterKeyMapping('+openSimMenu', 'Menù sim', 'keyboard', 'f3')
RegisterCommand('+openSimMenu', function() OpenSimMenu() end, false)
RegisterCommand('-openSimMenu', function() end, false)

function OpenSimMenu()
	ESX.UI.Menu.CloseAll()
	local elements = {}
	ESX.TriggerServerCallback('esx_cartesim:GetList', function(sim)

        for _, v in pairs(sim) do
            if v.nome_sim ~= '' then
                table.insert(elements, {label = tostring(v.nome_sim), value = v, piano_tariffario = v.piano_tariffario})
            else
                table.insert(elements, {label = tostring(v.number), value = v, piano_tariffario = v.piano_tariffario})
            end
		end
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'phone_change', {
			title = 'Carte SIM',
			elements = elements,
		}, function(data, menu)
			local val = data.current.value

			local elements2 = {
				{label = 'Usa', value = 'sim_use'},
                {label = 'Dai', value = 'sim_give'},
                {label = 'Rinomina', value = 'sim_rename'},
				{label = 'Cancella', value = 'sim_delete'}
			}

		  	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_change', {
				title = tostring(val.number),
				elements = elements2,
		  	}, function(data2, menu2)

				if data2.current.value == 'sim_use' then
					ESX.UI.Menu.CloseAll()
					cartesimServerT.usaSim({ number = data.current.value.number, piano_tariffario = data.current.piano_tariffario })
					-- TriggerServerEvent('esx_cartesim:sim_use', {number = data.current.value.number, piano_tariffario = data.current.piano_tariffario})
					ESX.ShowNotification("Hai usato la carta SIM "..data.current.value.number)
					Citizen.Wait(2000)
					gcPhoneServerT.allUpdate()
				end

				if data2.current.value == 'sim_give' then
					ESX.UI.Menu.CloseAll()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification('Nessun giocatore nelle vicinanze')
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
                        title = "Inserisci un nome, massimo 10 caratteri"
                    }, function(data3, menu3)
                        local sim_name = tostring(data3.value)
    
                        if #sim_name > 10 then
                            ESX.ShowNotification("Il nome non può superare i 10 caratteri", "error")
                            menu3.close()

                            return
                        end

						cartesimServerT.rinominaSim(numero, sim_name)
                        -- TriggerServerEvent('esx_cartesim:sim_rename', numero, sim_name)
						ESX.ShowNotification("Sim Rinominata", "success")

						ESX.UI.Menu.CloseAll()
                    end, function(data3, menu3)
                        menu3.close()
    
                        ESX.ShowNotification("Compilazione annullata", "error")
                    end)
                end

				if data2.current.value == 'sim_delete' then
					ESX.UI.Menu.CloseAll()
					cartesimServerT.eliminaSim(data.current.value.number)
					-- TriggerServerEvent('esx_cartesim:sim_delete', data.current.value.number)
					ESX.ShowNotification("Hai distrutto la SIM "..data.current.value.number)
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
			title = "Offerte telefoniche",
			elements = elementi
		  }, function(data, menu)
			local val = data.current.value
			
			ESX.TriggerServerCallback("esx_cartesim:GetOffertaByNumber", function(offerta)
				if offerta.piano_tariffario == "nessuno" then
					elementi2 = {
						{label = "Offerta: Nessun'offerta"},
						{label = "Scegli un'offerta", value = "scegli_offerta", icon = 22},
						{label = "Scegli un'offerta premium", value = "scegli_offerta_premium", icon = 22}
					}
				else
					for k, v in pairs(Config.Tariffs) do
						if v.label == offerta.piano_tariffario then
							elementi2 = {
								{label = "Offerta: "..v.label},
								{label = "Minuti: "..v.minuti.." m"},
								{label = "Messaggi: "..v.messaggi.." sms"},
								{label = "Internet: "..v.dati.." mb"},
								{label = "Cambia offerta", value = "scegli_offerta", icon = 22},
								{label = "Cambia offerta premium", value = "scegli_offerta_premium", icon = 22},
								{label = "Rinnova offerta", value = "rinnova_offerta", icon = 22}
							}
						end
					end
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_listasim_piani', {
					title = val.number,
					elements = elementi2
				  }, function(data2, menu2)
					local v = data2.current.value

					if v == "scegli_offerta" then
						openListaOfferte(val.number)
					end

					if v == "rinnova_offerta" then
						ESX.TriggerServerCallback("esx_cartesim:rinnovaOfferta", function(ok)
							if ok then
								ESX.ShowNotification("Offerta rinnovata con successo!", "success")
							else
								ESX.ShowNotification("Non hai abbastanza soldi per rinnovare l'offerta", "error")
								openOfferteMenu()
							end
						end, offerta.piano_tariffario, val.number)
					end
		
				end, function(data2, menu2)
					ESX.UI.Menu.CloseAll()
				end)

			end, val.number)

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

		local lista = {
			{label = "Minuti: "..val.minuti.." s"},
			{label = "Messaggi: "..val.messaggi.." sms"},
			{label = "Internet: "..val.dati.." mb"},
			{label = "Prezzo: "..val.price.."$"},
			{label = "Acquista l'offerta", value = "acquista", icon = 22}
		}

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'sim_compra_piano', {
			title = number,
			elements = lista
		  }, function(data2, menu2)
			local v = data2.current.value
	
			if v == "acquista" then
				ESX.TriggerServerCallback("esx_cartesim:acquistaOffertaCheckSoldi", function(ok)
					if ok then
						ESX.ShowNotification("~g~Offerta comprata con successo!")
					else
						ESX.ShowNotification("~r~Non hai abbatsanza soldi per completare l'acquisto")
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