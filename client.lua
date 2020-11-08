local Cam = nil
local ShowHud = true
local Speed = Config.Speed
local ClearTasks = false

local Database = {}

local AdjustSpeed = Config.AdjustSpeed
local RotateSpeed = Config.RotateSpeed

local AttachedEntity = nil

local RotateMode = 2
local AdjustMode = -1

local PlaceOnGround = false

RegisterNetEvent('spooner:toggle')
RegisterNetEvent('spooner:openDatabaseMenu')
RegisterNetEvent('spooner:openSaveDbMenu')

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

function EnableSpoonerMode()
	if not IsPedUsingAnyScenario(PlayerPedId()) then
		TaskStandStill(PlayerPedId(), -1)
		ClearTasks = true
	else
		ClearTasks = false
	end

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
	if ClearTasks then
		ClearPedTasks(PlayerPedId(), true, true)
	end

	RenderScriptCams(false, true, 500, true, true)
	SetCamActive(Cam, false)
	DetachCam(Cam)
	DestroyCam(Cam, true)
	Cam = nil
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

function DrawText(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
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

	return string.format('%x', model)
end

function GetLiveEntityProperties(entity)
	local model = GetEntityModel(entity)
	local x, y, z = table.unpack(GetEntityCoords(entity))
	local pitch, roll, yaw = table.unpack(GetEntityRotation(entity, 2))

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

	local outfit = Database[entity] and Database[entity].outfit or -1

	local attachBone, attachX, attachY, attachZ, attachPitch, attachRoll, attachYaw

	local lightsIntensity = Database[entity] and Database[entity].lightsIntensity or nil
	local lightsColour = Database[entity] and Database[entity].lightsColour or nil
	local lightsType = Database[entity] and Database[entity].lightsType or nil

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

function SpawnObject(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, lightsIntensity, lightsColour, lightsType)
	if not IsModelInCdimage(model) then
		return nil
	end

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
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
	if not IsModelInCdimage(model) then
		return nil
	end

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
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

	AddEntityToDatabase(veh, name)

	return veh
end

function SpawnPed(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, outfit, addToGroup)
	if not IsModelInCdimage(model) then
		return nil
	end

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
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

	AddEntityToDatabase(ped, name)

	return ped
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

function RemoveEntity(entity)
	if IsPedAPlayer(entity) then
		return
	end

	RequestControl(entity)
	SetEntityAsMissionEntity(entity, true, true)
	DeleteEntity(entity)

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
	if GetCurrentResourceName() == resourceName and Cam then
		DisableSpoonerMode()
		--RemoveAllFromDatabase();
	end
end)

local CurrentSpawn = nil

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
	RemoveEntityFromDatabase(data.handle)
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

	for entity, properties in pairs(Database) do
		table.insert(entities, entity)
	end

	for _, entity in ipairs(entities) do
		if DoesEntityExist(entity) then
			AddEntityToDatabase(entity)
		else
			RemoveEntityFromDatabase(entity)
		end
	end
end

function OpenPropertiesMenuForEntity(entity)
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
	RequestControl(data.handle)
	SetEntityInvincible(data.handle, true)
	cb({})
end)

