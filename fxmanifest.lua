fx_version 'adamant'
games { 'gta5' }

author 'Bob'
description 'Bobs Dealer'
version '0.1'

client_scripts {
    --'client/functions.lua',
    'client/main.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}