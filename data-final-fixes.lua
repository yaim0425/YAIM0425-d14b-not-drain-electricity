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
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Darle formato a las propiedades
    This_MOD.format_minable()
    This_MOD.format_icons()

    --- Clasificar la información de data.raw
    --- GMOD.items
    --- GMOD.tiles
    --- GMOD.fluids
    --- GMOD.recipes
    --- GMOD.entities
    --- GMOD.equipments
    This_MOD.filter_data()

    --- Clasificar la información de settings.startup
    --- GMOD.Setting
    This_MOD.load_setting()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
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

--- Crear espacios entre los elementos
function This_MOD.change_orders()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Inicializar las vaiables
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Orders = {}
    local Source = {}
    local N = 0

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Grupos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar las vaiables
    Orders = {}
    Source = {}

    --- Agrupar los Grupos
    for _, element in pairs(data.raw["item-group"]) do
        if element.order then
            table.insert(Source, element)
            table.insert(Orders, element.order)
        end
    end

    --- Cantidad de afectados
    N = GMOD.get_length(data.raw["item-group"])
    N = GMOD.digit_count(N) + 1

    --- Ordenear los orders
    table.sort(Orders)

    --- Cambiar el order de los subgrupos
    for iKey, order in pairs(Orders) do
        for jKey, element in pairs(Source) do
            if element.order == order then
                element.order = GMOD.pad_left_zeros(N, iKey) .. "0"
                table.remove(Source, jKey)
                break
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Subgrupos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar las vaiables
    Orders = {}
    Source = {}

    --- Agrupar los subgroups
    for _, element in pairs(GMOD.subgroups) do
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        Source[element.group] = Source[element.group] or {}
        table.insert(Source[element.group], element)
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        Orders[element.group] = Orders[element.group] or {}
        table.insert(Orders[element.group], element.order or element.name)
        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Cambiar el order de los subgrupos
    for subgroup, orders in pairs(Orders) do
        --- Ordenear los orders
        table.sort(orders)

        --- Cantidad de afectados
        N = GMOD.get_length(orders)
        N = GMOD.digit_count(N) + 1

        --- Remplazar los orders
        for iKey, order in pairs(orders) do
            for jKey, element in pairs(Source[subgroup]) do
                if element.order == order then
                    element.order = GMOD.pad_left_zeros(N, iKey) .. "0"
                    table.remove(Source[subgroup], jKey)
                    break
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Establecer subgrupos por defecto
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Subgrupos por defecto
    local Empty = {
        type = "item-subgroup",
        name = "subgroup-empty",
        group = "other",
        order = "999"
    }

    --- Crear el Subgrupos por defecto
    data:extend({ Empty })

    --- Inicializar las vaiables
    Orders = {}
    Source = {}
    Source.items = GMOD.items
    Source.fluids = GMOD.fluids
    Source.recipes = GMOD.recipes

    --- Objetos, recetas y fluidos
    for Key, Values in pairs(Source) do
        if Key ~= "recipes" then Values = { Values } end
        for _, values in ipairs(Values) do
            for _, value in pairs(values) do
                if not value.subgroup then
                    value.subgroup = Empty.name
                    value.order = value.name
                end
                if not value.order then
                    value.order = value.name
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Objetos, recetas y demás
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar las vaiables
    Orders = {}
    Source = {}

    --- Agrupar	los objetos, recetas y demás
    for _, elements in pairs(data.raw) do
        for _, element in pairs(elements) do
            --- Evitar estos tipos
            if element.type == "item-group" then break end
            if element.type == "item-subgroup" then break end

            --- El ciclo es solo para saltar
            --- elementos no deseados
            repeat
                --- Validación
                if not element.subgroup then break end
                if not element.order then break end

                --- Agrupar
                Source[element.subgroup] = Source[element.subgroup] or {}
                table.insert(Source[element.subgroup], element)

                Orders[element.subgroup] = Orders[element.subgroup] or {}
                table.insert(Orders[element.subgroup], element.order)
            until true
        end
    end

    --- Cambiar el order de los subgrupos
    for subgroup, orders in pairs(Orders) do
        --- Ordenear los orders
        table.sort(orders)

        --- Cantidad de afectados
        N = GMOD.get_length(orders)
        N = GMOD.digit_count(N) + 1

        --- Remplazar los orders
        for iKey, order in pairs(orders) do
            for jKey, element in pairs(Source[subgroup]) do
                if element.order == order then
                    element.order = GMOD.pad_left_zeros(N, iKey) .. "0"
                    table.remove(Source[subgroup], jKey)
                    break
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Agrupar las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for name, recipes in pairs(GMOD.recipes) do
        local item = GMOD.items[name]
        if item then
            item.order = item.order or "0"
            local order = tonumber(item.order) or 0
            for _, recipe in pairs(recipes) do
                if #recipe.results == 1 then
                    recipe.subgroup = item.subgroup
                    recipe.order = GMOD.pad_left_zeros(#item.order, order)
                    order = order + 1
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Clasificar la información de data.raw
--- GMOD.items
--- GMOD.tiles
--- GMOD.fluids
--- GMOD.recipes
--- GMOD.entities
--- GMOD.equipments
function This_MOD.filter_data()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Contenedores finales
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.items = {}
    GMOD.tiles = {}
    GMOD.fluids = {}
    GMOD.recipes = {}
    GMOD.entities = {}
    GMOD.equipments = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Otras funciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar si está oculta
    local function is_hidde(array)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Hidden = false
        Hidden = Hidden or array.hidden
        Hidden = Hidden or array.parameter
        Hidden = Hidden or GMOD.get_key(array.flags, "hidden")
        Hidden = Hidden or GMOD.get_key(array.flags, "spawnable")
        if Hidden then return true end
        return false

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Agrega las Recetas, Suelos y Objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar la receta a GMOD.recipes
    local function add_recipe(recipe)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Vaidación
        if is_hidde(recipe) then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Recorrer los resultados
        for _, result in pairs(recipe.results or {}) do
            --- Espacio a usar
            local Recipes = GMOD.recipes[result.name] or {}
            GMOD.recipes[result.name] = Recipes

            --- Agregar la receta si no se encuentra
            local Found = GMOD.get_tables(Recipes, "name", recipe.name, false)
            if not Found then table.insert(Recipes, recipe) end

            --- Guardar referencia del resultado
            if result.type == "item" then GMOD.items[result.name] = true end
            if result.type == "fluid" then GMOD.fluids[result.name] = true end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Guardar referencia de los ingredientes
        for _, ingredient in pairs(recipe.ingredients or {}) do
            if ingredient.type == "item" then GMOD.items[ingredient.name] = true end
            if ingredient.type == "fluid" then GMOD.fluids[ingredient.name] = true end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Agregar el suelo a GMOD.tiles
    local function add_tile(tile)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not tile.minable then return end
        if not tile.minable.results then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Verificar cada resultado
        for _, result in pairs(tile.minable.results) do
            --- El suelo no tiene receta
            if not GMOD.items[result.name] then
                GMOD.items[result.name] = true
            end

            --- Espacio a usar
            local Titles = GMOD.tiles[result.name] or {}
            GMOD.tiles[result.name] = Titles

            --- Agregar el suelo si no se encuentra
            local Found = GMOD.get_tables(Titles, "name", tile.name, false)
            if not Found then table.insert(Titles, tile) end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Agregar el item a GMOD.items
    local function add_item(item)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not item.stack_size then return end
        if is_hidde(item) then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Guardar objeto
        GMOD.items[item.name] = item

        --- Guardar suelo de no estarlo
        if item.place_as_tile and not GMOD.tiles[item.name] then
            local Tile = data.raw.tile[item.place_as_tile.result]
            GMOD.tiles[item.name] = GMOD.tiles[item.name] or {}
            table.insert(GMOD.tiles[item.name], Tile)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar las propiedades
        for index, property in pairs({
            entities = "place_result",
            equipments = "place_as_equipment_result"
        }) do
            if item[property] then
                --- Objeto de igual nombre que el resultado
                if item[property] == item.name then
                    GMOD[index][item.name] = true
                end

                --- Objeto de distinto nombre que el resultado
                if item[property] ~= item.name then
                    GMOD[index][item[property]] = true
                    GMOD[index][item.name] = item[property]
                end
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cargar las Recetas, Suelos, Fluidos y Objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer las recetas
    for _, recipe in pairs(data.raw.recipe) do
        add_recipe(recipe)
    end

    --- Cargar los fluidos
    for name, _ in pairs(GMOD.fluids) do
        local Fluid = data.raw.fluid[name]
        if Fluid then GMOD.fluids[name] = Fluid end
    end

    --- Cargar los suelos
    for _, tile in pairs(data.raw.tile) do
        add_tile(tile)
    end

    --- Cargar los objetos
    for _, array in pairs(data.raw) do
        for _, item in pairs(array) do
            add_item(item)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Buscar y cargar las Entidades y los Equipos
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Evitar estos tipos
    local Ignore_types = {
        tile = true,
        fluid = true,
        recipe = true
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Recorrer los elementos
    for _, elements in pairs({ GMOD.entities, GMOD.equipments }) do
        --- Cargar de forma directa
        for name, value in pairs(elements) do
            if type(value) == "boolean" then
                for _, element in pairs(data.raw) do
                    --- Buscar la entidad
                    element = element[name]

                    --- El ciclo es solo para saltar
                    --- elementos no deseados
                    repeat
                        --- Validación
                        if not element then break end
                        if Ignore_types[element.type] then break end

                        --- Entidades
                        if elements == GMOD.entities then
                            if not element.minable then break end
                            if not element.minable.results then break end
                        end

                        --- Equipos
                        if elements == GMOD.equipments then
                            if not element.shape then break end
                            if not element.sprite then break end
                        end

                        --- Guardar
                        elements[name] = element
                    until true
                end
            end
        end

        --- Cargar de forma indirecta
        for name, value in pairs(elements) do
            if type(value) == "string" then
                elements[name] = elements[value]
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Eliminar los elementos que no se pudieron cargar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable contenedora
    local Info = ""
    local Delete = {}
    local Array = {
        Item = GMOD.items,
        Tile = GMOD.tiles,
        Fluid = GMOD.fluids,
        Entity = GMOD.entities,
        Equipment = GMOD.equipments
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Identificar valores vacios
    for iKey, elemnts in pairs(Array) do
        for jKey, elemnt in pairs(elemnts) do
            if GMOD.is_boolean(elemnt) then
                Info = Info .. "\n\t\t"
                Info = Info .. iKey .. " not found or hidden: " .. jKey
                table.insert(Delete, jKey)
            end
        end
    end

    --- Eliminar valores vacios
    for _, list in pairs(Array) do
        for _, value in pairs(Delete) do
            list[value] = nil
        end
    end

    --- Imprimir un informe de lo eliminados
    if #Delete >= 1 then log(Info) end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Clasificar la información de settings.startup
--- GMOD.Setting
function This_MOD.load_setting()
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar el contenedor
    GMOD.setting = {}

    --- Recorrer las opciones de configuración
    for option, value in pairs(settings.startup) do
        --- Separar los datos esperados
        local ID, Name = GMOD.get_id_and_name(option)

        --- Validar los datos obtenidos
        if ID and Name then
            GMOD.setting[ID] = GMOD.setting[ID] or {}
            GMOD.setting[ID][Name] = value.value
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------------------------------
