local Cam = nil
local ShowHud = true
local Speed = Config.Speed
local ClearTasks = false

local Database = {}

local AdjustSpeed = Config.AdjustSpeed
local RotateSpeed = Config.RotateSpeed

local AttachedEntity = nil

local RotateMode = 0
local AdjustMode = -1

RegisterNetEvent('spooner:toggle')

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

RegisterCommand('spooner', function(source, args, raw)
	TriggerServerEvent('spooner:toggle')
end, false)

AddEventHandler('spooner:toggle', ToggleSpoonerMode)

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
		model = model,
		x = x,
		y = y,
		z = z,
		pitch = pitch,
		roll = roll,
		yaw = yaw
	}
end

function AddEntityToDatabase(entity, name)
	Database[entity] = GetLiveEntityProperties(entity)

	if name then
		Database[entity].name = name
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

function SpawnObject(name, model, x, y, z, pitch, roll, yaw)
	if not IsModelInCdimage(model) then
		return nil
	end

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end

	local object = CreateObjectNoOffset(model, x, y, z, true, false, true)

	if object < 1 then
		return nil
	end

	SetEntityRotation(object, pitch, roll, yaw, 2)

	FreezeEntityPosition(object, true)

	SetModelAsNoLongerNeeded(model)

	AddEntityToDatabase(object, name)

	return object
end

function RemoveEntity(entity)
	if IsPedAPlayer(entity) then
		return
	end

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

local CurrentObject = nil

RegisterNUICallback('closeObjectMenu', function(data, cb)
	if data.object then
		CurrentObject = data.object;
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
	FreezeEntityPosition(data.handle, true)
	cb({})
end)

RegisterNUICallback('unfreezeEntity', function(data, cb)
	FreezeEntityPosition(data.handle, false)
	cb({})
end)

RegisterNUICallback('setEntityRotation', function(data, cb)
	local pitch = data.pitch and data.pitch * 1.0 or 0.0
	local roll  = data.roll  and data.roll  * 1.0 or 0.0
	local yaw   = data.yaw   and data.yaw   * 1.0 or 0.0

	SetEntityRotation(data.handle, pitch, roll, yaw, 2)

	cb({})
end)

RegisterNUICallback('setEntityCoords', function(data, cb)
	local x = data.x and data.x * 1.0 or 0.0
	local y = data.y and data.y * 1.0 or 0.0
	local z = data.z and data.z * 1.0 or 0.0

	SetEntityCoordsNoOffset(data.handle, x, y, z)

	cb({})
end)

RegisterNUICallback('resetRotation', function(data, cb)
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
		entity = entity,
		properties = json.encode(GetEntityProperties(entity)),
		inDb = EntityIsInDatabase(entity)
	})
	SetNuiFocus(true, true)
end

RegisterNUICallback('openPropertiesMenuForEntity', function(data, cb)
	OpenPropertiesMenuForEntity(data.entity)
	cb({})
end)

RegisterNUICallback('invincibleOn', function(data, cb)
	SetEntityInvincible(data.handle, true)
	cb({})
end)

RegisterNUICallback('invincibleOff', function(data, cb)
	SetEntityInvincible(data.handle, false)
	cb({})
end)

RegisterNUICallback('placeEntityHere', function(data, cb)
	local x, y, z = table.unpack(GetCamCoord(Cam))
	local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))

	local spawnPos, entity, distance = GetInView(x, y, z, pitch, roll, yaw)

	SetEntityCoordsNoOffset(data.handle, spawnPos.x, spawnPos.y, spawnPos.z)
	PlaceObjectOnGroundProperly(data.handle)

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

function SaveDatabase(name)
	UpdateDatabase()
	SetResourceKvp(name, json.encode(Database))
end

function LoadDatabase(name)
	for entity, props in pairs(json.decode(GetResourceKvpString(name))) do
		SpawnObject(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw)
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
	LoadDatabase(data.name)
	cb({})
end)

RegisterNUICallback('deleteDb', function(data, cb)
	DeleteDatabase(data.name)
	cb({})
end)

