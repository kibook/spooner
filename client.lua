local Database = {}

local Cam
local Speed = Config.Speed
local AdjustSpeed = Config.AdjustSpeed
local RotateSpeed = Config.RotateSpeed
local AttachedEntity
local RotateMode = 2
local AdjustMode = 4
local SpeedMode = 0
local PlaceOnGround = false
local CurrentSpawn
local ShowControls = true
local KeepSelfInDb = true
local FocusTarget
local FocusTargetPos
local FreeFocus = false
local showEntityHandles = false

local SpoonerPrompts, ClearTasksPrompt, DetachPrompt

if Config.isRDR then
	SpoonerPrompts = UipromptGroup:new("Spooner", false)

	ClearTasksPrompt = Uiprompt:new(`INPUT_INTERACT_NEG`, "Clear Tasks", SpoonerPrompts)
	ClearTasksPrompt:setHoldMode(true)
	ClearTasksPrompt:setOnHoldModeJustCompleted(function()
	       TryClearTasks(PlayerPedId())
	end)

	DetachPrompt = Uiprompt:new(`INPUT_INTERACT_LEAD_ANIMAL`, "Detach", SpoonerPrompts)
	DetachPrompt:setHoldMode(true)
	DetachPrompt:setOnHoldModeJustCompleted(function()
	       TryDetach(PlayerPedId())
	end)
end

local StoreDeleted = false
local DeletedEntities = {}

local Permissions = {}

Permissions.maxEntities = 0

Permissions.spawn = {}
Permissions.spawn.ped = false
Permissions.spawn.vehicle = false
Permissions.spawn.object = false
Permissions.spawn.propset = false
Permissions.spawn.pickup = false

Permissions.delete = {}
Permissions.delete.own = {}
Permissions.delete.own.networked = false
Permissions.delete.own.nonNetworked = false
Permissions.delete.other = {}
Permissions.delete.other.networked = false
Permissions.delete.other.nonNetworked = false

Permissions.modify = {}
Permissions.modify.own = {}
Permissions.modify.own.networked = false
Permissions.modify.own.nonNetworked = false
Permissions.modify.other = {}
Permissions.modify.other.networked = false
Permissions.modify.other.nonNetworked = false

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
Permissions.properties.clone = false
Permissions.properties.attachments = false
Permissions.properties.lights = false
Permissions.properties.registerAsNetworked = false
Permissions.properties.focus = false

Permissions.properties.ped = {}
Permissions.properties.ped.changeModel = false
Permissions.properties.ped.outfit = false
Permissions.properties.ped.group = false
Permissions.properties.ped.scenario = false
Permissions.properties.ped.animation = false
Permissions.properties.ped.clearTasks = false
Permissions.properties.ped.weapon = false
Permissions.properties.ped.mount = false
Permissions.properties.ped.enterVehicle = false
Permissions.properties.ped.resurrect = false
Permissions.properties.ped.ai = false
Permissions.properties.ped.knockOffProps = false
Permissions.properties.ped.walkStyle = false
Permissions.properties.ped.clone = false
Permissions.properties.ped.cloneToTarget = false
Permissions.properties.ped.lookAtEntity = false
Permissions.properties.ped.clean = false
Permissions.properties.ped.scale = false
Permissions.properties.ped.configFlags = false
Permissions.properties.ped.goToWaypoint = false
Permissions.properties.ped.goToEntity = false
Permissions.properties.ped.attack = false

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

function IsEntityFrozen(entity)
	return Citizen.InvokeNative(0x083D497D57B7400F, entity)
end

function IsPedUsingScenarioHash(ped, scenarioHash)
	return Citizen.InvokeNative(0x34D6AC1157C8226C, ped, scenarioHash)
end

function IsPropSetFullyLoaded(propSet)
	return Citizen.InvokeNative(0xF42DB680A8B2A4D9, propSet)
end

function PlaceEntityOnGroundProperly(entity, p1)
	return Citizen.InvokeNative(0x9587913B9E772D29, entity, p1)
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

	if FocusTarget then
		FocusEntity(FocusTarget)
	end

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

	if entityHit <= 0 or GetEntityType(entityHit) == 0 then
		return endCoords, nil, 0
	end

	local entityCoords = GetEntityCoords(entityHit)

	local distance = #(vector3(x1, y1, z1) - entityCoords)

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

	return tostring(model)
end

function GetPlayerFromPed(ped)
	for _, playerId in ipairs(GetActivePlayers()) do
		if ped == GetPlayerPed(playerId) then
			return playerId
		end
	end

	return nil
end

function GetBoneIndex(entity, bone)
	if type(bone) == 'number' then
		return bone
	else
		if Config.isRDR then
			return GetEntityBoneIndexByName(entity, bone)
		else
			return GetPedBoneIndex(entity, Bones[bone])
		end
	end
end

function FindBoneName(entity, boneIndex)
	if Config.isRDR then
		for _, boneName in ipairs(Bones) do
			if GetEntityBoneIndexByName(entity, boneName) == boneIndex then
				return boneName
			end
		end

		return boneIndex
	else
		for boneName, boneId in pairs(Bones) do
			if GetPedBoneIndex(entity, boneId) == boneIndex then
				return boneName
			end
		end

		return boneIndex
	end
end

function GetPedConfigFlags(ped)
	local flags = {}

	for i = 0, 600 do
		flags[i] = GetPedConfigFlag(ped, i)
	end

	return flags
end

function GetLiveEntityProperties(entity)
	local model = GetEntityModel(entity)
	local x, y, z = table.unpack(GetEntityCoords(entity))
	local pitch, roll, yaw = table.unpack(GetEntityRotation(entity, 2))
	local isPlayer = IsPedAPlayer(entity)
	local player = isPlayer and GetPlayerFromPed(entity)
	local type = GetEntityType(entity)

	return {
		name = GetModelName(model),
		type = type,
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
		blockNonTemporaryEvents = false,
		isSelf = entity == PlayerPedId(),
		playerName = player and GetPlayerName(player),
		weapons = {},
		isFrozen = Config.isRDR and IsEntityFrozen(entity) or false,
		isVisible = IsEntityVisible(entity),
		pedConfigFlags = type == 1 and GetPedConfigFlags(entity) or nil,
		attachment = {
			to = GetEntityAttachedTo(entity),
			x = 0.0,
			y = 0.0,
			z = 0.0,
			pitch = 0.0,
			roll = 0.0,
			yaw = 0.0
		},
		netId = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity),
		exists = true
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

	local attachBone, attachX, attachY, attachZ, attachPitch, attachRoll, attachYaw, attachSoftPinning, attachCollision, attachVertex, attachFixedRot

	local lightsIntensity = Database[entity] and Database[entity].lightsIntensity or nil
	local lightsColour = Database[entity] and Database[entity].lightsColour or nil
	local lightsType = Database[entity] and Database[entity].lightsType or nil

	local animation = Database[entity] and Database[entity].animation
	local scenario = Database[entity] and Database[entity].scenario

	local blockNonTemporaryEvents = Database[entity] and Database[entity].blockNonTemporaryEvents or false

	local weapons = Database[entity] and Database[entity].weapons or {}

	local walkStyle = Database[entity] and Database[entity].walkStyle

	local scale = Database[entity] and Database[entity].scale

	if attachment then
		attachBone        = attachment.bone
		attachX           = attachment.x
		attachY           = attachment.y
		attachZ           = attachment.z
		attachPitch       = attachment.pitch
		attachRoll        = attachment.roll
		attachYaw         = attachment.yaw
		attachSoftPinning = attachment.useSoftPinning
		attachCollision   = attachment.collision
		attachVertex      = attachment.vertex
		attachFixedRot    = attachment.fixedRot
	else
		attachBone        = (Database[entity] and Database[entity].attachment.bone)
		attachX           = (Database[entity] and Database[entity].attachment.x              or 0.0)
		attachY           = (Database[entity] and Database[entity].attachment.y              or 0.0)
		attachZ           = (Database[entity] and Database[entity].attachment.z              or 0.0)
		attachPitch       = (Database[entity] and Database[entity].attachment.pitch          or 0.0)
		attachRoll        = (Database[entity] and Database[entity].attachment.roll           or 0.0)
		attachYaw         = (Database[entity] and Database[entity].attachment.yaw            or 0.0)
		attachSoftPinning = (Database[entity] and Database[entity].attachment.useSoftPinning or false)
		attachCollision   = (Database[entity] and Database[entity].attachment.collision      or true)
		attachVertex      = (Database[entity] and Database[entity].attachment.vertex         or 0)
		attachFixedRot    = (Database[entity] and Database[entity].attachment.fixedRot       or true)
	end

	local isFrozen = Database[entity] and Database[entity].isFrozen

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
	Database[entity].attachment.useSoftPinning = attachSoftPinning
	Database[entity].attachment.collision = attachCollision
	Database[entity].attachment.vertex = attachVertex
	Database[entity].attachment.fixedRot = attachFixedRot

	Database[entity].lightsIntensity = lightsIntensity
	Database[entity].lightsColour = lightsColour
	Database[entity].lightsType = lightsType

	Database[entity].animation = animation
	Database[entity].scenario = scenario

	Database[entity].blockNonTemporaryEvents = blockNonTemporaryEvents

	Database[entity].weapons = weapons

	Database[entity].walkStyle = walkStyle

	Database[entity].scale = scale

	if not Config.isRDR then
		Database[entity].isFrozen = isFrozen
	end

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

