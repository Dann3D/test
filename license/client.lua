local inExam = false

local function spawnLicensePed(licenseKey, data)
    local model = joaat(data.ped)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, data.coords.x, data.coords.y, data.coords.z - 1, data.heading, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'license_exam_' .. licenseKey,
            icon = 'fa-solid fa-id-card',
            label = 'Solicitar licencia: ' .. (Config.licenseTypes[licenseKey] and Config.licenseTypes[licenseKey].label or licenseKey),
            onSelect = function()
                TriggerServerEvent('ng_license:requestExam', licenseKey)
            end
        }
    })
end

CreateThread(function()
    for licenseKey, location in pairs(Config.locations) do
        spawnLicensePed(licenseKey, location)
    end
end)

RegisterNetEvent('ng_license:openExam', function(licenseType, questions)
    if inExam then return end
    inExam = true
    local correct = 0

    for i, q in ipairs(questions) do
        local inputs = {}
        for idx, txt in ipairs(q.a) do
            table.insert(inputs, {type = 'radio', label = txt, value = idx})
        end

        local dialogRes = lib.inputDialog(q.q, inputs)
        if dialogRes and tonumber(dialogRes[1]) == q.correct then
            correct = correct + 1
        end
        Wait(200)
    end

    local score = math.floor((correct / #questions) * 100)
    TriggerServerEvent('ng_license:submitExam', licenseType, nil, score)
    inExam = false
end)
