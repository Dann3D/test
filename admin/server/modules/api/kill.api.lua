APIcalls['kill'] = function(data, author)
    if data.source ~= nil then
        if GetPlayerPing(data.source) ~= nil then
            TriggerClientEvent('admin:kill', tonumber(data.source))
            SendWebhook(_"dsc_kill",
                _("dsc_killed", GetPlayerName(tonumber(data.source)), data.source),
                author)
            return {executed = true}
        end
        return {executed = false, message = _"invaid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end