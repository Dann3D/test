APIcalls['ban'] = function(data, author)
    if data.source ~= nil and data.message ~= nil then
        if GetPlayerPing(tonumber(data.source)) then
            BanPlayerById(data.source, data.message)
            SendWebhook("Ban",
                _('dsc_ban', GetPlayerName(tonumber(data.source)), data.source, data.message),
                author)
            DropPlayer(tonumber(data.source), _('banned', data.message))
            return {executed = true}
        end
        return {executed = false, message = _('invalid_source')}
    end
    return {executed = false, message = _('invalid_data')}
end

APIcalls['globalUnban'] = function(data, author)
    RestoreBannedPlayers()
    return {executed = true}
end

APIcalls['unban'] = function(data, author)
    if data.identifier ~= nil then
        if UnbanPlayerByIdentifier(data.identifier) then
            SendWebhook("Unban",
                _('dsc_unban', banned.name, data.identifier),
                author)
            return {executed = true, identifier = data.identifier}
        end
        return {executed = false, message = _('not_banned')}
    end
    return {executed = false, message = _('invalid_data')}
end

APIcalls['getBannedPlayers'] = function(data, author)
    return {executed = true, banned = GetBanList(true)}
end