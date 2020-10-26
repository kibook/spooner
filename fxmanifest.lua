fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

files {
	'ui/index.html',
	'ui/style.css',
	'ui/objects.js',
	'ui/script.js'
}

ui_page 'ui/index.html'

client_scripts {
	'config.lua',
	'objects.lua',
	'client.lua'
}

server_scripts {
	'server.lua'
}
