local ped = nil

local phoneProp = 0
local phoneModel = 0
local cachedProps = {}
-- OR "prop_npc_phone"
-- OR "prop_npc_phone_02"
-- OR "prop_cs_phone_01"

local currentStatus = 'out'
local lastDict = nil
local lastAnim = nil


local lib = {
	['cellphone@'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_listen_base',
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_call_out',
			['text'] = 'cellphone_call_to_text',
		}
	},
	['anim@cellphone@in_car@ps'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_in',
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_horizontal_exit',
			['text'] = 'cellphone_call_to_text',
		}
	}
}


function newPhoneProp()
	ped = GetPlayerPed(-1)
	
	deletePhone()

	if Config.Covers[myCover] ~= nil then
		phoneModel = GetHashKey(Config.Covers[myCover].prop)
	else
		phoneModel = GetHashKey(Config.BaseCover.prop)
	end

	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do Citizen.Wait(1) end

	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
	local bone = GetPedBoneIndex(ped, 28422)
	AttachEntityToEntity(phoneProp, ped, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)

	-- SetEntityAsNoLongerNeeded(phoneModel)

	table.insert(cachedProps, phoneProp)
end


function onCoverChange()
	if #cachedProps > 2 then doCleanup() end

	newPhoneProp()
end


function deletePhone()
	if phoneProp ~= 0 then
		Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
		phoneProp = 0
	end
end


function doCleanup()
	for k, v in pairs(cachedProps) do
		if DoesEntityExist(v) then
			Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(v))
		end
	end

	cachedProps = {}
	gcPhone.debug("^1[ZTH_Phone] ^0Cleared extra props for restart or overflow")
end


--[[
	out || text || Call ||
--]]
function PhonePlayAnim(status)
	if currentStatus == status then
		return
	end

	ped = GetPlayerPed(-1)

	local dict = "cellphone@"
	if IsPedInAnyVehicle(ped, false) then dict = "anim@cellphone@in_car@ps" end

	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Citizen.Wait(1) end

	local anim = lib[dict][currentStatus][status]
	if currentStatus ~= 'out' then StopAnimTask(ped, lastDict, lastAnim, 1.0) end

	TaskPlayAnim(ped, dict, anim, 3.0, -1, -1, 50, 0, false, false, false)

	if status ~= 'out' and currentStatus == 'out' then
		Citizen.Wait(380)
		-- newPhoneProp()
	end

	lastDict = dict
	lastAnim = anim
	currentStatus = status

	if status == 'out' then
		Citizen.Wait(180)
		-- deletePhone()
		StopAnimTask(ped, lastDict, lastAnim, 1.0)
	end
end


function PhonePlayOut()
	PhonePlayAnim('out')
end


function PhonePlayText()
	PhonePlayAnim('text')
end


function PhonePlayCall()
	PhonePlayAnim('call')
end


function PhonePlayIn() 
	if currentStatus == 'out' then
		PhonePlayText()
	end
end


AddEventHandler("onResourceStop", function(res)
	if res == GetCurrentResourceName() then
		deletePhone()

		doCleanup()
	end
end)


RegisterNetEvent("gcphone:animations_doCleanup")
AddEventHandler("gcphone:animations_doCleanup", function()
	doCleanup()
end)


--[[
	Citizen.CreateThread(function()
		local idle = 0
		while true do
			if not menuIsOpen then idle = 2000 end

			if currentStatus == "out" and not IsEntityPlayingAnim(ped, "cellphone@", "cellphone_text_in", 50) then
				
			end

			Citizen.Wait(idle)
		end
	end)
]]
