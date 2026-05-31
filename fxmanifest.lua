fx_version 'cerulean'
game 'gta5'

name 'wcayoheist'
author 'winnie'
description 'A fully configurable Cayo Perico heist for QBCore with ox_lib, ox_inventory, SN-Hacking, ps-ui, fd_dispatch'

shared_scripts {
    '@qb-core/shared.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/utils.lua',
    'client/start.lua',
    'client/approach.lua',
    'client/compound.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}
