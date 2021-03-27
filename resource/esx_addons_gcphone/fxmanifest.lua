fx_version "cerulean"

game "gta5"

client_script {
	"config.lua",
	"client.lua"
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server.lua"
}