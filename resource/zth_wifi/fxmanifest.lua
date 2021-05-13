fx_version "cerulean"

game "gta5"

server_script {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    'shared.lua',
    "server/utils.lua",
    "server/server.lua"
}

client_script {
    "config.lua",
    'shared.lua',
    "client/utils.lua",
    "client/client.lua"
}

