local Database = {}

local Cam = nil
local Speed = Config.Speed
local AdjustSpeed = Config.AdjustSpeed
local RotateSpeed = Config.RotateSpeed
local AttachedEntity = nil
local RotateMode = 2
local AdjustMode = -1
local PlaceOnGround = false
local CurrentSpawn = nil

local Permissions = {}

Permissions.maxEntities = 0

Permissions.spawn = {}
Permissions.spawn.ped = false
Permissions.spawn.vehicle = false
Permissions.spawn.object = false
Permissions.spawn.propset = false
Permissions.spawn.pickup = false

Permissions.delete = {}
Permissions.delete.own = false
Permissions.delete.other = false
Permissions.delete.networked = false
Permissions.delete.nonNetworked = false

Permissions.modify = {}
Permissions.modify.own = false
Permissions.modify.other = false
Permissions.modify.networked = false
Permissions.modify.nonNetworked = false

Permissions.properties = {}
Permissions.properties.freeze = false
Permissions.properties.position = false
Permissions.properties.goTo = false
Permissions.properties.rotation = false
Permissions.properties.health = false
Permissions.properties.invincible = false
Permissions.properties.visible = false
Permissions.properties.gravity = false
Permissions.properties.collision = false
Permissions.properties.attachments = false
Permissions.properties.lights = false

Permissions.properties.ped = {}
Permissions.properties.ped.changeModel = false
Permissions.properties.ped.outfit = false
Permissions.properties.ped.group = false
Permissions.properties.ped.scenario = false
Permissions.properties.ped.animation = false
Permissions.properties.ped.clearTasks = false
Permissions.properties.ped.weapon = false
Permissions.properties.ped.mount = false
Permissions.properties.ped.resurrect = false
Permissions.properties.ped.ai = false

Permissions.properties.vehicle = {}
Permissions.properties.vehicle.repair = false
Permissions.properties.vehicle.getin = false
Permissions.properties.vehicle.engine = false
Permissions.properties.vehicle.lights = false

RegisterNetEvent('spooner:init')
RegisterNetEvent('spooner:toggle')
RegisterNetEvent('spooner:openDatabaseMenu')
RegisterNetEvent('spooner:openSaveDbMenu')
RegisterNetEvent('spooner:refreshPermissions')

function SetLightsIntensityForEntity(entity, intensity)
	Citizen.InvokeNative(0x07C0F87AAC57F2E4, entity, intensity)
end

function SetLightsColorForEntity(entity, red, green, blue)
	Citizen.InvokeNative(0x6EC2A67962296F49, entity, red, green, blue)
end

function SetLightsTypeForEntity(entity, type)
	Citizen.InvokeNative(0xAB72C67163DC4DB4, entity, type)
end

function CreatePed_2(modelHash, x, y, z, heading, isNetwork, thisScriptCheck, p7, p8)
	return Citizen.InvokeNative(0xD49F9B0955C367DE, modelHash, x, y, z, heading, isNetwork, thisScriptCheck, p7, p8)
end

function SetRandomOutfitVariation(ped, p1)
	Citizen.InvokeNative(0x283978A15512B2FE, ped, p1)
end

function BlipAddForEntity(blipHash, entity)
	return Citizen.InvokeNative(0x23F74C2FDA6E7C61, blipHash, entity)
end

function SetPedOnMount(ped, mount, seatIndex, p3)
	Citizen.InvokeNative(0x028F76B6E78246EB, ped, mount, seatIndex, p3)
end

function IsUsingKeyboard(padIndex)
	return Citizen.InvokeNative(0xA571D46727E2B718, padIndex)
end

function RequestPropset(hash)
	return Citizen.InvokeNative(0xF3DE57A46D5585E9, hash)
end

function ReleasePropset(hash)
	return Citizen.InvokeNative(0xB1964A83B345B4AB, hash)
end

function HasPropsetLoaded(hash)
	return Citizen.InvokeNative(0x48A88FC684C55FDC, hash)
end

function CreatePropset(hash, x, y, z, p4, p5, p6, p7, p8)
	return Citizen.InvokeNative(0xE65C5CBA95F0E510, hash, x, y, z, p4, p5, p6, p7, p8)
end

function DeletePropset(propSet, p1, p2)
	return Citizen.InvokeNative(0x58AC173A55D9D7B4, propSet, p1, p2)
end

function DoesPropsetExist(propSet)
	return Citizen.InvokeNative(0x7DDDCF815E650FF5, propSet)
end

function GetEntitiesFromPropset(propSet, itemSet, p2, p3, p4)
	return Citizen.InvokeNative(0x738271B660FE0695, propSet, itemSet, p2, p3, p4)
end

function IsPickupTypeValid(pickupHash)
	return Citizen.InvokeNative(0x007BD043587F7C82, pickupHash)
end

function EnableSpoonerMode()
	local x, y, z = table.unpack(GetGameplayCamCoord())
	local pitch, roll, yaw = table.unpack(GetGameplayCamRot(2))
	local fov = GetGameplayCamFov()
	Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(Cam, x, y, z)
	SetCamRot(Cam, pitch, roll, yaw, 2)
	SetCamFov(Cam, fov)
	RenderScriptCams(true, true, 500, true, true)

	SendNUIMessage({
		type = 'showSpoonerHud'
	})
end

function DisableSpoonerMode()
	if Cam then
		RenderScriptCams(false, true, 500, true, true)
		SetCamActive(Cam, false)
		DetachCam(Cam)
		DestroyCam(Cam, true)
		Cam = nil
	end

	AttachedEntity = nil

	SendNUIMessage({
		type = 'hideSpoonerHud'
	})

	SetNuiFocus(false, false)
end

function ToggleSpoonerMode()
	if Cam then
		DisableSpoonerMode()
	else
		EnableSpoonerMode()
	end
end


function OpenDatabaseMenu()
	UpdateDatabase()
	SendNUIMessage({
		type = 'openDatabase',
		database = json.encode(Database)
	})
	SetNuiFocus(true, true)
end

function OpenSaveDbMenu()
	SendNUIMessage({
		type = 'openSaveLoadDbMenu',
		databaseNames = json.encode(GetSavedDatabases())
	})
	SetNuiFocus(true, true)
end

RegisterCommand('spooner', function(source, args, raw)
	TriggerServerEvent('spooner:toggle')
end, false)

RegisterCommand('spooner_db', function(source, args, raw)
	TriggerServerEvent('spooner:openDatabaseMenu')
end, false)

RegisterCommand('spooner_savedb', function(source, args, raw)
	TriggerServerEvent('spooner:openSaveDbMenu')
end, false)

AddEventHandler('spooner:toggle', ToggleSpoonerMode)
AddEventHandler('spooner:openDatabaseMenu', OpenDatabaseMenu)
AddEventHandler('spooner:openSaveDbMenu', OpenSaveDbMenu)

AddEventHandler('spooner:init', function(permissions)
	Permissions = permissions

	SendNUIMessage({
		type = 'updatePermissions',
		permissions = json.encode(permissions)
	})
end)

AddEventHandler('spooner:refreshPermissions', function()
	TriggerServerEvent('spooner:init')
end)

