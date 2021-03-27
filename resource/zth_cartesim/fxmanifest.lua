fx_version "cerulean"

game "gta5"

server_scripts {
  "@zth_gcphone/modules/utils.lua",
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  "@zth_gcphone/modules/utils.lua",
  'config.lua',
  'client/main.lua'
}
