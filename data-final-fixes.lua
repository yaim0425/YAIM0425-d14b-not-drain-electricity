---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Validar si se cargó antes <---
---------------------------------------------------------------------------------------------------

if GMOD and GMOD.name then return end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Cargar las funciones y constantes <---
---------------------------------------------------------------------------------------------------

require("__CONSTANTS__")
require("__FUNCTIONS__")

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Contenedor de este archivo <---
---------------------------------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Inicio del MOD <---
---------------------------------------------------------------------------------------------------

function This_MOD.start()
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Acciones <---
---------------------------------------------------------------------------------------------------

--- Darle formato a la propiedad "minable"
function This_MOD.format_minable()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    --- @param element table
    local function Format(element)
        --- Validar
        local minable = element.minable
        if not minable then return end
        if not minable.result then return end

        --- Dar el formato deseado
        minable.results = { {
            type = "item",
            name = minable.result,
            amount = minable.count or 1
        } }

        --- Borrar los valores reubicados
        minable.result = nil
        minable.count = nil
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    for _, elements in pairs(data.raw) do
        for _, element in pairs(elements) do
            Format(element)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Darle formato a la propiedad "icons"
function This_MOD.format_icons()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    --- @param element table
    local function Format(element)
        --- Validar
        if element.icons then return end
        if not element.icon then return end

        --- Dar el formato deseado
        element.icons = { {
            icon = element.icon,
            icon_size = element.icon_size ~= 64 and element.icon_size or nil
        } }

        --- Borrar los valores reubicados
        element.icon_size = nil
        element.icon = nil
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    for _, elements in pairs(data.raw) do
        for _, element in pairs(elements) do
            Format(element)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------------------------------