function SetWalkStyle(ped, base, style)
	Citizen.InvokeNative(0x923583741DC87BCE, ped, base)
	Citizen.InvokeNative(0x89F5E7ADECCCB49C, ped, style)

	if Database[ped] then
		Database[ped].walkStyle = {
			base = base,
			style = style
		}
	end
end

function SpawnObject(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, isVisible, lightsIntensity, lightsColour, lightsType)
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

	if isVisible == false then
		SetEntityVisible(object, false)
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

	if not Config.isRDR and Database[object] then
		Database[object].isFrozen = true
	end

	return object
end

function SpawnVehicle(name, model, x, y, z, pitch, roll, yaw, collisionDisabled, isVisible)
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

	if isVisible == false then
		SetEntityVisible(veh, false)
	end

	-- Weird fix for the hot air balloon, otherwise it doesn't move with the wind and only travels straight up.
	if model == GetHashKey('hotairballoon01') then
		SetVehicleAsNoLongerNeeded(veh)
	end

	AddEntityToDatabase(veh, name)

	if not Config.isRDR and Database[veh] then
		Database[veh].isFrozen = collisionDisabled
	end

	return veh
end

function PlayAnimation(ped, anim)
	if not DoesAnimDictExist(anim.dict) then
		return false
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, anim.dict, anim.name, anim.blendInSpeed, anim.blendOutSpeed, anim.duration, anim.flag, anim.playbackRate, false, false, false, '', false)

	RemoveAnimDict(anim.dict)

	return true
end

local function startScenario(ped, scenario)
	if Config.isRDR then
		TaskStartScenarioInPlace(ped, GetHashKey(scenario), -1)
	else
		TaskStartScenarioInPlace(ped, scenario, -1)
	end
end

function SpawnPed(props)
	if not Permissions.spawn.ped then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	if not LoadModel(props.model) then
		return nil
	end

	local ped
	if Config.isRDR then
		ped = CreatePed_2(props.model, props.x, props.y, props.z, 0.0, true, false)
	else
		ped = CreatePed(0, props.model, props.x, props.y, props.z, 0.0, true, false)
	end

	SetModelAsNoLongerNeeded(props.model)

	if not ped or ped < 1 then
		return nil
	end

	SetEntityRotation(ped, props.pitch, props.roll, props.yaw, 2)

	if props.collisionDisabled then
		FreezeEntityPosition(ped, true)
		SetEntityCollision(ped, false, false)
	end

	if props.isVisible == false then
		SetEntityVisible(ped, false)
	end

	if props.outfit == -1 then
		SetRandomOutfitVariation(ped, true)
	else
		SetPedOutfitPreset(ped, props.outfit)
	end

	if props.isInGroup then
		AddToGroup(ped)
	end

	if props.animation then
		PlayAnimation(ped, props.animation)
	end

	if props.scenario then
		Wait(500)
		startScenario(ped, props.scenario)
	end

	if props.blockNonTemporaryEvents then
		SetBlockingOfNonTemporaryEvents(ped, true)
	end

	if props.weapons then
		for _, weapon in ipairs(props.weapons) do
			if Config.isRDR then
				GiveWeaponToPed_2(ped, GetHashKey(weapon), 500, true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
			else
				GiveWeaponToPed(ped, GetHashKey(weapon), 500, false, true)
			end
		end
	end

	if props.walkStyle then
		SetWalkStyle(ped, props.walkStyle.base, props.walkStyle.style)
	end

	if props.scale then
		SetPedScale(ped, props.scale)
	end

	if props.pedConfigFlags then
		for flag, value in pairs(props.pedConfigFlags) do
			SetPedConfigFlag(ped, tonumber(flag), value)
		end
	end

	AddEntityToDatabase(ped, props.name)
	Database[ped].outfit = props.outfit
	Database[ped].animation = props.animation
	Database[ped].scenario = props.scenario
	Database[ped].blockNonTemporaryEvents = props.blockNonTemporaryEvents
	Database[ped].weapons = props.weapons
	Database[ped].walkStyle = props.walkStyle
	Database[ped].scale = props.scale

	if not Config.isRDR and Database[ped] then
		Database[ped].isFrozen = props.collisionDisabled
	end

	return ped
end

function WaitForPropSetToLoad(propSet)
	local timeWaited = 0

	while not IsPropSetFullyLoaded(propSet) and timeWaited <= 500 do
		Wait(100)
		timeWaited = timeWaited + 100
	end

	return true
end

function SpawnPropset(name, model, x, y, z, heading)
	if not Permissions.spawn.propset then
		return nil
	end

	if IsDatabaseFull() then
		return nil
	end

	-- Spawn the propset
	RequestPropset(model)

	while not HasPropsetLoaded(model) do
		Wait(0)
	end

	local propset = CreatePropset(model, x, y, z, 0, heading, 0.0, false, false)

	ReleasePropset(hash)

	if not propset or propset < 1 then
		return nil
	end

	-- Give the propset time to fully load
	WaitForPropSetToLoad(propset)

	-- Objects spawned as part of a propset are not networked, so clone
	-- those objects into your DB as new, networked objects, then delete
	-- the propset.
	local itemset = CreateItemset(true)
	local size = GetEntitiesFromPropset(propset, itemset, 0, false, false)

	if size > 0 then
		for i = 0, size - 1 do
			CloneEntity(GetIndexedItemInItemset(i, itemset))
		end
	end

	if IsItemsetValid(itemset) then
		DestroyItemset(itemset)
	end

	DeletePropset(propset, false, false)

	return nil
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
end

function CanDeleteEntity(entity)
	if EntityIsInDatabase(entity) then
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.delete.own.networked
		else
			return Permissions.delete.own.nonNetworked
		end
	else
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.delete.other.networked
		else
			return Permissions.delete.other.nonNetworked
		end
	end
end

function StoreDeletedEntity(entity)
	local props = GetLiveEntityProperties(entity)

	table.insert(DeletedEntities, {
		x = props.x,
		y = props.y,
		z = props.z,
		model = props.model,
	})
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
		if StoreDeleted and not EntityIsInDatabase(entity) then
			StoreDeletedEntity(entity)
		end

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

function SaveDatabaseInKvs(name, db)
	SetResourceKvp('DB_' .. name, json.encode(db))
end

function LoadDatabaseFromKvs(name)
	return json.decode(GetResourceKvpString('DB_' .. name))
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		DisableSpoonerMode()

		if Config.CleanUpOnStop then
			RemoveAllFromDatabase();
		end
	end
end)

