frontCam = false

local CellFrontCamActivate = function(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

RegisterNetEvent("camera:open")
AddEventHandler("camera:open", function() TakePhoto(nil) end)


RegisterNUICallback('takePhoto', function(data, cb) TakePhoto(data, cb) end)

function TakePhoto(data, cb)
	if data == nil then return end

	CreateMobilePhone(1)
	CellCamActivate(true, true)
	takePhoto = true
	disableCameraMovement = false
	Citizen.Wait(0)

	if hasFocus == true then
		SetNuiFocus(false, false)
		hasFocus = false
	end

	while takePhoto do
		Citizen.Wait(0)

		if IsControlJustPressed(1, 172) then -- Toogle Mode -- only arrow up
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
	  	elseif IsControlJustPressed(1, 177) then -- CANCEL
			menuButtonsThread = false
			DestroyMobilePhone()
			CellCamActivate(false, false)
			cb(json.encode({ url = nil }))

			takePhoto = false
			break
	  	elseif IsControlJustPressed(1, 176) then -- TAKE.. PIC
			takePhoto = false
			disableCameraMovement = true
			if data.options == nil then data.options = { width = 800 } end 
			data.options.headers = {['Authorization'] = string.format('Client-ID %s', '1a792f246b071c4')}
			
		  	exports['screenshot-basic']:requestScreenshotUpload(data.url, data.field, {headers = {['Authorization'] = string.format('Client-ID %s', '1a792f246b071c4')}}, function(data)
				local resp = json.decode(data)
				DestroyMobilePhone()
				CellCamActivate(false, false)

				if resp.data then
					cb(json.encode({ url = resp.data.link }))
				else
					cb(nil)
				end
			end)
		end

		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(19)
		HideHudAndRadarThisFrame()
	end
	
	Citizen.Wait(1000)
	PhonePlayAnim('text', false, true)
end