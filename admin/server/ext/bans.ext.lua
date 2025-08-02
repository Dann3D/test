local MySQL = assert(MySQL, 'no MySQL imported')
local banList, ready = {}, false

local function LoadBannedPlayers()
    local rows = MySQL.Sync.fetchAll('SELECT * FROM `esx_manager_bans`')
    if #rows then
        for _, row in pairs(rows) do
            banList[row.identifier] = {name=row.name, reason=row.reason}
        end
    end
    ready = true
end

local function InsertBan(identifier, name, reason)
    MySQL.Sync.execute('INSERT INTO `esx_manager_bans` (`identifier`, `name`, `reason`) VALUES(@identifier, @name, @reason)', {
        ['@identifier'] = identifier,
        ['@name'] = name,
        ['@reason'] = reason
    })
    banList[identifier] = {name = name, reason = reason}
end

local function DeleteBan(identifier)
    MySQL.Sync.execute('DELETE FROM `esx_manager_bans` WHERE `identifier` = @identifier', {
        ['@identifier'] = identifier
    })
    banList[identifier] = nil
    collectgarbage "collect"
end

local function GetIdentifier(source)
    source = tostring(source)
    for i=0, GetNumPlayerIdentifiers(source), 1 do
        local identifier = GetPlayerIdentifier(source, i)
        if identifier ~= nil and identifier:startsWith(Config.Identifier) then
            return identifier
        end
    end
    print('Fail GetIdentifier', source, type(source))
end

function IsPlayerBanned(source)
    if not ready then LoadBannedPlayers() end
    return banList[GetIdentifier(source)]
end

function IsIdentifierBanned(identifier)
    if not ready then LoadBannedPlayers() end
    return banList[identifier]
end

function BanPlayerById(source, reason)
    if GetPlayerPing(source) ~= nil and not IsPlayerBanned(source) then
        InsertBan(GetIdentifier(source), GetPlayerName(source), reason)
        return true
    end
    return false
end

function UnbanPlayerById(source)
    if GetPlayerPing(source) ~= nil and IsPlayerBanned(source) then
        DeleteBan(GetIdentifier(source))
        return true
    end
    return false
end

function UnbanPlayerByIdentifier(identifier)
    if IsIdentifierBanned(identifier) then
        DeleteBan(identifier)
        return true
    end
    return false
end

function RestoreBannedPlayers()
    MySQL.Sync.execute('TRUNCATE `esx_manager_bans`')
    banList = {}
    return true
end

function GetBanList(array)
    if not ready then LoadBannedPlayers() end
    if not array then
        return banList
    else
        local t = {}
        for identifier, data in pairs(banList) do
            table.insert(t, {name = data.name, identifier = identifier, reason = data.reason})
        end
        return t
    end
end