RegisterNUICallback('closeSpawnMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

function Contains(list, item)
	for _, value in ipairs(list) do
		if value == item then
			return true
		end
	end
	return false
end

RegisterNUICallback('closePedMenu', function(data, cb)
	if data.modelName and (Permissions.spawn.byName or Contains(Peds, data.modelName)) then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 1
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeVehicleMenu', function(data, cb)
	if data.modelName and (Permissions.spawn.byName or Contains(Vehicles, data.modelName)) then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 2
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closeObjectMenu', function(data, cb)
	if data.modelName and (Permissions.spawn.byName or Contains(Objects, data.modelName)) then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 3
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closePropsetMenu', function(data, cb)
	if data.modelName and (Permissions.spawn.byName or Contains(Propsets, data.modelName)) then
		CurrentSpawn = {
			modelName = data.modelName,
			type = 4
		}
	end
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('closePickupMenu', function(data, cb)
	if data.modelName and (Permissions.spawn.byName or Contains(Pickups, data.modelName)) then
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
	cb({
		database = json.encode(Database)
	})
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

	if not KeepSelfInDb and data.handle == PlayerPedId() then
		KeepSelfInDb = true
	end

	cb({})
end)

RegisterNUICallback('addCustomEntityToDatabase', function(data, cb)
	if not Permissions.maxEntities and Permissions.modify.other then
		AddEntityToDatabase(data.handle)

		if not KeepSelfInDb and data.handle == PlayerPedId() then
			KeepSelfInDb = true
		end
	end

	cb{database = json.encode(Database)}
end)

RegisterNUICallback('removeEntityFromDatabase', function(data, cb)
	if not Permissions.maxEntities and Permissions.modify.other then
		RemoveEntityFromDatabase(data.handle)

		if KeepSelfInDb and data.handle == PlayerPedId() then
			KeepSelfInDb = false
		end
	end
	cb({})
end)

RegisterNUICallback('freezeEntity', function(data, cb)
	if Permissions.properties.freeze and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		FreezeEntityPosition(data.handle, true)

		if not Config.isRDR and Database[data.handle] then
			Database[data.handle].isFrozen = true
		end
	end
	cb({})
end)

RegisterNUICallback('unfreezeEntity', function(data, cb)
	if Permissions.properties.freeze and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		FreezeEntityPosition(data.handle, false)

		if not Config.isRDR and Database[data.handle] then
			Database[data.handle].isFrozen = false
		end
	end
	cb({})
end)

RegisterNUICallback('setEntityRotation', function(data, cb)
	if Permissions.properties.rotation and CanModifyEntity(data.handle) then
		local pitch = data.pitch and data.pitch * 1.0 or 0.0
		local roll  = data.roll  and data.roll  * 1.0 or 0.0
		local yaw   = data.yaw   and data.yaw   * 1.0 or 0.0

		RequestControl(data.handle)
		SetEntityRotation(data.handle, pitch, roll, yaw, 2)
	end

	cb({})
end)

RegisterNUICallback('setEntityCoords', function(data, cb)
	if Permissions.properties.position and CanModifyEntity(data.handle) then
		local x = data.x and data.x * 1.0 or 0.0
		local y = data.y and data.y * 1.0 or 0.0
		local z = data.z and data.z * 1.0 or 0.0

		RequestControl(data.handle)
		SetEntityCoordsNoOffset(data.handle, x, y, z)
	end

	cb({})
end)

RegisterNUICallback('resetRotation', function(data, cb)
	if Permissions.properties.rotation and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityRotation(data.handle, 0.0, 0.0, 0.0, 2)
	end
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
		elseif Database[entity].isSelf then
			RemoveEntityFromDatabase(entity)
		else
			Database[entity].exists = false
		end
	end

	for _, propset in ipairs(propsets) do
		if DoesPropsetExist(propset) then
			AddEntityToDatabase(propset)
		else
			Database[propset].exists = false
		end
	end

	for _, pickup in ipairs(pickups) do
		if DoesPickupExist(pickup) then
			AddEntityToDatabase(pickup)
		else
			Database[pickup].exists = false
		end
	end
end

function CanModifyEntity(entity)
	if EntityIsInDatabase(entity) then
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.modify.own.networked
		else
			return Permissions.modify.own.nonNetworked
		end
	else
		if NetworkGetEntityIsNetworked(entity) then
			return Permissions.modify.other.networked
		else
			return Permissions.modify.other.nonNetworked
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
	if Permissions.properties.invincible and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityInvincible(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('invincibleOff', function(data, cb)
	if Permissions.properties.invincible and CanModifyEntity(data.handle) then
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
	local r1 = GetEntityRotation(entity, 2)

	if Config.isRDR then
		PlaceEntityOnGroundProperly(entity, false)
	else
		local type = GetEntityType(entity)

		if type == 2 then
			SetVehicleOnGroundProperly(entity)
		elseif type == 3 then
			PlaceObjectOnGroundProperly(entity, false)
		end
	end

	local r2 = GetEntityRotation(entity, 2)
	SetEntityRotation(entity, r2.x, r2.y, r1.z, 2)
end

RegisterNUICallback('placeEntityHere', function(data, cb)
	if Permissions.properties.position and CanModifyEntity(data.handle) then
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
	else
		cb({})
	end
end)

function PrepareDatabaseForSave()
	local db = json.decode(json.encode(Database))
	local ped = PlayerPedId()

	for entity, props in pairs(db) do
		if props.attachment.to == ped then
			props.attachment.to = -1
		end
	end

	db[tostring(ped)] = nil

	return {
		spawn = db,
		delete = DeletedEntities
	}
end

function SaveDatabase(name)
	UpdateDatabase()
	SaveDatabaseInKvs(name, PrepareDatabaseForSave())
end

function RemoveDeletedEntity(x, y, z, hash)
	local handle = GetClosestObjectOfType(x, y, z, 1.0, hash, false, false, false)

	if handle ~= 0 then
		DeleteEntity(handle)
	end
end

function AttachEntity(from, to, bone, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
	if not bone then
		bone = 0
	end

	local boneIndex = GetBoneIndex(to, bone)

	AttachEntityToEntity(from, to, boneIndex, x, y, z, pitch, roll, yaw, false, useSoftPinning, collision, false, vertex, fixedRot, false, false)

	if EntityIsInDatabase(from) then
		AddEntityToDatabase(from, nil, {
			to = to,
			bone = bone,
			x = x,
			y = y,
			z = z,
			pitch = pitch,
			roll = roll,
			yaw = yaw,
			useSoftPinning = useSoftPinning,
			collision = collision,
			vertex = vertex,
			fixedRot = fixedRot
		})
	end
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

	-- For backwards compatibility with older DB format
	if not (db.spawn and db.delete) then
		db = {spawn = db, delete = {}}
	end

	if StoreDeleted then
		for _, deleted in pairs(db.delete) do
			RemoveDeletedEntity(deleted.x, deleted.y, deleted.z, deleted.model)
			table.insert(DeletedEntities, deleted)
		end
	end

	for entity, props in pairs(db.spawn) do
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

		spawn.props.x = x
		spawn.props.y = y
		spawn.props.z = z
		spawn.props.pitch = pitch
		spawn.props.roll = roll
		spawn.props.yaw = yaw

		if spawn.props.type == 1 then
			entity = SpawnPed(spawn.props)
		elseif spawn.props.type == 2 then
			entity = SpawnVehicle(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.isVisible)
		elseif spawn.props.type == 5 then
			entity = SpawnPickup(spawn.props.name, spawn.props.model, x, y, z)
		else
			entity = SpawnObject(spawn.props.name, spawn.props.model, x, y, z, pitch, roll, yaw, spawn.props.collisionDisabled, spawn.props.isVisible, spawn.props.lightsIntensity, spawn.props.lightsColour, spawn.props.lightsType)
		end

		if entity and relative then
			PlaceOnGroundProperly(entity)
		end

		handles[spawn.entity] = entity
	end

	for _, spawn in ipairs(spawns) do
		if spawn.props.quaternion then
			local x = spawn.props.quaternion.x
			local y = spawn.props.quaternion.y
			local z = spawn.props.quaternion.z
			local w = -spawn.props.quaternion.w

			SetEntityQuaternion(handles[spawn.entity], x, y, z, w)
		end

		if spawn.props.attachment and spawn.props.attachment.to ~= 0 then
			local from  = handles[spawn.entity]
			local to    = spawn.props.attachment.to == -1 and PlayerPedId() or handles[spawn.props.attachment.to]
			local bone  = spawn.props.attachment.bone
			local x     = spawn.props.attachment.x + 0.0
			local y     = spawn.props.attachment.y + 0.0
			local z     = spawn.props.attachment.z + 0.0
			local pitch = spawn.props.attachment.pitch + 0.0
			local roll  = spawn.props.attachment.roll + 0.0
			local yaw   = spawn.props.attachment.yaw + 0.0
			local useSoftPinning = spawn.props.attachment.useSoftPinning
			local collision = spawn.props.attachment.collision
			local vertex = spawn.props.attachment.vertex or 0
			local fixedRot = spawn.props.attachment.fixedRot

			if type(bone) == 'number' then
				bone = FindBoneName(to, bone)
			end

			if useSoftPinning == nil then
				useSoftPinning = true
			end

			if collision == nil then
				collision = true
			end

			if fixedRot == nil then
				fixedRot = true
			end

			AttachEntity(from, to, bone, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)

			AddEntityToDatabase(from, nil, {
				to = to,
				bone = bone,
				x = x,
				y = y,
				z = z,
				pitch = pitch,
				roll = roll,
				yaw = yaw,
				useSoftPinning = useSoftPinning,
				collision = collision,
				vertex = vertex,
				fixedRot = fixedRot
			})
		end
	end
end

function LoadSavedDatabase(name, relative, replace)
	local db = LoadDatabaseFromKvs(name)

	if db then
		LoadDatabase(db, relative, replace)
	end
end

function GetSavedDatabases()
	local dbs = {}

	local handle = StartFindKvp('DB_')

	while true do
		local kvp = FindKvp(handle)

		if kvp then
			table.insert(dbs, string.sub(kvp, 4))
		else
			break
		end
	end

	EndFindKvp(handle)

	table.sort(dbs)

	return dbs
end

function DeleteDatabase(name)
	DeleteResourceKvp('DB_' .. name)
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

function GetFavourites()
	local content = GetResourceKvpString('favourites')

	if content then
		return json.decode(content)
	end
end

RegisterNUICallback('init', function(data, cb)
	local bones

	if Config.isRDR then
		bones = Bones
	else
		bones = {}

		for boneName, _ in pairs(Bones) do
			table.insert(bones, boneName)
		end

		table.sort(bones)
	end

	cb({
		peds = json.encode(Peds),
		vehicles = json.encode(Vehicles),
		objects = json.encode(Objects),
		scenarios = json.encode(Scenarios),
		weapons = json.encode(Weapons),
		animations = json.encode(Animations),
		propsets = json.encode(Propsets),
		pickups = json.encode(Pickups),
		bones = json.encode(bones),
		walkStyleBases = json.encode(WalkStyleBases),
		walkStyles = json.encode(WalkStyles),
		adjustSpeed = AdjustSpeed,
		rotateSpeed = RotateSpeed,
		favourites = GetFavourites()
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
	local clone

	if props.type == 1 then
		clone = SpawnPed(props)
	elseif props.type == 2 then
		clone = SpawnVehicle(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.isVisible)
	elseif props.type == 3 then
		clone = SpawnObject(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw, props.collisionDisabled, props.isVisible, props.lightsIntensity, props.lightsColour, props.lightsType)
	elseif props.type == 5 then
		clone = SpawnPickup(props.name, props.model, props.x, props.y, props.z)
	else
		return nil
	end

	if clone and props.attachment and props.attachment.to ~= 0 then
		AttachEntity(clone, props.attachment.to, props.attachment.bone, props.attachment.x, props.attachment.y, props.attachment.z, props.attachment.pitch, props.attachment.roll, props.attachment.yaw, props.attachment.useSoftPinning, props.attachment.collision, props.attachment.vertex, props.attachment.fixedRot)
	end

	return clone
end

RegisterNUICallback('cloneEntity', function(data, cb)
	if Permissions.properties.clone and CanModifyEntity(data.handle) then
		local clone = CloneEntity(data.handle)

		if clone then
			OpenPropertiesMenuForEntity(clone)
		end
	end

	cb({})
end)

RegisterNUICallback('closeHelpMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

RegisterNUICallback('getIntoVehicle', function(data, cb)
	if Permissions.properties.vehicle.getin then
		DisableSpoonerMode()
		RequestControl(data.handle)
		TaskWarpPedIntoVehicle(PlayerPedId(), data.handle, -1)
	end
	cb({})
end)

RegisterNUICallback('repairVehicle', function(data, cb)
	if Permissions.properties.vehicle.repair and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetVehicleFixed(data.handle)
	end
	cb({})
end)

RegisterNUICallback('attackPed', function(data, cb)
	if Permissions.properties.ped.attack and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		TaskCombatPed(data.handle, data.ped)
	end
	cb {}
end)

function ConvertDatabaseToMapEditorXml(creator, database)
	local xml = '<?xml version="1.0"?>\n<Map>\n\t<MapMeta Creator="' .. creator .. '"/>\n'

	for _, properties in ipairs(database.delete) do
		xml = xml .. string.format('\t<DeletedObject Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s"/>\n', properties.model, properties.x, properties.y, properties.z)
	end

	for entity, properties in pairs(database.spawn) do
		if properties.type == 1 then
			xml = xml .. string.format('\t<Ped Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_y="%s" Rotation_z="%s" Preset="%d" Collision="%s" Visible="%s"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw, properties.outfit, properties.collisionDisabled and "false" or "true", properties.isVisible and "true" or "false")
		elseif properties.type == 2 then
			xml = xml .. string.format('\t<Vehicle Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_y="%s" Rotation_z="%s" Collision="%s" Visible="%s"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw, properties.collisionDisabled and "false" or "true", properties.isVisible and "true" or "false")
		else
			xml = xml .. string.format('\t<Object Hash="%s" Position_x="%s" Position_y="%s" Position_z="%s" Rotation_x="%s" Rotation_y="%s" Rotation_z="%s" Collision="%s" Visible="%s"/>\n', properties.model, properties.x, properties.y, properties.z, properties.pitch, properties.roll, properties.yaw, properties.collisionDisabled and "false" or "true", properties.isVisible and "true" or "false")
		end
	end

	xml = xml .. '</Map>'

	return xml
end

local function toQuaternion(pitch, roll, yaw)
	local rot = -vector3(roll, pitch, yaw)

	local p = math.rad(rot.y)
	local r = math.rad(rot.z)
	local y = math.rad(rot.x)

	local cy = math.cos(y * 0.5)
	local sy = math.sin(y * 0.5)
	local cr = math.cos(r * 0.5)
	local sr = math.sin(r * 0.5)
	local cp = math.cos(p * 0.5)
	local sp = math.sin(p * 0.5)

	local q = {}

	q.x = cy * sp * cr + sy * cp * sr
	q.y = sy * cp * cr - cy * sp * sr
	q.z = cy * cp * sr - sy * sp * cr
	q.w = cy * cp * cr + sy * sp * sr

	return q
end

function ConvertDatabaseToYmap(database)
	local minX, maxX, minY, maxY, minZ, maxZ

	local entitiesXml = '\t<entities>\n'

	for entity, properties in pairs(database.spawn) do
		if properties.type == 3 then
			local q = toQuaternion(properties.pitch, properties.roll, properties.yaw)

			if not minX or properties.x < minX then
				minX = properties.x
			end
			if not maxX or properties.x > maxX then
				maxX = properties.x
			end
			if not minY or properties.y < minY then
				minY = properties.y
			end
			if not maxY or properties.y > maxY then
				maxY = properties.y
			end
			if not minZ or properties.z < minZ then
				minZ = properties.z
			end
			if not maxZ or properties.z > maxZ then
				maxZ = properties.z
			end

			local flags = 1572865

			if properties.isFrozen then
				flags = flags + 32
			end

			entitiesXml = entitiesXml .. '\t\t<Item type="CEntityDef">\n'
			entitiesXml = entitiesXml .. '\t\t\t<archetypeName>' .. properties.name .. '</archetypeName>\n'
			entitiesXml = entitiesXml .. '\t\t\t<flags value="' .. flags .. '"/>\n'
			entitiesXml = entitiesXml .. string.format('\t\t\t<position x="%f" y="%f" z="%f"/>\n', properties.x, properties.y, properties.z)
			entitiesXml = entitiesXml .. string.format('\t\t\t<rotation w="%f" x="%f" y="%f" z="%f"/>\n', q.w, q.x, q.y, q.z)
			entitiesXml = entitiesXml .. '\t\t\t<scaleXY value="1"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<scaleZ value="1"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<parentIndex value="-1"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<lodDist value="500"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<childLodDist value="500"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<lodLevel>LODTYPES_DEPTH_HD</lodLevel>\n'
			entitiesXml = entitiesXml .. '\t\t\t<numChildren value="0"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<ambientOcclusionMultiplier value="255"/>\n'
			entitiesXml = entitiesXml .. '\t\t\t<artificialAmbientOcclusion value="255"/>\n'
			entitiesXml = entitiesXml .. '\t\t</Item>\n'
		end
	end

	entitiesXml = entitiesXml .. '\t</entities>\n'

	local xml = '<?xml version="1.0"?>\n<CMapData>\n\t<flags value="2"/>\n\t<contentFlags value="65"/>\n'

	if minX and minY and minZ and maxX and maxY and maxZ then
		xml = xml .. string.format('\t<streamingExtentsMin x="%f" y="%f" z="%f"/>\n', minX - 400, minY - 400, minZ - 400)
		xml = xml .. string.format('\t<streamingExtentsMax x="%f" y="%f" z="%f"/>\n', maxX + 400, maxY + 400, maxZ + 400)
		xml = xml .. string.format('\t<entitiesExtentsMin x="%f" y="%f" z="%f"/>\n', minX, minY, minZ)
		xml = xml .. string.format('\t<entitiesExtentsMax x="%f" y="%f" z="%f"/>\n', maxX, maxY, maxZ)

		xml = xml .. entitiesXml
	end

	xml = xml .. '</CMapData>'

	return xml
end

function ConvertDatabaseToPropPlacerJson(database)
	local props = {}

	for entity, properties in pairs(database.spawn) do
		props[properties.yaw .. '-' .. properties.x] = {
			prophash = properties.model,
			x = properties.x,
			y = properties.y,
			z = properties.z,
			heading = properties.yaw
		}
	end

	return json.encode(props)
end

function BackupDbs()
	local dbs = {}

	for _, name in ipairs(GetSavedDatabases()) do
		dbs[name] = LoadDatabaseFromKvs(name)
	end

	return json.encode(dbs)
end

function RestoreDbs(content)
	local dbs = json.decode(content)

	for name, db in pairs(dbs) do
		SaveDatabaseInKvs(name, db)
	end
end

local function loadYmap(xml)
	local curElem, isEntity

	local db = {}
	local i = 0
	local key = "0"

	local parser = SLAXML:parser {
		startElement = function(name, nsURI, nsPrefix)
			curElem = name
		end,
		attribute = function(name, value, nsURI, nsPrefix)
			if name == "type" and value == "CEntityDef" then
				isEntity = true
				db[key] = {
					quaternion = {},
					x = 0.0,
					y = 0.0,
					z = 0.0,
					pitch = 0.0,
					roll = 0.0,
					yaw = 0.0
				}
			elseif curElem == "position" then
				value = (tonumber(value) or 0) + 0.0
				if name == "x" then
					db[key].x = value
				elseif name == "y" then
					db[key].y = value
				elseif name == "z" then
					db[key].z = value
				end
			elseif curElem == "rotation" then
				db[key].quaternion[name] = (tonumber(value) or 0) + 0.0
			elseif isEntity and curElem == "flags" and name == "value" then
				value = tonumber(value) or 0
				db[key].isFrozen = (value & 32) == 32
			end
		end,
		closeElement = function(name, nsURI)
			if isEntity and name == "Item" then
				isEntity = false
				i = i + 1
				key = tostring(i)
			end
			curElem = nil
		end,
		text = function(text, cdata)
			if isEntity then
				if curElem == "archetypeName" then
					db[key].name = text
					db[key].model = GetHashKey(text)
				end
			end
		end
	}

	parser:parse(xml, {stripWhitespace=true})

	LoadDatabase(db, false, false)
end

function ExportDatabase(format)
	UpdateDatabase()

	local db = PrepareDatabaseForSave()

	if format == 'spooner-db-json' then
		return json.encode(db)
	elseif format == 'map-editor-xml' then
		return ConvertDatabaseToMapEditorXml(GetPlayerName(), db)
	elseif format == 'ymap' then
		return ConvertDatabaseToYmap(db)
	elseif format == 'propplacer' then
		return ConvertDatabaseToPropPlacerJson(db)
	elseif format == 'backup' then
		return BackupDbs()
	end
end

function ImportDatabase(format, content)
	if format == 'spooner-db-json' then
		local db = json.decode(content)

		if db then
			LoadDatabase(db, false, false)
		end
	elseif format == 'backup' then
		RestoreDbs(content)
	elseif format == 'ymap' then
		loadYmap(content)
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
	if CanModifyEntity(data.handle) then
		RequestControl(data.handle)
	end
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
	if Permissions.properties.attachments and CanModifyEntity(data.from) then
		local from = data.from
		local to = data.to
		local bone = data.bone
		local useSoftPinning = data.useSoftPinning
		local collision = data.collision
		local vertex = data.vertex
		local fixedRot = data.fixedRot

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

		if type(bone) == 'number' then
			bone = FindBoneName(to, bone)
		end

		RequestControl(from)
		AttachEntity(from, to, bone, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
	end

	cb({})
end)

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
	cb({})
end)

function TryDetach(handle)
	if Permissions.properties.attachments and CanModifyEntity(handle) then
		RequestControl(handle)
		DetachEntity(handle, false, true)

		if EntityIsInDatabase(handle) then
			AddEntityToDatabase(handle, nil, {
				to = 0,
				x = 0.0,
				y = 0.0,
				z = 0.0,
				pitch = 0.0,
				roll = 0.0,
				yaw = 0.0
			})
		end
	end
end

RegisterNUICallback('detach', function(data, cb)
	TryDetach(data.handle)
	cb({})
end)

RegisterNUICallback('setEntityHealth', function(data, cb)
	if Permissions.properties.health and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityHealth(data.handle, data.health, 0)
	end
	cb({})
end)

RegisterNUICallback('setEntityVisible', function(data, cb)
	if Permissions.properties.visible and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityVisible(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('setEntityInvisible', function(data, cb)
	if Permissions.properties.visible and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityVisible(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('gravityOn', function(data, cb)
	if Permissions.properties.gravity and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityHasGravity(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('gravityOff', function(data, cb)
	if Permissions.properties.gravity and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityHasGravity(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('performScenario', function(data, cb)
	if Permissions.properties.ped.scenario and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		startScenario(data.handle, data.scenario)

		if Database[data.handle] then
			Database[data.handle].animation = nil
			Database[data.handle].scenario = data.scenario
		end
	end

	cb({})
end)

function TryClearTasks(handle)
	if Permissions.properties.ped.clearTasks and CanModifyEntity(handle) then
		RequestControl(handle)
		ClearPedTasks(handle)

		if Database[handle] then
			Database[handle].scenario = nil
			Database[handle].animation = nil
		end
	end
end

RegisterNUICallback('clearPedTasks', function(data, cb)
	TryClearTasks(data.handle)
	cb({})
end)

RegisterNUICallback('clearPedTasksImmediately', function(data, cb)
	if Permissions.properties.ped.clearTasks and CanModifyEntity(data.handle) then
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
	if Permissions.properties.ped.outfit and CanModifyEntity(data.handle) then
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
	if Permissions.properties.ped.group and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		AddToGroup(data.handle)
	end
	cb({})
end)

RegisterNUICallback('removeFromGroup', function(data, cb)
	if Permissions.properties.ped.group and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		RemovePedFromGroup(data.handle)
		RemoveBlip(GetBlipFromEntity(data.handle))
	end
	cb({})
end)

RegisterNUICallback('collisionOn', function(data, cb)
	if Permissions.properties.collision and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityCollision(data.handle, true, true)
	end
	cb({})
end)

RegisterNUICallback('collisionOff', function(data, cb)
	if Permissions.properties.collision and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetEntityCollision(data.handle, false, false)
	end
	cb({})
end)

RegisterNUICallback('giveWeapon', function(data, cb)
	if Permissions.properties.ped.weapon and CanModifyEntity(data.handle) then
		RequestControl(data.handle)

		if Config.isRDR then
			GiveWeaponToPed_2(data.handle, GetHashKey(data.weapon), 500, true, false, 0, false, 0.5, 1.0, 0, false, 0.0, false)
		else
			GiveWeaponToPed(data.handle, GetHashKey(data.weapon), 500, false, true)
		end

		if Database[data.handle] then
			table.insert(Database[data.handle].weapons, data.weapon)
		end
	end
	cb({})
end)

RegisterNUICallback('removeAllWeapons', function(data, cb)
	if Permissions.properties.ped.weapon and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		RemoveAllPedWeapons(data.handle, true, true)

		if Database[data.handle] then
			Database[data.handle].weapons = {}
		end
	end
	cb({})
end)

RegisterNUICallback('resurrectPed', function(data, cb)
	if Permissions.properties.ped.resurrect and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		ResurrectPed(data.handle)
	end
	cb({})
end)

RegisterNUICallback('setOnMount', function(data, cb)
	if Permissions.properties.ped.mount and CanModifyEntity(data.handle) then
		SetPedOnMount(data.handle, data.entity, -1, false)
	end
	cb({})
end)

RegisterNUICallback('engineOn', function(data, cb)
	if Permissions.properties.vehicle.engine and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetVehicleEngineOn(data.handle, true, true)
	end
	cb({})
end)

RegisterNUICallback('engineOff', function(data, cb)
	if Permissions.properties.vehicle.engine and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetVehicleEngineOn(data.handle, false, true)
	end
	cb({})
end)

RegisterNUICallback('setLightsIntensity', function(data, cb)
	if Permissions.properties.lights and CanModifyEntity(data.handle) then
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
	if Permissions.properties.lights and CanModifyEntity(data.handle) then
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
	if Permissions.properties.lights and CanModifyEntity(data.handle) then
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
	if Permissions.properties.vehicle.lights and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetVehicleLights(data.handle, false)
	end
	cb({})
end)

RegisterNUICallback('setVehicleLightsOff', function(data, cb)
	if Permissions.properties.vehicle.lights and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetVehicleLights(data.handle, true)
	end
	cb({})
end)

RegisterNUICallback('aiOn', function(data, cb)
	if Permissions.properties.ped.ai and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetBlockingOfNonTemporaryEvents(data.handle, false)

		if Database[data.handle] then
			Database[data.handle].blockNonTemporaryEvents = false
		end
	end

	cb({})
end)

RegisterNUICallback('aiOff', function(data, cb)
	if Permissions.properties.ped.ai and CanModifyEntity(data.handle) then
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
	if Permissions.properties.ped.animation and CanModifyEntity(data.handle) then
		local blendInSpeed = data.blendInSpeed and data.blendInSpeed * 1.0 or 1.0
		local blendOutSpeed = data.blendOutSpeed and data.blendOutSpeed * 1.0 or 1.0
		local duration = data.duration and data.duraction or -1
		local flag = data.flag and data.flag or 1
		local playbackRate = data.playbackRate and data.playbackRate * 1.0 or 0.0

		RequestControl(data.handle)

		local animation = {
			dict = data.dict,
			name = data.name,
			blendInSpeed = blendInSpeed,
			blendOutSpeed = blendOutSpeed,
			duration = duration,
			flag = flag,
			playbackRate = playbackRate
		}

		if PlayAnimation(data.handle, animation) and Database[data.handle] then
			Database[data.handle].animation = animation
			Database[data.handle].scenario = nil
		end
	end

	cb({})
end)

RegisterNUICallback('loadPermissions', function(data, cb)
	cb(json.encode(Permissions))
end)

RegisterNUICallback('knockOffProps', function(data, cb)
	if Permissions.properties.ped.knockOffProps and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		KnockOffPedProp(data.handle, true, true, true, true)
	end

	cb({})
end)

RegisterNUICallback('setWalkStyle', function(data, cb)
	if Permissions.properties.ped.walkStyle and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		SetWalkStyle(data.handle, data.base, data.style)
	end

	cb({})
end)

RegisterNUICallback('setStoreDeleted', function(data, cb)
	if StoreDeleted then
		StoreDeleted = false
		DeletedEntities = {}
	else
		StoreDeleted = true
	end

	cb({})
end)

RegisterNUICallback('clonePedToTarget', function(data, cb)
	if Permissions.properties.ped.cloneToTarget and CanModifyEntity(data.target) then
		RequestControl(data.target)
		ClonePedToTarget(data.handle, data.target)
	end

	cb({})
end)

RegisterNUICallback('lookAtEntity', function(data, cb)
	if Permissions.properties.ped.lookAtEntity and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		TaskLookAtEntity(data.handle, data.target, -1)
	end

	cb({})
end)

RegisterNUICallback('clearLookAt', function(data, cb)
	if Permissions.properties.ped.lookAtEntity and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		TaskClearLookAt(data.handle)
	end

	cb({})
end)

RegisterNUICallback('registerAsNetworked', function(data, cb)
	if Permissions.properties.registerAsNetworked and CanModifyEntity(data.handle) then
		NetworkRegisterEntityAsNetworked(data.handle)
	end

	cb({})
end)

RegisterNUICallback('saveFavourites', function(data, cb)
	SetResourceKvp('favourites', json.encode(data.favourites))
	cb({})
end)

RegisterNUICallback('cleanPed', function(data, cb)
	if Permissions.properties.ped.clean and CanModifyEntity(data.handle) then
		RequestControl(data.handle)
		ClearPedEnvDirt(data.handle)
		ClearPedDamageDecalByZone(data.handle, 10, "ALL")
		ClearPedBloodDamage(data.handle)
	end
	cb({})
end)

RegisterNUICallback('setScale', function(data, cb)
	if Permissions.properties.ped.scale and CanModifyEntity(data.handle) then
		local scale = data.scale or 1.0

		if scale < 0.1 then
			scale = 0.1
		elseif scale > 10.0 then
			scale = 10.0
		end

		RequestControl(data.handle)
		SetPedScale(data.handle, scale + 0.0)

		if Database[data.handle] then
			Database[data.handle].scale = scale
		end
	end

	cb({})
end)

RegisterNUICallback('selectEntity', function(data, cb)
	if CanModifyEntity(data.handle) then
		if AttachedEntity == data.handle then
			AttachedEntity = nil
		else
			if not Cam then
				EnableSpoonerMode()
			end

			AttachedEntity = data.handle
		end
	end
	cb({})
end)

function TryClonePed(handle)
	if Permissions.properties.ped.clone and CanModifyEntity(handle) then
		RequestControl(handle)
		local clone = CloneEntity(handle)
		Citizen.Wait(500)
		ClonePedToTarget(handle, clone)
	end
end

RegisterNUICallback('clonePed', function(data, cb)
	TryClonePed(data.handle)
	cb({})
end)

function GetPedConfigFlagsWithDescr(ped)
	local flags = GetPedConfigFlags(ped)

	local flagsWithDescr = {}

	for flag, value in pairs(flags) do
		local descr = PedConfigFlags[flag]

		if descr then
			flagsWithDescr[tostring(flag)] = {descr = descr, value = value}
		elseif value then
			flagsWithDescr[tostring(flag)] = {descr = "", value = true}
		end
	end

	return flagsWithDescr
end

RegisterNUICallback('getPedConfigFlags', function(data, cb)
	cb(GetPedConfigFlagsWithDescr(data.handle))
end)

function TrySetPedConfigFlag(handle, flag, value)
	if Permissions.properties.ped.configFlags and CanModifyEntity(handle) then
		RequestControl(handle)
		SetPedConfigFlag(handle, flag, value)
	end
end

RegisterNUICallback('setPedConfigFlag', function(data, cb)
	TrySetPedConfigFlag(data.handle, data.flag, data.value)
	cb(GetPedConfigFlagsWithDescr(data.handle))
end)

function TryGoToWaypoint(handle)
	if Permissions.properties.ped.goToWaypoint and CanModifyEntity(handle) then
		RequestControl(handle)

		local coords = GetWaypointCoords()
		local groundZ = GetHeightmapBottomZForPosition(coords.x, coords.y)

		local vehicle = GetVehiclePedIsIn(handle, false)

		if vehicle == 0 then
			TaskGoToCoordAnyMeans(handle, coords.x, coords.y, groundZ, 1.0, 0, 0, 0, 0.5)
		else
			TaskVehicleDriveToCoord(handle, vehicle, coords.x, coords.y, groundZ, 2.0, 0, GetEntityModel(vehicle), 67108864, 0.5, 0.0)
		end
	end
end

RegisterNUICallback('goToWaypoint', function(data, cb)
	TryGoToWaypoint(data.handle)
	cb({})
end)

function TryPedGoToEntity(handle, entity)
	if Permissions.properties.ped.goToEntity and CanModifyEntity(handle) then
		RequestControl(handle)

		local vehicle = GetVehiclePedIsIn(handle, false)

		if vehicle == 0 then
			TaskGoToEntity(handle, entity, -1, 1.0, 1.0, 0.0, 0)
		else
			TaskVehicleDriveToCoord(handle, vehicle, GetEntityCoords(entity), 2.0, 0, GetEntityModel(vehicle), 67108864, 0.5, 0.0)
		end
	end
end

RegisterNUICallback('pedGoToEntity', function(data, cb)
	TryPedGoToEntity(data.handle, data.entity)
	cb({})
end)

function FocusEntity(entity)
	FocusTarget = entity
	FocusTargetPos = GetEntityCoords(entity)

	if not FreeFocus then
		StopCamPointing(Cam)
		PointCamAtEntity(Cam, entity)
	end
end

function UnfocusEntity()
	FocusTarget = nil
	StopCamPointing(Cam)
end

function TryFocusEntity(handle)
	if Permissions.properties.focus then
		if not Cam then
			EnableSpoonerMode()
		end

		FocusEntity(handle)
	end
end

RegisterNUICallback('focusEntity', function(data, cb)
	if FocusTarget == data.handle then
		UnfocusEntity()
	else
		TryFocusEntity(data.handle)
	end

	cb({})
end)

function TryEnterVehicle(handle, entity)
	if Permissions.properties.ped.enterVehicle and CanModifyEntity(handle) then
		if IsVehicleSeatFree(entity, -1) then
			TaskWarpPedIntoVehicle(handle, entity, -1)
		else
			TaskWarpPedIntoVehicle(handle, entity, -2)
		end
	end
end

RegisterNUICallback('enterVehicle', function(data, cb)
	TryEnterVehicle(data.handle, data.entity)
	cb({})
end)

-- Temporary function to migrate old kvs keys of DBs to the new kvs key format
function MigrateOldSavedDbs()
	local handle = StartFindKvp("")

	while true do
		local kvp = FindKvp(handle)

		if kvp then
			if kvp ~= 'favourites' and string.sub(kvp, 1, 3) ~= 'DB_' and not GetResourceKvpString('DB_' .. kvp) then
				SetResourceKvp('DB_' .. kvp, GetResourceKvpString(kvp))
				print('Migrated old DB: ' .. kvp)
				DeleteResourceKvp(kvp)
			end
		else
			break
		end
	end

	EndFindKvp(handle)
end
RegisterCommand('spooner_migrate_old_dbs', function(source, args, raw)
	MigrateOldSavedDbs()
end)

function CheckControls(func, pad, controls)
	if type(controls) == 'number' then
		return func(pad, controls)
	end

	for _, control in ipairs(controls) do
		if func(pad, control) then
			return true
		end
	end

	return false
end

function MainSpoonerUpdates()
	if IsUsingKeyboard(0) and CheckControls(IsDisabledControlJustPressed, 0, Config.ToggleControl) then
		TriggerServerEvent('spooner:toggle')
	end

	if Cam then
		DisableAllControlActions(0)
		EnableControlAction(0, `INPUT_FRONTEND_PAUSE_ALTERNATE`, true)
		EnableControlAction(0, `INPUT_MP_TEXT_CHAT_ALL`, true)

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
		elseif FocusTarget and not FreeFocus then
			entity = FocusTarget
		end

		SendNUIMessage({
			type = 'updateSpoonerHud',
			entity = entity,
			netId = NetworkGetEntityIsNetworked(entity) and ObjToNet(entity),
			entityType = GetSpoonerEntityType(entity),
			modelName = GetModelName(GetSpoonerEntityModel(entity)),
			attachedEntity = AttachedEntity,
			speed = string.format('%.2f', Speed),
			currentSpawn = CurrentSpawn and CurrentSpawn.modelName,
			rotateMode = RotateMode,
			adjustMode = AdjustMode,
			speedMode = SpeedMode,
			placeOnGround = PlaceOnGround,
			adjustSpeed = AdjustSpeed,
			rotateSpeed = RotateSpeed,
			cursorX = string.format('%.2f', spawnPos.x),
			cursorY = string.format('%.2f', spawnPos.y),
			cursorZ = string.format('%.2f', spawnPos.z),
			camX = string.format('%.2f', x2),
			camY = string.format('%.2f', y2),
			camZ = string.format('%.2f', z2),
			camHeading = string.format('%.2f', yaw2),
			focusTarget = FocusTarget,
			freeFocus = FreeFocus
		})

		if CheckControls(IsDisabledControlPressed, 0, Config.IncreaseSpeedControl) then
			if SpeedMode == 0 then
				Speed = Speed + Config.SpeedIncrement
			elseif SpeedMode == 1 then
				AdjustSpeed = AdjustSpeed + Config.AdjustSpeedIncrement
			elseif SpeedMode == 2 then
				RotateSpeed = RotateSpeed + Config.RotateSpeedIncrement
			end
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.DecreaseSpeedControl) then
			if SpeedMode == 0 then
				Speed = Speed - Config.SpeedIncrement
			elseif SpeedMode == 1 then
				AdjustSpeed = AdjustSpeed - Config.AdjustSpeedIncrement
			elseif SpeedMode == 2 then
				RotateSpeed = RotateSpeed - Config.RotateSpeedIncrement
			end
		end

		if Speed < Config.MinSpeed then
			Speed = Config.MinSpeed
		elseif Speed > Config.MaxSpeed then
			Speed = Config.MaxSpeed
		end

		if AdjustSpeed < Config.MinAdjustSpeed then
			AdjustSpeed = Config.MinAdjustSpeed
		elseif AdjustSpeed > Config.MaxAdjustSpeed then
			AdjustSpeed = Config.MaxAdjustSpeed
		end

		if RotateSpeed < Config.MinRotateSpeed then
			RotateSpeed = Config.MinRotateSpeed
		elseif RotateSpeed > Config.MaxRotateSpeed then
			RotateSpeed = Config.MaxRotateSpeed
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.UpControl) then
			z2 = z2 + Speed
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.DownControl) then
			z2 = z2 - Speed
		end

		local axisX = GetDisabledControlNormal(0, Config.LookLrControl)
		local axisY = GetDisabledControlNormal(0, Config.LookUdControl)

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

		if CheckControls(IsDisabledControlPressed, 0, Config.ForwardControl) then
			x2 = x2 + dx1
			y2 = y2 + dy1
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.BackwardControl) then
			x2 = x2 - dx1
			y2 = y2 - dy1
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.LeftControl) then
			x2 = x2 + dx2
			y2 = y2 + dy2
		end

		if CheckControls(IsDisabledControlPressed, 0, Config.RightControl) then
			x2 = x2 - dx2
			y2 = y2 - dy2
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.SpawnControl) and CurrentSpawn then
			local entity

			if CurrentSpawn.type == 1 then
				entity = SpawnPed{
					name = CurrentSpawn.modelName,
					model = GetHashKey(CurrentSpawn.modelName),
					x = spawnPos.x,
					y = spawnPos.y,
					z = spawnPos.z,
					pitch = 0.0,
					roll = 0.0,
					yaw = yaw2 + 180.0,
					collisionDisabled = false,
					isVisible = true,
					outfit = -1,
					isInGroup = false,
					blockNonTemporaryEvents = false
				}

			elseif CurrentSpawn.type == 2 then
				entity = SpawnVehicle(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, true)
			elseif CurrentSpawn.type == 3 then
				entity = SpawnObject(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, yaw2, false, true, nil, nil, nil)
			elseif CurrentSpawn.type == 4 then
				entity = SpawnPropset(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z, yaw2)
			elseif CurrentSpawn.type == 5 then
				entity = SpawnPickup(CurrentSpawn.modelName, GetHashKey(CurrentSpawn.modelName), spawnPos.x, spawnPos.y, spawnPos.z)
			end

			if entity then
				PlaceOnGroundProperly(entity)
			end
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.SelectControl) then
			if AttachedEntity then
				AttachedEntity = nil
			elseif entity and CanModifyEntity(entity) then
				if IsEntityAttached(entity) then
					AttachedEntity = GetEntityAttachedTo(entity)
				else
					AttachedEntity = entity
				end
			end
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.DeleteControl) and entity then
			if AttachedEntity then
				RemoveEntity(AttachedEntity)
				AttachedEntity = nil
			else
				RemoveEntity(entity)
			end
		end

		if CheckControls(IsDisabledControlJustReleased, 0, Config.SpawnMenuControl) then
			SendNUIMessage({
				type = 'openSpawnMenu'
			})
			SetNuiFocus(true, true)
		end

		if CheckControls(IsDisabledControlJustReleased, 0, Config.DbMenuControl) then
			OpenDatabaseMenu()
		end

		if CheckControls(IsDisabledControlJustReleased, 0, Config.SaveLoadDbMenuControl) then
			OpenSaveDbMenu()
		end

		if CheckControls(IsDisabledControlJustReleased, 0, Config.HelpMenuControl) then
			SendNUIMessage({
				type = 'openHelpMenu'
			})
			SetNuiFocus(true, true)
		end

		if CheckControls(IsDisabledControlJustReleased, 0, Config.ToggleControlsControl) then
			ShowControls = not ShowControls
			if ShowControls then
				SendNUIMessage({
					type = 'showControls'
				})
			else
				SendNUIMessage({
					type = 'hideControls'
				})
			end
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.RotateModeControl) then
			RotateMode = (RotateMode + 1) % 3
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.AdjustModeControl) then
			if AdjustMode < 4 then
				AdjustMode = (AdjustMode + 1) % 4
			else
				AdjustMode = 0
			end
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.FreeAdjustModeControl) then
			AdjustMode = 4
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.AdjustOffControl) then
			AdjustMode = 5
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.SpeedModeControl) then
			SpeedMode = (SpeedMode + 1) % 3
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.PlaceOnGroundControl) then
			PlaceOnGround = not PlaceOnGround
		end

		if CheckControls(IsDisabledControlJustPressed, 0, Config.FocusControl) then
			if not entity or FocusTarget == entity then
				UnfocusEntity()
			else
				TryFocusEntity(entity)
			end
		end

		if FocusTarget and CheckControls(IsDisabledControlJustPressed, 0, Config.ToggleFocusModeControl) then
			if FreeFocus then
				PointCamAtEntity(Cam, FocusTarget)
				FreeFocus = false
			else
				StopCamPointing(Cam)
				FreeFocus = true
			end
		end

		if entity and CanModifyEntity(entity) then
			local posChanged = false
			local rotChanged = false

			if CheckControls(IsDisabledControlJustReleased, 0, Config.PropMenuControl) then
				OpenPropertiesMenuForEntity(entity)
			end

			if CheckControls(IsDisabledControlJustPressed, 0, Config.CloneControl) then
				AttachedEntity = CloneEntity(entity)
			end

			local ex1, ey1, ez1, epitch1, eroll1, eyaw1

			if Database[entity] and Database[entity].attachment.to > 0 then
				ex1 = Database[entity].attachment.x
				ey1 = Database[entity].attachment.y
				ez1 = Database[entity].attachment.z
				epitch1 = Database[entity].attachment.pitch
				eroll1 = Database[entity].attachment.roll
				eyaw1 = Database[entity].attachment.yaw
			else
				ex1, ey1, ez1 = table.unpack(GetEntityCoords(entity))
				epitch1, eroll1, eyaw1 = table.unpack(GetEntityRotation(entity, 2))
			end

			local ex2 = ex1
			local ey2 = ey1
			local ez2 = ez1
			local epitch2 = epitch1
			local eroll2 = eroll1
			local eyaw2 = eyaw1

			local edx1, edy1, edx2, edy2

			if Database[entity] and Database[entity].attachment.to > 0 then
				edx1 = 0
				edy1 = AdjustSpeed
				edx2 = AdjustSpeed
				edy2 = 0
			else
				edx1 = AdjustSpeed * math.sin(r1)
				edy1 = AdjustSpeed * math.cos(r1)
				edx2 = AdjustSpeed * math.sin(r2)
				edy2 = AdjustSpeed * math.cos(r2)
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.RotateLeftControl) then
				if RotateMode == 0 then
					epitch2 = epitch2 + RotateSpeed
				elseif RotateMode == 1 then
					eroll2 = eroll2 + RotateSpeed
				else
					eyaw2 = eyaw2 + RotateSpeed
				end

				rotChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.RotateRightControl) then
				if RotateMode == 0 then
					epitch2 = epitch2 - RotateSpeed
				elseif RotateMode == 1 then
					eroll2 = eroll2 - RotateSpeed
				else
					eyaw2 = eyaw2 - RotateSpeed
				end

				rotChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustUpControl) then
				ez2 = ez2 + AdjustSpeed
				posChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustDownControl) then
				ez2 = ez2 - AdjustSpeed
				posChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustForwardControl) then
				ex2 = ex2 + edx1
				ey2 = ey2 + edy1
				posChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustBackwardControl) then
				ex2 = ex2 - edx1
				ey2 = ey2 - edy1
				posChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustLeftControl) then
				ex2 = ex2 + edx2
				ey2 = ey2 + edy2
				posChanged = true
			end

			if CheckControls(IsDisabledControlPressed, 0, Config.AdjustRightControl) then
				ex2 = ex2 - edx2
				ey2 = ey2 - edy2
				posChanged = true
			end

			if AttachedEntity or posChanged or rotChanged then
				RequestControl(entity)

				if Database[entity] and Database[entity].attachment.to > 0 then
					AttachEntity(entity,
						Database[entity].attachment.to,
						Database[entity].attachment.bone,
						ex2, ey2, ez2,
						epitch2, eroll2, eyaw2,
						Database[entity].attachment.useSoftPinning,
						Database[entity].attachment.collision,
						Database[entity].attachment.vertex,
						Database[entity].attachment.fixedRot)
				else
					if posChanged then
						SetEntityCoordsNoOffset(entity, ex2, ey2, ez2)
					end

					if rotChanged then
						SetEntityRotation(entity, epitch2, eroll2, eyaw2, 2)
					end
				end

				if AttachedEntity then
					if AdjustMode < 4 then
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
								SetEntityRotation(AttachedEntity, epitch2 - axisX * Config.SpeedLr, eroll2, eyaw2, 2)
							elseif RotateMode == 1 then
								SetEntityRotation(AttachedEntity, epitch2, eroll2 - axisX * Config.SpeedLr, eyaw2, 2)
							else
								SetEntityRotation(AttachedEntity, epitch2, eroll2, eyaw2 - axisX * Config.SpeedLr, 2)
							end
						end
					elseif AdjustMode == 4 then
						SetEntityCoordsNoOffset(AttachedEntity, spawnPos.x, spawnPos.y, spawnPos.z)
					end

					if PlaceOnGround or AdjustMode == 4 then
						PlaceOnGroundProperly(AttachedEntity)
					end
				end
			end
		end

		if FocusTarget then
			if DoesEntityExist(FocusTarget) then
				local currentPos = GetEntityCoords(FocusTarget)

				SetCamCoord(Cam, vector3(x2, y2, z2) + (currentPos - FocusTargetPos))

				FocusTargetPos = currentPos
			else
				UnfocusEntity()
			end
		else
			SetCamCoord(Cam, x2, y2, z2)
		end

		SetCamRot(Cam, pitch2, 0.0, yaw2)
	end
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function enumerateEntities(firstFunc, nextFunc, endFunc)
	return coroutine.wrap(function()
		local iter, id = firstFunc()

		if not id or id == 0 then
			endFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = endFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = nextFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		endFunc(iter)
	end)
