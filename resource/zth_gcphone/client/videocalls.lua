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