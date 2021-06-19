fx_version "adamant"

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

-- RedM
--[[
game "rdr3"
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

files {
	"ui/chineserocks.ttf",
	"ui/rdr3.css"
}

client_scripts {
	"@uiprompt/uiprompt.lua",

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
	"data/rdr3/weapons.lua",

	"client.lua"
}
]]

-- FiveM
--[[
game "gta5"

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
	"data/gta5/weapons.lua",

	"client.lua"
}
]]