end

local function enumeratePeds()
	return enumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function enumerateVehicles()
	return enumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function enumerateObjects()
	return enumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function drawText3d(x, y, z, text)
	local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

	if onScreen then
		SetTextScale(0.35, 0.35)

		if Config.isRDR then
			SetTextFontForCurrentCommand(1)
			SetTextColor(255, 255, 255, 255)
		else
			SetTextFont(0)
			SetTextColour(255, 255, 255, 255)
		end

		SetTextCentre(1)

		if Config.isRDR then
			DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
		else
			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(screenX, screenY)
		end
	end
end

local function drawEntityHandle(type, entity, camCoords)
	local coords = GetEntityCoords(entity)

	if #(camCoords - coords) <= Config.EntityHandleDrawDistance then
		drawText3d(coords.x, coords.y, coords.z, type .. " " .. tostring(entity))
	end
end

local function drawEntityHandles()
	if Cam then
		if IsDisabledControlJustPressed(0, Config.EntityHandlesControl) then
			showEntityHandles = not showEntityHandles
		end

		if showEntityHandles then
			local camCoords = GetCamCoord(Cam)

			for ped in enumeratePeds() do
				drawEntityHandle("ped", ped, camCoords)
			end

			for vehicle in enumerateVehicles() do
				drawEntityHandle("vehicle", vehicle, camCoords)
			end

			for object in enumerateObjects() do
				drawEntityHandle("object", object, camCoords)
			end
		end
	end
