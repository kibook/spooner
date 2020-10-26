local Cam = nil
local ShowHud = true
local Speed = Config.Speed
local ClearTasks = false

local Database = {}

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

function RemoveEntity(entity)
	if IsPedAPlayer(entity) then
		return
	end

	SetEntityAsMissionEntity(entity, true, true)
	DeleteEntity(entity)

	Database[entity] = nil
end

function UpdateEntityProperties(entity)
	local x, y, z = table.unpack(GetEntityCoords(entity))
	local pitch, roll, yaw = table.unpack(GetEntityRotation(entity, 2))

	Database[entity].x = x
	Database[entity].y = y
	Database[entity].z = z
	Database[entity].pitch = pitch
	Database[entity].roll = yaw
	Database[entity].yaw = yaw
end

function AddEntityToDatabase(entity, name)
	Database[entity] = {
		name = name
	}
	UpdateEntityProperties(entity)
end

function SpawnObject(name, x, y, z)
	local model = GetHashKey(name)

	if not IsModelInCdimage(model) then
		return nil
	end

	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end

	local object = CreateObject(model, x, y, z, true, false, true)

	if object < 1 then
		return nil
	end

	PlaceObjectOnGroundProperly(object)
	FreezeEntityPosition(object, true)

	SetModelAsNoLongerNeeded(model)

	AddEntityToDatabase(object, name)

	return object
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

RegisterNUICallback('addEntityToDatabase', function(data, cb)
	AddEntityToDatabase(data.handle, GetModelName(data.handle))
	cb({})
end)

RegisterNUICallback('removeEntityFromDatabase', function(data, cb)
	Database[data.handle] = nil
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

function GetModelName(entity)
	local model = GetEntityModel(entity)

	for _, name in ipairs(Objects) do
		if model == GetHashKey(name) then
			return name
		end
	end

	return '?'
end

function OpenPropertiesMenuForEntity(entity)
	local properties = Database[entity]

	if not properties then
		local x, y, z = table.unpack(GetEntityCoords(entity))
		local pitch, roll, yaw = table.unpack(GetEntityRotation(entity, 2))

		properties = {
			name = GetModelName(entity),
			x = x,
			y = y,
			z = z,
			pitch = pitch,
			roll = roll,
			yaw = yaw
		}
	end

	SendNUIMessage({
		type = 'openPropertiesMenu',
		entity = entity,
		properties = json.encode(properties)
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
end)

function IsUsingKeyboard(padIndex)
	return Citizen.InvokeNative(0xA571D46727E2B718, padIndex)
end

function UpdateDatabase()
	local entities = {}

	for entity, properties in pairs(Database) do
		table.insert(entities, entity)
	end

	for _, entity in ipairs(entities) do
		if DoesEntityExist(entity) then
			UpdateEntityProperties(entity)
		else
			Database[entity] = nil
		end
	end
end

local AttachedEntity = nil

local RotateMode = 0

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/spooner', 'Toggle spooner mode', {})

	while true do
		Wait(0)

		if IsUsingKeyboard(0) and IsControlJustPressed(0, Config.ToggleControl) then
			TriggerServerEvent('spooner:toggle')
		end

		if Cam then
			local x, y, z = table.unpack(GetCamCoord(Cam))
			local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))

			local spawnPos, entity, distance = GetInView(x, y, z, pitch, roll, yaw)

			SendNUIMessage({
				type = 'updateSpoonerHud',
				entity = entity,
				speed = string.format('%.2f', Speed),
				currentObject = CurrentObject,
				rotateMode = RotateMode
			})

			UpdateDatabase()

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
				z = z + Speed
			end

			if IsControlPressed(0, Config.DownControl) then
				z = z - Speed
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
				x = x + dx1
				y = y + dy1
			end

			if IsControlPressed(0, Config.BackwardControl) then
				x = x - dx1
				y = y - dy1
			end

			if IsControlPressed(0, Config.LeftControl) then
				x = x + dx2
				y = y + dy2
			end

			if IsControlPressed(0, Config.RightControl) then
				x = x - dx2
				y = y - dy2
			end

			if IsControlJustPressed(0, Config.SpawnSelectControl) then
				if AttachedEntity then
					AttachedEntity = nil
				elseif entity then
					AttachedEntity = entity
				elseif CurrentObject then
					SpawnObject(CurrentObject, spawnPos.x, spawnPos.y, spawnPos.z)
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

			if IsControlJustPressed(0, Config.RotateModeControl) then
				RotateMode = (RotateMode + 1) % 3
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

				if IsControlPressed(0, Config.RotateLeftControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 + Config.RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 + Config.RotateSpeed
					else
						eyaw2 = eyaw2 + Config.RotateSpeed
					end
				end

				if IsControlPressed(0, Config.RotateRightControl) then
					if RotateMode == 0 then
						epitch2 = epitch2 - Config.RotateSpeed
					elseif RotateMode == 1 then
						eroll2 = eroll2 - Config.RotateSpeed
					else
						eyaw2 = eyaw2 - Config.RotateSpeed
					end

				end

				if IsControlPressed(0, Config.AdjustUpControl) then
					ez2 = ez2 + Config.AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustDownControl) then
					ez2 = ez2 - Config.AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustNorthControl) then
					ey2 = ey2 + Config.AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustSouthControl) then
					ey2 = ey2 - Config.AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustEastControl) then
					ex2 = ex2 + Config.AdjustSpeed
				end

				if IsControlPressed(0, Config.AdjustWestControl) then
					ex2 = ex2 - Config.AdjustSpeed
				end

				if ex2 ~= ex1 or ey2 ~= ey1 or ez2 ~= ez1 then
					SetEntityCoordsNoOffset(entity, ex2, ey2, ez2)
				end

				if epitch2 ~= epitch1 or eroll2 ~= eroll1 or eyaw2 ~= eyaw1 then
					SetEntityRotation(entity, epitch2, eroll2, eyaw2, 2)
				end
			end

			if AttachedEntity then
				SetEntityCoordsNoOffset(AttachedEntity, spawnPos.x, spawnPos.y, spawnPos.z)
				PlaceObjectOnGroundProperly(AttachedEntity)
			end

			SetCamCoord(Cam, x, y, z)
			SetCamRot(Cam, pitch, 0.0, yaw)
		end
	end
end)
