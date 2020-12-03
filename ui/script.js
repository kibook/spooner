var peds = [];
var vehicles = [];
var objects = [];
var scenarios = [];
var weapons = [];
var animations = {};
var propsets = [];
var pickups = [];

var lastSpawnMenu = -1;

var propertiesMenuUpdate;

function sendMessage(name, params) {
	return fetch('https://' + GetParentResourceName() + '/' + name, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(params)
	});
}

function showSpoonerHud() {
	document.querySelector('#hud').style.display = 'block';
}

function hideSpoonerHud() {
	document.querySelector('#hud').style.display = 'none';
}

function updateSpoonerHud(data) {
	var crosshair = document.querySelector('#crosshair');

	if (data.attachedEntity) {
		crosshair.className = 'attached';
	} else if (data.entity) {
		crosshair.className = 'active';
	} else {
		crosshair.className = 'inactive';
	}

	var entityInfo = document.querySelector('#entity-info');
	var entityId = document.querySelector('#entity-id');
	var entityNetId = document.querySelector('#entity-net-id');
	
	if (data.entity) {
		if (data.netId) {
			entityId.innerHTML = data.entity.toString(16) + ' [' + data.netId.toString(16) + ']';
		} else {
			entityId.innerHTML = data.entity.toString(16);
		}
		entityInfo.style.display = 'block';
	} else {
		entityInfo.style.display = 'none';
	}

	var spawnInfo = document.querySelector('#spawn-info');
	var spawnId = document.querySelector('#spawn-id');

	if (data.currentSpawn) {
		spawnId.innerHTML = data.currentSpawn;
		spawnInfo.style.display = 'block';
	} else {
		spawnInfo.style.display = 'none';
	}

	document.querySelector('#speed').innerHTML = data.speed;

	switch(data.adjustMode) {
		case -1:
			document.querySelector('#adjust-mode').innerHTML = 'Free';
			break;
		case 0:
			document.querySelector('#adjust-mode').innerHTML = 'X';
			break;
		case 1:
			document.querySelector('#adjust-mode').innerHTML = 'Y';
			break;
		case 2:
			document.querySelector('#adjust-mode').innerHTML = 'Z';
			break;
		case 3:
			document.querySelector('#adjust-mode').innerHTML = 'Rotate';
			break;
		case 4:
			document.querySelector('#adjust-mode').innerHTML = 'Off';
			break;

	}

	switch(data.rotateMode) {
		case 0:
			document.querySelector('#rotate-mode').innerHTML = 'Pitch';
			break;
		case 1:
			document.querySelector('#rotate-mode').innerHTML = 'Roll';
			break;
		case 2:
			document.querySelector('#rotate-mode').innerHTML = 'Yaw';
			break;
	}

	if (data.adjustMode == -1) {
		document.querySelector('#place-on-ground-container').style.display = 'none';
	} else {
		document.querySelector('#place-on-ground-container').style.display = 'block';
	}

	if (data.placeOnGround) {
		document.querySelector('#place-on-ground').innerHTML = 'On';
	} else {
		document.querySelector('#place-on-ground').innerHTML = 'Off';
	}

	document.querySelector('#cam-x').innerHTML = data.x;
	document.querySelector('#cam-y').innerHTML = data.y;
	document.querySelector('#cam-z').innerHTML = data.z;
	document.querySelector('#cam-heading').innerHTML = data.heading;

	document.querySelector('#adjust-speed').innerHTML = data.adjustSpeed;
	document.querySelector('#rotate-speed').innerHTML = data.rotateSpeed;

	document.querySelector('#model-name').innerHTML = data.modelName;

	switch(data.entityType) {
		case 1:
			document.querySelector('#entity-type').innerHTML = 'Ped';
			break;
		case 2:
			document.querySelector('#entity-type').innerHTML = 'Vehicle';
			break;
		case 3:
			document.querySelector('#entity-type').innerHTML = 'Object';
			break;
		default:
			document.querySelector('#entity-type').innerHTML = 'Entity';
			break;
	}
}

function openSpawnMenu() {
	switch (lastSpawnMenu) {
		case 0:
			document.querySelector('#ped-menu').style.display = 'flex';
			break;
		case 1:
			document.querySelector('#vehicle-menu').style.display = 'flex';
			break;
		case 2:
			document.querySelector('#object-menu').style.display = 'flex';
			break;
		case 3:
			document.querySelector('#propset-menu').style.display = 'flex';
			break;
		case 4:
			document.querySelector('#pickup-menu').style.display = 'flex';
			break;
		default:
			document.querySelector('#spawn-menu').style.display = 'flex';
			break;
	}
}

function closeSpawnMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	sendMessage('closeSpawnMenu', {})
}

function openPedMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#ped-menu').style.display = 'flex';
	lastSpawnMenu = 0;
}

function openVehicleMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#vehicle-menu').style.display = 'flex';
	lastSpawnMenu = 1;
}

function openObjectMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#object-menu').style.display = 'flex';
	lastSpawnMenu = 2;
}

function openPropsetMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#propset-menu').style.display = 'flex';
	lastSpawnMenu = 3;
}

function openPickupMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#pickup-menu').style.display = 'flex';
	lastSpawnMenu = 4;
}

