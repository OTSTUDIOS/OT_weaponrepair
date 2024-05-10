fx_version 'cerulean'
game 'gta5'
author 'stuxxy'
version '1.5.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

escrow_ignore {
    '*.lua'
}