var peds = [];
var vehicles = [];
var objects = [];

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
	
	if (data.entity) {
		entityId.innerHTML = data.entity.toString(16);
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
		div.className = 'object';
		div.innerHTML = entityId.toString(16) + ' ' + database[handle].name;
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

function updatePropertiesMenu(data) {
	var properties = JSON.parse(data.properties);

	document.querySelectorAll('.vehicle-property').forEach(e => e.style.display = 'none');

	switch (properties.type) {
		case 1:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'ped';
			break;
		case 2:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'vehicle';
			document.querySelectorAll('.vehicle-property').forEach(e => e.style.display = 'block');
			break;
		case 3:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'object';
			break;
		default:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'entity';
			break;
	}

	var entity = document.querySelector('#properties-menu-entity-id');
	entity.setAttribute('data-handle', data.entity);
	entity.innerHTML = data.entity.toString(16);

	document.querySelector('#properties-model').innerHTML = properties.name;

	document.querySelector('#properties-x').value = properties.x;
	document.querySelector('#properties-y').value = properties.y;
	document.querySelector('#properties-z').value = properties.z;

	document.querySelector('#properties-pitch').value = properties.pitch;
	document.querySelector('#properties-roll').value = properties.roll;
	document.querySelector('#properties-yaw').value = properties.yaw;

	if (data.inDb) {
		document.querySelector('#properties-add-to-db').style.display = 'none';
		document.querySelector('#properties-remove-from-db').style.display = 'block';
	} else {
		document.querySelector('#properties-add-to-db').style.display = 'block';
		document.querySelector('#properties-remove-from-db').style.display = 'none';
	}
}

function sendUpdatePropertiesMenuMessage(handle, open) {
	sendMessage('updatePropertiesMenu', {
		handle: handle
	}).then(resp => resp.json()).then(function(resp){
		updatePropertiesMenu(resp);

		if (open) {
			document.querySelector('#properties-menu').style.display = 'block';
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

	clearInterval(propertiesMenuUpdate);

	if (loseFocus) {
		sendMessage('closePropertiesMenu', {});
	}
}

function loadDatabase(name) {
	var relative = document.querySelector('#load-db-relative').checked;

	sendMessage('loadDb', {
		name: name,
		relative: relative
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
	}
});

window.addEventListener('load', function() {
	sendMessage('init', {}).then(resp => resp.json()).then(function(resp) {
		peds = JSON.parse(resp.peds);
		populatePedList();

		vehicles = JSON.parse(resp.vehicles);
		populateVehicleList();

		objects = JSON.parse(resp.objects);
		populateObjectList();

		document.querySelectorAll('.adjust-speed').forEach(e => e.value = resp.adjustSpeed);
		document.querySelectorAll('.adjust-input').forEach(e => e.step = resp.adjustSpeed);

		document.querySelectorAll('.rotate-speed').forEach(e => e.value = resp.rotateSpeed);
		document.querySelectorAll('.rotate-input').forEach(e => e.step = resp.rotateSpeed);
	});

	document.querySelector('#ped-search-filter').addEventListener('input', function(event) {
		populatePedList(this.value);
	});

	document.querySelector('#vehicle-search-filter').addEventListener('input', function(event) {
		populateVehicleList(this.value);
	});
	document.querySelector('#object-search-filter').addEventListener('input', function(event) {
		populateObjectList(this.value);
	});

	document.querySelector('#ped-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#ped-menu').style.display = 'none';

		sendMessage('closePedMenu', {
			modelName: document.querySelector('#ped-search-filter').value
		});
	});

	document.querySelector('#vehicle-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#vehicle-menu').style.display = 'none';

		sendMessage('closevehicleMenu', {
			modelName: document.querySelector('#vehicle-search-filter').value
		});
	});

	document.querySelector('#object-spawn-by-name').addEventListener('click', function(event) {
		document.querySelector('#object-menu').style.display = 'none';

		sendMessage('closeObjectMenu', {
			modelName: document.querySelector('#object-search-filter').value
		});
	});

	document.querySelector('#ped-menu-close-btn').addEventListener('click', function(event) {
		closePedMenu();
	});

	document.querySelector('#vehicle-menu-close-btn').addEventListener('click', function(event) {
		closeVehicleMenu();
	});

	document.querySelector('#object-menu-close-btn').addEventListener('click', function(event) {
		closeObjectMenu();
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

	document.querySelector('#export-db-btn').addEventListener('click', function(event) {
		sendMessage('exportDb', {
			name: document.querySelector('#save-db-name').value
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#exported-db-content').value = resp.content;
			document.querySelector('#save-load-db-menu').style.display = 'none';
			document.querySelector('#exported-db').style.display = 'flex';
		});
	});

	document.querySelector('#exported-db-close').addEventListener('click', function(event) {
		document.querySelector('#exported-db').style.display = 'none';
		sendMessage('closeExportedDbWindow', {});
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
});