function closePedMenu(selected) {
	document.querySelector('#ped-menu').style.display = 'none';

	if (selected) {
		var name = selected.innerHTML;

		sendMessage('closePedMenu', {
			modelName: name
		});

		var entries = document.querySelectorAll('#ped-list .object');

		for (i = 0; i < entries.length; ++i) {
			entries[i].className = 'object';
		}

		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closeVehicleMenu(selected) {
	document.querySelector('#vehicle-menu').style.display = 'none';

	if (selected) {
		var name = selected.innerHTML;

		sendMessage('closeVehicleMenu', {
			modelName: name
		});

		var entries = document.querySelectorAll('#vehicle-list .object');

		for (i = 0; i < entries.length; ++i) {
			entries[i].className = 'object';
		}

		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closeObjectMenu(selected) {
	document.querySelector('#object-menu').style.display = 'none';

	if (selected) {
		var name = selected.innerHTML;

		sendMessage('closeObjectMenu', {
			modelName: name
		});

		var entries = document.querySelectorAll('#object-list .object');

		for (i = 0; i < entries.length; ++i) {
			entries[i].className = 'object';
		}

		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closePropsetMenu(selected) {
	document.querySelector('#propset-menu').style.display = 'none';

	if (selected) {
		var name = selected.innerHTML;

		sendMessage('closePropsetMenu', {
			modelName: name
		});

		var entries = document.querySelectorAll('#propset-list .object');

		for (i = 0; i < entries.length; ++i) {
			entries[i].className = 'object';
		}

		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closePickupMenu(selected) {
	document.querySelector('#pickup-menu').style.display = 'none';

	if (selected) {
		var name = selected.innerHTML;

		sendMessage('closePickupMenu', {
			modelName: name
		});

		var entries = document.querySelectorAll('#pickup-list .object');

		for (i = 0; i < entries.length; ++i) {
			entries[i].className = 'object';
		}

		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function performScenario(scenario) {
	document.querySelectorAll('#scenario-list .object').forEach(e => e.className = 'object');
	scenario.className = 'object selected';

	sendMessage('performScenario', {
		handle: currentEntity(),
		scenario: scenario.innerHTML
	});
}

function giveWeapon(weapon) {
	sendMessage('giveWeapon', {
		handle: currentEntity(),
		weapon: weapon.innerHTML
	});
}

function playAnimation(animation) {
	document.querySelectorAll('#animation-list .object').forEach(e => e.className = 'object');
	animation.className = 'object selected';

	sendMessage('playAnimation', {
		handle: currentEntity(),
		dict: animation.getAttribute('data-dict'),
		name: animation.getAttribute('data-name'),
		blendInSpeed: parseFloat(document.querySelector('#animation-blend-in-speed').value),
		blendOutSpeed: parseFloat(document.querySelector('#animation-blend-out-speed').value),
		duration: parseInt(document.querySelector('#animation-duration').value),
		flag: parseInt(document.querySelector('#animation-flag').value),
		playbackRate: parseFloat(document.querySelector('#animation-playback-rate').value)
	});
}

function populatePedList(filter) {
	var pedList = document.querySelector('#ped-list');

	pedList.innerHTML = '';

	for (i = 0; i < peds.length; ++i) {
		var name = peds[i];

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = name;
			div.addEventListener('click', function(event) {
				closePedMenu(this);
			});
			pedList.appendChild(div);
		}
	}
}

function setPlayerModel(modelName) {
	sendMessage('setPlayerModel', {
		modelName: modelName
	}).then(resp => resp.json()).then(resp => {
		document.getElementById('properties-menu-entity-id').setAttribute('data-handle', resp.handle);
		clearInterval(propertiesMenuUpdate);
		propertiesMenuUpdate = setInterval(function() {
			sendUpdatePropertiesMenuMessage(resp.handle, false);
		}, 500);
	});
}

function populatePlayerModelList(filter) {
	var pedList = document.querySelector('#player-model-list');

	pedList.innerHTML = '';

	for (i = 0; i < peds.length; ++i) {
		var name = peds[i];

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = name;
			div.addEventListener('click', function(event) {
				pedList.querySelectorAll('.object').forEach(e => e.className = 'object');
				this.className = 'object selected';
				setPlayerModel(this.innerHTML);
			});
			pedList.appendChild(div);
		}
	}
}

function populateVehicleList(filter) {
	var vehicleList = document.querySelector('#vehicle-list');

	vehicleList.innerHTML = '';

	for (i = 0; i < vehicles.length; ++i) {
		var name = vehicles[i];

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = name;
			div.addEventListener('click', function(event) {
				closeVehicleMenu(this);
			});
			vehicleList.appendChild(div);
		}
	}
}

function populateObjectList(filter) {
	var objectList = document.querySelector('#object-list');

	objectList.innerHTML = '';

	for (i = 0; i < objects.length; ++i) {
		var name = objects[i];

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = name;
			div.addEventListener('click', function(event) {
				closeObjectMenu(this);
			});
			objectList.appendChild(div);
		}
	}
}

function populateScenarioList(filter) {
	var scenarioList = document.querySelector('#scenario-list');

	scenarioList.innerHTML = '';

	scenarios.forEach(function(scenario) {
		if (!filter || filter == '' || scenario.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = scenario;
			div.addEventListener('click', function(event) {
				performScenario(this);
			});
			scenarioList.appendChild(div);
		}
	});
}

function populateWeaponList(filter) {
	var weaponList = document.querySelector('#weapon-list');

	weaponList.innerHTML = '';

	weapons.forEach(function(weapon) {
		if (!filter || filter == '' || weapon.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = weapon;
			div.addEventListener('click', function(event) {
				giveWeapon(this);
			});
			weaponList.appendChild(div);
		}
	});
}

function populateAnimationList(filter) {
	var animationList = document.querySelector('#animation-list');
	var animationMaxResults = parseInt(document.querySelector('#animation-search-max-results').value);

	animationList.innerHTML = '';

	var results = [];

	Object.keys(animations).forEach(function(dict) {
		animations[dict].forEach(function(anim) {
			var name = dict + ': ' + anim;

			if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
				results.push({
					name: name,
					dict: dict,
					anim: anim
				})
			}
		});
	});

	results.sort(function(a, b) {
		if (a.name < b.name) {
			return -1;
		}
		if (a.name > b.name) {
			return 1;
		}
		return 0;
	});

	document.getElementById('animation-search-total-results').innerHTML = results.length;

	for (var i = 0; i < results.length && i < animationMaxResults; ++i) {
		var div = document.createElement('div');
		div.className = 'object';
		div.innerHTML = results[i].name;
		div.setAttribute('data-dict', results[i].dict);
		div.setAttribute('data-name', results[i].anim);
		div.addEventListener('click', function() {
			playAnimation(this);
		});
		animationList.appendChild(div);
	}
}

function populatePropsetList(filter) {
	var propsetList = document.querySelector('#propset-list');

	propsetList.innerHTML = '';

	propsets.forEach(propset => {
		if (!filter || filter == '' || propset.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = propset;
			div.addEventListener('click', function(event) {
				closePropsetMenu(this);
			});
			propsetList.appendChild(div);
		}
	});
}

function populatePickupList(filter) {
	var pickupList = document.querySelector('#pickup-list');

	pickupList.innerHTML = '';

	pickups.forEach(pickup => {
		if (!filter || filter == '' || pickup.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');
			div.className = 'object';
			div.innerHTML = pickup;
			div.addEventListener('click', function(event) {
				closePickupMenu(this);
			});
			pickupList.appendChild(div);
		}
	});
}

function deleteEntity(object) {
	var handle = object.getAttribute('data-handle');

	object.remove();

	sendMessage('deleteEntity', {
		handle: parseInt(handle)
	});

	if (!document.querySelector('#object-database-list .object')) {
		closeDatabase();
	}
}

function openDatabase(data) {
	var objectList = document.querySelector('#object-database-list');
	var database = JSON.parse(data.database);

	objectList.innerHTML = '';

	Object.keys(database).forEach(function(handle) {
		var entityId = parseInt(handle);

		var div = document.createElement('div');
		if (database[handle].isSelf) {
			div.className = 'object self';
		} else {
			div.className = 'object'
		}

		if (database[handle].playerName) {
			if (database[handle].netId) {
				div.innerHTML = entityId.toString(16) + ' [' + database[handle].netId.toString(16) + '] ' + database[handle].name + ' (' + database[handle].playerName + ')';
			} else {
				div.innerHTML = entityId.toString(16) + ' ' + database[handle].name + ' (' + database[handle].playerName + ')';
			}
		} else {
			if (database[handle].netId) {
				div.innerHTML = entityId.toString(16) + ' [' + database[handle].netId.toString(16) + '] ' + database[handle].name;
			} else {
				div.innerHTML = entityId.toString(16) + ' ' + database[handle].name;
			}
		}

		div.setAttribute('data-handle', handle);
		div.addEventListener('click', function(event) {
			document.querySelector('#object-database').style.display = 'none';
			sendMessage('openPropertiesMenuForEntity', {
				entity: entityId
			});
		});
		div.addEventListener('contextmenu', function(event) {
			deleteEntity(this);
		});
		objectList.appendChild(div);
	});

	document.querySelector('#object-database').style.display = 'flex';
}

function closeDatabase() {
	document.querySelector('#object-database').style.display = 'none';

	sendMessage('closeDatabase', {});
}

function removeAllFromDatabase() {
	sendMessage('removeAllFromDatabase', {});

	closeDatabase()
}

function setFieldIfInactive(id, value) {
	var field = document.getElementById(id);

	if (document.activeElement != field) {
		field.value = value;
	}
}

function updatePropertiesMenu(data) {
	var properties = JSON.parse(data.properties);

	document.querySelectorAll('.player-property').forEach(e => e.style.display = 'none');
	document.querySelectorAll('.ped-property').forEach(e => e.style.display = 'none');
	document.querySelectorAll('.vehicle-property').forEach(e => e.style.display = 'none');
	document.querySelectorAll('.object-property').forEach(e => e.style.display = 'none');

	switch (properties.type) {
		case 1:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'ped';
			document.querySelectorAll('.ped-property').forEach(e => e.style.display = 'block');
			break;
		case 2:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'vehicle';
			document.querySelectorAll('.vehicle-property').forEach(e => e.style.display = 'block');
			break;
		case 3:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'object';
			document.querySelectorAll('.object-property').forEach(e => e.style.display = 'block');
			break;
		case 4:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'propset';
			break;
		case 5:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'pickup';
			break;
		default:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'entity';
			break;
	}

	if (properties.playerName) {
		document.querySelectorAll('.player-property').forEach(e => e.style.display = 'block');
	}

	var entity = document.querySelector('#properties-menu-entity-id');
	entity.setAttribute('data-handle', data.entity);
	if (properties.playerName) {
		if (properties.netId) {
			entity.innerHTML = data.entity.toString(16) + ' [' + properties.netId.toString(16) + '] (' + properties.playerName + ')';
		} else {
			entity.innerHTML = data.entity.toString(16) + ' (' + properties.playerName + ')';
		}
	} else {
		if (properties.netId) {
			entity.innerHTML = data.entity.toString(16) + ' [' + properties.netId.toString(16) + ']';
		} else {
			entity.innerHTML = data.entity.toString(16);
		}
	}

	document.querySelector('#properties-model').innerHTML = properties.name;

	setFieldIfInactive('properties-x', properties.x);
	setFieldIfInactive('properties-y', properties.y);
	setFieldIfInactive('properties-z', properties.z);

	setFieldIfInactive('properties-pitch', properties.pitch);
	setFieldIfInactive('properties-roll', properties.roll);
	setFieldIfInactive('properties-yaw', properties.yaw);

	if (data.inDb) {
		document.querySelector('#properties-add-to-db').style.display = 'none';
		document.querySelector('#properties-remove-from-db').style.display = 'block';
	} else {
		document.querySelector('#properties-add-to-db').style.display = 'block';
		document.querySelector('#properties-remove-from-db').style.display = 'none';
	}

	setFieldIfInactive('properties-health', properties.health);

	setFieldIfInactive('properties-outfit', properties.outfit);

	document.querySelector('#properties-request-control').disabled = data.hasNetworkControl || properties.type == 0;

	if (properties.isFrozen) {
		document.getElementById('properties-freeze').style.display = 'none';
		document.getElementById('properties-unfreeze').style.display = 'block';
	} else {
		document.getElementById('properties-unfreeze').style.display = 'none';
		document.getElementById('properties-freeze').style.display = 'block';
	}

	if (properties.isInGroup) {
		document.querySelector('#properties-add-to-group').style.display = 'none';
		document.querySelector('#properties-remove-from-group').style.display = 'block';
	} else {
		document.querySelector('#properties-remove-from-group').style.display = 'none';
		document.querySelector('#properties-add-to-group').style.display = 'block';
	}

	if (properties.collisionDisabled) {
		document.querySelector('#properties-collision-off').style.display = 'none';
		document.querySelector('#properties-collision-on').style.display = 'block';
	} else {
		document.querySelector('#properties-collision-on').style.display = 'none';
		document.querySelector('#properties-collision-off').style.display = 'block';
	}

	if (properties.lightsIntensity) {
		setFieldIfInactive('properties-lights-intensity', properties.lightsIntensity);
	} else {
		setFieldIfInactive('properties-lights-intensity', 0);
	}

	if (properties.lightsColour) {
		setFieldIfInactive('properties-lights-red', properties.lightsColour.red);
		setFieldIfInactive('properties-lights-green', properties.lightsColour.green);
		setFieldIfInactive('properties-lights-blue', properties.lightsColour.blue);
	} else {
		setFieldIfInactive('properties-lights-red', 0);
		setFieldIfInactive('properties-lights-green', 0);
		setFieldIfInactive('properties-lights-blue', 0);
	}

	if (properties.lightsType) {
		setFieldIfInactive('properties-lights-type', properties.lightsType);
	} else {
		setFieldIfInactive('properties-lights-type', 0);
	}
}

function sendUpdatePropertiesMenuMessage(handle, open) {
	sendMessage('updatePropertiesMenu', {
		handle: handle
	}).then(resp => resp.json()).then(function(resp){
		updatePropertiesMenu(resp);

		if (open) {
			document.querySelector('#properties-menu').style.display = 'flex';
		}
	});
}

function openPropertiesMenu(data) {
	sendUpdatePropertiesMenuMessage(data.entity, true);

	if (propertiesMenuUpdate) {
		clearInterval(propertiesMenuUpdate);
		propertiesMenuUpdate = null;
	}

	propertiesMenuUpdate = setInterval(function() {
		sendUpdatePropertiesMenuMessage(data.entity, false);
	}, 500);
}

function closePropertiesMenu(loseFocus) {
	document.querySelector('#properties-menu').style.display = 'none';
	document.querySelector('#ped-options-menu').style.display = 'none';
	document.querySelector('#vehicle-options-menu').style.display = 'none';

	clearInterval(propertiesMenuUpdate);

	if (loseFocus) {
		sendMessage('closePropertiesMenu', {});
	}
}

function loadDatabase(name) {
	var relative = document.querySelector('#load-db-relative').checked;
	var replace = document.querySelector('#replace-db').checked;

	sendMessage('loadDb', {
		name: name,
		relative: relative,
		replace: replace
	});
}

function updateDbList(data) {
	var databaseNames = JSON.parse(data);
	var dbList = document.querySelector('#db-list');

	dbList.innerHTML = '';

	databaseNames.forEach(function(name) {
		var div = document.createElement('div');
		div.className = 'database';
		div.innerHTML = name;
		div.addEventListener('click', function(event) {
			loadDatabase(this.innerHTML);
		});
		div.addEventListener('contextmenu', function(event) {
			sendMessage('deleteDb', {
				name: this.innerHTML
			});
			this.remove();
		});
		dbList.appendChild(div);
	});
}

function openSaveLoadDbMenu(databaseNames) {
	updateDbList(databaseNames)
	document.querySelector('#save-load-db-menu').style.display = 'flex';
}

function closeSaveLoadDbMenu() {
	document.querySelector('#save-load-db-menu').style.display = 'none';
	sendMessage('closeSaveLoadDbMenu', {});
}

function goToEntity(handle) {
	sendMessage('goToEntity', {
		handle: handle
	});
}

function openHelpMenu() {
	document.querySelector('#help-menu').style.display = 'flex';
	document.querySelector('#hud').style.display = 'none';
}

function closeHelpMenu() {
	document.querySelector('#help-menu').style.display = 'none';
	document.querySelector('#hud').style.display = 'block';
	sendMessage('closeHelpMenu', {});
}

function getIntoVehicle(handle) {
	sendMessage('getIntoVehicle', {
		handle: handle
	});
}

function attachTo(fromEntity, toEntity) {
	sendMessage('attachTo', {
		from: fromEntity,
		to: toEntity,
		bone: parseInt(document.querySelector('#attachment-bone').value),
		x: parseFloat(document.querySelector('#attachment-x').value),
		y: parseFloat(document.querySelector('#attachment-y').value),
		z: parseFloat(document.querySelector('#attachment-z').value),
		pitch: parseFloat(document.querySelector('#attachment-pitch').value),
		roll: parseFloat(document.querySelector('#attachment-roll').value),
		yaw: parseFloat(document.querySelector('#attachment-yaw').value),
		keepPos: document.querySelector('#attachment-keep-pos').checked
	});
	sendMessage('getDatabase', {handle: fromEntity}).then(resp => resp.json()).then(resp => openAttachToMenu(fromEntity, resp));
}

function openAttachToMenu(fromEntity, data) {
	var properties = JSON.parse(data.properties);
	var database = JSON.parse(data.database);

	var list = document.querySelector('#attach-to-list');

	list.innerHTML = '';

	var addTo = true;

	Object.keys(database).forEach(function(handle) {
		var toEntity = parseInt(handle);

		if (toEntity == fromEntity) {
			return;
		}

		var div = document.createElement('div');

		if (properties.attachment.to == handle) {
			div.className = 'object selected';
			addTo = false;
		} else {
			div.className = 'object';
		}

		div.innerHTML = toEntity.toString(16) + ' ' + database[handle].name;
		div.setAttribute('data-handle', handle);
		div.addEventListener('click', function(event) {
			document.querySelector('#attachment-options-menu').style.display = 'none';
			attachTo(fromEntity, toEntity);
		});
		list.appendChild(div);
	});

	if (addTo && properties.attachment.to) {
		var div = document.createElement('div');
		div.className = 'object selected';
		if (database[properties.attachment.to]) {
			div.innerHTML = database[properties.attachment.to].name;
		} else {
			div.innerHTML = properties.attachment.to.toString(16);
		}
		div.addEventListener('click', function(event) {
			document.querySelector('#attachment-options-menu').style.display = 'none';
			attachTo(fromEntity, properties.attachment.to);
		});
		list.appendChild(div);
	}

	document.querySelector('#attachment-bone').value = properties.attachment.bone;
	document.querySelector('#attachment-x').value = properties.attachment.x;
	document.querySelector('#attachment-y').value = properties.attachment.y;
	document.querySelector('#attachment-z').value = properties.attachment.z;
	document.querySelector('#attachment-pitch').value = properties.attachment.pitch;
	document.querySelector('#attachment-roll').value = properties.attachment.roll;
	document.querySelector('#attachment-yaw').value = properties.attachment.yaw;

	if (properties.attachment.to) {
		document.querySelector('#attachment-options-detach').style.display = 'block';
	} else {
		document.querySelector('#attachment-options-detach').style.display = 'none';
	}

	document.querySelector('#attachment-options-menu').style.display = 'flex';
}

function updatePermissions(data) {
	var permissions = JSON.parse(data.permissions);

	document.querySelector('#spawn-menu-peds').disabled = !permissions.spawn.ped;
	document.querySelector('#spawn-menu-vehicles').disabled = !permissions.spawn.vehicle;
	document.querySelector('#spawn-menu-objects').disabled = !permissions.spawn.object;
	document.querySelector('#spawn-menu-propsets').disabled = !permissions.spawn.propset;
	document.querySelector('#spawn-menu-pickups').disabled = !permissions.spawn.pickup;

	document.querySelector('#properties-freeze').disabled = !permissions.properties.freeze;
	document.querySelector('#properties-unfreeze').disabled = !permissions.properties.freeze;
	document.querySelector('#properties-x').disabled = !permissions.properties.position;
	document.querySelector('#properties-y').disabled = !permissions.properties.position;
	document.querySelector('#properties-z').disabled = !permissions.properties.position;
	document.querySelector('#properties-place-here').disabled = !permissions.properties.position;
	document.querySelector('#properties-goto').disabled = !permissions.properties.goTo;
	document.querySelector('#properties-pitch').disabled = !permissions.properties.rotation;
	document.querySelector('#properties-roll').disabled = !permissions.properties.rotation;
	document.querySelector('#properties-yaw').disabled = !permissions.properties.rotation;
	document.querySelector('#properties-reset-rotation').disabled = !permissions.properties.rotation;
	document.querySelector('#properties-health').disabled = !permissions.properties.health;
	document.querySelector('#properties-invincible-on').disabled = !permissions.properties.invincible;
	document.querySelector('#properties-invincible-off').disabled = !permissions.properties.invincible;
	document.querySelector('#properties-visible').disabled = !permissions.properties.visible;
	document.querySelector('#properties-invisible').disabled = !permissions.properties.visible;
	document.querySelector('#properties-gravity-on').disabled = !permissions.properties.gravity;
	document.querySelector('#properties-gravity-off').disabled = !permissions.properties.gravity;
	document.querySelector('#properties-collision-off').disabled = !permissions.properties.collision;
	document.querySelector('#properties-collision-on').disabled = !permissions.properties.collision;
	document.querySelector('#properties-attach').disabled = !permissions.properties.attachments;
	document.querySelector('#properties-player-model').disabled = !permissions.properties.ped.changeModel;
	document.querySelector('#properties-outfit').disabled = !permissions.properties.ped.outfit;
	document.querySelector('#properties-add-to-group').disabled = !permissions.properties.ped.group;
	document.querySelector('#properties-remove-from-group').disabled = !permissions.properties.ped.group;
	document.querySelector('#properties-scenario').disabled = !permissions.properties.ped.scenario;
	document.querySelector('#properties-animation').disabled = !permissions.properties.ped.animation;
	document.querySelector('#properties-clear-ped-tasks').disabled = !permissions.properties.ped.clearTasks;
	document.querySelector('#properties-clear-ped-tasks-immediately').disabled = !permissions.properties.ped.clearTasks;
	document.querySelector('#properties-give-weapon').disabled = !permissions.properties.ped.weapon;
	document.querySelector('#properties-remove-all-weapons').disabled = !permissions.properties.ped.weapon;
	document.querySelector('#properties-get-on-mount').disabled = !permissions.properties.ped.mount;
	document.querySelector('#properties-resurrect-ped').disabled = !permissions.properties.ped.resurrect;
	document.querySelector('#properties-ai-on').disabled = !permissions.properties.ped.ai;
	document.querySelector('#properties-ai-off').disabled = !permissions.properties.ped.ai;
	document.querySelector('#properties-repair-vehicle').disabled = !permissions.properties.vehicle.repair;
	document.querySelector('#properties-get-in').disabled = !permissions.properties.vehicle.getin
	document.querySelector('#properties-engine-on').disabled = !permissions.properties.vehicle.engine
	document.querySelector('#properties-engine-off').disabled = !permissions.properties.vehicle.engine
	document.querySelector('#properties-vehicle-lights-on').disabled = !permissions.properties.vehicle.lights;
	document.querySelector('#properties-vehicle-lights-off').disabled = !permissions.properties.vehicle.lights;
}

function currentEntity() {
	return parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'));
}

window.addEventListener('message', function(event) {
	switch (event.data.type) {
		case 'showSpoonerHud':
			showSpoonerHud();
			break;
		case 'hideSpoonerHud':
			hideSpoonerHud();
			break;
		case 'updateSpoonerHud':
			updateSpoonerHud(event.data);
			break;
		case 'openSpawnMenu':
			openSpawnMenu();
			break;
		case 'openDatabase':
			openDatabase(event.data);
			break;
		case 'openPropertiesMenu':
			openPropertiesMenu(event.data);
			break;
		case 'openSaveLoadDbMenu':
			openSaveLoadDbMenu(event.data.databaseNames);
			break;
		case 'openHelpMenu':
			openHelpMenu();
			break;
		case 'updatePermissions':
			updatePermissions(event.data);
			break;
	}
});

window.addEventListener('load', function() {
	sendMessage('init', {}).then(resp => resp.json()).then(function(resp) {
		peds = JSON.parse(resp.peds);
		populatePedList();
		populatePlayerModelList();

		vehicles = JSON.parse(resp.vehicles);
		populateVehicleList();

		objects = JSON.parse(resp.objects);
		populateObjectList();

		scenarios = JSON.parse(resp.scenarios);
		populateScenarioList();

		weapons = JSON.parse(resp.weapons);
		populateWeaponList();

		animations = JSON.parse(resp.animations);
		populateAnimationList();

		propsets = JSON.parse(resp.propsets);
		populatePropsetList();

		pickups = JSON.parse(resp.pickups);
		populatePickupList();

		document.querySelectorAll('.adjust-speed').forEach(e => e.value = resp.adjustSpeed);
		document.querySelectorAll('.adjust-input').forEach(e => e.step = resp.adjustSpeed);

		document.querySelectorAll('.rotate-speed').forEach(e => e.value = resp.rotateSpeed);
		document.querySelectorAll('.rotate-input').forEach(e => e.step = resp.rotateSpeed);
	});

	document.querySelector('#ped-search-filter').addEventListener('input', function(event) {
		populatePedList(this.value);
	});

	document.querySelector('#player-model-search-filter').addEventListener('input', function(event) {
		populatePlayerModelList(this.value);
	});

	document.querySelector('#vehicle-search-filter').addEventListener('input', function(event) {
		populateVehicleList(this.value);
	});

	document.querySelector('#object-search-filter').addEventListener('input', function(event) {
		populateObjectList(this.value);
	});

	document.getElementById('propset-search-filter').addEventListener('input', function(event) {
		populatePropsetList(this.value);
	});

	document.querySelector('#ped-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#ped-menu').style.display = 'none';

		sendMessage('closePedMenu', {
			modelName: document.querySelector('#ped-search-filter').value
		});
	});

	document.querySelector('#player-model-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#player-model-menu').style.display = 'none';
		setPlayerModel(document.querySelector('#player-model-search-filter').value);
	});

	document.querySelector('#vehicle-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#vehicle-menu').style.display = 'none';

		sendMessage('closeVehicleMenu', {
			modelName: document.querySelector('#vehicle-search-filter').value
		});
	});

	document.querySelector('#object-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#object-menu').style.display = 'none';

		sendMessage('closeObjectMenu', {
			modelName: document.querySelector('#object-search-filter').value
		});
	});

	document.querySelector('#propset-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#propset-menu').style.display = 'none';

		sendMessage('closePropsetMenu', {
			modelName: document.querySelector('#propset-search-filter').value
		});
	});

	document.querySelector('#pickup-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#pickup-menu').style.display = 'none';

		sendMessage('closePickupMenu', {
			modelName: document.querySelector('#pickup-search-filter').value
		});
	});

	document.querySelector('#ped-menu-close-btn').addEventListener('click', function(event) {
		closePedMenu();
	});

	document.getElementById('player-model-menu-close-btn').addEventListener('click', function(event) {
		document.querySelector('#player-model-menu').style.display = 'none';
		document.querySelector('#ped-options-menu').style.display = 'flex';
	});

	document.querySelector('#vehicle-menu-close-btn').addEventListener('click', function(event) {
		closeVehicleMenu();
	});

	document.querySelector('#object-menu-close-btn').addEventListener('click', function(event) {
		closeObjectMenu();
	});

	document.querySelector('#propset-menu-close-btn').addEventListener('click', function(event) {
		closePropsetMenu();
	});

	document.querySelector('#pickup-menu-close-btn').addEventListener('click', function(event) {
		closePickupMenu();
	});

	document.querySelector('#object-database-remove-all-btn').addEventListener('click', function(event) {
		removeAllFromDatabase();
	});

	document.querySelector('#object-database-close-btn').addEventListener('click', function(event) {
		closeDatabase();
	});

	document.querySelector('#properties-add-to-db').addEventListener('click', function(event) {
		sendMessage('addEntityToDatabase', {
			handle: currentEntity()
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#properties-add-to-db').style.display = 'none';
			document.querySelector('#properties-remove-from-db').style.display = 'block';
		});
	});

	document.querySelector('#properties-remove-from-db').addEventListener('click', function(event) {
		sendMessage('removeEntityFromDatabase', {
			handle: currentEntity()
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#properties-add-to-db').style.display = 'block';
			document.querySelector('#properties-remove-from-db').style.display = 'none';
		});
	});

	document.querySelector('#properties-freeze').addEventListener('click', function(event) {
		sendMessage('freezeEntity', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-unfreeze').addEventListener('click', function(event) {
		sendMessage('unfreezeEntity', {
			handle: currentEntity()
		});
	});

	document.querySelectorAll('.set-coords').forEach(function(e) {
		e.addEventListener('input', function(event) {
			sendMessage('setEntityCoords', {
				handle: currentEntity(),
				x: parseFloat(document.querySelector('#properties-x').value),
				y: parseFloat(document.querySelector('#properties-y').value),
				z: parseFloat(document.querySelector('#properties-z').value)
			});
		});
	});

	document.querySelector('#properties-place-here').addEventListener('click', function(event) {
		sendMessage('placeEntityHere', {
			handle: currentEntity()
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#properties-x').value = resp.x;
			document.querySelector('#properties-y').value = resp.y;
			document.querySelector('#properties-z').value = resp.z;
			document.querySelector('#properties-pitch').value = resp.pitch;
			document.querySelector('#properties-roll').value = resp.roll;
			document.querySelector('#properties-yaw').value = resp.pitch;
		});
	});

	document.querySelector('#properties-goto').addEventListener('click', function(event) {
		closePropertiesMenu(true);
		goToEntity(currentEntity())
	});

	document.querySelectorAll('.set-rotation').forEach(function(e) {
		e.addEventListener('input', function(event) {
			sendMessage('setEntityRotation', {
				handle: currentEntity(),
				pitch: parseFloat(document.querySelector('#properties-pitch').value),
				roll: parseFloat(document.querySelector('#properties-roll').value),
				yaw: parseFloat(document.querySelector('#properties-yaw').value)
			});
		});
	});

	document.querySelector('#properties-reset-rotation').addEventListener('click', function(event) {
		sendMessage('resetRotation', {
			handle: currentEntity()
		});
		document.querySelector('#properties-pitch').value = 0.0;
		document.querySelector('#properties-roll').value = 0.0;
		document.querySelector('#properties-yaw').value = 0.0;
	});

	document.querySelector('#properties-invincible-on').addEventListener('click', function(event) {
		sendMessage('invincibleOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-invincible-off').addEventListener('click', function(event) {
		sendMessage('invincibleOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-clone').addEventListener('click', function(event) {
		sendMessage('cloneEntity', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-delete').addEventListener('click', function(event) {
		sendMessage('deleteEntity', {
			handle: currentEntity()
		});

		closePropertiesMenu(true);
	});

	document.querySelector('#properties-menu-close-btn').addEventListener('click', function(event) {
		closePropertiesMenu(true);
	});

	document.querySelector('#save-db-btn').addEventListener('click', function(event) {
		sendMessage('saveDb', {
			name: document.querySelector('#save-db-name').value
		}).then(resp => resp.json()).then(resp => updateDbList(resp));
	});

	document.querySelector('#import-export-db-btn').addEventListener('click', function(event) {
		document.querySelector('#save-load-db-menu').style.display = 'none';
		document.querySelector('#import-export-db').style.display = 'flex';
	});

	document.querySelector('#import-db').addEventListener('click', function(event) {
		var url = document.querySelector('#import-url').value;

		if (url) {
			fetch(url).then(resp => resp.text()).then(function(text) {
				document.querySelector('#import-export-content').value = text;

				sendMessage('importDb', {
					format: document.querySelector('#import-export-format').value,
					content: text
				});
			});
		} else {
			sendMessage('importDb', {
				format: document.querySelector('#import-export-format').value,
				content: document.querySelector('#import-export-content').value
			});
		}
	});

	document.querySelector('#export-db').addEventListener('click', function(event) {
		sendMessage('exportDb', {
			format: document.querySelector('#import-export-format').value
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#import-export-content').value = resp;
		});
	});

	document.querySelector('#import-export-db-close').addEventListener('click', function(event) {
		document.querySelector('#import-export-db').style.display = 'none';
		sendMessage('closeImportExportDbWindow', {});
	});

	document.querySelector('#save-load-db-menu-close-btn').addEventListener('click', function(event) {
		closeSaveLoadDbMenu();
	});

	document.querySelectorAll('.adjust-speed').forEach(e => e.addEventListener('input', function(event) {
		document.querySelectorAll('.adjust-speed').forEach(e => e.value = this.value);
		document.querySelectorAll('.adjust-input').forEach(e => e.step = this.value);

		sendMessage('setAdjustSpeed', {
			speed: this.value
		});
	}));

	document.querySelectorAll('.rotate-speed').forEach(e => e.addEventListener('input', function(event) {
		document.querySelectorAll('.rotate-speed').forEach(e => e.value = this.value);
		document.querySelectorAll('.rotate-input').forEach(e => e.step = this.value);

		sendMessage('setRotateSpeed', {
			speed: this.value
		});
	}));

	document.querySelector('#help-menu-close-btn').addEventListener('click', function(event) {
		closeHelpMenu();
	});

	document.querySelector('#spawn-menu-peds').addEventListener('click', function(event) {
		openPedMenu();
	});

	document.querySelector('#spawn-menu-vehicles').addEventListener('click', function(event) {
		openVehicleMenu();
	});

	document.querySelector('#spawn-menu-objects').addEventListener('click', function(event) {
		openObjectMenu();
	});

	document.querySelector('#spawn-menu-propsets').addEventListener('click', function(event) {
		openPropsetMenu();
	});

	document.querySelector('#spawn-menu-pickups').addEventListener('click', function(event) {
		openPickupMenu();
	});

	document.querySelector('#spawn-menu-close').addEventListener('click', function(event) {
		closeSpawnMenu();
	});

	document.querySelector('#properties-get-in').addEventListener('click', function(event) {
		closePropertiesMenu(true);
		getIntoVehicle(currentEntity())
	});

	document.querySelector('#properties-repair-vehicle').addEventListener('click', function(event) {
		sendMessage('repairVehicle', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-request-control').addEventListener('click', function(event) {
		sendMessage('requestControl', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-attach').addEventListener('click', function(event) {
		closePropertiesMenu(false);
		sendMessage('getDatabase', {handle: currentEntity()}).then(resp => resp.json()).then(resp => openAttachToMenu(currentEntity(), resp));
	});

	document.querySelector('#attachment-options-menu-close').addEventListener('click', function(event) {
		document.querySelector('#attachment-options-menu').style.display = 'none';
		sendMessage('openPropertiesMenuForEntity', {
			entity: currentEntity()
		});

	});

	document.querySelector('#attachment-options-detach').addEventListener('click', function(event) {
		document.querySelector('#attachment-options-menu').style.display = 'none';
		sendMessage('detach', {
			handle: currentEntity()
		});
		sendMessage('getDatabase', {handle: currentEntity()}).then(resp => resp.json()).then(resp => openAttachToMenu(currentEntity(), resp));
	});

	document.querySelectorAll('.set-attach').forEach(e => e.addEventListener('input', function(event) {
		sendMessage('attachTo', {
			from: currentEntity(),
			to: null,
			bone: parseInt(document.querySelector('#attachment-bone').value),
			x: parseFloat(document.querySelector('#attachment-x').value),
			y: parseFloat(document.querySelector('#attachment-y').value),
			z: parseFloat(document.querySelector('#attachment-z').value),
			pitch: parseFloat(document.querySelector('#attachment-pitch').value),
			roll: parseFloat(document.querySelector('#attachment-roll').value),
			yaw: parseFloat(document.querySelector('#attachment-yaw').value),
			keepPos: false
		});
	}));

	document.querySelector('#properties-health').addEventListener('input', function(event) {
		sendMessage('setEntityHealth', {
			handle: currentEntity(),
			health: parseInt(this.value)
		});
	});

	document.querySelector('#properties-visible').addEventListener('click', function(event) {
		sendMessage('setEntityVisible', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-invisible').addEventListener('click', function(event) {
		sendMessage('setEntityInvisible', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-gravity-on').addEventListener('click', function(event) {
		sendMessage('gravityOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-gravity-off').addEventListener('click', function(event) {
		sendMessage('gravityOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-scenario').addEventListener('click', function(event) {
		document.querySelector('#ped-options-menu').style.display = 'none';
		document.querySelector('#scenario-menu').style.display = 'flex';
	});

	document.querySelector('#scenario-menu-close').addEventListener('click', function(event) {
		document.querySelector('#scenario-menu').style.display = 'none';
		document.querySelector('#ped-options-menu').style.display = 'flex';
	});

	document.querySelector('#scenario-search-filter').addEventListener('input', function(event) {
		populateScenarioList(this.value);
	});

	document.querySelector('#properties-clear-ped-tasks').addEventListener('click', function(event) {
		sendMessage('clearPedTasks', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-clear-ped-tasks-immediately').addEventListener('click', function(event) {
		sendMessage('clearPedTasksImmediately', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-outfit').addEventListener('input', function(event) {
		sendMessage('setOutfit', {
			handle: currentEntity(),
			outfit: parseInt(this.value)
		});
	});

	document.querySelector('#properties-add-to-group').addEventListener('click', function(event) {
		sendMessage('addToGroup', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-remove-from-group').addEventListener('click', function(event) {
		sendMessage('removeFromGroup', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-collision-on').addEventListener('click', function(event) {
		sendMessage('collisionOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-collision-off').addEventListener('click', function(event) {
		sendMessage('collisionOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-ped-options').addEventListener('click', function(event) {
		document.querySelector('#properties-menu').style.display = 'none';
		document.querySelector('#ped-options-menu').style.display = 'flex';
	});

	document.querySelector('#ped-options-menu-close').addEventListener('click', function(event) {
		document.querySelector('#ped-options-menu').style.display = 'none';
		document.querySelector('#properties-menu').style.display = 'flex';
	});

	document.querySelector('#properties-vehicle-options').addEventListener('click', function(event) {
		document.querySelector('#properties-menu').style.display = 'none';
		document.querySelector('#vehicle-options-menu').style.display = 'flex';
	});

	document.querySelector('#vehicle-options-menu-close').addEventListener('click', function(event) {
		document.querySelector('#vehicle-options-menu').style.display = 'none';
		document.querySelector('#properties-menu').style.display = 'flex';
	});

	document.querySelector('#properties-give-weapon').addEventListener('click', function(event) {
		document.querySelector('#ped-options-menu').style.display = 'none';
		document.querySelector('#weapon-menu').style.display = 'flex';
	});

	document.querySelector('#weapon-search-filter').addEventListener('input', function(event) {
		populateWeaponList(this.value);
	});

	document.querySelector('#properties-remove-all-weapons').addEventListener('click', function(event) {
		sendMessage('removeAllWeapons', {
			handle: currentEntity()
		});
	});

	document.querySelector('#weapon-menu-close').addEventListener('click', function(event) {
		document.querySelector('#weapon-menu').style.display = 'none';
		document.querySelector('#ped-options-menu').style.display = 'flex';
	});

	document.querySelector('#properties-resurrect-ped').addEventListener('click', function(event) {
		sendMessage('resurrectPed', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-get-on-mount').addEventListener('click', function(event) {
		closePropertiesMenu(true);
		sendMessage('getOnMount', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-engine-on').addEventListener('click', function(event) {
		sendMessage('engineOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-engine-off').addEventListener('click', function(event) {
		sendMessage('engineOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-lights-options').addEventListener('click', function(event) {
		document.querySelector('#properties-menu').style.display = 'none';
		document.querySelector('#lights-options-menu').style.display = 'flex';
	});

	document.querySelector('#lights-options-menu-close').addEventListener('click', function(event) {
		document.querySelector('#lights-options-menu').style.display = 'none';
		document.querySelector('#properties-menu').style.display = 'flex';
	});

	document.querySelector('#properties-lights-intensity').addEventListener('input', function(event) {
		sendMessage('setLightsIntensity', {
			handle: currentEntity(),
			intensity: parseFloat(this.value)
		});
	});

	document.querySelectorAll('.lights-colour').forEach(e => e.addEventListener('input', function(event) {
		sendMessage('setLightsColour', {
			handle: currentEntity(),
			red: parseFloat(document.querySelector('#properties-lights-red').value),
			green: parseFloat(document.querySelector('#properties-lights-green').value),
			blue: parseFloat(document.querySelector('#properties-lights-blue').value)
		});
	}));

	document.querySelector('#properties-lights-type').addEventListener('click', function(event) {
		sendMessage('setLightsType', {
			handle: currentEntity(),
			type: parseInt(this.value)
		});
	});

	document.querySelector('#properties-vehicle-lights-on').addEventListener('click', function(event) {
		sendMessage('setVehicleLightsOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-vehicle-lights-off').addEventListener('click', function(event) {
		sendMessage('setVehicleLightsOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-ai-on').addEventListener('click', function(event) {
		sendMessage('aiOn', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-ai-off').addEventListener('click', function(event) {
		sendMessage('aiOff', {
			handle: currentEntity()
		});
	});

	document.querySelector('#properties-animation').addEventListener('click', function(event) {
		document.querySelector('#ped-options-menu').style.display = 'none';
		document.querySelector('#animation-menu').style.display = 'flex';
	});

	document.querySelector('#animation-menu-close').addEventListener('click', function(event) {
		document.querySelector('#animation-menu').style.display = 'none';
		document.querySelector('#ped-options-menu').style.display = 'flex';
	});

	document.querySelector('#animation-search-filter').addEventListener('input', function(event) {
		populateAnimationList(this.value);
	});

	document.querySelector('#animation-search-max-results').addEventListener('input', function(event) {
		populateAnimationList(document.querySelector('#animation-search-filter').value)
	});

	document.querySelector('#pickup-search-filter').addEventListener('input', function(event) {
		populatePickupList(this.value);
	});

	document.getElementById('properties-player-model').addEventListener('click', function(event) {
		document.querySelector('#ped-options-menu').style.display = 'none';
		document.querySelector('#player-model-menu').style.display = 'flex';
	});
});
