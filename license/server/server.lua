local ESX = nil

-- Obtener ESX
if not ESX then
    local ok, obj = pcall(function()
        return exports['es_extended'] and exports['es_extended']:getSharedObject()
    end)
    if ok and obj then ESX = obj end
end
if not ESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-- Crear tabla si no existe
exports.oxmysql:execute([[
CREATE TABLE IF NOT EXISTS multi_licenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  license_type VARCHAR(50) NOT NULL,
  citizen_id VARCHAR(128) NOT NULL,
  issued_by VARCHAR(128) DEFAULT NULL,
  issued_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
]])

local function chargePlayerByXPlayer(xPlayer, amount)
    if not xPlayer or amount <= 0 then return true end

    local money = xPlayer.getMoney and xPlayer.getMoney() or
                  (xPlayer.getAccount and (xPlayer.getAccount('money') and xPlayer.getAccount('money').money or 0) or 0)

    if money >= amount then
        if xPlayer.removeMoney then xPlayer.removeMoney(amount) end
        return true
    end

    local bank = 0
    if xPlayer.getAccount then
        local acc = xPlayer.getAccount('bank')
        bank = acc and acc.money or 0
    end

    if bank >= amount then
        if xPlayer.removeAccountMoney then xPlayer.removeAccountMoney('bank', amount) end
        return true
    end

    return false
end

RegisterNetEvent('ng_license:requestExam', function(licenseType)
    local src = source
    local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
    local licenseCfg = Config.licenseTypes and Config.licenseTypes[licenseType]
    if not licenseCfg then
        TriggerClientEvent('ox_lib:notify', src, {type='error', description='Tipo de licencia inválido'})
        return
    end

    local cost = licenseCfg.cost or 0
    local charged = true
    if xPlayer then
        charged = chargePlayerByXPlayer(xPlayer, cost)
    end

    if not charged then
        TriggerClientEvent('ox_lib:notify', src, {type='error', description='No tienes dinero suficiente'})
        return
    end

    local pool = Config.questions and Config.questions[licenseType] or {}
    if #pool == 0 then
        TriggerClientEvent('ox_lib:notify', src, {type='error', description='No hay preguntas configuradas para esta licencia'})
        return
    end

    local chosen = {}
    math.randomseed(os.time() + src)
    local count = licenseCfg.questionsCount or math.min(10, #pool)
    for i=1, count do
        local idx = math.random(1, #pool)
        table.insert(chosen, pool[idx])
    end

    TriggerClientEvent('ng_license:openExam', src, licenseType, chosen)
end)

RegisterNetEvent('ng_license:submitExam', function(licenseType, answers, score)
    local src = source
    local passed = (score >= Config.passPercent)
    if passed then
        pcall(function()
            TriggerEvent('qs-inventory:AddItem', src, Config.licenseItem, 1)
        end)

        local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
        local cid = tostring(xPlayer and (xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier) or src)

        local query = 'INSERT INTO multi_licenses (license_type, citizen_id, issued_by) VALUES (?, ?, ?)'
        exports.oxmysql:execute(query, {licenseType, cid, 'system'})

        TriggerClientEvent('ox_lib:notify', src, {type='success', description='Licencia emitida correctamente'})
    else
        TriggerClientEvent('ox_lib:notify', src, {type='error', description='No aprobaste el examen'})
    end
end)

exports('HasLicense', function(citizenId, licenseType)
    local query = 'SELECT id FROM multi_licenses WHERE citizen_id = ? AND license_type = ? LIMIT 1'
    local result = exports.oxmysql.query.await(query, {citizenId, licenseType})
    return result and #result > 0
end)

AddEventHandler('onResourceStart', function(resName)
    if GetCurrentResourceName() ~= resName then return end
    print('ng_multi_license started (ESX mode)')
end)
