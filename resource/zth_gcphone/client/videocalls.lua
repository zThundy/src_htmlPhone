local IsCameraActive = false

RegisterNUICallback("openVideoCallCamera", function(data, cb)
    CreateMobilePhone(1)
	CellCamActivate(true, true)
	Citizen.Wait(0)

    if hasFocus then
		SetNuiFocus(false, false)
		hasFocus = false
	end

    CellFrontCamActivate(true)

    while IsCameraActive do
	  	if IsControlJustPressed(1, 177) then
			menuButtonsThread = false
			DestroyMobilePhone()
			CellCamActivate(false, false)
            break
        end
        Citizen.Wait(1)
    end
end)

RegisterNUICallback("startVideoCall", function(data, cb)
	-- local number = data.numero
	-- local extradata = data.extraData
	-- local rtcoffer = data.rtcOffer

	if not GLOBAL_AIRPLANE then
        if data.rtcOffer == nil then data.rtcOffer = '' end
        gcPhoneServerT.startVideoCall(data.numero, data.rtcOffer, data.extraData)
    else
        ESX.ShowNotification(Config.Language["PHONECALLS_AEREO_MODE_ERROR"])
    end
end)

RegisterNUICallback("acceptVideoCall", function(data, cb)
	-- local infoCall = data.infoCall
	-- local rtcAnswer = data.rtcAnswer
	gcPhoneServerT.acceptVideoCall(data.infoCall, data.rtcAnswer)
end)

RegisterNUICallback("rejectVideoCall", function(data, cb)
	-- this is useless :)
end)

RegisterNUICallback('onVideoCandidates', function (data, cb)
    gcPhoneServerT.videoCandidates(data.id, data.candidates)
    cb("ok")
end)

RegisterNetEvent("gcPhone:acceptVideoCall")
AddEventHandler("gcPhone:acceptVideoCall", function(infoCall, initiator)
	if not inCall then
        inCall = true

        Citizen.CreateThread(function()
            local coords, distance = nil, nil
            secondiRimanenti = infoCall.secondiRimanenti
            if not infoCall.updateMinuti then secondiRimanenti = 1000000 end

            while inCall do
                Citizen.Wait(1000)
                if initiator then
                    secondiRimanenti = secondiRimanenti - 1

                    if secondiRimanenti == 0 then 
                        gcPhoneServerT.rejectCall(infoCall)
                    end
                end
				
				if radioPower == 0 then
					gcPhoneServerT.rejectCall(infoCall)
				end
            end
        
            PlaySoundJS('callend.ogg')
            Wait(1500)
            StopSoundJS('callend.ogg')
        end)
        
        if Config.EnableTokoVoip then
            -- print("aggiungo in canale "..infoCall.id)
            TokovoipEnstablishCall(infoCall.id)
        elseif Config.EnableSaltyChat then
            if infoCall then
                gcPhoneServerT.setEndpointSource(infoCall.receiver_src)
                gcPhoneServerT.EstablishCall(infoCall.receiver_src)
            end
        end
    end

    if menuIsOpen == false then 
        TogglePhone()
    end

    PhonePlayCall()
    SendNUIMessage({ event = 'acceptCall', infoCall = infoCall, initiator = initiator })
end)