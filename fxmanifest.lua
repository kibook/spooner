-- Set this to one of the following:
-- FiveM: "gta5"
-- RedM: "rdr3"
local gameName = ""

fx_version "cerulean"
game(gameName)
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

name "spooner"
author "kibukj"
description "Entity spawner for FiveM and RedM"
repository "https://github.com/kibook/spooner"

dependency "logmanager"

files {
	"ui/index.html",
	"ui/style.css",
	"ui/script.js",
	"ui/keyboard.ttf"
}

ui_page "ui/index.html"

shared_scripts {
	"config.lua"
}

server_scripts {
	"server.lua"
}

if gameName == "rdr3" then
	dependency "uiprompt"

	files {
		"ui/chineserocks.ttf",
		"ui/rdr3.css"
	}

	client_script "@uiprompt/uiprompt.lua"

	client_scripts {
		"data/rdr3/animations.lua",
		"data/rdr3/bones.lua",
		"data/rdr3/objects.lua",
		"data/rdr3/pedConfigFlags.lua",
		"data/rdr3/peds.lua",
		"data/rdr3/pickups.lua",
		"data/rdr3/propsets.lua",
		"data/rdr3/scenarios.lua",
		"data/rdr3/vehicles.lua",
		"data/rdr3/walkstyles.lua",
		"data/rdr3/weapons.lua"
	}
elseif gameName == "gta5" then
	files {
		"ui/pricedown.otf",
		"ui/gta5.css"
	}

	client_scripts {
		"data/gta5/animations.lua",
		"data/gta5/bones.lua",
		"data/gta5/objects.lua",
		"data/gta5/pedConfigFlags.lua",
		"data/gta5/peds.lua",
		"data/gta5/pickups.lua",
		"data/gta5/propsets.lua",
		"data/gta5/scenarios.lua",
		"data/gta5/vehicles.lua",
		"data/gta5/walkstyles.lua",
		"data/gta5/weapons.lua"
	}
else
	print("WARNING: spooner has not been configured. Please edit fxmanifest.lua and set the gameName variable.")
end

client_script "client.lua"
