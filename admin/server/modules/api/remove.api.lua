APIcalls['removeItem'] = function(data, author)
    if data.source ~= nil and data.name ~= nil and tonumber(data.amount) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer ~= nil then
            local xItem = xPlayer.getInventoryItem(data.name)
            if not xItem then return {executed = false, message = _"invalid_item"} end

            if xItem.count >= tonumber(data.amount) then
                xPlayer.removeInventoryItem(xItem.name, tonumber(data.amount))
                SendWebhook(_"dsc_remove_item",
                _("dsc_removed_item", xItem.label, data.amount, GetPlayerName(tonumber(data.source)), data.source),
                author)
                return {
                    executed = true,
                    count = xItem.count - tonumber(data.amount)
                }
            end
            return {executed = false, message = _"invalid_amount"}
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

local function RemoveAccount(xPlayer, account, amount)
    if IS_ESX_FINAL then return xPlayer.removeAccountMoney(account, tonumber(amount)) end
    if account == "money" then
        return xPlayer.removeMoney(tonumber(amount))
    end
    return xPlayer.removeAccountMoney(account, tonumber(amount))
end

APIcalls['removeAccount'] = function(data, author)
    if data.source ~= nil and data.account ~= nil and tonumber(data.amount) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer then
            local xAccount = GetAccount(xPlayer, data.account)
            if xAccount then
                if xAccount.money >= tonumber(data.amount) then
                    RemoveAccount(xPlayer, data.account, data.amount)
                    SendWebhook(_"dsc_remove_acc",
                    _("dsc_removed_acc", data.account, data.amount, GetPlayerName(tonumber(data.source)), data.source),
                    author)
                    return {
                        executed = true,
                        account = data.account,
                        current = xAccount.money - tonumber(data.amount)
                    }
                end
                return {executed = false, message = _"invalid_amount"}
            end
            return {executed = false, message = _"invalid_account"}
        end
        return {executed = false, message = _"invalid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end

APIcalls['removeWeapon'] = function(data, author)
    if data.source ~= nil and data.name ~= nil and tonumber(data.ammo) ~= nil then
        local xPlayer = ESX.GetPlayerFromId(tonumber(data.source))
        if xPlayer then
            if tonumber(data.ammo) > 0 then
                xPlayer.removeWeaponAmmo(data.name, tonumber(data.ammo))
                return {executed = true}
            elseif tonumber(data.ammo) == 0 then
                xPlayer.removeWeapon(data.name)
                return {executed = true}
            end
        end
        return {executed = false, message = _"invalid_source"}
    end
    return {executed = false, message = _"invalid_data"}
end