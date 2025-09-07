---------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Validar si se cargó antes <---
---------------------------------------------------------------------------

if GMOD and GMOD.name then return end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Cargar las funciones y constantes <---
---------------------------------------------------------------------------

require("__CONSTANTS__")
require("__FUNCTIONS__")

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Contenedor de este archivo <---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Inicio del MOD <---
---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Darle formato a las propiedades
    This_MOD.format_minable()
    This_MOD.format_icons()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cambiar los orders de los elementos
    This_MOD.change_orders()

    --- Establecer traducción en todos los elementos
    This_MOD.set_localised()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---> Funciones locales <---
---------------------------------------------------------------------------

--- Darle formato a la propiedad "minable"
function This_MOD.format_minable()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    --- @param element table
    local function format(element)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar
        if not element.minable then return end
        if not element.minable.result then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Dar el formato deseado
        element.minable.results = { {
            type = "item",
            name = element.minable.result,
            amount = element.minable.count or 1
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Borrar los valores reubicados
        element.minable.result = nil
        element.minable.count = nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    for _, elements in pairs(data.raw) do
        for _, element in pairs(elements) do
            format(element)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Darle formato a la propiedad "icons"
function This_MOD.format_icons()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    --- @param element table
    local function format(element)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar
        if element.icons then return end
        if not element.icon then return end
        if type(element.icon) ~= "string" then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Dar el formato deseado
        element.icons = { {
            icon = element.icon,
            icon_size = element.icon_size ~= 64 and element.icon_size or nil
        } }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Borrar los valores reubicados
        element.icon_size = nil
        element.icon = nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Hacer el cambio
    for _, elements in pairs(data.raw) do
        for _, element in pairs(elements) do
            format(element)
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

--- Clasificar la información de data.raw
--- GMOD.items
--- GMOD.tiles
--- GMOD.fluids
--- GMOD.recipes
--- GMOD.entities
--- GMOD.equipments
function This_MOD.filter_data()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Contenedores finales
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.items = {}
    GMOD.tiles = {}
    GMOD.fluids = {}
    GMOD.recipes = {}
    GMOD.entities = {}
    GMOD.equipments = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Otras funciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validar si está oculta
    local function is_hidde(array)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Hidden = false
        Hidden = Hidden or array.hidden
        Hidden = Hidden or array.parameter
        Hidden = Hidden or GMOD.get_key(array.flags, "hidden")
        Hidden = Hidden or GMOD.get_key(array.flags, "spawnable")
        if Hidden then return true end
        return false

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Agrega las Recetas, Suelos y Objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Agregar la receta a GMOD.recipes
    local function add_recipe(recipe)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Vaidación
        if is_hidde(recipe) then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Guardar referencia de los ingredientes
        for _, ingredient in pairs(recipe.ingredients or {}) do
            if ingredient.type == "item" then GMOD.items[ingredient.name] = true end
            if ingredient.type == "fluid" then GMOD.fluids[ingredient.name] = true end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Agregar el suelo a GMOD.tiles
    local function add_tile(tile)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not tile.minable then return end
        if not tile.minable.results then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- Agregar el item a GMOD.items
    local function add_item(item)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validación
        if not item.stack_size then return end
        if is_hidde(item) then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Guardar objeto
        GMOD.items[item.name] = item

        --- Guardar suelo de no estarlo
        if item.place_as_tile and not GMOD.tiles[item.name] then
            local Tile = data.raw.tile[item.place_as_tile.result]
            GMOD.tiles[item.name] = GMOD.tiles[item.name] or {}
            table.insert(GMOD.tiles[item.name], Tile)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cargar las Recetas, Suelos, Fluidos y Objetos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Buscar y cargar las Entidades y los Equipos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Evitar estos tipos
    local Ignore_types = {
        tile = true,
        fluid = true,
        recipe = true
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Eliminar los elementos que no se pudieron cargar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Identificar valores vacios
    for iKey, elemnts in pairs(Array) do
        for jKey, elemnt in pairs(elemnts) do
            if type(elemnt) == "boolean" then
                Info = Info .. "\n\t\t"
                Info = Info .. iKey .. " not found or hidden: " .. jKey
                table.insert(Delete, { elemnts, jKey })
            end
        end
    end

    --- Eliminar valores vacios
    for _, value in pairs(Delete) do
        value[1][value[2]] = nil
    end

    --- Imprimir un informe de lo eliminados
    if #Delete >= 1 then log(Info) end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Clasificar la información de settings.startup
--- GMOD.Setting
function This_MOD.load_setting()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

--- Cambiar los orders de los elementos
function This_MOD.change_orders()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Inicializar las vaiables
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Orders = {}
    local Source = {}
    local N = 0

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Grupos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Subgrupos
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar las vaiables
    Orders = {}
    Source = {}

    --- Agrupar los subgroups
    for _, element in pairs(GMOD.subgroups) do
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        Source[element.group] = Source[element.group] or {}
        table.insert(Source[element.group], element)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        Orders[element.group] = Orders[element.group] or {}
        table.insert(Orders[element.group], element.order or element.name)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---



    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Establecer subgrupos por defecto
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Subgrupos por defecto
    local Empty = {
        type = "item-subgroup",
        name = "subgroup-empty",
        group = "other",
        order = "999"
    }

    --- Crear el Subgrupos por defecto
    data:extend({ Empty })

    --- Objetos, recetas y fluidos
    for Key, Values in pairs({
        items = GMOD.items,
        fluids = GMOD.fluids,
        recipes = GMOD.recipes
    }) do
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Objetos, recetas y demás
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

                --- Elementos a agrupar
                Source[element.subgroup] = Source[element.subgroup] or {}
                table.insert(Source[element.subgroup], element)

                --- Elementos a ordenar
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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Agrupar las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

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

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Establecer traducción en todos los elementos
function This_MOD.set_localised()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Traducir estas secciones
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Establecer la traducción
    for name, subgroup in pairs({
        tile = GMOD.tiles,
        fluid = GMOD.fluids,
        entity = GMOD.entities,
        equipment = GMOD.equipments
    }) do
        if name ~= "tile" then subgroup = { subgroup } end
        for _, elements in pairs(subgroup) do
            for _, element in pairs(elements) do
                if element.localised_name then
                    if type(element.localised_name) == "table" and element.localised_name[1] ~= "" then
                        element.localised_name = { "", element.localised_name }
                    end
                end
                if not element.localised_name then
                    element.localised_name = { "", { name .. "-name." .. element.name } }
                end
                if not element.localised_description then
                    element.localised_description = { "", { name .. "-description." .. element.name } }
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Funciones a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Establece el nombre de la receta
    local function set_localised(name, recipe, field)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Valores a usar
        local Field = "localised_" .. field
        local fluid = GMOD.fluids[name]
        local item = GMOD.items[name]

        --- El resultado es un objeto
        if item then
            --- Nombre del objeto por defecto
            recipe[Field] = item[Field]

            --- Traducción para una entidad
            if item.place_result then
                local Entiy = GMOD.entities[item.place_result]
                item[Field] = Entiy[Field]
                recipe[Field] = Entiy[Field]
            end

            --- Traducción para un suelo
            if item.place_as_tile then
                local tile = data.raw.tile[item.place_as_tile.result]
                item[Field] = tile[Field]
                recipe[Field] = tile[Field]
            end

            --- Traducción para un equipamiento
            if item.place_as_equipment_result then
                local result = item.place_as_equipment_result
                local equipment = GMOD.equipments[result]
                if equipment then
                    item[Field] = equipment[Field]
                    recipe[Field] = equipment[Field]
                end
            end

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end

        --- El resultado es un liquido
        if fluid then recipe[Field] = fluid[Field] end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Traducción de los objetos y las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Establecer la traducción de los objetos
    for _, item in pairs(GMOD.items) do
        if item.localised_name then
            if type(item.localised_name) == "table" and item.localised_name[1] ~= "" then
                item.localised_name = { "", item.localised_name }
            end
        end
        for _, field in pairs({ "name", "description" }) do
            local Field = "localised_" .. field
            if not item[Field] then
                item[Field] = { "", { "item-" .. field .. "." .. item.name } }
                set_localised(item.name, {}, field)
            end
        end
    end

    --- Establecer la traducción en la receta
    for _, recipes in pairs(GMOD.recipes) do
        if recipes.localised_name then
            if type(recipes.localised_name) == "table" and recipes.localised_name[1] ~= "" then
                recipes.localised_name = { "", recipes.localised_name }
            end
        end

        for _, recipe in pairs(recipes) do
            for _, field in pairs({ "name", "description" }) do
                local Field = "localised_" .. field
                --- Establece el nombre de la receta
                if not recipe[Field] then
                    --- Recetas con varios resultados
                    if #recipe.results ~= 1 then
                        if not recipe.main_product or recipe.main_product == "" then
                            --- Traducción por defecto
                            recipe[Field] = { "", { "recipe-" .. field .. "." .. recipe.name } }
                        else
                            --- Usar objeto o fluido de referencia
                            set_localised(recipe.main_product, recipe, field)
                        end
                    end

                    --- Receta con unico resultado
                    if #recipe.results == 1 then
                        local result = recipe.results[1]
                        set_localised(result.name, recipe, field)
                    end
                end
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Traducción de las tecnologias
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Actualizar el apodo del nombre
    for _, tech in pairs(data.raw.technology) do
        --- Renombrar
        local Full_name = tech.name

        --- Separar la información
        local Name, Level = Full_name:match("(.+)-(%d+)")
        if Level then Level = " " .. (Level or "") end
        if not Name then Name = Full_name end

        --- Corrección para las tecnologías infinitas
        if tech.unit and tech.unit.count_formula then
            Level = nil
        end

        --- Construir el apodo
        if tech.localised_name then
            if tech.localised_name[1] ~= "" then
                tech.localised_name = { "", tech.localised_name }
            end
        else
            tech.localised_name = { "", { "technology-name." .. Name }, Level }
        end
        tech.localised_description = { "", { "technology-description." .. Name } }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------

--- Iniciar el MOD
This_MOD.start()

---------------------------------------------------------------------------
