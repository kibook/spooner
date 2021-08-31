var peds = [];
var vehicles = [];
var objects = [];
var scenarios = [];
var weapons = [];
var animations = {};
var propsets = [];
var pickups = [];
var walkStyleBases = [];
var walkStyles = [];

var lastSpawnMenu = -1;

var propertiesMenuUpdate;

const favouriteTypes = [
	'peds',
	'vehicles',
	'objects',
	'propsets',
	'pickups',
	'scenarios',
	'animations',
	'weapons',
	'walkStyles',
	'playerModels'
];

var favourites = {};

function sendMessage(name, params) {
	return fetch('https://' + GetParentResourceName() + '/' + name, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(params)
	});
}

function copyToClipboard(text) {
	var e = document.createElement('textarea');
	e.textContent = text;
	document.body.appendChild(e);

	var selection = document.getSelection();
	selection.removeAllRanges();

	e.select();
	document.execCommand('copy');

	selection.removeAllRanges();
	e.remove();
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
			entityId.innerHTML = data.entity.toString() + ' [' + data.netId.toString() + ']';
		} else {
			entityId.innerHTML = data.entity.toString();
		}
		entityInfo.style.display = 'block';

		document.getElementById('basic-controls').style.display = 'none';
		document.getElementById('entity-controls').style.display = 'flex';
	} else {
		entityInfo.style.display = 'none';

		document.getElementById('entity-controls').style.display = 'none';
		document.getElementById('basic-controls').style.display = 'flex';
	}

	var spawnInfo = document.querySelector('#spawn-info');
	var spawnId = document.querySelector('#spawn-id');

	if (data.currentSpawn) {
		spawnId.innerHTML = data.currentSpawn;
		spawnInfo.style.display = 'block';
	} else {
		spawnInfo.style.display = 'none';
	}

	if (data.speedMode == 0) {
		document.querySelector('#speed').innerHTML = `[${data.speed}]`
	} else {
		document.querySelector('#speed').innerHTML = data.speed;
	}

	switch(data.adjustMode) {
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
			document.querySelector('#adjust-mode').innerHTML = 'Free';
			break;
		case 5:
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

	if (data.adjustMode == 4) {
		document.querySelector('#place-on-ground-container').style.display = 'none';
	} else {
		document.querySelector('#place-on-ground-container').style.display = 'block';
	}

	if (data.placeOnGround) {
		document.querySelector('#place-on-ground').innerHTML = 'On';
	} else {
		document.querySelector('#place-on-ground').innerHTML = 'Off';
	}

	document.getElementById('cam-x').innerHTML = data.camX;
	document.getElementById('cam-y').innerHTML = data.camY;
	document.getElementById('cam-z').innerHTML = data.camZ;
	document.getElementById('cam-heading').innerHTML = data.camHeading;
	document.getElementById('cursor-x').innerHTML = data.cursorX;
	document.getElementById('cursor-y').innerHTML = data.cursorY;
	document.getElementById('cursor-z').innerHTML = data.cursorZ;

	if (data.speedMode == 1) {
		document.querySelector('#adjust-speed').innerHTML = `[${data.adjustSpeed.toFixed(3)}]`;
	} else {
		document.querySelector('#adjust-speed').innerHTML = data.adjustSpeed.toFixed(3);
	}

	if (data.speedMode == 2) {
		document.querySelector('#rotate-speed').innerHTML = `[${data.rotateSpeed.toFixed(1)}]`;
	} else {
		document.querySelector('#rotate-speed').innerHTML = data.rotateSpeed.toFixed(1);
	}

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

	var focusInfo = document.getElementById('focus-info');

	if (data.focusTarget) {
		document.getElementById('focus-target').innerHTML = data.focusTarget.toString();
		document.getElementById('focus-mode').innerHTML = data.freeFocus ? 'Free' : 'Fixed';
		focusInfo.style.display = 'block';
	} else {
		focusInfo.style.display = 'none';
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
		var name = selected.getAttribute('data-model');

		sendMessage('closePedMenu', {
			modelName: name
		});

		document.querySelectorAll('#ped-list .object').forEach(e => {
			if (favourites.peds[e.getAttribute('data-model')]) {
				e.className = 'object favourite';
			} else {
				e.className = 'object';
			}
		});
		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closeVehicleMenu(selected) {
	document.querySelector('#vehicle-menu').style.display = 'none';

	if (selected) {
		var name = selected.getAttribute('data-model');

		sendMessage('closeVehicleMenu', {
			modelName: name
		});

		document.querySelectorAll('#vehicle-list .object').forEach(e => {
			if (favourites.vehicles[e.getAttribute('data-model')]) {
				e.className = 'object favourite';
			} else {
				e.className = 'object';
			}
		});
		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closeObjectMenu(selected) {
	document.querySelector('#object-menu').style.display = 'none';

	if (selected) {
		var name = selected.getAttribute('data-model');

		sendMessage('closeObjectMenu', {
			modelName: name
		});

		document.querySelectorAll('#object-list .object').forEach(e => {
			if (favourites.objects[e.getAttribute('data-model')]) {
				e.className = 'object favourite';
			} else {
				e.className = 'object';
			}
		});
		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closePropsetMenu(selected) {
	document.querySelector('#propset-menu').style.display = 'none';

	if (selected) {
		var name = selected.getAttribute('data-model');

		sendMessage('closePropsetMenu', {
			modelName: name
		});

		document.querySelectorAll('#propset-list .object').forEach(e => {
			if (favourites.propsets[e.getAttribute('data-model')]) {
				e.className = 'object favourite';
			} else {
				e.className = 'object';
			}
		});
		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function closePickupMenu(selected) {
	document.querySelector('#pickup-menu').style.display = 'none';

	if (selected) {
		var name = selected.getAttribute('data-model');

		sendMessage('closePickupMenu', {
			modelName: name
		});

		document.querySelectorAll('#pickup-list .object').forEach(e => {
			if (favourites.pickups[e.getAttribute('data-model')]) {
				e.className = 'object favourite';
			} else {
				e.className = 'object';
			}
		});
		selected.className = 'object selected';
	} else {
		document.querySelector('#spawn-menu').style.display = 'flex';
		lastSpawnMenu = -1;
	}
}

function performScenario(scenario) {
	document.querySelectorAll('#scenario-list .object').forEach(e => {
		if (favourites.scenarios[e.getAttribute('data-scenario')]) {
			e.className = 'object favourite';
		} else {
			e.className = 'object';
		}
	});
	scenario.className = 'object selected';

	sendMessage('performScenario', {
		handle: currentEntity(),
		scenario: scenario.getAttribute('data-scenario')
	});
}

function giveWeapon(weapon) {
	sendMessage('giveWeapon', {
		handle: currentEntity(),
		weapon: weapon.getAttribute('data-model')
	});
}

function playAnimation(animation) {
	document.querySelectorAll('#animation-list .object').forEach(e => {
		if (favourites.animations[e.getAttribute('data-dict') + ': ' + e.getAttribute('data-name')]) {
			e.className = 'object favourite';
		} else {
			e.className = 'object';
		}
	});
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

function setWalkStyle(selected) {
	sendMessage('setWalkStyle', {
		handle: currentEntity(),
		base: selected.getAttribute('data-base'),
		style: selected.getAttribute('data-style')
	});

	document.querySelectorAll('#walk-style-list .object').forEach(e => {
		if (favourites.walkStyles[e.getAttribute('data-base') + ': ' + e.getAttribute('data-style')]) {
			e.className = 'object favourite';
		} else {
			e.className = 'object';
		}
	});
	selected.className = 'object selected';
}

function favouriteOnClick(event) {
	removeFavourite(this);
}

function nonFavouriteOnClick(event) {
	addFavourite(this);
}

function addFavourite(selected) {
	var type = selected.getAttribute('data-favourite-type');
	var name = selected.getAttribute('data-favourite-name');

	favourites[type][name] = true;

	sendMessage('saveFavourites', {
		favourites: favourites
	});

	selected.className = 'object favourite';
	selected.removeEventListener('contextmenu', nonFavouriteOnClick);
	selected.addEventListener('contextmenu', favouriteOnClick);
}

function removeFavourite(selected) {
	var type = selected.getAttribute('data-favourite-type');
	var name = selected.getAttribute('data-favourite-name');

	delete favourites[type][name];

	sendMessage('saveFavourites', {
		favourites: favourites
	});

	selected.className = 'object';
	selected.removeEventListener('contextmenu', favouriteOnClick);
	selected.addEventListener('contextmenu', nonFavouriteOnClick);
}

function populatePedList(filter) {
	var pedList = document.getElementById('ped-list');
	var favsOnly = document.getElementById('favourite-peds').hasAttribute('data-active');

	pedList.innerHTML = '';

	peds.forEach(name => {
		var isFav = favourites.peds[name];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', name);
			div.setAttribute('data-favourite-type', 'peds');
			div.setAttribute('data-favourite-name', name);

			div.innerHTML = name;

			div.addEventListener('click', function(event) {
				closePedMenu(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			pedList.appendChild(div);
		}
	});
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
	var pedList = document.getElementById('player-model-list');
	var favsOnly = document.getElementById('favourite-player-models').hasAttribute('data-active');

	pedList.innerHTML = '';

	peds.forEach(name => {
		var isFav = favourites.playerModels[name];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', name);
			div.setAttribute('data-favourite-type', 'playerModels');
			div.setAttribute('data-favourite-name', name);

			div.innerHTML = name;

			div.addEventListener('click', function(event) {
				pedList.querySelectorAll('.object').forEach(e => {
					if (favourites.playerModels[e.getAttribute('data-model')]) {
						e.className = 'object favourite';
					} else {
						e.className = 'object';
					}
				});
				this.className = 'object selected';
				setPlayerModel(this.getAttribute('data-model'));
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			pedList.appendChild(div);
		}
	});
}

function populateVehicleList(filter) {
	var vehicleList = document.getElementById('vehicle-list');
	var favsOnly = document.getElementById('favourite-vehicles').hasAttribute('data-active');

	vehicleList.innerHTML = '';

	vehicles.forEach(name => {
		var isFav = favourites.vehicles[name];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', name);
			div.setAttribute('data-favourite-type', 'vehicles');
			div.setAttribute('data-favourite-name', name);

			div.innerHTML = name;

			div.addEventListener('click', function(event) {
				closeVehicleMenu(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			vehicleList.appendChild(div);
		}
	});
}

function populateObjectList(filter) {
	var objectList = document.getElementById('object-list');
	var favsOnly = document.getElementById('favourite-objects').hasAttribute('data-active');

	objectList.innerHTML = '';

	objects.forEach(name => {
		var isFav = favourites.objects[name];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', name);
			div.setAttribute('data-favourite-type', 'objects');
			div.setAttribute('data-favourite-name', name);

			div.innerHTML = name;

			div.addEventListener('click', function(event) {
				closeObjectMenu(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			objectList.appendChild(div);
		}
	});
}

function populateScenarioList(filter) {
	var scenarioList = document.getElementById('scenario-list');
	var favsOnly = document.getElementById('favourite-scenarios').hasAttribute('data-active');

	scenarioList.innerHTML = '';

	scenarios.forEach(scenario => {
		var isFav = favourites.scenarios[scenario];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || scenario.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-scenario', scenario);
			div.setAttribute('data-favourite-type', 'scenarios');
			div.setAttribute('data-favourite-name', scenario);

			div.innerHTML = scenario;

			div.addEventListener('click', function(event) {
				performScenario(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			scenarioList.appendChild(div);
		}
	});
}

function populateWeaponList(filter) {
	var weaponList = document.getElementById('weapon-list');
	var favsOnly = document.getElementById('favourite-weapons').hasAttribute('data-active');

	weaponList.innerHTML = '';

	weapons.forEach(weapon => {
		var isFav = favourites.weapons[weapon];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || weapon.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', weapon);
			div.setAttribute('data-favourite-type', 'weapons');
			div.setAttribute('data-favourite-name', weapon);

			div.innerHTML = weapon;

			div.addEventListener('click', function(event) {
				giveWeapon(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			weaponList.appendChild(div);
		}
	});
}

function populateAnimationList(filter) {
	var animationList = document.getElementById('animation-list');
	var animationMaxResults = parseInt(document.getElementById('animation-search-max-results').value);
	var favsOnly = document.getElementById('favourite-animations').hasAttribute('data-active');

	animationList.innerHTML = '';

	var results = [];

	Object.keys(animations).forEach(dict => {
		animations[dict].forEach(name => {
			var label = dict + ': ' + name;

			if (favsOnly && !favourites.animations[label]) {
				return;
			}

			if (!filter || filter == '' || label.toLowerCase().includes(filter.toLowerCase())) {
				results.push({
					label: label,
					dict: dict,
					name: name
				})
			}
		});
	});

	results.sort(function(a, b) {
		if (a.label < b.label) {
			return -1;
		}
		if (a.label > b.label) {
			return 1;
		}
		return 0;
	});

	document.getElementById('animation-search-total-results').innerHTML = results.length;

	for (var i = 0; i < results.length && i < animationMaxResults; ++i) {
		var isFav = favourites.animations[results[i].label];

		var div = document.createElement('div');

		if (isFav) {
			div.className = 'object favourite';
		} else {
			div.className = 'object';
		}

		div.setAttribute('data-dict', results[i].dict);
		div.setAttribute('data-name', results[i].name);
		div.setAttribute('data-favourite-type', 'animations');
		div.setAttribute('data-favourite-name', results[i].label);

		div.innerHTML = results[i].label;

		div.addEventListener('click', function() {
			playAnimation(this);
		});

		if (isFav) {
			div.addEventListener('contextmenu', favouriteOnClick);
		} else {
			div.addEventListener('contextmenu', nonFavouriteOnClick);
		}

		animationList.appendChild(div);
	}
}

function populatePropsetList(filter) {
	var propsetList = document.getElementById('propset-list');
	var favsOnly = document.getElementById('favourite-propsets').hasAttribute('data-active');

	propsetList.innerHTML = '';

	propsets.forEach(propset => {
		var isFav = favourites.propsets[propset];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || propset.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', propset);
			div.setAttribute('data-favourite-type', 'propsets');
			div.setAttribute('data-favourite-name', propset);

			div.innerHTML = propset;

			div.addEventListener('click', function(event) {
				closePropsetMenu(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			propsetList.appendChild(div);
		}
	});
}

function populatePickupList(filter) {
	var pickupList = document.getElementById('pickup-list');
	var favsOnly = document.getElementById('favourite-pickups').hasAttribute('data-active');

	pickupList.innerHTML = '';

	pickups.forEach(pickup => {
		var isFav = favourites.pickups[pickup];

		if (favsOnly && !isFav) {
			return;
		}

		if (!filter || filter == '' || pickup.toLowerCase().includes(filter.toLowerCase())) {
			var div = document.createElement('div');

			if (isFav) {
				div.className = 'object favourite';
			} else {
				div.className = 'object';
			}

			div.setAttribute('data-model', pickup);
			div.setAttribute('data-favourite-type', 'pickups');
			div.setAttribute('data-favourite-name', pickup);

			div.innerHTML = pickup;

			div.addEventListener('click', function(event) {
				closePickupMenu(this);
			});

			if (isFav) {
				div.addEventListener('contextmenu', favouriteOnClick);
			} else {
				div.addEventListener('contextmenu', nonFavouriteOnClick);
			}

			pickupList.appendChild(div);
		}
	});
}

function populateBoneNameList() {
	var boneList = document.getElementById('attachment-bone-name');

	boneList.innerHTML = '<option></option>';

	bones.forEach(bone => {
		var option = document.createElement('option');
		option.value = bone;
		option.innerHTML = bone;
		boneList.appendChild(option);
	});
}

function populateWalkStyleList(filter) {
	var walkStyleList = document.getElementById('walk-style-list');
	var favsOnly = document.getElementById('favourite-walk-styles').hasAttribute('data-active');

	walkStyleList.innerHTML = '';

	walkStyleBases.forEach(base => {
		walkStyles.forEach(style => {
			var name = base + ': ' + style;
			var isFav = favourites.walkStyles[name];

			if (favsOnly && !isFav) {
				return;
			}

			if (!filter || filter == '' || name.toLowerCase().includes(filter.toLowerCase())) {
				var div = document.createElement('div');

				if (isFav) {
					div.className = 'object favourite';
				} else {
					div.className = 'object';
				}

				div.setAttribute('data-base', base);
				div.setAttribute('data-style', style);
				div.setAttribute('data-favourite-type', 'walkStyles');
				div.setAttribute('data-favourite-name', name);

				div.innerHTML = name;

				div.addEventListener('click', function(event) {
					setWalkStyle(this);
				});

				if (isFav) {
					div.addEventListener('contextmenu', favouriteOnClick);
				} else {
					div.addEventListener('contextmenu', nonFavouriteOnClick);
				}

				walkStyleList.appendChild(div);
			}
		});
	});
}

function deleteEntity(object) {
	var handle = object.getAttribute('data-handle');

	object.remove();

	sendMessage('deleteEntity', {
		handle: parseInt(handle)
	}).then(resp => resp.json()).then(resp => openDatabase(resp));
}

function entityDisplayName(entity, props) {
	if (props.exists) {
		if (props.netId) {
			if (props.playerName) {
				return `${entity.toString()} [${props.netId.toString()}] ${props.name} (${props.playerName})`;
			} else {
				return `${entity.toString()} [${props.netId.toString()}] ${props.name}`;
			}
		} else {
			return `${entity.toString()} ${props.name}`
		}
	} else {
		return `(Invalid) ${entity.toString()} ${props.name}`
	}
}

function openDatabase(data) {
	var objectList = document.querySelector('#object-database-list');
	var database = JSON.parse(data.database);

	var keys = Object.keys(database);

	var totalEntities = keys.length;
	var totalPeds = 0;
	var totalVehicles = 0;
	var totalObjects = 0;
	var totalNetworked = 0;

	objectList.innerHTML = '';

	keys.forEach(function(handle) {
		var entityId = parseInt(handle);

		switch (database[handle].type) {
			case 1:
				++totalPeds;
				break;
			case 2:
				++totalVehicles;
				break;
			case 3:
				++totalObjects;
				break;
		}

		if (database[handle].netId) {
			++totalNetworked;
		}

		var div = document.createElement('div');

		if (database[handle].isSelf) {
			div.className = 'object self';
		} else if (!database[handle].exists) {
			div.className = 'object invalid';
		} else {
			div.className = 'object'
		}

		div.innerHTML = entityDisplayName(entityId, database[handle]);

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

	document.getElementById('object-database-total-entities').innerHTML = keys.length;
	document.getElementById('object-database-total-peds').innerHTML = totalPeds;
	document.getElementById('object-database-total-vehicles').innerHTML = totalVehicles;
	document.getElementById('object-database-total-objects').innerHTML = totalObjects;
	document.getElementById('object-database-total-networked').innerHTML = totalNetworked;

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
	if (properties.netId) {
		if (properties.playerName) {
			entity.innerHTML = data.entity.toString() + ' [' + properties.netId.toString() + '] (' + properties.playerName + ')';
		} else {
			entity.innerHTML = data.entity.toString() + ' [' + properties.netId.toString() + ']';
		}
	} else {
		entity.innerHTML = data.entity.toString();
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

	if (properties.netId) {
		document.getElementById('properties-request-control').disabled = data.hasNetworkControl || properties.type == 0;
		document.getElementById('properties-register-as-networked').style.display = 'none';
		document.getElementById('properties-request-control').style.display = 'block';
	} else {
		document.getElementById('properties-request-control').style.display = 'none';
		document.getElementById('properties-register-as-networked').style.display = 'block';
	}

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

	if (properties.isVisible) {
		document.getElementById('properties-visible').style.display = 'none';
		document.getElementById('properties-invisible').style.display = 'block';
	} else {
		document.getElementById('properties-invisible').style.display = 'none';
		document.getElementById('properties-visible').style.display = 'block';
	}

	if (properties.scale) {
		setFieldIfInactive('properties-scale', properties.scale);
	} else {
		setFieldIfInactive('properties-scale', 1.0)
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
	var boneName = document.getElementById('attachment-bone-name').value;
	var boneIndex = parseInt(document.getElementById('attachment-bone-index').value);

	sendMessage('attachTo', {
		from: fromEntity,
		to: toEntity,
		bone: boneName == '' ? boneIndex : boneName,
		x: parseFloat(document.getElementById('attachment-x').value),
		y: parseFloat(document.getElementById('attachment-y').value),
		z: parseFloat(document.getElementById('attachment-z').value),
		pitch: parseFloat(document.getElementById('attachment-pitch').value),
		roll: parseFloat(document.getElementById('attachment-roll').value),
		yaw: parseFloat(document.getElementById('attachment-yaw').value),
		keepPos: document.getElementById('attachment-keep-pos').checked,
		useSoftPinning: document.getElementById('attachment-use-soft-pinning').checked,
		collision: document.getElementById('attachment-collision').checked,
		vertex: parseInt(document.getElementById('attachment-vertex').value),
		fixedRot: document.getElementById('attachment-fixed-rot').checked
	});
	sendMessage('getDatabase', {handle: fromEntity}).then(resp => resp.json()).then(resp => openAttachToMenu(fromEntity, resp));
}

function openAttachToMenu(fromEntity, data) {
	var properties = JSON.parse(data.properties);
	var database = JSON.parse(data.database);

	var list = document.getElementById('attach-to-list');

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

		div.innerHTML = entityDisplayName(toEntity, database[handle]);

		div.setAttribute('data-handle', handle);
		div.addEventListener('click', function(event) {
			document.getElementById('attachment-options-menu').style.display = 'none';
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
			div.innerHTML = properties.attachment.to.toString();
		}
		div.addEventListener('click', function(event) {
			document.getElementById('attachment-options-menu').style.display = 'none';
			attachTo(fromEntity, properties.attachment.to);
		});
		list.appendChild(div);
	}

	if (typeof properties.attachment.bone == 'number') {
		document.getElementById('attachment-bone-name').value = '';
		document.getElementById('attachment-bone-index').value = properties.attachment.bone;
	} else {
		document.getElementById('attachment-bone-index').value = '';
		document.getElementById('attachment-bone-name').value = properties.attachment.bone;
	}

	document.getElementById('attachment-x').value = properties.attachment.x;
	document.getElementById('attachment-y').value = properties.attachment.y;
	document.getElementById('attachment-z').value = properties.attachment.z;
	document.getElementById('attachment-pitch').value = properties.attachment.pitch;
	document.getElementById('attachment-roll').value = properties.attachment.roll;
	document.getElementById('attachment-yaw').value = properties.attachment.yaw;
	document.getElementById('attachment-use-soft-pinning').value = properties.attachment.useSoftPinning;
	document.getElementById('attachment-collision').value = properties.attachment.collision;
	document.getElementById('attachment-vertex').value = properties.attachment.vertex;
	document.getElementById('attachment-fixed-rot').value = properties.attachment.fixedRot;

	if (properties.attachment.to) {
		document.getElementById('attachment-options-detach').style.display = 'block';
	} else {
		document.getElementById('attachment-options-detach').style.display = 'none';
	}

	document.getElementById('attachment-options-menu').style.display = 'flex';
}

function updatePermissions(data) {
	var permissions = JSON.parse(data.permissions);

	document.getElementById('spawn-menu-peds').disabled = !permissions.spawn.ped;
	document.getElementById('spawn-menu-vehicles').disabled = !permissions.spawn.vehicle;
	document.getElementById('spawn-menu-objects').disabled = !permissions.spawn.object;
	document.getElementById('spawn-menu-propsets').disabled = !permissions.spawn.propset;
	document.getElementById('spawn-menu-pickups').disabled = !permissions.spawn.pickup;
	document.querySelectorAll('.spawn-by-name').forEach(e => e.disabled = !permissions.spawn.byName);

	document.getElementById('properties-freeze').disabled = !permissions.properties.freeze;
	document.getElementById('properties-unfreeze').disabled = !permissions.properties.freeze;
	document.getElementById('properties-x').disabled = !permissions.properties.position;
	document.getElementById('properties-y').disabled = !permissions.properties.position;
	document.getElementById('properties-z').disabled = !permissions.properties.position;
	document.getElementById('properties-place-here').disabled = !permissions.properties.position;
	document.getElementById('properties-goto').disabled = !permissions.properties.goTo;
	document.getElementById('properties-pitch').disabled = !permissions.properties.rotation;
	document.getElementById('properties-roll').disabled = !permissions.properties.rotation;
	document.getElementById('properties-yaw').disabled = !permissions.properties.rotation;
	document.getElementById('properties-reset-rotation').disabled = !permissions.properties.rotation;
	document.getElementById('properties-health').disabled = !permissions.properties.health;
	document.getElementById('properties-invincible-on').disabled = !permissions.properties.invincible;
	document.getElementById('properties-invincible-off').disabled = !permissions.properties.invincible;
	document.getElementById('properties-visible').disabled = !permissions.properties.visible;
	document.getElementById('properties-invisible').disabled = !permissions.properties.visible;
	document.getElementById('properties-gravity-on').disabled = !permissions.properties.gravity;
	document.getElementById('properties-gravity-off').disabled = !permissions.properties.gravity;
	document.getElementById('properties-collision-off').disabled = !permissions.properties.collision;
	document.getElementById('properties-collision-on').disabled = !permissions.properties.collision;
	document.getElementById('properties-clone').disabled = !permissions.properties.clone;
	document.getElementById('properties-attach').disabled = !permissions.properties.attachments;
	document.getElementById('properties-player-model').disabled = !permissions.properties.ped.changeModel;
	document.getElementById('properties-outfit').disabled = !permissions.properties.ped.outfit;
	document.getElementById('properties-add-to-group').disabled = !permissions.properties.ped.group;
	document.getElementById('properties-remove-from-group').disabled = !permissions.properties.ped.group;
	document.getElementById('properties-scenario').disabled = !permissions.properties.ped.scenario;
	document.getElementById('properties-animation').disabled = !permissions.properties.ped.animation;
	document.getElementById('properties-clear-ped-tasks').disabled = !permissions.properties.ped.clearTasks;
	document.getElementById('properties-clear-ped-tasks-immediately').disabled = !permissions.properties.ped.clearTasks;
	document.getElementById('properties-give-weapon').disabled = !permissions.properties.ped.weapon;
	document.getElementById('properties-remove-all-weapons').disabled = !permissions.properties.ped.weapon;
	document.getElementById('properties-set-on-mount').disabled = !permissions.properties.ped.mount;
	document.getElementById('properties-resurrect-ped').disabled = !permissions.properties.ped.resurrect;
	document.getElementById('properties-ai-on').disabled = !permissions.properties.ped.ai;
	document.getElementById('properties-ai-off').disabled = !permissions.properties.ped.ai;
	document.getElementById('properties-knock-off-props').disabled = !permissions.properties.ped.knockOffProps;
	document.getElementById('properties-clone-ped').disabled = !permissions.properties.clone;
	document.getElementById('properties-clone-to-target').disabled = !permissions.properties.ped.cloneToTarget;
	document.getElementById('properties-repair-vehicle').disabled = !permissions.properties.vehicle.repair;
	document.getElementById('properties-get-in').disabled = !permissions.properties.vehicle.getin
	document.getElementById('properties-engine-on').disabled = !permissions.properties.vehicle.engine
	document.getElementById('properties-engine-off').disabled = !permissions.properties.vehicle.engine
	document.getElementById('properties-vehicle-lights-on').disabled = !permissions.properties.vehicle.lights;
	document.getElementById('properties-vehicle-lights-off').disabled = !permissions.properties.vehicle.lights;
	document.getElementById('properties-register-as-networked').disabled = !permissions.properties.registerAsNetworked;
	document.getElementById('add-to-db-btn').disabled = permissions.maxEntities || !permissions.modify.other;
}

function currentEntity() {
	return parseInt(document.querySelector('#properties-menu-entity-id').getAttribute('data-handle'));
}

function openEntitySelect(menuId, onEntitySelect, ignoreEntity) {
	var menu = document.getElementById(menuId);

	var entitySelect = document.getElementById('entity-select-menu');
	entitySelect.innerHTML = '';

	var entitySelectClose = document.createElement('button');
	entitySelectClose.innerHTML = 'Back';
	entitySelectClose.addEventListener('click', event => {
		entitySelect.style.display = 'none';
		menu.style.display = 'flex';
	});

	var entitySelectList = document.createElement('div');
	entitySelectList.className = 'list';

	sendMessage('getDatabase', {}).then(resp => resp.json()).then(resp => {
		var database = JSON.parse(resp.database);

		Object.keys(database).forEach(key => {
			var handle = parseInt(key);

			if (handle != ignoreEntity) {
				var div = document.createElement('div');
				div.className = 'object';

				div.innerHTML = entityDisplayName(handle, database[key]);

				div.addEventListener('click', event => {
					onEntitySelect(handle);
					entitySelect.style.display = 'none';
					menu.style.display = 'flex';
				});

				entitySelectList.appendChild(div);
			}
		});

		entitySelect.appendChild(entitySelectList);
		entitySelect.appendChild(entitySelectClose);

		menu.style.display = 'none';
		entitySelect.style.display = 'flex';
	});
}

function showControls() {
	document.getElementById('controls').style.display = 'flex';
}

function hideControls() {
	document.getElementById('controls').style.display = 'none';
}

function populatePedConfigFlagsList(flags) {
	var configFlagsList = document.getElementById('config-flags-list');

	configFlagsList.innerHTML = '';

	Object.keys(flags).forEach(key => {
		var flag = flags[key];

		var div = document.createElement('div');
		if (flag.value) {
			div.className = 'config-flag on';
		} else {
			div.className = 'config-flag off';
		}

		var flagDiv = document.createElement('div');
		flagDiv.className = 'config-flag-number';
		flagDiv.innerHTML = key;

		var descrDiv = document.createElement('div');
		descrDiv.className = 'config-flag-descr';
		descrDiv.innerHTML = flag.descr;

		var setDiv = document.createElement('div');
		setDiv.className = 'config-flag-set';

		var setButton = document.createElement('button');
		if (flag.value) {
			setButton.innerHTML = '<i class="fas fa-toggle-on"></i>';
			setButton.addEventListener('click', event => {
				sendMessage('setPedConfigFlag', {
					handle: currentEntity(),
					flag: parseInt(key),
					value: false
				}).then(resp => resp.json()).then(resp => populatePedConfigFlagsList(resp));
			});
		} else {
			setButton.innerHTML = '<i class="fas fa-toggle-off"></i>';
			setButton.addEventListener('click', event => {
				sendMessage('setPedConfigFlag', {
					handle: currentEntity(),
					flag: parseInt(key),
					value: true
				}).then(resp => resp.json()).then(resp => populatePedConfigFlagsList(resp));
			});
		}

		setDiv.appendChild(setButton);

		div.appendChild(flagDiv);
		div.appendChild(descrDiv);
		div.appendChild(setDiv);

		configFlagsList.appendChild(div);
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
		case 'updatePermissions':
			updatePermissions(event.data);
			break;
		case 'showControls':
			showControls();
			break;
		case 'hideControls':
			hideControls();
			break;
	}
});

window.addEventListener('load', function() {
	sendMessage('init', {}).then(resp => resp.json()).then(function(resp) {
		if (resp.favourites) {
			favourites = resp.favourites;
		}

		favouriteTypes.forEach(type => {
			if (!favourites[type] || Array.isArray(favourites[type])) {
				favourites[type] = {};
			}
		});

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

		bones = JSON.parse(resp.bones);
		populateBoneNameList();

		walkStyleBases = JSON.parse(resp.walkStyleBases);
		walkStyles = JSON.parse(resp.walkStyles);
		populateWalkStyleList();

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

	document.querySelector('#object-database-delete-all-btn').addEventListener('click', function(event) {
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
		var boneName = document.getElementById('attachment-bone-name').value;
		var boneIndex = parseInt(document.getElementById('attachment-bone-index').value);

		sendMessage('attachTo', {
			from: currentEntity(),
			to: null,
			bone: boneName == '' ? boneIndex : boneName,
			x: parseFloat(document.getElementById('attachment-x').value),
			y: parseFloat(document.getElementById('attachment-y').value),
			z: parseFloat(document.getElementById('attachment-z').value),
			pitch: parseFloat(document.getElementById('attachment-pitch').value),
			roll: parseFloat(document.getElementById('attachment-roll').value),
			yaw: parseFloat(document.getElementById('attachment-yaw').value),
			useSoftPinning: document.getElementById('attachment-use-soft-pinning').checked,
			collision: document.getElementById('attachment-collision').checked,
			vertex: parseInt(document.getElementById('attachment-vertex').value),
			fixedRot: document.getElementById('attachment-fixed-rot').checked,
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

	document.getElementById('properties-knock-off-props').addEventListener('click', function(event) {
		sendMessage('knockOffProps', {
			handle: currentEntity()
		});
	});

	document.getElementById('walk-style-search-filter').addEventListener('input', function(event) {
		populateWalkStyleList(this.value);
	});

	document.getElementById('properties-walk-style').addEventListener('click', function(event) {
		document.getElementById('ped-options-menu').style.display = 'none';
		document.getElementById('walk-style-menu').style.display = 'flex';
	});

	document.getElementById('walk-style-menu-close').addEventListener('click', function(event) {
		document.getElementById('walk-style-menu').style.display = 'none';
		document.getElementById('ped-options-menu').style.display = 'flex';
	});

	document.getElementById('store-deleted').addEventListener('input', function(event) {
		sendMessage('setStoreDeleted', {
			toggle: this.checked
		});
	});

	document.getElementById('properties-clone-to-target').addEventListener('click', function(event) {
		var handle = currentEntity();
		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('clonePedToTarget', {
				handle: handle,
				target: entity
			});
		}, handle);
	});

	document.getElementById('properties-look-at-entity').addEventListener('click', function(event) {
		var handle = currentEntity();
		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('lookAtEntity', {
				handle: handle,
				target: entity
			});
		}, handle);
	});

	document.getElementById('properties-clear-look-at').addEventListener('click', function(event) {
		sendMessage('clearLookAt', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-set-on-mount').addEventListener('click', function(event) {
		var handle = currentEntity();
		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('setOnMount', {
				handle: handle,
				entity: entity
			});
		}, handle);
	});

	document.getElementById('properties-enter-vehicle').addEventListener('click', function(event) {
		var handle = currentEntity();
		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('enterVehicle', {
				handle: handle,
				entity: entity
			});
		}, handle);
	});

	document.getElementById('properties-register-as-networked').addEventListener('click', function(event) {
		sendMessage('registerAsNetworked', {
			handle: currentEntity()
		});
	});

	document.querySelectorAll('.favourites').forEach(e => e.addEventListener('click', function(event) {
		var active = this.hasAttribute('data-active');

		if (active) {
			this.removeAttribute('data-active');
			this.innerHTML = '<i class="far fa-star"></i>';
			this.style.color = null;
		} else {
			this.setAttribute('data-active', '');
			this.innerHTML = '<i class="fas fa-star"></i>';
			this.style.color = 'gold';
		}

		switch (this.id) {
			case 'favourite-peds':
				populatePedList(document.getElementById('ped-search-filter').value);
				break;
			case 'favourite-vehicles':
				populateVehicleList(document.getElementById('vehicle-search-filter').value);
				break;
			case 'favourite-objects':
				populateObjectList(document.getElementById('object-search-filter').value);
				break;
			case 'favourite-player-models':
				populatePlayerModelList(document.getElementById('player-model-search-filter').value);
				break;
			case 'favourite-weapons':
				populateWeaponList(document.getElementById('weapon-search-filter').value);
				break;
			case 'favourite-scenarios':
				populateScenarioList(document.getElementById('scenario-search-filter').value);
				break;
			case 'favourite-animations':
				populateAnimationList(document.getElementById('animation-search-filter').value);
				break;
			case 'favourite-propsets':
				populatePropsetList(document.getElementById('propset-search-filter').value);
				break;
			case 'favourite-pickups':
				populatePickupList(document.getElementById('pickup-search-filter').value);
				break;
			case 'favourite-walk-styles':
				populateWalkStyleList(document.getElementById('walk-style-search-filter').value);
				break;
		}
	}));

	document.getElementById('import-export-format').addEventListener('input', function(event) {
		var importButton = document.getElementById('import-db');

		switch (this.value) {
			case 'spooner-db-json':
				importButton.disabled = false;
				break;
			case 'map-editor-xml':
				importButton.disabled = true;
				break;
			case 'propplacer':
				importButton.disabled = true;
				break;
			case 'backup':
				importButton.disabled = false;
				break;
		}
	});

	document.getElementById('properties-clean').addEventListener('click', function(event) {
		sendMessage('cleanPed', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-scale').addEventListener('input', function(event) {
		sendMessage('setScale', {
			handle: currentEntity(),
			scale: parseFloat(this.value)
		});
	});

	document.getElementById('properties-select').addEventListener('click', function(event) {
		sendMessage('selectEntity', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-clone-ped').addEventListener('click', function(event) {
		sendMessage('clonePed', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-config-flags').addEventListener('click', function(event) {
		sendMessage('getPedConfigFlags', {
			handle: currentEntity()
		}).then(resp => resp.json()).then(resp => {
			populatePedConfigFlagsList(resp);
			document.getElementById('ped-options-menu').style.display = 'none';
			document.getElementById('config-flags-menu').style.display = 'flex';
		});
	});

	document.getElementById('close-config-flags-menu').addEventListener('click', function(event) {
		document.getElementById('config-flags-menu').style.display = 'none';
		document.getElementById('ped-options-menu').style.display = 'flex';
	});

	document.getElementById('add-config-flag').addEventListener('click', function(event) {
		var flag = parseInt(document.getElementById('config-flag').value);

		sendMessage('setPedConfigFlag', {
			handle: currentEntity(),
			flag: flag,
			value: true
		}).then(resp => resp.json()).then(resp => populatePedConfigFlagsList(resp));
	});

	document.getElementById('animation-stop').addEventListener('click', function(event) {
		sendMessage('clearPedTasks', {
			handle: currentEntity()
		});
	});

	document.getElementById('scenario-stop').addEventListener('click', function(event) {
		sendMessage('clearPedTasks', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-go-to-waypoint').addEventListener('click', function(event) {
		sendMessage('goToWaypoint', {
			handle: currentEntity()
		});
	});

	document.getElementById('properties-go-to-entity').addEventListener('click', function(event) {
		var handle = currentEntity();
		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('pedGoToEntity', {
				handle: handle,
				entity: entity
			});
		}, handle);
	});

	document.getElementById('properties-focus').addEventListener('click', function(event) {
		sendMessage('focusEntity', {
			handle: currentEntity()
		});
	});

	document.getElementById('copy-position').addEventListener('click', function(event) {
		var x = document.getElementById('properties-x').value;
		var y = document.getElementById('properties-y').value;
		var z = document.getElementById('properties-z').value;

		copyToClipboard(x + ', ' + y + ', ' + z)
	});

	document.getElementById('copy-rotation').addEventListener('click', function(event) {
		var p = document.getElementById('properties-pitch').value;
		var r = document.getElementById('properties-roll').value;
		var y = document.getElementById('properties-yaw').value;

		copyToClipboard(p + ', ' + r + ', ' + y);
	});

	document.getElementById('copy-attachment-position').addEventListener('click', function(event) {
		var x = document.getElementById('attachment-x').value;
		var y = document.getElementById('attachment-y').value;
		var z = document.getElementById('attachment-z').value;

		copyToClipboard(x + ', ' + y + ', ' + z)
	});

	document.getElementById('copy-model-name').addEventListener('click', function(event) {
               var modelname = document.getElementById('properties-model').innerText;
               copyToClipboard(modelname)
       });

	document.getElementById('copy-attachment-rotation').addEventListener('click', function(event) {
		var p = document.getElementById('attachment-pitch').value;
		var r = document.getElementById('attachment-roll').value;
		var y = document.getElementById('attachment-yaw').value;

		copyToClipboard(p + ', ' + r + ', ' + y);
	});

	document.getElementById('add-to-db-btn').addEventListener('click', function(event) {
		document.getElementById('object-database').style.display = 'none';
		document.getElementById('add-to-db-menu').style.display = 'flex';
	});

	document.getElementById('add-to-db-menu-close').addEventListener('click', function(event) {
		document.getElementById('add-to-db-menu').style.display = 'none';
		document.getElementById('object-database').style.display = 'flex';
	});

	document.getElementById('add-custom-entity-btn').addEventListener('click', function(event) {
		sendMessage('addCustomEntityToDatabase', {
			handle: parseInt(document.getElementById('custom-entity-handle').value)
		}).then(resp => resp.json()).then(resp => {
			document.getElementById('add-to-db-menu').style.display = 'none';
			openDatabase(resp);
		});
	});

	document.getElementById('properties-attack').addEventListener('click', function(event) {
		let handle = currentEntity();

		openEntitySelect('ped-options-menu', function(entity) {
			sendMessage('attackPed', {
				handle: handle,
				ped: entity
			});
		}, handle);
	});
});