RegisterNUICallback('init', function(data, cb)
	cb({
		objects = json.encode(Objects),
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

RegisterNUICallback('cloneEntity', function(data, cb)
	local props = GetLiveEntityProperties(data.handle)
	local entity = SpawnObject(props.name, props.model, props.x, props.y, props.z, props.pitch, props.roll, props.yaw)

	if entity then
		OpenPropertiesMenuForEntity(entity)
	end

	cb({})
end)

function IsUsingKeyboard(padIndex)
	return Citizen.InvokeNative(0xA571D46727E2B718, padIndex)
end

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/spooner', 'Toggle spooner mode', {})

	while true do
		Wait(0)

		if IsUsingKeyboard(0) and IsControlJustPressed(0, Config.ToggleControl) then
			TriggerServerEvent('spooner:toggle')
		end

		if Cam then
			local x1, y1, z1 = table.unpack(GetCamCoord(Cam))
			local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))

			local x2 = x1
			local y2 = y1
			local z2 = z1

			local spawnPos, entity, distance = GetInView(x2, y2, z2, pitch, roll, yaw)

			if AttachedEntity then
				entity = AttachedEntity
			end

			SendNUIMessage({
				type = 'updateSpoonerHud',
				entity = entity,
				speed = string.format('%.2f', Speed),
				currentObject = CurrentObject,
				rotateMode = RotateMode,
				adjustMode = AdjustMode
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
				yaw = yaw + axisX * -1.0 * Config.SpeedUd * 1.0
				pitch = math.max(math.min(89.9, pitch + axisY * -1.0 * Config.SpeedLr * 1.0), -89.9)
			end

			local r1 = -yaw * math.pi / 180
			local dx1 = Speed * math.sin(r1)
			local dy1 = Speed * math.cos(r1)

			local r2 = math.floor(yaw + 90.0) % 360 * -1.0 * math.pi / 180
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
				elseif CurrentObject then
					PlaceObjectOnGroundProperly(SpawnObject(CurrentObject, GetHashKey(CurrentObject), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, 0.0, 0.0))
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
					type = 'openObjectMenu'
				})
				SetNuiFocus(true, true)
			end

			if IsControlJustReleased(0, Config.DbMenuControl) then
				SendNUIMessage({
					type = 'openDatabase',
					database = json.encode(Database)
				})
				SetNuiFocus(true, true)
			end

			if IsControlJustReleased(0, Config.SaveLoadDbMenuControl) then
				SendNUIMessage({
					type = 'openSaveLoadDbMenu',
					databaseNames = json.encode(GetSavedDatabases())
				})
				SetNuiFocus(true, true)
			end

			if IsControlJustPressed(0, Config.RotateModeControl) then
				RotateMode = (RotateMode + 1) % 3
			end

			if IsControlJustPressed(0, Config.AdjustModeControl) then
				AdjustMode = (AdjustMode + 1) % 4
			end

			if IsControlJustPressed(0, Config.ResetAdjustModeControl) then
				AdjustMode = -1
			end

			if entity then
				if IsControlJustReleased(0, Config.PropMenuControl) then
					OpenPropertiesMenuForEntity(entity)
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
				local edx2 = AdjustSpeed * math.cos(r2)
				local edy2 = AdjustSpeed * math.cos(r2)

				if IsControlPressed(0, Config.RotateLeftControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 + RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 + RotateSpeed
					else
						eyaw2 = eyaw2 + RotateSpeed
					end
				end

				if IsControlPressed(0, Config.RotateRightControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 - RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 - RotateSpeed
					else
						eyaw2 = eyaw2 - RotateSpeed
					end

				end

				if IsControlPressed(0, Config.AdjustUpControl) then
					ez2 = ez2 + AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustDownControl) then
					ez2 = ez2 - AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustForwardControl) then
					ex2 = ex2 + edx1
					ey2 = ey2 + edy1
				end

				if IsControlPressed(0, Config.AdjustBackwardControl) then
					ex2 = ex2 - edx1
					ey2 = ey2 - edy1
				end

				if IsControlPressed(0, Config.AdjustLeftControl) then
					ex2 = ex2 + edx2
					ey2 = ey2 + edy2
				end

				if IsControlPressed(0, Config.AdjustRightControl) then
					ex2 = ex2 - edx2
					ey2 = ey2 - edy2
				end

				if ex2 ~= ex1 or ey2 ~= ey1 or ez2 ~= ez1 then
					SetEntityCoordsNoOffset(entity, ex2, ey2, ez2)
				end

				if epitch2 ~= epitch1 or eroll2 ~= eroll1 or eyaw2 ~= eyaw1 then
					SetEntityRotation(entity, epitch2, eroll2, eyaw2, 2)
				end

				if AttachedEntity then
					if AdjustMode == -1 then
						SetEntityCoordsNoOffset(AttachedEntity, spawnPos.x, spawnPos.y, spawnPos.z)
						PlaceObjectOnGroundProperly(AttachedEntity)
					elseif AdjustMode == 0 then
						SetEntityCoordsNoOffset(AttachedEntity, ex2 - axisX, ey2, ez2)
					elseif AdjustMode == 1 then
						SetEntityCoordsNoOffset(AttachedEntity, ex2, ey2 - axisX, ez2)
					elseif AdjustMode == 2 then
						SetEntityCoordsNoOffset(AttachedEntity, ex2, ey2, ez2 - axisY)
					end
				end
			end

			SetCamCoord(Cam, x2, y2, z2)
			SetCamRot(Cam, pitch, 0.0, yaw)
		end
	end
end)