function GetSpoonerEntityType(entity)
	return Database[entity] and Database[entity].type or GetEntityType(entity)
end

function GetSpoonerEntityModel(entity)
	return Database[entity] and Database[entity].model or GetEntityModel(entity)
end

function GetInView(x1, y1, z1, pitch, roll, yaw)
	local rx = -math.sin(math.rad(yaw)) * math.abs(math.cos(math.rad(pitch)))
	local ry =  math.cos(math.rad(yaw)) * math.abs(math.cos(math.rad(pitch)))
	local rz =  math.sin(math.rad(pitch))

	local x2 = x1 + rx * 10000.0
	local y2 = y1 + ry * 10000.0
	local z2 = z1 + rz * 10000.0

	local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(StartShapeTestRay(x1, y1, z1, x2, y2, z2, -1, -1, 1))

	if entityHit <= 0 then
		return endCoords, nil, 0
	end

	--if IsPedAPlayer(entityHit) then
	--	return endCoords, nil, 0
	--end

	local x3, y3, z3 = table.unpack(GetEntityCoords(entityHit))

	local distance = GetDistanceBetweenCoords(x1, y1, z1, x3, y3, z3, true)

	if distance >= 100.0 then
		return endCoords, nil, distance
	end

	return endCoords, entityHit, distance
end

function GetModelName(model)
	for _, name in ipairs(Peds) do
		if model == GetHashKey(name) then
			return name
		end
	end

	for _, name in ipairs(Vehicles) do
		if model == GetHashKey(name) then
			return name
		end
	end

	for _, name in ipairs(Objects) do
		if model == GetHashKey(name) then
			return name
		end
	end

	for _, name in ipairs(Pickups) do
		if model == GetHashKey(name) then
			return name
		end
	end

	return string.format('%x', model)
end

function GetPlayerFromPed(ped)
	for _, playerId in ipairs(GetActivePlayers()) do
		if ped == GetPlayerPed(playerId) then
			return playerId
		end
	end

	return nil
end

function GetLiveEntityProperties(entity)
	local model = GetEntityModel(entity)
	local x, y, z = table.unpack(GetEntityCoords(entity))
	local pitch, roll, yaw = table.unpack(GetEntityRotation(entity, 2))
	local isPlayer = IsPedAPlayer(entity)
	local player = isPlayer and GetPlayerFromPed(entity)

	return {
		name = GetModelName(model),
		type = GetEntityType(entity),
		model = model,
		x = x,
		y = y,
		z = z,
		pitch = pitch,
		roll = roll,
		yaw = yaw,
		health = GetEntityHealth(entity),
		outfit = -1,
		isInGroup = IsPedGroupMember(entity, GetPlayerGroup(PlayerId())),
		collisionDisabled = GetEntityCollisionDisabled(entity),
		lightsIntensity = nil,
		lightsColour = nil,
		lightsType = nil,
		animation = nil,
		scenario = nil,
		blockNonTemporaryEvents = false,
		isSelf = entity == PlayerPedId(),
		playerName = player and GetPlayerName(player),
		attachment = {
			to = GetEntityAttachedTo(entity),
			bone = 0,
			x = 0.0,
			y = 0.0,
			z = 0.0,
			pitch = 0.0,
			roll = 0.0,
			yaw = 0.0
		}
	}
end

function AddEntityToDatabase(entity, name, attachment)
	if not entity then
		return nil
	end

	if not name and Database[entity] then
		name = Database[entity].name
	end

	local model = Database[entity] and Database[entity].model
	local type = Database[entity] and Database[entity].type

	local outfit = Database[entity] and Database[entity].outfit or -1

	local attachBone, attachX, attachY, attachZ, attachPitch, attachRoll, attachYaw

	local lightsIntensity = Database[entity] and Database[entity].lightsIntensity or nil
	local lightsColour = Database[entity] and Database[entity].lightsColour or nil
	local lightsType = Database[entity] and Database[entity].lightsType or nil

	local animation = Database[entity] and Database[entity].animation
	local scenario = Database[entity] and Database[entity].scenario

	local blockNonTemporaryEvents = Database[entity] and Database[entity].blockNonTemporaryEvents or false

	if attachment then
		attachBone  = attachment.bone
		attachX     = attachment.x
		attachY     = attachment.y
		attachZ     = attachment.z
		attachPitch = attachment.pitch
		attachRoll  = attachment.roll
		attachYaw   = attachment.yaw
	else
		attachBone  = (Database[entity] and Database[entity].attachment.bone  or 0)
		attachX     = (Database[entity] and Database[entity].attachment.x     or 0.0)
		attachY     = (Database[entity] and Database[entity].attachment.y     or 0.0)
		attachZ     = (Database[entity] and Database[entity].attachment.z     or 0.0)
		attachPitch = (Database[entity] and Database[entity].attachment.pitch or 0.0)
		attachRoll  = (Database[entity] and Database[entity].attachment.roll  or 0.0)
		attachYaw   = (Database[entity] and Database[entity].attachment.yaw   or 0.0)
	end

	Database[entity] = GetLiveEntityProperties(entity)

	if name then
		Database[entity].name = name
	end

	if model then
		Database[entity].model = model
	end

	if type then
		Database[entity].type = type
	end

	Database[entity].outfit = outfit

	Database[entity].attachment.bone = attachBone
	Database[entity].attachment.x = attachX
	Database[entity].attachment.y = attachY
	Database[entity].attachment.z = attachZ
	Database[entity].attachment.pitch = attachPitch
	Database[entity].attachment.roll = attachRoll
	Database[entity].attachment.yaw = attachYaw

	Database[entity].lightsIntensity = lightsIntensity
	Database[entity].lightsColour = lightsColour
	Database[entity].lightsType = lightsType

	Database[entity].animation = animation
	Database[entity].scenario = scenario

	Database[entity].blockNonTemporaryEvents = blockNonTemporaryEvents

	return Database[entity]
end

function RemoveEntityFromDatabase(entity)
	Database[entity] = nil
end

function GetEntityPropertiesFromDatabase(entity)
	return AddEntityToDatabase(entity)
end

function EntityIsInDatabase(entity)
	return Database[entity] ~= nil
end

function GetEntityProperties(entity)
	if EntityIsInDatabase(entity) then
		return GetEntityPropertiesFromDatabase(entity)
	else
		return GetLiveEntityProperties(entity)
	end
end

function GetDatabaseSize()
	local n = 0

	for entity, props in pairs(Database) do
		n = n + 1
	end

	return n
end

function IsDatabaseFull()
	return Permissions.maxEntities and GetDatabaseSize() >= Permissions.maxEntities
end

function LoadModel(model)
	if IsModelInCdimage(model) then
		RequestModel(model)

		while not HasModelLoaded(model) do
			Wait(0)
		end

		return true
	else
		return false
	end
end

