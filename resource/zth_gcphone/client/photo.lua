frontCam = false

local CellFrontCamActivate = function(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

RegisterNUICallback('takePhoto', function(data, cb) Citizen.CreateThreadNow(function() TakePhoto(data, cb) end) end)
RegisterNUICallback('takeVideo', function(data, cb) Citizen.CreateThreadNow(function() TakeVideo(data, cb) end) end)

function TakeVideo(data, cb)
	local videoRecord = true
	local frontCam = false
	
	CreateMobilePhone(1)
	CellCamActivate(true, true)

	cb("ok")

	while videoRecord do
		if IsControlJustPressed(1, 172) then -- Toogle Mode -- only arrow up
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
		elseif IsControlJustPressed(1, 177) then -- CANCEL
			videoRecord = false
			DestroyMobilePhone()
			CellCamActivate(false, false)
		end

		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(19)
		HideHudAndRadarThisFrame()
		Citizen.Wait(0)
	end
end

function TakePhoto(data, cb)
	if data == nil then return end
	local takePhoto = true
	local frontCam = false

	CreateMobilePhone(1)
	CellCamActivate(true, true)

	while takePhoto do
		Citizen.Wait(0)

		if IsControlJustPressed(1, 172) then -- Toogle Mode -- only arrow up
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
	  	elseif IsControlJustPressed(1, 177) then -- CANCEL
			DestroyMobilePhone()
			CellCamActivate(false, false)
			cb(json.encode({ url = nil }))
			takePhoto = false
			break
	  	elseif IsControlJustPressed(1, 176) then -- TAKE.. PIC
			takePhoto = false
		  	exports['screenshot-basic']:requestScreenshotUpload(Config.DiscordWebhook, "files[]", function(data)
				local resp = json.decode(data)
				DestroyMobilePhone()
				CellCamActivate(false, false)

				if resp.attachments and resp.attachments[1] then
					cb(json.encode({ url = resp.attachments[1].proxy_url }))
					SendNUIMessage({ event = "addPhotoToGallery", link = resp.attachments[1].proxy_url })
					
					DestroyMobilePhone()
					CellCamActivate(false, false)

					PhonePlayOut()
					Citizen.Wait(1000)
					PhonePlayText()
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
end