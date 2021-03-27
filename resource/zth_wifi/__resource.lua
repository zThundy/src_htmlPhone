resource_manifest_version '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

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