end

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/spooner', 'Toggle spooner mode', {})

	TriggerServerEvent('spooner:init')

	while true do
		MainSpoonerUpdates()

		if Config.isRDR then
			SpoonerPrompts:handleEvents()
		end

		drawEntityHandles()

		Wait(0)
	end
end)

function UpdateDbEntities()
	local playerPed = PlayerPedId()

	if KeepSelfInDb and not EntityIsInDatabase(playerPed) then
		AddEntityToDatabase(playerPed)
	end

	local enableSpoonerPrompts = false

	for entity, properties in pairs(Database) do
		if not NetworkGetEntityIsNetworked(entity) then
			NetworkRegisterEntityAsNetworked(entity)
		end

		if properties.scenario then
			local hash = GetHashKey(properties.scenario)

			if not IsPedUsingScenarioHash(entity, hash) then
				startScenario(entity, properties.scenario)
			end
		elseif properties.animation then
			if not IsEntityPlayingAnim(entity, properties.animation.dict, properties.animation.name, properties.animation.flag) then
				PlayAnimation(entity, properties.animation)
			end
		end

		-- Show prompts for certain spooner shortcuts on your own ped
		if Config.isRDR then
			if entity == playerPed then
				if properties.scenario or properties.animation then
					if Permissions.properties.ped.clearTasks then
						if not ClearTasksPrompt:isEnabled() then
							ClearTasksPrompt:setEnabledAndVisible(true)
						end

						enableSpoonerPrompts = true
					end
				else
					if ClearTasksPrompt:isEnabled() then
						ClearTasksPrompt:setEnabledAndVisible(false)
					end
				end

				if properties.attachment.bone then
					if Permissions.properties.attachments then
						if not DetachPrompt:isEnabled() then
							DetachPrompt:setEnabledAndVisible(true)
						end
						enableSpoonerPrompts = true
					end
				else
					if DetachPrompt:isEnabled() then
						DetachPrompt:setEnabledAndVisible(false)
					end
				end
			end
		end
	end

	if Config.isRDR then
		if enableSpoonerPrompts then
			if not SpoonerPrompts:isActive() then
				SpoonerPrompts:setActive(true)
			end
		else
			if SpoonerPrompts:isActive() then
				SpoonerPrompts:setActive(false)
			end
		end
	end
end

CreateThread(function()
	while true do
		Wait(1000)
		UpdateDbEntities()
	end
end)
