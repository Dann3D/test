APIcalls['giveItem'] = function(data, author)
    if data.source ~= nil and data.name ~= nil and tonumber(data.amount) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer ~= nil then
            local xItem = xPlayer.getInventoryItem(data.name)
            if not xItem then return {executed = false, message = _"invalid_item"} end
            if IS_ESX_FINAL and not xPlayer.canCarryItem(data.name, tonumber(data.amount)) then
                return {executed = false, message = _"no_space"}
            end

            xPlayer.addInventoryItem(data.name, tonumber(data.amount))
            SendWebhook(_"dsc_give_item",
            _("dsc_gived_item", xItem.label, data.amount, GetPlayerName(tonumber(data.source)), data.source),
            author)
            return {
                executed = true,
                name = xItem.name,
                count = xItem.count + tonumber(data.amount)
            }
        end
        return {executed = false, message = _"invalid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end

local function GetAccount(xPlayer, account)
    if IS_ESX_FINAL then return xPlayer.getAccount(account) end
    if account == "money" then
        return {name = 'money', money = xPlayer.getMoney()}
    else
        return xPlayer.getAccount(account)
    end
end

local function AddAccount(xPlayer, account, amount)
    if IS_ESX_FINAL then return xPlayer.addAccountMoney(account, tonumber(amount)) end
    if account == "money" then return xPlayer.addMoney(tonumber(amount)) end
    return xPlayer.addAccountMoney(account, tonumber(amount))
end

APIcalls['giveAccount'] = function(data, author)
    if data.source ~= nil and data.account ~= nil and tonumber(data.amount) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer then
            local xAccount = GetAccount(xPlayer, data.account)
            if xAccount then
                AddAccount(xPlayer, data.account, data.amount)
                SendWebhook(_"dsc_give_account",
                _("dsc_gived_account", data.account, data.amount, GetPlayerName(tonumber(data.source)), data.source),
                author)
                return {
                    executed = true,
                    account = data.account,
                    current = xAccount.money + tonumber(data.amount)
                }
            end
            return {executed = false, message = _"invalid_account"}
        end
        return {executed = false, message = _"invalid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end

APIcalls['giveWeapon'] = function(data, author)
    if data.source ~= nil and data.name ~= nil and tonumber(data.ammo) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer then
            if tonumber(data.ammo) > 0 then
                xPlayer.addWeapon(data.name, tonumber(data.ammo))
                return {executed = true}
            end
        end
        return {executed = false, message = _"invalid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end