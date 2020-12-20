
ui_page 'html/index.html'

files {
	'html/index.html',
	'html/static/css/app.css',
	'html/static/js/app.js',
	'html/static/js/manifest.js',
	'html/static/js/vendor.js',

	'html/static/config/config.json',
	
	'html/static/img/app_bank/*.png',
	'html/static/img/app_dati/*.png',
	'html/static/img/app_favourites/*.png',
	'html/static/img/app_galleria/*.png',
	'html/static/img/app_instagram/*.png',
	'html/static/img/app_tchat/*.png',
	'html/static/img/app_whatsapp/*.png',
	'html/static/img/app_wifi/*.png',
	'html/static/img/background/*.png',
	'html/static/img/cover/*.png',
	'html/static/img/dati/*.png',
	'html/static/img/icons_app/*.png',
	'html/static/img/twitter/*.png',

	'html/static/img/*.png',
	'html/static/fonts/fontawesome-webfont.ttf',

	'html/static/sound/*.ogg',
}

client_script {
	"config.lua",
	"client/animation.lua",
	"client/client.lua",

	"client/photo.lua",
	"client/app_tchat.lua",
	"client/bank.lua",
	"client/twitter.lua",
	"client/instagram.lua",
	"client/whatsapp.lua",
	"client/cover.lua",
	"client/bluetooth.lua",
	"client/suoneria.lua",
	"client/modem.lua"
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server/server.lua",

	"server/app_tchat.lua",
	"server/twitter.lua",
	"server/instagram.lua",
	"server/bank.lua",
	"server/whatsapp.lua",
	"server/cover.lua",
	"server/bluetooth.lua",
	"server/suoneria.lua",
	"server/modem.lua"
}

data_file 'DLC_ITYP_REQUEST' 'stream/bk_phone.ytyp'
