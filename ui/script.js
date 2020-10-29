var peds = [];
var vehicles = [];
var objects = [];

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
}

function openSpawnMenu() {
	document.querySelector('#spawn-menu').style.display = 'flex';
}

function closeSpawnMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	sendMessage('closeSpawnMenu', {})
}

function openPedMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#ped-menu').style.display = 'flex';
}

function openVehicleMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#vehicle-menu').style.display = 'flex';
}

function openObjectMenu() {
	document.querySelector('#spawn-menu').style.display = 'none';
	document.querySelector('#object-menu').style.display = 'flex';
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
		sendMessage('closePedMenu', {});
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
		sendMessage('closeVehicleMenu', {});
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
		sendMessage('closeObjectMenu', {});
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
		var div = document.createElement('div');
		div.className = 'object';
		div.innerHTML = database[handle].name;
		div.setAttribute('data-handle', handle);
		div.addEventListener('click', function(event) {
			document.querySelector('#object-database').style.display = 'none';
			sendMessage('openPropertiesMenuForEntity', {
				entity: parseInt(handle)
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

function openPropertiesMenu(data) {
	document.querySelector('#properties-menu').style.display = 'block';

	var properties = JSON.parse(data.properties)

	switch (properties.type) {
		case 1:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'ped';
			break;
		case 2:
			document.querySelector('#properties-menu-entity-type').innerHTML = 'vehicle';
			document.querySelector('#properties-get-in-container').style.display = 'block';
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

function closePropertiesMenu() {
	document.querySelector('#properties-menu').style.display = 'none';

	sendMessage('closePropertiesMenu', {});
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
	document.querySelector('#properties-menu').style.display = 'none';
	sendMessage('goToEntity', {
		handle: handle
	});
}

function openHelpMenu() {
	document.querySelector('#help-menu').style.display = 'block';
}

function closeHelpMenu() {
	document.querySelector('#help-menu').style.display = 'none';
	sendMessage('closeHelpMenu', {});
}

function getIntoVehicle(handle) {
	document.querySelector('#properties-menu').style.display = 'none';
	sendMessage('getIntoVehicle', {
		handle: handle
	});
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

		document.querySelector('#position-step').value = resp.adjustSpeed;
		document.querySelector('#properties-x').step = resp.adjustSpeed;
		document.querySelector('#properties-y').step = resp.adjustSpeed;
		document.querySelector('#properties-z').step = resp.adjustSpeed;

		document.querySelector('#rotation-step').value = resp.rotateSpeed;
		document.querySelector('#properties-pitch').step = resp.rotateSpeed;
		document.querySelector('#properties-roll').step = resp.rotateSpeed;
		document.querySelector('#properties-yaw').step = resp.rotateSpeed;
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
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#properties-add-to-db').style.display = 'none';
			document.querySelector('#properties-remove-from-db').style.display = 'block';
		});
	});

	document.querySelector('#properties-remove-from-db').addEventListener('click', function(event) {
		sendMessage('removeEntityFromDatabase', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		}).then(resp => resp.json()).then(function(resp) {
			document.querySelector('#properties-add-to-db').style.display = 'block';
			document.querySelector('#properties-remove-from-db').style.display = 'none';
		});
	});

	document.querySelector('#properties-freeze').addEventListener('click', function(event) {
		sendMessage('freezeEntity', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
	});

	document.querySelector('#properties-unfreeze').addEventListener('click', function(event) {
		sendMessage('unfreezeEntity', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
	});

	document.querySelectorAll('.set-coords').forEach(function(e) {
		e.addEventListener('input', function(event) {
			sendMessage('setEntityCoords', {
				handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle')),
				x: parseFloat(document.querySelector('#properties-x').value),
				y: parseFloat(document.querySelector('#properties-y').value),
				z: parseFloat(document.querySelector('#properties-z').value)
			});
		});
	});

	document.querySelector('#properties-place-here').addEventListener('click', function(event) {
		sendMessage('placeEntityHere', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
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
		goToEntity(parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle')));
	});

	document.querySelectorAll('.set-rotation').forEach(function(e) {
		e.addEventListener('input', function(event) {
			sendMessage('setEntityRotation', {
				handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle')),
				pitch: parseFloat(document.querySelector('#properties-pitch').value),
				roll: parseFloat(document.querySelector('#properties-roll').value),
				yaw: parseFloat(document.querySelector('#properties-yaw').value)
			});
		});
	});

	document.querySelector('#properties-reset-rotation').addEventListener('click', function(event) {
		sendMessage('resetRotation', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
		document.querySelector('#properties-pitch').value = 0.0;
		document.querySelector('#properties-roll').value = 0.0;
		document.querySelector('#properties-yaw').value = 0.0;
	});

	document.querySelector('#properties-invincible-on').addEventListener('click', function(event) {
		sendMessage('invincibleOn', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
	});

	document.querySelector('#properties-invincible-off').addEventListener('click', function(event) {
		sendMessage('invincibleOff', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
	});

	document.querySelector('#properties-clone').addEventListener('click', function(event) {
		sendMessage('cloneEntity', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});
	});

	document.querySelector('#properties-delete').addEventListener('click', function(event) {
		sendMessage('deleteEntity', {
			handle: parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'))
		});

		closePropertiesMenu();
	});

	document.querySelector('#properties-menu-close-btn').addEventListener('click', function(event) {
		closePropertiesMenu();
	});

	document.querySelector('#save-db-btn').addEventListener('click', function(event) {
		sendMessage('saveDb', {
			name: document.querySelector('#save-db-name').value
		}).then(resp => resp.json()).then(resp => updateDbList(resp));
	});

	document.querySelector('#save-load-db-menu-close-btn').addEventListener('click', function(event) {
		closeSaveLoadDbMenu();
	});

	document.querySelector('#position-step').addEventListener('input', function(event) {
		document.querySelector('#properties-x').step = this.value;
		document.querySelector('#properties-y').step = this.value;
		document.querySelector('#properties-z').step = this.value;

		sendMessage('setAdjustSpeed', {
			speed: this.value
		});
	});

	document.querySelector('#rotation-step').addEventListener('input', function(event) {
		document.querySelector('#properties-pitch').step = this.value;
		document.querySelector('#properties-roll').step = this.value;
		document.querySelector('#properties-yaw').step = this.value;

		sendMessage('setRotateSpeed', {
			speed: this.value
		});
	});

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
		getIntoVehicle(parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle')));
	});
});