function SpawnObject(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, lightsIntensity, lightsColour, lightsType)
	if not Permissions.spawn.object then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	if not LoadModel(model) then
		return nil
	end

	local object = CreateObjectNoOffset(model, x, y, z, true, false, true)

	SetModelAsNoLongerNeeded(model)

	if not object or object < 1 then
		return nil
	end

	SetEntityRotation(object, pitch, roll, yaw, 2)

	FreezeEntityPosition(object, true)

	if collisionDisabled then
		SetEntityCollision(object, false, false)
	end

	if lightsIntensity then
		SetLightsIntensityForEntity(object, lightsIntensity)
	end

	if lightsColour then
		SetLightsColorForEntity(object, lightsColour.red, lightsColour.green, lightsColour.blue)
	end

	if lightsType then
		SetLightsTypeForEntity(object, lightsType)
	end

	AddEntityToDatabase(object, name)

	return object
end

function SpawnVehicle(name, model, x, y, z, pitch, roll, yaw, collisionDisabled)
	if not Permissions.spawn.vehicle then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	if not LoadModel(model) then
		return nil
	end

	local veh = CreateVehicle(model, x, y, z, 0.0, true, false)

	SetModelAsNoLongerNeeded(model)

	if not veh or veh < 1 then
		return nil
	end

	SetEntityRotation(veh, pitch, roll, yaw, 2)

	if collisionDisabled then
		FreezeEntityPosition(veh, true)
		SetEntityCollision(veh, false, false)
	end

	-- Weird fix for the hot air balloon, otherwise it doesn't move with the wind and only travels straight up.
	if model == GetHashKey('hotairballoon01') then
		SetVehicleAsNoLongerNeeded(veh)
	end

	AddEntityToDatabase(veh, name)

	return veh
end

function SpawnPed(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, outfit, addToGroup, animation, scenario, blockNonTemporaryEvents)
	if not Permissions.spawn.ped then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	if not LoadModel(model) then
		return nil
	end

	local ped = CreatePed_2(model, x, y, z, 0.0, true, false)

	SetModelAsNoLongerNeeded(model)

	if not ped or ped < 1 then
		return nil
	end

	SetEntityRotation(ped, pitch, roll, yaw, 2)

	if collisionDisabled then
		FreezeEntityPosition(ped, true)
		SetEntityCollision(ped, false, false)
	end

	if outfit == -1 then
		SetRandomOutfitVariation(ped, true)
	else
		SetPedOutfitPreset(ped, outfit)
	end

	if addToGroup then
		AddToGroup(ped)
	end

	if animation then
		if DoesAnimDictExist(animation.dict) then
			RequestAnimDict(animation.dict)

			while not HasAnimDictLoaded(animation.dict) do
				Wait(0)
			end

			TaskPlayAnim(ped, animation.dict, animation.name, animation.blendInSpeed, animation.blendOutSpeed, animation.duration, animation.flag, animation.playbackRate, false, false, false, '', false)
		end
	end

	if scenario then
		Wait(500)
		TaskStartScenarioInPlace(ped, GetHashKey(scenario), -1)
	end

	if blockNonTemporaryEvents then
		SetBlockingOfNonTemporaryEvents(ped, true)
	end

	AddEntityToDatabase(ped, name)
	Database[ped].outfit = outfit
	Database[ped].animation = animation
	Database[ped].scenario = scenario
	Database[ped].blockNonTemporaryEvents = blockNonTemporaryEvents

	return ped
end

function SpawnPropset(name, model, x, y, z, heading)
	if not Permissions.spawn.propset then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	RequestPropset(model)
	while not HasPropsetLoaded(model) do
		Wait(0)
	end

	local propset = CreatePropset(model, x, y, z, 0, heading, 0.0, true, false)

	ReleasePropset(hash)

	if not propset or propset < 1 then
		return nil
	end

	-- FIXME: Eventually, individual objects from the propset should be stored in the DB instead of the propset itself, but I'm not sure how to use GetEntitiesFromPropset properly so that it works consistently.
	AddEntityToDatabase(propset, name)
	Database[propset].type = 4

	return propset

	--local itemset = CreateItemset(true)
	--GetEntitiesFromPropset(propset, itemset, 0, false, false)
	--local size = GetItemsetSize(itemset)

	--if size == 0 then
	--	DeletePropset(propset, true, true)
	--else
	--	for i = 0, size - 1 do
	--		AddEntityToDatabase(GetIndexedItemInItemset(i, itemset))
	--	end
	--end
	--DeletePropset(propset, false, false)
	--
	--return nil
end

function SpawnPickup(name, model, x, y, z)
	if not Permissions.spawn.pickup then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	if not IsPickupTypeValid(model) then
		return nil
	end

	local pickup = CreatePickup(model, x, y, z, 0, 0, false, 0, 0, 0.0, 0)

	if not pickup or pickup < 1 then
		return nil
	end

	AddEntityToDatabase(pickup, name)
	Database[pickup].model = model
	Database[pickup].type = 5

	return pickup
end

function RequestControl(entity)
	local type = GetEntityType(entity)

	if type < 1 or type > 3 then
		return
	end

	NetworkRequestControlOfEntity(entity)

	--while not NetworkHasControlOfEntity(entity) do
	--	Wait(0)
	--end
end

function CanDeleteEntity(entity)
	if EntityIsInDatabase(entity) then
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.delete.own and Permissions.delete.networked
		else
			return Permissions.delete.own and Permissions.delete.nonNetworked
		end
	else
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.delete.other and Permissions.delete.networked
		else
			return Permissions.delete.other and Permissions.delete.nonNetworked
		end
	end
end

function RemoveEntity(entity)
	if not CanDeleteEntity(entity) then
		return
	end

	if IsPedAPlayer(entity) then
		return
	end

	local entityType = GetSpoonerEntityType(entity)

	if entityType == 4 then
		DeletePropset(entity)
	elseif entityType == 5 then
		RemovePickup(entity)
	else
		RequestControl(entity)
		SetEntityAsMissionEntity(entity, true, true)
		DeleteEntity(entity)
	end

	RemoveEntityFromDatabase(entity)
end

function RemoveAllFromDatabase()
	local entities = {}
	for handle, info in pairs(Database) do
		table.insert(entities, handle)
	end
	for _, handle in ipairs(entities) do
		RemoveEntity(handle)
	end
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		DisableSpoonerMode()
		--RemoveAllFromDatabase();
	end
end)

RegisterNUICallback('closeSpawnMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closePedMenu', function(data, cb)
	if data.modelName then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 1
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeVehicleMenu', function(data, cb)
	if data.modelName then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 2
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeObjectMenu', function(data, cb)
	if data.modelName then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 3
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closePropsetMenu', function(data, cb)
	if data.modelName then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 4
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closePickupMenu', function(data, cb)
	if data.modelName then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 5
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeDatabase', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('deleteEntity', function(data, cb)
	RemoveEntity(data.handle)
	cb({})
end)

RegisterNUICallback('removeAllFromDatabase', function(data, cb)
	RemoveAllFromDatabase();
	cb({})
end)

RegisterNUICallback('closePropertiesMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeSaveLoadDbMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('addEntityToDatabase', function(data, cb)
	AddEntityToDatabase(data.handle)
	cb({})
end)

RegisterNUICallback('removeEntityFromDatabase', function(data, cb)
	if not Permissions.maxEntities and Permissions.modify.other then
		RemoveEntityFromDatabase(data.handle)
	end
	cb({})
end)

RegisterNUICallback('freezeEntity', function(data, cb)
	RequestControl(data.handle)
	FreezeEntityPosition(data.handle, true)
	cb({})
end)