RegisterNUICallback('invincibleOff', function(data, cb)
	RequestControl(data.handle)
	SetEntityInvincible(data.handle, false)
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

function LoadDatabase(db, relative)
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
			entity = SpawnPed(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.outfit, spawn.props.isInGroup)
		elseif spawn.props.type == 2 then
			entity = SpawnVehicle(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled)
		else
			entity = SpawnObject(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.lightsIntensity, spawn.props.lightsColour, spawn.props.lightsType)
		end

		if relative then
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

function LoadSavedDatabase(name, relative)
	local db = json.decode(GetResourceKvpString(name))

	if db then
		LoadDatabase(db, relative)
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
	LoadSavedDatabase(data.name, data.relative)
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

function TeleportToCoords(x, y, z, h)
	local ent = PlayerPedId()
	FreezeEntityPosition(ent, true)
	SetEntityCoords(ent, x, y, z, 0, 0, 0, 0, 0)
	SetEntityHeading(ent, h)
	FreezeEntityPosition(ent, false)
end

RegisterNUICallback('goToEntity', function(data, cb)
	DisableSpoonerMode()
	local x, y, z = table.unpack(GetEntityCoords(data.handle))
	TeleportToCoords(x, y, z, 0.0)
	cb({})
end)

function CloneEntity(entity)
	local props = GetEntityProperties(entity)
	local entityType = GetEntityType(entity)

	if entityType == 1 then
		return SpawnPed(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.outfit, props.isInGroup)
	elseif entityType == 2 then
		return SpawnVehicle(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled)
	elseif entityType == 3 then
		return SpawnObject(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.lightsIntensity, props.lightsColour, props.lightsType)
	else
		return nil
	end
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
	RequestControl(data.handle)
	SetVehicleFixed(data.handle)
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
			LoadDatabase(db, false)
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
		local x2, y2, z2 = table.unpack(GetEntityCoords(to))
		local rot = GetEntityRotation(from, 2)

		x = x1 - x2
		y = y1 - y2
		z = z1 - z2

		pitch = rot.x
		roll = rot.y
		yaw = rot.z
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

	cb({})
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('detach', function(data, cb)
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

	cb({})
end)

RegisterNUICallback('setEntityHealth', function(data, cb)
	RequestControl(data.handle)
	SetEntityHealth(data.handle, data.health, 0)
	cb({})
end)

RegisterNUICallback('setEntityVisible', function(data, cb)
	RequestControl(data.handle)
	SetEntityVisible(data.handle, true)
	cb({})
end)

RegisterNUICallback('setEntityInvisible', function(data, cb)
	RequestControl(data.handle)
	SetEntityVisible(data.handle, false)
	cb({})
end)

RegisterNUICallback('gravityOn', function(data, cb)
	RequestControl(data.handle)
	SetEntityHasGravity(data.handle, true)
	cb({})
end)

RegisterNUICallback('gravityOff', function(data, cb)
	RequestControl(data.handle)
	SetEntityHasGravity(data.handle, false)
	cb({})
end)

RegisterNUICallback('performScenario', function(data, cb)
	RequestControl(data.handle)
	ClearPedTasksImmediately(data.handle)
	TaskStartScenarioInPlace(data.handle, GetHashKey(data.scenario), -1)

	if data.handle == PlayerPedId() then
		ClearTasks = false
	end

	cb({})
end)

RegisterNUICallback('clearPedTasks', function(data, cb)
	RequestControl(data.handle)
	ClearPedTasks(data.handle)
	cb({})
end)

RegisterNUICallback('clearPedTasksImmediately', function(data, cb)
	RequestControl(data.handle)
	ClearPedTasksImmediately(data.handle)
	cb({})
end)

RegisterNUICallback('setOutfit', function(data, cb)
	RequestControl(data.handle)
	SetPedOutfitPreset(data.handle, data.outfit)

	if EntityIsInDatabase(data.handle) then
		Database[data.handle].outfit = data.outfit
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
	RequestControl(data.handle)
	AddToGroup(data.handle)
	cb({})
end)

RegisterNUICallback('removeFromGroup', function(data, cb)
	RequestControl(data.handle)
	RemovePedFromGroup(data.handle)
	RemoveBlip(GetBlipFromEntity(data.handle))
	cb({})
end)

RegisterNUICallback('collisionOn', function(data, cb)
	RequestControl(data.handle)
	SetEntityCollision(data.handle, true, true)
	cb({})
end)

RegisterNUICallback('collisionOff', function(data, cb)
	RequestControl(data.handle)
	SetEntityCollision(data.handle, false, false)
	cb({})
end)

RegisterNUICallback('giveWeapon', function(data, cb)
	RequestControl(data.handle)
	GiveWeaponToPed_2(data.handle, GetHashKey(data.weapon), 500, true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
	cb({})
end)

RegisterNUICallback('removeAllWeapons', function(data, cb)
	RequestControl(data.handle)
	RemoveAllPedWeapons(data.handle, true, true)
	cb({})
end)

RegisterNUICallback('resurrectPed', function(data, cb)
	RequestControl(data.handle)
	ResurrectPed(data.handle)
	cb({})
end)

RegisterNUICallback('getOnMount', function(data, cb)
	DisableSpoonerMode()
	RequestControl(data.handle)
	SetPedOnMount(PlayerPedId(), data.handle, -1, false)
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
	local intensity = data.intensity and data.intensity * 1.0 or 0.0

	RequestControl(data.handle)
	SetLightsIntensityForEntity(data.handle, intensity)

	if EntityIsInDatabase(data.handle) then
		Database[data.handle].lightsIntensity = intensity
	end

	cb({})
end)

RegisterNUICallback('setLightsColour', function(data, cb)
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

	cb({})
end)

RegisterNUICallback('setLightsType', function(data, cb)
	local type = data.type and data.type or 0

	RequestControl(data.handle)
	SetLightsTypeForEntity(data.handle, type)

	if EntityIsInDatabase(data.handle) then
		Database[data.handle].lightsType = type
	end

	cb({})
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/spooner', 'Toggle spooner mode', {})

	while true do
		Wait(0)

		if not EntityIsInDatabase(PlayerPedId()) then
			AddEntityToDatabase(PlayerPedId())
		end

		if IsUsingKeyboard(0) and IsControlJustPressed(0, Config.ToggleControl) then
			TriggerServerEvent('spooner:toggle')
		end

		if Cam then
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
				entityType = GetEntityType(entity),
				modelName = GetModelName(GetEntityModel(entity)),
				attachedEntity = AttachedEntity,
				speed = string.format('%.2f', Speed),
				currentSpawn = CurrentSpawn and CurrentSpawn.modelName,
				rotateMode = RotateMode,
				adjustMode = AdjustMode,
				placeOnGround = PlaceOnGround,
				adjustSpeed = AdjustSpeed,
				rotateSpeed = RotateSpeed,
				x = string.format('%.2f', x2),
				y = string.format('%.2f', y2),
				z = string.format('%.2f', z2),
				heading = string.format('%.2f', yaw2)
			})

			if Speed < Config.MinSpeed then
				Speed = Config.MinSpeed
			end
			if Speed > Config.MaxSpeed then
				Speed = Config.MaxSpeed
			end

			if IsControlPressed(0, Config.IncreaseSpeedControl) then
				Speed = Speed + Config.SpeedIncrement
			end

			if IsControlPressed(0, Config.DecreaseSpeedControl) then
				Speed = Speed - Config.SpeedIncrement
			end

			if IsControlPressed(0, Config.UpControl) then
				z2 = z2 + Speed
			end

			if IsControlPressed(0, Config.DownControl) then
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

			if IsControlPressed(0, Config.ForwardControl) then
				x2 = x2 + dx1
				y2 = y2 + dy1
			end

			if IsControlPressed(0, Config.BackwardControl) then
				x2 = x2 - dx1
				y2 = y2 - dy1
			end

			if IsControlPressed(0, Config.LeftControl) then
				x2 = x2 + dx2
				y2 = y2 + dy2
			end

			if IsControlPressed(0, Config.RightControl) then
				x2 = x2 - dx2
				y2 = y2 - dy2
			end

			if IsControlJustPressed(0, Config.SpawnSelectControl) then
				if AttachedEntity then
					AttachedEntity = nil
				elseif entity then
					AttachedEntity = entity
				elseif CurrentSpawn then
					local entity

					if CurrentSpawn.type == 1 then
						entity = SpawnPed(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, -1, false)
					elseif CurrentSpawn.type == 2 then
						entity = SpawnVehicle(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false)
					elseif CurrentSpawn.type == 3 then
						entity = SpawnObject(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, nil, nil, nil)
					end

					PlaceOnGroundProperly(entity)
				end
			end

			if IsControlJustPressed(0, Config.DeleteControl) and entity then
				if AttachedEntity then
					RemoveEntity(AttachedEntity)
					AttachedEntity = nil
				else
					RemoveEntity(entity)
				end
			end

			if IsControlJustReleased(0, Config.ObjectMenuControl) then
				SendNUIMessage({
					type = 'openSpawnMenu'
				})
				SetNuiFocus(true, true)
			end

			if IsControlJustReleased(0, Config.DbMenuControl) then
				OpenDatabaseMenu()
			end

			if IsControlJustReleased(0, Config.SaveLoadDbMenuControl) then
				OpenSaveDbMenu()
			end

			if IsControlJustReleased(0, Config.HelpMenuControl) then
				SendNUIMessage({
					type = 'openHelpMenu'
				})
				SetNuiFocus(true, true)
			end

			if IsControlJustPressed(0, Config.RotateModeControl) then
				RotateMode = (RotateMode + 1) % 3
			end

			if IsControlJustPressed(0, Config.AdjustModeControl) then
				AdjustMode = (AdjustMode + 1) % 5
			end

			if IsControlJustPressed(0, Config.FreeAdjustModeControl) then
				AdjustMode = -1
			end

			if IsControlJustPressed(0, Config.PlaceOnGroundControl) then
				PlaceOnGround = not PlaceOnGround
			end

			if entity then
				local posChanged = false
				local rotChanged = false

				if IsControlJustReleased(0, Config.PropMenuControl) then
					OpenPropertiesMenuForEntity(entity)
				end

				if IsControlJustPressed(0, Config.CloneControl) then
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

				if IsControlPressed(0, Config.RotateLeftControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 + RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 + RotateSpeed
					else
						eyaw2 = eyaw2 + RotateSpeed
					end

					rotChanged = true
				end

				if IsControlPressed(0, Config.RotateRightControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 - RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 - RotateSpeed
					else
						eyaw2 = eyaw2 - RotateSpeed
					end

					rotChanged = true
				end

				if IsControlPressed(0, Config.AdjustUpControl) then
					ez2 = ez2 + AdjustSpeed
					posChanged = true
				end

				if IsControlPressed(0, Config.AdjustDownControl) then
					ez2 = ez2 - AdjustSpeed
					posChanged = true
				end

				if IsControlPressed(0, Config.AdjustForwardControl) then
					ex2 = ex2 + edx1
					ey2 = ey2 + edy1
					posChanged = true
				end

				if IsControlPressed(0, Config.AdjustBackwardControl) then
					ex2 = ex2 - edx1
					ey2 = ey2 - edy1
					posChanged = true
				end

				if IsControlPressed(0, Config.AdjustLeftControl) then
					ex2 = ex2 + edx2
					ey2 = ey2 + edy2
					posChanged = true
				end

				if IsControlPressed(0, Config.AdjustRightControl) then
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
