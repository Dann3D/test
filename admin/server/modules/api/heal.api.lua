APIcalls['revive'] = function(data, author)
    if data.source ~= nil then
        if GetPlayerPing(data.source) ~= nil then
            TriggerClientEvent(Config.Events.reviveSource, tonumber(data.source))
            SendWebhook(_"dsc_revive",
                _("dsc_revived", GetPlayerName(tonumber(data.source)), data.source),
                author)
            return {executed = true}
        end
        return {executed = false, message = _"invaid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end

APIcalls['globalRevive'] = function(data, author)
    TriggerClientEvent(Config.Events.reviveSource, -1)
    SendWebhook(_"dsc_grevive", _"dsc_grevived", author)
    return {executed = true}
end

APIcalls['globalHeal'] = function(data, author)
    TriggerClientEvent(Config.Events.healSource, -1, 'big', true)
    SendWebhook(_"dsc_gheal", "dsc_ghealed", author)
    return {executed = true}
end