local function compatibleAccounts(xPlayer)
    if IS_ESX_FINAL then
        return xPlayer.getAccounts(true)
    else
        return {
            money = xPlayer.getMoney(),
            bank = xPlayer.getAccount('bank').money,
        }
    end
end


APIcalls['getInfoFromSource'] = function(data)
    if data.source and GetPlayerPing(data.source) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer then
            return {
                executed    = true,
                source      = data.source,
                name        = data.name,
                accounts    = compatibleAccounts(xPlayer),
                firstname   = xPlayer.get('firstName') or 'nil',
                lastname    = xPlayer.get('lastName') or 'nil',
                --bdate       = xPlayer.get('dateofbirth'),
                --sex         = xPlayer.get('sex'),
                --height      = xPlayer.get('height'),
                group       = xPlayer.getGroup(),
            }
        end
    end
    return {executed = false, message = _'invalid_source'}
end