RegisterNUICallback('unfreezeEntity', function(data, cb)
	RequestControl(data.handle)
	FreezeEntityPosition(data.handle, false)
	cb({})
end)

RegisterNUICallback('setEntityRotation', function(data, cb)
	local pitch = data.pitch and data.pitch * 1.0 or 0.0
	local roll  = data.roll  and data.roll  * 1.0 or 0.0
	local yaw   = data.yaw   and data.yaw   * 1.0 or 0.0

	RequestControl(data.handle)
	SetEntityRotation(data.handle, pitch, roll, yaw, 2)

	cb({})
end)

RegisterNUICallback('setEntityCoords', function(data, cb)
	local x = data.x and data.x * 1.0 or 0.0
	local y = data.y and data.y * 1.0 or 0.0
	local z = data.z and data.z * 1.0 or 0.0

	RequestControl(data.handle)
	SetEntityCoordsNoOffset(data.handle, x, y, z)

	cb({})
end)

RegisterNUICallback('resetRotation', function(data, cb)
	RequestControl(data.handle)
	SetEntityRotation(data.handle, 0.0, 0.0, 0.0, 2)
	cb({})
end)

function UpdateDatabase()
	local entities = {}
	local propsets = {}
	local pickups = {}

	for entity, properties in pairs(Database) do
		if properties.type == 4 then
			table.insert(propsets, entity)
		elseif properties.type == 5 then
			table.insert(pickups, entity)
		else
			table.insert(entities, entity)
		end
	end

	for _, entity in ipairs(entities) do
		if DoesEntityExist(entity) then
			AddEntityToDatabase(entity)
		else
			RemoveEntityFromDatabase(entity)
		end
	end

	for _, propset in ipairs(propsets) do
		if DoesPropsetExist(propset) then
			AddEntityToDatabase(propset)
		else
			RemoveEntityFromDatabase(propset)
		end
	end

	for _, pickup in ipairs(pickups) do
		if DoesPickupExist(pickup) then
			AddEntityToDatabase(pickup)
		else
			RemoveEntityFromDatabase(pickup)
		end
	end
end

function CanModifyEntity(entity)
	if EntityIsInDatabase(entity) then
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.modify.own and Permissions.modify.networked
		else
			return Permissions.modify.own and Permissions.modify.nonNetworked
		end
	else
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.modify.other and Permissions.modify.networked
		else
			return Permissions.modify.other and Permissions.modify.nonNetworked
		end
	end
end

function OpenPropertiesMenuForEntity(entity)
	if not CanModifyEntity(entity) then
		SetNuiFocus(false, false)
		return
	end

	SendNUIMessage({
		type = 'openPropertiesMenu',
		entity = entity
	})
	SetNuiFocus(true, true)
end

RegisterNUICallback('openPropertiesMenuForEntity', function(data, cb)
	OpenPropertiesMenuForEntity(data.entity)
	cb({})
end)

RegisterNUICallback('updatePropertiesMenu', function(data, cb)
	cb({
		entity = data.handle,
		properties = json.encode(GetEntityProperties(data.handle)),
		inDb = EntityIsInDatabase(data.handle),
		hasNetworkControl = NetworkHasControlOfEntity(data.handle)
	})
end)

RegisterNUICallback('invincibleOn', function(data, cb)
	if Permissions.properties.invincible then
		RequestControl(data.handle)
		SetEntityInvincible(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('invincibleOff', function(data, cb)
	if Permissions.properties.invincible then
		RequestControl(data.handle)
		SetEntityInvincible(data.handle, false)
	end
	cb({})
end)

function PlacePedOnGroundProperly(ped)
	local x, y, z = table.unpack(GetEntityCoords(ped))
	local found, groundz, normal = GetGroundZAndNormalFor_3dCoord(x, y, z)
	if found then
		SetEntityCoordsNoOffset(ped, x, y, groundz + normal.z, true)
	end
end

function PlaceOnGroundProperly(entity)
	local entityType = GetEntityType(entity)

	local r1 = GetEntityRotation(entity, 2)

	if entityType == 1 then
		PlacePedOnGroundProperly(entity)
	elseif entityType == 2 then
		SetVehicleOnGroundProperly(entity)
	elseif entityType == 3 then
		PlaceObjectOnGroundProperly(entity)
	end

	local r2 = GetEntityRotation(entity, 2)

	SetEntityRotation(entity, r2.x, r2.y, r1.z, 2)
end

RegisterNUICallback('placeEntityHere', function(data, cb)
	local x, y, z = table.unpack(GetCamCoord(Cam))
	local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))

	local spawnPos, entity, distance = GetInView(x, y, z, pitch, roll, yaw)

	RequestControl(data.handle)
	SetEntityCoordsNoOffset(data.handle, spawnPos.x, spawnPos.y, spawnPos.z)
	PlaceOnGroundProperly(data.handle)

	x, y, z = table.unpack(GetEntityCoords(data.handle))
	pitch, roll, yaw = table.unpack(GetEntityRotation(data.handle, 2))

	cb({
		x = x,
		y = y,
		z = z,
		pitch = pitch,
		roll = roll,
		yaw = yaw
	})
end)

function PrepareDatabaseForSave(database)
	local db = json.decode(json.encode(database))

	for entity, props in pairs(db) do
		if props.attachment.to == PlayerPedId() then
			props.attachment.to = -1
		end
	end

	db[tostring(PlayerPedId())] = nil

	return db
end

function SaveDatabase(name)
	UpdateDatabase()
	SetResourceKvp(name, json.encode(PrepareDatabaseForSave(Database)))
end

