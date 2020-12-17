--====================================================================================
-- #Author: Jonathan D @ Gannon
--====================================================================================

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
local lastFlag = nil


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
	print("^1[ZTH_Phone] ^0Cleared extra props for restart or overflow")
end


--[[
	out || text || Call ||
--]]
function PhonePlayAnim(status, freeze)
	if currentStatus == status then
		return
	end

	ped = GetPlayerPed(-1)
	local freeze = freeze or false

	if IsPedInAnyVehicle(ped, false) then freeze = false end

	local dict = "cellphone@"
	if IsPedInAnyVehicle(ped, false) then dict = "anim@cellphone@in_car@ps" end

	loadAnimDict(dict)

	local anim = lib[dict][currentStatus][status]
	if currentStatus ~= 'out' then StopAnimTask(ped, lastDict, lastAnim, 1.0) end

	local flag = 50
	if freeze == true then flag = 14 end
	TaskPlayAnim(ped, dict, anim, 3.0, -1, -1, flag, 0, false, false, false)

	if status ~= 'out' and currentStatus == 'out' then
		Citizen.Wait(380)
		newPhoneProp()
	end

	lastDict = dict
	lastAnim = anim
	lastFlag = flag
	currentStatus = status

	if status == 'out' then
		Citizen.Wait(180)
		deletePhone()
		StopAnimTask(ped, lastDict, lastAnim, 1.0)
	end
end


function PhonePlayOut()
	PhonePlayAnim('out', false)
end


function PhonePlayText()
	PhonePlayAnim('text', false)
end


function PhonePlayCall()
	PhonePlayAnim('call', false)
end


function PhonePlayIn() 
	if currentStatus == 'out' then
		PhonePlayText()
	end
end


function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end


AddEventHandler("onResourceStop", function(res)
	if res == GetCurrentResourceName() then
		deletePhone()

		doCleanup()
	end
end)
