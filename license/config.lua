Config = {}

Config.licenseItem = 'license_card' -- ítem que da la licencia (modifícalo si usas otro)

Config.passPercent = 70 -- porcentaje para aprobar el examen

Config.useOxTarget = true -- activar ox_target para interacción

Config.licenseTypes = {
    driver_license = {
        label = "Licencia de Conducir",
        cost = 5000,
        questionsCount = 10
    },
    weapon_license = {
        label = "Licencia de Armas",
        cost = 15000,
        questionsCount = 10
    },
    id_card = {
        label = "Documento de Identidad",
        cost = 2000,
        questionsCount = 10
    },
    polarized_license = {
        label = "Licencia de Caza",
        cost = 10000,
        questionsCount = 10
    }
}

Config.locations = {
    driver_license = {
        coords = vector3(-266.28, -962.36, 31.22),
        heading = 200.0,
        ped = 'a_m_m_business_01'
    },
    weapon_license = {
        coords = vector3(22.15, -1106.86, 29.8),
        heading = 160.0,
        ped = 's_m_y_ammucity_01'
    },
    id_card = {
        coords = vector3(-545.55, -204.14, 38.22),
        heading = 80.0,
        ped = 's_m_m_ciasec_01'
    },
    polarized_license = {
        coords = vector3(-679.65, 5832.12, 17.33),
        heading = 45.0,
        ped = 's_m_y_hunter_01'
    }
}

Config.questions = {
    driver_license = {
        {q = "¿Color de la luz que indica detenerse?", a = {"Rojo", "Verde", "Amarillo"}, correct = 1},
        {q = "¿Qué documento debes portar al conducir?", a = {"Licencia", "Pasaporte", "Ninguno"}, correct = 1},
        {q = "¿Velocidad máxima en zona urbana?", a = {"50 km/h", "80 km/h", "100 km/h"}, correct = 1},
        {q = "¿Prioridad en intersección sin señalización?", a = {"Derecha", "Izquierda", "Nadie"}, correct = 1},
        {q = "¿Qué hacer ante un semáforo amarillo?", a = {"Acelerar", "Detenerse si es seguro", "Ignorarlo"}, correct = 2},
        {q = "¿Uso de cinturón de seguridad?", a = {"Obligatorio", "Opcional", "Nunca"}, correct = 1},
        {q = "¿Qué hacer ante un cruce peatonal?", a = {"Frenar y ceder", "Pasar rápido", "Ignorarlo"}, correct = 1},
        {q = "¿Qué indica una línea continua?", a = {"No adelantar", "Adelantar", "Nada"}, correct = 1},
        {q = "¿Qué revisar antes de conducir?", a = {"Frenos y luces", "Radio", "Asientos"}, correct = 1},
        {q = "¿Qué significa una señal de stop?", a = {"Parar completamente", "Reducir", "Nada"}, correct = 1}
    },
    weapon_license = {
        {q = "¿Es legal portar armas sin licencia?", a = {"Sí", "No", "Depende"}, correct = 2},
        {q = "¿Dónde se puede disparar legalmente?", a = {"Campo de tiro", "En la calle", "En fiestas"}, correct = 1},
        {q = "¿Qué hacer si tu arma se atasca?", a = {"Apuntar a otro lado", "Revisar con seguridad", "Golpearla"}, correct = 2},
        {q = "¿Se permite portar arma en lugares públicos?", a = {"Sí", "No", "Siempre"}, correct = 2},
        {q = "¿Qué calibre es letal?", a = {"Todos", "Ninguno", "Solo grandes"}, correct = 1},
        {q = "¿Qué hacer antes de disparar?", a = {"Verificar objetivo", "Cerrar ojos", "Correr"}, correct = 1},
        {q = "¿Se puede prestar un arma?", a = {"Sí", "No", "Depende"}, correct = 2},
        {q = "¿Qué se necesita para comprar un arma?", a = {"Licencia y registro", "Nada", "Pasaporte"}, correct = 1},
        {q = "¿Cómo transportar un arma?", a = {"Descargada y segura", "Cargada en mano", "En el bolsillo"}, correct = 1},
        {q = "¿Qué hacer después de disparar?", a = {"Guardar arma", "Lanzarla", "Mostrarla"}, correct = 1}
    },
    id_card = {
        {q = "¿Qué identifica a un ciudadano?", a = {"Pasaporte", "DNI", "Licencia"}, correct = 2},
        {q = "¿Quién expide el DNI?", a = {"Gobierno", "Vecino", "Tienda"}, correct = 1},
        {q = "¿Es obligatorio portar el DNI?", a = {"Sí", "No", "Depende"}, correct = 1},
        {q = "¿Qué contiene el DNI?", a = {"Datos personales", "Canciones", "Publicidad"}, correct = 1},
        {q = "¿Puede expirar el DNI?", a = {"Sí", "No", "Nunca"}, correct = 1},
        {q = "¿El DNI es único?", a = {"Sí", "No", "Depende"}, correct = 1},
        {q = "¿Qué hacer si pierdes el DNI?", a = {"Denunciar", "Ignorar", "Comprar otro"}, correct = 1},
        {q = "¿Quién puede solicitar tu DNI?", a = {"Policía", "Cualquiera", "Nadie"}, correct = 1},
        {q = "¿Puedes fotocopiar el DNI?", a = {"Sí", "No", "Nunca"}, correct = 1},
        {q = "¿Dónde se guarda el DNI?", a = {"Cartera", "Casa", "Coche"}, correct = 1}
    },
    polarized_license = {
        {q = "¿Es legal cazar sin licencia?", a = {"Sí", "No", "Depende"}, correct = 2},
        {q = "¿Qué animales se pueden cazar?", a = {"Permitidos por ley", "Todos", "Ninguno"}, correct = 1},
        {q = "¿Dónde se puede cazar?", a = {"Zonas autorizadas", "Cualquier lugar", "Ciudad"}, correct = 1},
        {q = "¿Qué llevar al cazar?", a = {"Licencia y equipo", "Solo arma", "Nada"}, correct = 1},
        {q = "¿Se puede cazar de noche?", a = {"Sí", "No", "Depende"}, correct = 2},
        {q = "¿Qué hacer si ves un animal protegido?", a = {"No cazarlo", "Cazarlo", "Asustarlo"}, correct = 1},
        {q = "¿Qué equipo de seguridad usar?", a = {"Chaleco y señalización", "Ninguno", "Sombrero"}, correct = 1},
        {q = "¿Quién controla la caza?", a = {"Guardabosques", "Vecinos", "Cazadores"}, correct = 1},
        {q = "¿Qué hacer si hieres un animal?", a = {"Rematar rápido", "Dejarlo", "Llevarlo a casa"}, correct = 1},
        {q = "¿Qué hacer con el arma al terminar?", a = {"Descargar y guardar", "Tirar", "Dejar cargada"}, correct = 1}
    }
}

Config.passPercent = 70
Config.useOxTarget = true