function LoadDatabase(db, relative, replace)
	if replace then
		RemoveAllFromDatabase()
	end

	local ax = 0.0
	local ay = 0.0
	local az = 0.0

	local spawns = {}
	local handles = {}

	for entity, props in pairs(db) do
		if relative then
			ax = ax + props.x
			ay = ay + props.y
			az = az + props.z
		end

		table.insert(spawns, {entity = tonumber(entity), props = props})
	end

	local dx, dy, dz

	local rot = GetCamRot(Cam, 2)

	if relative then
		ax = ax / #spawns
		ay = ay / #spawns
		az = az / #spawns

		local pos = GetCamCoord(Cam)
		local spawnPos, entity, distance = GetInView(pos.x, pos.y, pos.z, rot.x, rot.y, rot.z)

		dx = spawnPos.x - ax
		dy = spawnPos.y - ay
		dz = spawnPos.z - az
	end

	local r = math.rad(rot.z)
	local cosr = math.cos(r)
	local sinr = math.sin(r)

	for _, spawn in ipairs(spawns) do
		local entity

		local x, y, z, pitch, roll, yaw

		if relative then
			x = (((spawn.props.x - ax) * cosr - (spawn.props.y - ay) * sinr + ax) + dx) * 1.0
			y = (((spawn.props.y - ay) * cosr + (spawn.props.x - ax) * sinr + ay) + dy) * 1.0
			z = (spawn.props.z + dz) * 1.0
			pitch = spawn.props.pitch * 1.0
			roll = spawn.props.roll * 1.0
			yaw = (spawn.props.yaw + rot.z) * 1.0
		else
			x = spawn.props.x * 1.0
			y = spawn.props.y * 1.0
			z = spawn.props.z * 1.0
			pitch = spawn.props.pitch * 1.0
			roll = spawn.props.roll * 1.0
			yaw = spawn.props.yaw * 1.0
		end

		if spawn.props.type == 1 then
			entity = SpawnPed(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.outfit, spawn.props.isInGroup, spawn.props.animation, spawn.props.scenario, spawn.props.blockNonTemporaryEvents)
		elseif spawn.props.type == 2 then
			entity = SpawnVehicle(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled)
		elseif spawn.props.type == 5 then
			entity = SpawnPickup(spawn.props.name, spawn.props.model, x, y, z)
		else
			entity = SpawnObject(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.lightsIntensity, spawn.props.lightsColour, spawn.props.lightsType)
		end

		if entity and relative then
			PlaceOnGroundProperly(entity)
		end

		handles[spawn.entity] = entity
	end

	for _, spawn in ipairs(spawns) do
		if spawn.props.attachment and spawn.props.attachment.to ~= 0 then
			local from  = handles[spawn.entity]
			local to    = spawn.props.attachment.to == -1 and PlayerPedId() or handles[spawn.props.attachment.to]
			local bone  = spawn.props.attachment.bone
			local x     = spawn.props.attachment.x * 1.0
			local y     = spawn.props.attachment.y * 1.0
			local z     = spawn.props.attachment.z * 1.0
			local pitch = spawn.props.attachment.pitch * 1.0
			local roll  = spawn.props.attachment.roll * 1.0
			local yaw   = spawn.props.attachment.yaw * 1.0

			AttachEntityToEntity(from, to, bone, x, y, z, pitch, roll, yaw, false, false, true, false, 0, true, false, false)

			AddEntityToDatabase(from, nil, {
				to = to,
				bone = bone,
				x = x,
				y = y,
				z = z,
				pitch = pitch,
				roll = roll,
				yaw = yaw
			})
		end
	end
end

function LoadSavedDatabase(name, relative, replace)
	local db = json.decode(GetResourceKvpString(name))

	if db then
		LoadDatabase(db, relative, replace)
	end
end

function GetSavedDatabases()
	local dbs = {}

	local handle = StartFindKvp("")

	while true do
		local kvp = FindKvp(handle)

		if kvp then
			table.insert(dbs, kvp)
		else
			break
		end
	end

	EndFindKvp(handle)

	table.sort(dbs)

	return dbs
end

function DeleteDatabase(name)
	DeleteResourceKvp(name)
end

RegisterNUICallback('saveDb', function(data, cb)
	SaveDatabase(data.name)
	cb(json.encode(GetSavedDatabases()))
end)

RegisterNUICallback('loadDb', function(data, cb)
	LoadSavedDatabase(data.name, data.relative, data.replace)
	cb({})
end)

RegisterNUICallback('deleteDb', function(data, cb)
	DeleteDatabase(data.name)
	cb({})
end)

RegisterNUICallback('init', function(data, cb)
	cb({
		peds = json.encode(Peds),
		vehicles = json.encode(Vehicles),
		objects = json.encode(Objects),
		scenarios = json.encode(Scenarios),
		weapons = json.encode(Weapons),
		animations = json.encode(Animations),
		propsets = json.encode(Propsets),
		pickups = json.encode(Pickups),
		adjustSpeed = AdjustSpeed,
		rotateSpeed = RotateSpeed
	})
end)

RegisterNUICallback('setAdjustSpeed', function(data, cb)
	AdjustSpeed = data.speed * 1.0
	cb({})
end)

RegisterNUICallback('setRotateSpeed', function(data, cb)
	RotateSpeed = data.speed * 1.0
	cb({})
end)

function GetTeleportTarget()
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped, false)
	local mnt = GetMount(ped)
	return (veh == 0 and (mnt == 0 and ped or mnt) or veh)
end

function TeleportToCoords(x, y, z, h)
	local ent = GetTeleportTarget()
	FreezeEntityPosition(ent, true)
	SetEntityCoords(ent, x, y, z, 0, 0, 0, 0, 0)
	SetEntityHeading(ent, h)
	FreezeEntityPosition(ent, false)
end

RegisterNUICallback('goToEntity', function(data, cb)
	if Permissions.properties.goTo then
		DisableSpoonerMode()
		local x, y, z = table.unpack(GetEntityCoords(data.handle))
		TeleportToCoords(x, y, z, 0.0)
	end
	cb({})
end)

function CloneEntity(entity)
	local props = GetEntityProperties(entity)
	local clone = nil

	if props.type == 1 then
		clone = SpawnPed(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.outfit, props.isInGroup, props.animation, props.scenario, props.blockNonTemporaryEvents)
	elseif props.type == 2 then
		clone = SpawnVehicle(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled)
	elseif props.type == 3 then
		clone = SpawnObject(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.lightsIntensity, props.lightsColour, props.lightsType)
	elseif props.type == 5 then
		clone = SpawnPickup(props.name, props.model, props.x, props.y, props.z)
	else
		return nil
	end

	if clone and props.attachment and props.attachment.to ~= 0 then
		AttachEntityToEntity(clone, props.attachment.to, props.attachment.bone, props.attachment.x, props.attachment.y, props.attachment.z, props.attachment.pitch, props.attachment.roll, props.attachment.yaw, false, false, true, false, 0, true, false, false)

		AddEntityToDatabase(clone, nil, props.attachment)
	end

	return clone
end

RegisterNUICallback('cloneEntity', function(data, cb)
	local clone = CloneEntity(data.handle)

	if clone then
		OpenPropertiesMenuForEntity(clone)
	end

	cb({})
end)

RegisterNUICallback('closeHelpMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('getIntoVehicle', function(data, cb)
	DisableSpoonerMode()
	RequestControl(data.handle)
	TaskWarpPedIntoVehicle(PlayerPedId(), data.handle, -1)
	cb({})
end)

RegisterNUICallback('repairVehicle', function(data, cb)
	if Permissions.properties.vehicle.repair then
		RequestControl(data.handle)
		SetVehicleFixed(data.handle)
	end
	cb({})
end)

