fx_version 'cerulean'
game 'gta5'
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
author 		'PiterMcFlebor'
description 'Resource made by PiterMcFlebor'
version 	'1.1'
discord     'ƤƖƬЄƦ MƇƑԼЄƁƠƦ#9270'
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
debug_mode  'no'   -- set this to 'yes' to enable developer mode
locale      'en'    -- set this to any locale located at './locales'
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
shared_scripts {
    'extended.lua',
    'locales/common.lua',
    'locales/*.locale.lua',
}
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
client_scripts {
    'client/*.lua'
}
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/config.web.lua',
    'server/ext/*.ext.lua',
    'server/modules/utils.webmod.lua',
    'server/modules/*.webmod.lua',
    'server/modules/api/*.api.lua',
    'server/*.web.lua',
}
-- Leaked By: Leaking Hub | J. Snow | leakinghub.com
dependency 'es_extended'
