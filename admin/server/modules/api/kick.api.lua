APIcalls["kick"] = function(data, author)
    if data.source ~= nil and data.message ~= nil then
        local source = tonumber(data.source)
        if GetPlayerPing(source) ~= nil then
            DropPlayer(source, data.message)
            SendWebhook(_"dsc_kick",
                _("dsc_kicked", GetPlayerName(tonumber(data.source)), data.source, data.message),
                author)
            return {executed = true, source = data.source}
        end
    end
    return {executed = false, message = _"invalid_source"}
end