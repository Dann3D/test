APIcalls['warn'] = function(data, author)
    if data.source ~= nil and data.message ~= nil then
        if GetPlayerPing(tonumber(data.source)) then
            TriggerClientEvent(Config.Events.chatMessage, tonumber(data.source), {
                args = {"^3WARNING", "^7"..data.message}
            })
            WarnPlayer(data.source, data.message)
            SendWebhook(_"dsc_warning",
                _("dsc_warned", GetPlayerName(tonumber(data.source)), data.source, data.message),
                author)
            return {executed = true}
        end
        return {executed = false, message = _('invalid_source')}
    end
    return {executed = false, message = _('invalid_data')}
end

APIcalls['removeWarn'] = function(data, author)
    if data.id ~= nil then
        if RemoveWarning(tonumber(data.id)) then
            return {executed = true, id = data.id}
        end
        return {executed = false, message = _('invalid_warning')}
    end
    return {executed = false, message = _('invalid_data')}
end

APIcalls['editWarn'] = function(data, author)
    if data.id ~= nil and data.reason ~= nil then
        if UpdateWarning(data.id, data.reason) then
            return {executed = true}
        end
        return {executed = false, message = _('invalid_warning')}
    end
    return {executed = false, message = _('invalid_data')}
end

APIcalls['getWarnings'] = function(data, author)
    return {executed = true, warns = GetWarnList()}
end