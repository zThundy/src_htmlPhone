fx_version "bodacious"
game "gta5"
version "3.4.0"
author "zThundy__"

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/static/css/app.css',
    'html/static/js/*.js',

    'html/static/config/config.json',
    'html/static/img/**/*',
    'html/static/img/*.png',
    'html/static/fonts/*',

    'html/static/sound/*',
    "html/static/sound/phoneDialogsEffect/*",
    "html/static/sound/tts/*",

    "modules/Luaoop.lua",
    "modules/TunnelV2.lua",
    "modules/IDManager.lua",
    "modules/Tools.lua",
}

shared_scripts {
    "modules/utils.lua",
    "config.lua",
    "config.lang.lua",
    "config.wifi.lua",
    "config.sim.lua",
    "config.services.lua",
    "shared.lua",
}

client_script {
    "client/animation.lua",
    "client/client.lua",
    "client/nui_callbacks.lua",

    "client/req.lua",

    "client/photo.lua",
    "client/app_tchat.lua",
    "client/bank.lua",
    "client/twitter.lua",
    "client/instagram.lua",
    "client/whatsapp.lua",
    "client/cover.lua",
    "client/bluetooth.lua",
    "client/modem.lua",
    "client/darkweb.lua",
    "client/email.lua",
    "client/news.lua",
    "client/azienda.lua",
    "client/bourse.lua",
    "client/phonebox.lua",
    "client/videocalls.lua",

    -- modules
    "modules/tokovoip.lua",
    "modules/wifi/client/*.lua",
    "modules/sim/client/*.lua",
    "modules/services/client/*.lua",
}

server_script {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua",
    
    "server/req.lua",

    "server/app_tchat.lua",
    "server/twitter.lua",
    "server/instagram.lua",
    "server/bank.lua",
    "server/whatsapp.lua",
    "server/cover.lua",
    "server/bluetooth.lua",
    "server/modem.lua",
    "server/darkweb.lua",
    "server/email.lua",
    "server/news.lua",
    "server/azienda.lua",
    "server/bourse.lua",
    "server/phonebox.lua",
    "server/videocalls.lua",

    -- modules
    "modules/saltychat.lua",
    "modules/wifi/server/*.lua",
    "modules/sim/server/*.lua",
    "modules/services/server/*.lua",
}

dependencies {
    'es_extended',
    'gridsystem',
    'screenshot-basic'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bk_phone.ytyp'
