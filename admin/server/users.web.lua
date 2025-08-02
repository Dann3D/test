-- Set username & passwords here!
-- Follow the example

-- example with full permissions
user 'admin' 
    : password 'admin'
    : permissions {
        ban = true, unban = true,   globalUnban = true,
        warn            = true,     removeWarn  = true, editWarn = true,
        kick            = true,
        kill            = true,
        revive          = true,
        globalRevive    = true,
        globalHeal      = true,
        getBannedPlayers    = true, getWarnings             = true,
        getInfoFromSource   = true, getInventoryFromSource  = true,
        --
        giveItem        = true, removeItem      = true,
        giveAccount     = true, removeAccount   = true, setAccount = true,
        giveWeapon      = true, removeWeapon    = true,
        --
        setCoords       = true,
        setGroup        = true,
        setName         = true,
    }

-- example with 3 permissions
user 'moderator'
    : password 'moderator'
    : permissions {
        kick            = true,
        kill            = true,
        giveItem        = true,
    }