function ConvertDatabaseToMapEditorXml(creator, database)
	local xml = '<Map>\n\t<MapMeta Creator="' .. creator .. '"/>\n'

	for entity, properties in pairs(database) do
		if properties.type == 1 then
			xml = xml .. string.format('\t<Ped Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_Y="%s" Rotation_z="%s" Preset="%d"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw, properties.outfit)
		elseif properties.type == 2 then
			xml = xml .. string.format('\t<Vehicle Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_Y="%s" Rotation_z="%s"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw)
		else
			xml = xml .. string.format('\t<Object Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_Y="%s" Rotation_z="%s"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw)
		end
	end

	xml = xml .. '</Map>'

	return xml
end

function ExportDatabase(format)
	UpdateDatabase()

	if format == 'spooner-db-json' then
		return json.encode(PrepareDatabaseForSave(Database))
	elseif format == 'map-editor-xml' then
		return ConvertDatabaseToMapEditorXml(GetPlayerName(), PrepareDatabaseForSave(Database))
	end
end

function ImportDatabase(format, content)
	if format == 'spooner-db-json' then
		local db = json.decode(content)

		if db then
			LoadDatabase(db, false, false)
		end
	end
end

RegisterNUICallback('exportDb', function(data, cb)
	cb(ExportDatabase(data.format))
end)

RegisterNUICallback('importDb', function(data, cb)
	ImportDatabase(data.format, data.content)
	cb({})
end)

RegisterNUICallback('closeImportExportDbWindow', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('requestControl', function(data, cb)
	RequestControl(data.handle)
	cb({})
end)

RegisterNUICallback('getDatabase', function(data, cb)
	UpdateDatabase()
	cb({
		properties = json.encode(GetEntityProperties(data.handle)),
		database = json.encode(Database)
	})
end)

RegisterNUICallback('attachTo', function(data, cb)
	if Permissions.properties.attachments then
		local from = data.from
		local to = data.to

		if not to then
			local props = GetEntityProperties(from)

			if props.attachment.to ~= 0 then
				to = props.attachment.to
			else
				cb({})
				return
			end
		end

		local x, y, z, pitch, roll, yaw

		if data.keepPos then
			local x1, y1, z1 = table.unpack(GetEntityCoords(from))
			x, y, z = table.unpack(GetOffsetFromEntityGivenWorldCoords(to, x1, y1, z1))
			pitch, roll, yaw = table.unpack(GetEntityRotation(from, 2) - GetEntityRotation(to, 2))
		else
			x = data.x and data.x * 1.0 or 0.0
			y = data.y and data.y * 1.0 or 0.0
			z = data.z and data.z * 1.0 or 0.0
			pitch = data.pitch and data.pitch * 1.0 or 0.0
			roll = data.roll and data.roll * 1.0 or 0.0
			yaw = data.yaw and data.yaw * 1.0 or 0.0
		end

		RequestControl(from)
		AttachEntityToEntity(from, to, data.bone, x, y, z, pitch, roll, yaw, false, false, true, false, 0, true, false, false)

		if EntityIsInDatabase(from) then
			AddEntityToDatabase(from, nil, {
				to = to,
				bone = data.bone,
				x = x,
				y = y,
				z = z,
				pitch = pitch,
				roll = roll,
				yaw = yaw
			})
		end
	end

	cb({})
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('detach', function(data, cb)
	if Permissions.properties.attachments then
		RequestControl(data.handle)
		DetachEntity(data.handle, false, true)

		if EntityIsInDatabase(data.handle) then
			AddEntityToDatabase(data.handle, nil, {
				to = 0,
				bone = 0,
				x = 0.0,
				y = 0.0,
				z = 0.0,
				pitch = 0.0,
				roll = 0.0,
				yaw = 0.0
			})
		end
	end

	cb({})
end)

RegisterNUICallback('setEntityHealth', function(data, cb)
	if Permissions.properties.health then
		RequestControl(data.handle)
		SetEntityHealth(data.handle, data.health, 0)
	end
	cb({})
end)

RegisterNUICallback('setEntityVisible', function(data, cb)
	if Permissions.properties.visible then
		RequestControl(data.handle)
		SetEntityVisible(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('setEntityInvisible', function(data, cb)
	if Permissions.properties.visible then
		RequestControl(data.handle)
		SetEntityVisible(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('gravityOn', function(data, cb)
	if Permissions.properties.gravity then
		RequestControl(data.handle)
		SetEntityHasGravity(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('gravityOff', function(data, cb)
	if Permissions.properties.gravity then
		RequestControl(data.handle)
		SetEntityHasGravity(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('performScenario', function(data, cb)
	if Permissions.properties.ped.scenario then
		RequestControl(data.handle)
		TaskStartScenarioInPlace(data.handle, GetHashKey(data.scenario), 0, true)

		if Database[data.handle] then
			Database[data.handle].animation = nil
			Database[data.handle].scenario = data.scenario
		end
	end

	cb({})
end)

RegisterNUICallback('clearPedTasks', function(data, cb)
	if Permissions.properties.ped.clearTasks then
		RequestControl(data.handle)
		ClearPedTasks(data.handle)

		if Database[data.handle] then
			Database[data.handle].scenario = nil
			Database[data.handle].animation = nil
		end
	end

	cb({})
end)

RegisterNUICallback('clearPedTasksImmediately', function(data, cb)
	if Permissions.properties.ped.clearTasks then
		RequestControl(data.handle)
		ClearPedTasksImmediately(data.handle)

		if Database[data.handle] then
			Database[data.handle].scenario = nil
			Database[data.handle].animation = nil
		end
	end

	cb({})
end)

RegisterNUICallback('setOutfit', function(data, cb)
	if Permissions.properties.ped.outfit then
		RequestControl(data.handle)
		SetPedOutfitPreset(data.handle, data.outfit)

		if EntityIsInDatabase(data.handle) then
			Database[data.handle].outfit = data.outfit
		end
	end

	cb({})
end)

function AddToGroup(ped)
	local group = GetPlayerGroup(PlayerId())
	SetPedAsGroupMember(ped, group)
	SetGroupSeparationRange(group, -1)
	SetPedCanTeleportToGroupLeader(ped, group, true)
	BlipAddForEntity(Config.GroupMemberBlipSprite, ped)
end

RegisterNUICallback('addToGroup', function(data, cb)
	if Permissions.properties.ped.group then
		RequestControl(data.handle)
		AddToGroup(data.handle)
	end
	cb({})
end)

RegisterNUICallback('removeFromGroup', function(data, cb)
	if Permissions.properties.ped.group then
		RequestControl(data.handle)
		RemovePedFromGroup(data.handle)
		RemoveBlip(GetBlipFromEntity(data.handle))
	end
	cb({})
end)

RegisterNUICallback('collisionOn', function(data, cb)
	if Permissions.properties.collision then
		RequestControl(data.handle)
		SetEntityCollision(data.handle, true, true)
	end
	cb({})
end)

RegisterNUICallback('collisionOff', function(data, cb)
	if Permissions.properties.collision then
		RequestControl(data.handle)
		SetEntityCollision(data.handle, false, false)
	end
	cb({})
end)

RegisterNUICallback('giveWeapon', function(data, cb)
	if Permissions.properties.ped.weapon then
		RequestControl(data.handle)
		GiveWeaponToPed_2(data.handle, GetHashKey(data.weapon), 500, true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
	end
	cb({})
end)

RegisterNUICallback('removeAllWeapons', function(data, cb)
	if Permissions.properties.ped.weapon then
		RequestControl(data.handle)
		RemoveAllPedWeapons(data.handle, true, true)
	end
	cb({})
end)

RegisterNUICallback('resurrectPed', function(data, cb)
	if Permissions.properties.ped.resurrect then
		RequestControl(data.handle)
		ResurrectPed(data.handle)
	end
	cb({})
end)

RegisterNUICallback('getOnMount', function(data, cb)
	if Permissions.properties.ped.mount then
		DisableSpoonerMode()
		RequestControl(data.handle)
		SetPedOnMount(PlayerPedId(), data.handle, -1, false)
	end
	cb({})
end)

RegisterNUICallback('engineOn', function(data, cb)
	RequestControl(data.handle)
	SetVehicleEngineOn(data.handle, true, true)
	cb({})
end)

RegisterNUICallback('engineOff', function(data, cb)
	RequestControl(data.handle)
	SetVehicleEngineOn(data.handle, false, true)
	cb({})
end)

RegisterNUICallback('setLightsIntensity', function(data, cb)
	if Permissions.properties.lights then
		local intensity = data.intensity and data.intensity * 1.0 or 0.0

		RequestControl(data.handle)
		SetLightsIntensityForEntity(data.handle, intensity)

		if EntityIsInDatabase(data.handle) then
			Database[data.handle].lightsIntensity = intensity
		end
	end

	cb({})
end)

RegisterNUICallback('setLightsColour', function(data, cb)
	if Permissions.properties.lights then
		local red = data.red and data.red or 0
		local green = data.green and data.green or 0
		local blue = data.blue and data.blue or 0

		RequestControl(data.handle)
		SetLightsColorForEntity(data.handle, red, green, blue)

		if EntityIsInDatabase(data.handle) then
			Database[data.handle].lightsColour = {
				red = red,
				green = green,
				blue = blue
			}
		end
	end

	cb({})
end)

RegisterNUICallback('setLightsType', function(data, cb)
	if Permissions.properties.lights then
		local type = data.type and data.type or 0

		RequestControl(data.handle)
		SetLightsTypeForEntity(data.handle, type)

		if EntityIsInDatabase(data.handle) then
			Database[data.handle].lightsType = type
		end
	end

	cb({})
end)

RegisterNUICallback('setVehicleLightsOn', function(data, cb)
	if Permissions.properties.vehicle.lights then
		RequestControl(data.handle)
		SetVehicleLights(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('setVehicleLightsOff', function(data, cb)
	if Permissions.properties.vehicle.lights then
		RequestControl(data.handle)
		SetVehicleLights(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('aiOn', function(data, cb)
	if Permissions.properties.ped.ai then
		RequestControl(data.handle)
		SetBlockingOfNonTemporaryEvents(data.handle, false)

		if Database[data.handle] then
			Database[data.handle].blockNonTemporaryEvents = false
		end
	end

	cb({})
end)

RegisterNUICallback('aiOff', function(data, cb)
	if Permissions.properties.ped.ai then
		RequestControl(data.handle)
		SetBlockingOfNonTemporaryEvents(data.handle, true)

		if Database[data.handle] then
			Database[data.handle].blockNonTemporaryEvents = true
		end
	end

	cb({})
end)

RegisterNUICallback('setPlayerModel', function(data, cb)
	if Permissions.properties.ped.changeModel and data.modelName then
		local model = GetHashKey(data.modelName)

		if LoadModel(model) then
			SetPlayerModel(PlayerId(), model, true)
		end
	end
	cb({
		handle = PlayerPedId()
	})
end)

RegisterNUICallback('playAnimation', function(data, cb)
	if Permissions.properties.ped.animation then
		local blendInSpeed = data.blendInSpeed and data.blendInSpeed * 1.0 or 1.0
		local blendOutSpeed = data.blendOutSpeed and data.blendOutSpeed * 1.0 or 1.0
		local duration = data.duration and data.duraction or -1
		local flag = data.flag and data.flag or 1
		local playbackRate = data.playbackRate and data.playbackRate * 1.0 or 1.0

		RequestControl(data.handle)

		if DoesAnimDictExist(data.dict) then
			RequestAnimDict(data.dict)

			while not HasAnimDictLoaded(data.dict) do
				Wait(0)
			end

			TaskPlayAnim(data.handle, data.dict, data.name, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, false, false, false, '', false)

			if Database[data.handle] then
				Database[data.handle].animation = {
					dict = data.dict,
					name = data.name,
					blendInSpeed = blendOutSpeed,
					blendOutSpeed = blendOutSpeed,
					duration = duration,
					flag = flag,
					playbackRate = playbackRate
				}
				Database[data.handle].scenario = nil
			end
		end
	end

	cb({})
end)

RegisterNUICallback('loadPermissions', function(data, cb)
	cb(json.encode(Permissions))
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/spooner', 'Toggle spooner mode', {})

	TriggerServerEvent('spooner:init')

	while true do
		Wait(0)

		if not EntityIsInDatabase(PlayerPedId()) then
			AddEntityToDatabase(PlayerPedId())
		end

		if IsUsingKeyboard(0) and IsDisabledControlJustPressed(0, Config.ToggleControl) then
			TriggerServerEvent('spooner:toggle')
		end

		if Cam then
			DisableAllControlActions(0)
			EnableControlAction(0, 0x4A903C11)
			EnableControlAction(0, 0x9720fcee)

			local x1, y1, z1 = table.unpack(GetCamCoord(Cam))
			local pitch1, roll1, yaw1 = table.unpack(GetCamRot(Cam, 2))

			local x2 = x1
			local y2 = y1
			local z2 = z1
			local pitch2 = pitch1
			local roll2 = roll1
			local yaw2 = yaw1

			local spawnPos, entity, distance = GetInView(x2, y2, z2, pitch2, roll2, yaw2)

			if AttachedEntity then
				entity = AttachedEntity
			end

			SendNUIMessage({
				type = 'updateSpoonerHud',
				entity = entity,
				entityType = GetSpoonerEntityType(entity),
				modelName = GetModelName(GetSpoonerEntityModel(entity)),
				attachedEntity = AttachedEntity,
				speed = string.format('%.2f', Speed),
				currentSpawn = CurrentSpawn and CurrentSpawn.modelName,
				rotateMode = RotateMode,
				adjustMode = AdjustMode,
				placeOnGround = PlaceOnGround,
				adjustSpeed = AdjustSpeed,
				rotateSpeed = RotateSpeed,
				x = string.format('%.2f', spawnPos.x),
				y = string.format('%.2f', spawnPos.y),
				z = string.format('%.2f', spawnPos.z),
				heading = string.format('%.2f', yaw2)
			})

			if Speed < Config.MinSpeed then
				Speed = Config.MinSpeed
			end
			if Speed > Config.MaxSpeed then
				Speed = Config.MaxSpeed
			end

			if IsDisabledControlPressed(0, Config.IncreaseSpeedControl) then
				Speed = Speed + Config.SpeedIncrement
			end

			if IsDisabledControlPressed(0, Config.DecreaseSpeedControl) then
				Speed = Speed - Config.SpeedIncrement
			end

			if IsDisabledControlPressed(0, Config.UpControl) then
				z2 = z2 + Speed
			end

			if IsDisabledControlPressed(0, Config.DownControl) then
				z2 = z2 - Speed
			end

			local axisX = GetDisabledControlNormal(0, 0xA987235F)
			local axisY = GetDisabledControlNormal(0, 0xD2047988)

			if axisX ~= 0.0 or axisY ~= 0.0 then
				yaw2 = yaw2 + axisX * -1.0 * Config.SpeedUd
				pitch2 = math.max(math.min(89.9, pitch2 + axisY * -1.0 * Config.SpeedLr), -89.9)
			end

			local r1 = -yaw2 * math.pi / 180
			local dx1 = Speed * math.sin(r1)
			local dy1 = Speed * math.cos(r1)

			local r2 = math.floor(yaw2 + 90.0) % 360 * -1.0 * math.pi / 180
			local dx2 = Speed * math.sin(r2)
			local dy2 = Speed * math.cos(r2)

			if IsDisabledControlPressed(0, Config.ForwardControl) then
				x2 = x2 + dx1
				y2 = y2 + dy1
			end

			if IsDisabledControlPressed(0, Config.BackwardControl) then
				x2 = x2 - dx1
				y2 = y2 - dy1
			end

			if IsDisabledControlPressed(0, Config.LeftControl) then
				x2 = x2 + dx2
				y2 = y2 + dy2
			end

			if IsDisabledControlPressed(0, Config.RightControl) then
				x2 = x2 - dx2
				y2 = y2 - dy2
			end

			if IsDisabledControlJustPressed(0, Config.SpawnSelectControl) then
				if AttachedEntity then
					AttachedEntity = nil
				elseif entity and CanModifyEntity(entity) then
					if IsEntityAttached(entity) then
						AttachedEntity = GetEntityAttachedTo(entity)
					else
						AttachedEntity = entity
					end
				elseif CurrentSpawn then
					local entity

					if CurrentSpawn.type == 1 then
						entity = SpawnPed(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, -1, false, nil, nil, false)
					elseif CurrentSpawn.type == 2 then
						entity = SpawnVehicle(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false)
					elseif CurrentSpawn.type == 3 then
						entity = SpawnObject(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, nil, nil, nil)
					elseif CurrentSpawn.type == 4 then
						entity = SpawnPropset(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, yaw2)
					elseif CurrentSpawn.type == 5 then
						entity = SpawnPickup(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z)
					end

					if entity then
						PlaceOnGroundProperly(entity)
					end
				end
			end

			if IsDisabledControlJustPressed(0, Config.DeleteControl) and entity then
				if AttachedEntity then
					RemoveEntity(AttachedEntity)
					AttachedEntity = nil
				else
					RemoveEntity(entity)
				end
			end

			if IsDisabledControlJustReleased(0, Config.ObjectMenuControl) then
				SendNUIMessage({
					type = 'openSpawnMenu'
				})
				SetNuiFocus(true, true)
			end

			if IsDisabledControlJustReleased(0, Config.DbMenuControl) then
				OpenDatabaseMenu()
			end

			if IsDisabledControlJustReleased(0, Config.SaveLoadDbMenuControl) then
				OpenSaveDbMenu()
			end

			if IsDisabledControlJustReleased(0, Config.HelpMenuControl) then
				SendNUIMessage({
					type = 'openHelpMenu'
				})
				SetNuiFocus(true, true)
			end

			if IsDisabledControlJustPressed(0, Config.RotateModeControl) then
				RotateMode = (RotateMode + 1) % 3
			end

			if IsDisabledControlJustPressed(0, Config.AdjustModeControl) then
				AdjustMode = (AdjustMode + 1) % 5
			end

			if IsDisabledControlJustPressed(0, Config.FreeAdjustModeControl) then
				AdjustMode = -1
			end

			if IsDisabledControlJustPressed(0, Config.PlaceOnGroundControl) then
				PlaceOnGround = not PlaceOnGround
			end

			if entity and CanModifyEntity(entity) then
				local posChanged = false
				local rotChanged = false

				if IsDisabledControlJustReleased(0, Config.PropMenuControl) then
					OpenPropertiesMenuForEntity(entity)
				end

				if IsDisabledControlJustPressed(0, Config.CloneControl) then
					AttachedEntity = CloneEntity(entity)
				end

				local ex1, ey1, ez1 = table.unpack(GetEntityCoords(entity))
				local epitch1, eroll1, eyaw1 = table.unpack(GetEntityRotation(entity, 2))
				local ex2 = ex1
				local ey2 = ey1
				local ez2 = ez1
				local epitch2 = epitch1
				local eroll2 = eroll1
				local eyaw2 = eyaw1

				local edx1 = AdjustSpeed * math.sin(r1)
				local edy1 = AdjustSpeed * math.cos(r1)
				local edx2 = AdjustSpeed * math.sin(r2)
				local edy2 = AdjustSpeed * math.cos(r2)

				if IsDisabledControlPressed(0, Config.RotateLeftControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 + RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 + RotateSpeed
					else
						eyaw2 = eyaw2 + RotateSpeed
					end

					rotChanged = true
				end

				if IsDisabledControlPressed(0, Config.RotateRightControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 - RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 - RotateSpeed
					else
						eyaw2 = eyaw2 - RotateSpeed
					end

					rotChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustUpControl) then
					ez2 = ez2 + AdjustSpeed
					posChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustDownControl) then
					ez2 = ez2 - AdjustSpeed
					posChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustForwardControl) then
					ex2 = ex2 + edx1
					ey2 = ey2 + edy1
					posChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustBackwardControl) then
					ex2 = ex2 - edx1
					ey2 = ey2 - edy1
					posChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustLeftControl) then
					ex2 = ex2 + edx2
					ey2 = ey2 + edy2
					posChanged = true
				end

				if IsDisabledControlPressed(0, Config.AdjustRightControl) then
					ex2 = ex2 - edx2
					ey2 = ey2 - edy2
					posChanged = true
				end

				if AttachedEntity or posChanged or rotChanged then
					RequestControl(entity)

					if posChanged then
						SetEntityCoordsNoOffset(entity, ex2, ey2, ez2)
					end

					if rotChanged then
						SetEntityRotation(entity, epitch2, eroll2, eyaw2, 2)
					end

					if AttachedEntity then
						if AdjustMode == -1 then
							SetEntityCoordsNoOffset(AttachedEntity, spawnPos.x, spawnPos.y, spawnPos.z)
							PlaceOnGroundProperly(AttachedEntity)
						elseif AdjustMode ~= 4 then
							x2 = x1
							y2 = y1
							z2 = z1
							pitch2 = pitch1
							yaw2 = yaw1

							if AdjustMode == 0 then
								SetEntityCoordsNoOffset(AttachedEntity, ex2 - axisX, ey2, ez2)
							elseif AdjustMode == 1 then
								SetEntityCoordsNoOffset(AttachedEntity, ex2, ey2 - axisX, ez2)
							elseif AdjustMode == 2 then
								SetEntityCoordsNoOffset(AttachedEntity, ex2, ey2, ez2 - axisY)
							elseif AdjustMode == 3 then
								if RotateMode == 0 then
									SetEntityRotation(AttachedEntity, epitch2 - axisX * Config.SpeedLr, eroll2, eyaw2)
								elseif RotateMode == 1 then
									SetEntityRotation(AttachedEntity, epitch2, eroll2 - axisX * Config.SpeedLr, eyaw2)
								else
									SetEntityRotation(AttachedEntity, epitch2, eroll2, eyaw2 - axisX * Config.SpeedLr)
								end
							end

							if PlaceOnGround then
								PlaceOnGroundProperly(AttachedEntity)
							end
						end
					end
				end
			end

			SetCamCoord(Cam, x2, y2, z2)
			SetCamRot(Cam, pitch2, 0.0, yaw2)
		end
	end
end)
