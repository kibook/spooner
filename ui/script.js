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
}

function openObjectMenu() {
	document.querySelector('#object-menu').style.display = 'flex';
}

function closeObjectMenu(object) {
	document.querySelector('#object-menu').style.display = 'none';

	if (object) {
		var name = object.innerHTML;

		fetch('https://' + GetParentResourceName() + '/closeObjectMenu', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				object: name
			})
		});

		var objects = document.querySelectorAll('#object-list .object');

		for (i = 0; i < objects.length; ++i) {
			objects[i].className = 'object';
		}

		object.className = 'object selected';
	} else {
		fetch('https://' + GetParentResourceName() + '/closeObjectMenu', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: '{}'
		});
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

function deleteObject(object) {
	var handle = object.getAttribute('data-handle');

	object.remove();

	fetch('https://' + GetParentResourceName() + '/deleteObject', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({
			handle: parseInt(handle)
		})
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
			openPropertiesMenu({
				entity: parseInt(handle)
			});
		});
		div.addEventListener('contextmenu', function(event) {
			deleteObject(this);
		});
		objectList.appendChild(div);
	});

	document.querySelector('#object-database').style.display = 'block';
}

function closeDatabase() {
	document.querySelector('#object-database').style.display = 'none';

	fetch('https://' + GetParentResourceName() + '/closeDatabase', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify({})
	});
}

function removeAllFromDatabase() {
	fetch('https://' + GetParentResourceName() + '/removeAllFromDatabase', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: '{}'
	});

	closeDatabase()
}

function addEntityToDatabase(entity) {
}

function openPropertiesMenu(data) {
	document.querySelector('#properties-menu').style.display = 'block';
	var entity = document.querySelector('#properties-menu-entity-id');
	entity.setAttribute('data-handle', data.entity);
	entity.innerHTML = data.entity.toString(16);

	var properties = JSON.parse(data.properties)

	document.querySelector('#properties-x').value = properties.x;
	document.querySelector('#properties-y').value = properties.y;
	document.querySelector('#properties-z').value = properties.z;

	document.querySelector('#properties-pitch').value = properties.pitch;
	document.querySelector('#properties-roll').value = properties.roll;
	document.querySelector('#properties-yaw').value = properties.yaw;
}

function closePropertiesMenu() {
	document.querySelector('#properties-menu').style.display = 'none';

	fetch('https://' + GetParentResourceName() + '/closePropertiesMenu', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: '{}'
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
		case 'openObjectMenu':
			openObjectMenu();
			break;
		case 'openDatabase':
			openDatabase(event.data);
			break;
		case 'openPropertiesMenu':
			openPropertiesMenu(event.data);
			break;
	}
});

function sendMessage(name, params) {
	fetch('https://' + GetParentResourceName() + '/' + name, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(params)
	});
}

window.addEventListener('load', function() {
	populateObjectList();

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
		var entity = document.querySelector('#properties-menu-entity-id');
		var handle = entity.getAttribute('data-handle');
		var id = parseInt(handle)

		sendMessage('addEntityToDatabase', {
			handle: id,
			name: id.toString(16)
		});
	});

	document.querySelector('#properties-remove-from-db').addEventListener('click', function(event) {
		var entity = document.querySelector('#properties-menu-entity-id');
		var handle = entity.getAttribute('data-handle');

		sendMessage('removeEntityFromDatabase', {
			handle: parseInt(handle)
		});
	});

	document.querySelector('#properties-freeze').addEventListener('click', function(event) {
		var entity = document.querySelector('#properties-menu-entity-id');
		var handle = entity.getAttribute('data-handle');

		fetch('https://' + GetParentResourceName() + '/freezeEntity', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				handle: parseInt(handle)
			})
		});
	});

	document.querySelector('#properties-unfreeze').addEventListener('click', function(event) {
		var entity = document.querySelector('#properties-menu-entity-id');
		var handle = entity.getAttribute('data-handle');

		fetch('https://' + GetParentResourceName() + '/unfreezeEntity', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				handle: parseInt(handle)
			})
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

	document.querySelector('#properties-delete').addEventListener('click', function(event) {
		var entity = document.querySelector('#properties-menu-entity-id');
		var handle = entity.getAttribute('data-handle');

		fetch('https://' + GetParentResourceName() + '/deleteObject', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({
				handle: parseInt(handle)
			})
		});

		closePropertiesMenu();
	});

	document.querySelector('#properties-menu-close-btn').addEventListener('click', function(event) {
		closePropertiesMenu();
	});
});
