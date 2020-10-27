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

	if (data.entity) {
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

	if (data.currentObject) {
		spawnId.innerHTML = data.currentObject;
		spawnInfo.style.display = 'block';
	} else {
		spawnInfo.style.display = 'none';
	}

	document.querySelector('#speed').innerHTML = data.speed;

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

	switch(data.adjustMode) {
		case -1:
			document.querySelector('#adjust-mode').innerHTML = 'Ground';
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
			document.querySelector('#adjust-mode').innerHTML = 'Off';
			break;

	}
}

function openObjectMenu() {
	document.querySelector('#object-menu').style.display = 'flex';
}

function closeObjectMenu(object) {
	document.querySelector('#object-menu').style.display = 'none';

	if (object) {
		var name = object.innerHTML;

		sendMessage('closeObjectMenu', {
			object: name
		});

		var objects = document.querySelectorAll('#object-list .object');

		for (i = 0; i < objects.length; ++i) {
			objects[i].className = 'object';
		}

		object.className = 'object selected';
	} else {
		sendMessage('closeObjectMenu', {});
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
	var entity = document.querySelector('#properties-menu-entity-id');
	entity.setAttribute('data-handle', data.entity);
	entity.innerHTML = data.entity.toString(16);

	var properties = JSON.parse(data.properties)

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

function updateDbList(data) {
	var databaseNames = JSON.parse(data);
	var dbList = document.querySelector('#db-list');

	dbList.innerHTML = '';

	databaseNames.forEach(function(name) {
		var div = document.createElement('div');
		div.className = 'database';
		div.innerHTML = name;
		div.addEventListener('click', function(event) {
			sendMessage('loadDb', {
				name: this.innerHTML
			});
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
	document.querySelector('#save-load-db-menu').style.display = 'block';
}

function closeSaveLoadDbMenu() {
	document.querySelector('#save-load-db-menu').style.display = 'none';
	sendMessage('closeSaveLoadDbMenu', {});
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
		case 'openObjectMenu':
			openObjectMenu();
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
	}
});

window.addEventListener('load', function() {
	sendMessage('init', {}).then(resp => resp.json()).then(function(resp) {
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

	document.querySelector('#search-filter').addEventListener('input', function(event) {
		populateObjectList(this.value);
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
});
