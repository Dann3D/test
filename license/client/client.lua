local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local inExam = false

-- Crear y spawnear peds en las ubicaciones definidas en Config.locations
CreateThread(function()
    for licenseType, info in pairs(Config.locations) do
        local model = GetHashKey(info.ped)
        print('[LicenseScript] Cargando modelo de ped:', info.ped, model)

        RequestModel(model)
        local start = GetGameTimer()
        while not HasModelLoaded(model) do
            Wait(10)
            if GetGameTimer() - start > 5000 then
                print('[LicenseScript] ERROR: Modelo no cargó después de 5 segundos:', info.ped)
                break
            end
        end

        if HasModelLoaded(model) then
            local ped = CreatePed(4, model, info.coords.x, info.coords.y, info.coords.z - 1.0, info.heading, false, true)
            print('[LicenseScript] Ped creado en:', info.coords.x, info.coords.y, info.coords.z)
            SetEntityAsMissionEntity(ped, true, true)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetPedCanRagdoll(ped, false)
        else
            print('[LicenseScript] No se pudo cargar el modelo:', info.ped)
        end
    end
end)


-- Crear zonas ox_target para interactuar
CreateThread(function()
    if Config.useOxTarget and exports.ox_target then
        for k, v in pairs(Config.locations) do
            exports.ox_target:addBoxZone({
                coords = v.coords,
                size = vector3(1.2, 1.2, 1.2),
                rotation = 0,
                debug = false,
                options = {
                    {
                        name = 'ng_license:openMenu',
                        label = 'Solicitar Licencia',
                        onSelect = function()
                            openLicenseMenu(k)
                        end
                    }
                }
            })
        end
    end
end)

-- Menú ESX para seleccionar la licencia a solicitar
function openLicenseMenu()
    local elements = {}

    for key, info in pairs(Config.licenseTypes) do
        table.insert(elements, {label = info.label .. ' - $' .. tostring(info.cost), value = key})
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'license_menu', {
        title = 'Solicitar licencia',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()
        if data.current and data.current.value then
            TriggerServerEvent('ng_license:requestExam', data.current.value)
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Mostrar preguntas una a una en menú ESX
RegisterNetEvent('ng_license:openExam', function(licenseType, questions)
    if inExam then return end
    inExam = true

    local correct = 0
    local currentQuestion = 1

    local function showQuestion(index)
        if index > #questions then
            local score = math.floor((correct / #questions) * 100)
            TriggerServerEvent('ng_license:submitExam', licenseType, nil, score)
            inExam = false
            return
        end

        local q = questions[index]
        local options = {}

        for i, ans in ipairs(q.a) do
            table.insert(options, {label = ans, value = i})
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'license_question_'..index, {
            title = q.q,
            align = 'top-left',
            elements = options
        }, function(data, menu)
            if data.current.value == q.correct then
                correct = correct + 1
            end
            menu.close()
            showQuestion(index + 1)
        end, function(data, menu)
            menu.close()
            inExam = false
        end)
    end

    showQuestion(currentQuestion)
end)
