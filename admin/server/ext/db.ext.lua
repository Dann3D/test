local MySQL = assert(MySQL, 'no MySQL running')

MySQL.ready(function()
    local affectedWarns = MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `esx_manager_warns` (
            `id` INT(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
            `name` TEXT NOT NULL,
            `warned` TEXT NOT NULL,
            `reason` TEXT NOT NULL,
            `date` TEXT
        )
    ]])

    local affectedBans = MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS `esx_manager_bans` (
            `identifier` VARCHAR(60) PRIMARY KEY NOT NULL,
            `name` TEXT NOT NULL,
            `reason` LONGTEXT NOT NULL
        )
    ]])

    print('Tablas creadas: warns:', affectedWarns, 'bans:', affectedBans)
end)
