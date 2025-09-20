---------------------------------------------------------------------------
---[ __FUNCTIONS__.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Valiación ]---
---------------------------------------------------------------------------

--- Validar si se cargó antes
if GMOD.copy then return end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Funciones globales ]---
---------------------------------------------------------------------------

--- Obtiener información del nombre de la carpeta
--- that_mod.id
--- that_mod.name
--- that_mod.prefix
function GMOD.get_id_and_name(value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if type(value) ~= "nil" then
        if type(value) ~= "string" then
            return
        end
    else
        --- Nivel 2 porque se llama desde otra función
        local Info = debug.getinfo(2, "S")
        local Source = Info.source

        --- Elimina el prefijo @ si viene de un archivo
        local Path = Source:sub(1, 1) == "@" and Source:sub(2) or Source

        --- Objetener el nombre del directorio
        value = Path:match("__([^/]+)__")
        if not value then return end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Separa de la cadena dada los IDs y el resto del nombre
    --- @param full_name string
    --- @return table|nil # IDs encontrados como lista
    --- @return string|nil # Nombre sin los IDs ni el prefijo
    local function get_id_and_name(full_name)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del nombre en partes
        local Parts = {}

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        -- Dividir en partes separadas por guiones
        for segment in string.gmatch(full_name, "[^%-]+") do
            if segment ~= GMOD.name then
                table.insert(Parts, segment)
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        -- Extraer los IDs válidos
        local IDs, Rest_parts = {}, {}
        for _, Part in ipairs(Parts) do
            if Part:match("^i%dMOD%d%d$") then
                table.insert(IDs, Part)
            else
                table.insert(Rest_parts, Part)
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- No hay IDs
        if #IDs == 0 then return end

        --- El MOD no tiene nombre
        local Rest = nil
        if #Rest_parts > 0 then Rest = table.concat(Rest_parts, "-") end
        if not Rest then return end
        if Rest == "" then return end

        --- Devolver IDs y resto del nombre
        return IDs, Rest

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Dividir el nombre por guiones
    local IDs, Name = get_id_and_name(value)

    --- No es un mod valido
    if not IDs then return end

    --- Información propia del mod
    local Output = {}
    Output.id = IDs[#IDs]
    Output.ids = "-" .. table.concat(IDs, "-") .. "-"
    Output.name = Name
    Output.prefix = GMOD.name .. "-" .. Output.id .. "-"
    return Output

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

--- Devuelve el elemento cuyo key y value se igual al dado
--- @param array table # Tabla en la cual buscar
--- @param key string|nil # propiedad a buscar
--- @param value any|nil # Valor a buscar
--- @return any #
---- Array con las tablas que contienen el key y value dado
---- o nil si no lo encuentra
function GMOD.get_tables(array, key, value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Validación
    if type(array) ~= "table" then return end
    if key == nil and value == nil then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Coincidencias encontradas
    local Results = {}
    local Added_results = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar las coincidencia
    local function Search(tbl)
        local Found = false

        -- Caso: key y value
        if key ~= nil and value ~= nil then
            if tbl[key] == value then
                Found = true
            end
        end

        -- Caso: solo key
        if key ~= nil and value == nil then
            if tbl[key] ~= nil then
                Found = true
            end
        end

        -- Caso: solo value
        if key == nil and value ~= nil then
            for _, v in pairs(tbl) do
                if v == value then
                    Found = true
                    break
                end
            end
        end

        --- Agregar la tabla
        if Found then
            if Added_results[tbl] == nil then
                table.insert(Results, tbl)
            end
        end

        --- Buscar en las subtablas
        for _, v in pairs(tbl) do
            if type(v) == "table" then
                Search(v)
            end
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Iniciar la busqueda
    Search(array)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver el resultado
    return #Results > 0 and Results or nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Contar los elementos en la tabla
---- __ADVERTENCIA:__ El conteo NO es recursivo
--- @param array table # Tabla en la cual buscar
--- @return any #
---- Conteo de los elementos de la tabla
---- o nil si la tabla esta vacia
function GMOD.get_length(array)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valdación
    if type(array) ~= "table" then
        return
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable de salida
    local Output = 0

    --- Contar campos
    for _ in pairs(array) do
        Output = Output + 1
    end

    --- Devolver el resultado
    return Output > 0 and Output or nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Devuelve el key que le corresponde al valor dado
--- @param array table # Tabla en la cual buscar
--- @param value any # Valor a buscar
--- @return any #
---- __integer:__ Posición de la primera coincidencia con el valor
---- __nil:__ El valor dado no es valido
function GMOD.get_key(array, value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valdación
    if type(array) ~= "table" then return end
    if type(value) == "nil" then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Buscar el valor
    for Key, Value in pairs(array) do
        if value == Value then
            return Key
        end
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Cuenta la cantidad de caracteres en el valor dado
--- @param value integer # __Ejemplo:__ _123_
--- @return any # __Ejemplo:__ _3_
function GMOD.digit_count(value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if type(value) ~= "number" then return end
    return string.len(tostring(value))

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Agrega ceros a la izquierda hasta completar los digitos
--- @param digits integer # __Ejemplo:__ _5_
--- @param value integer # __Ejemplo:__ _123_
--- @return string # __Ejemplo:__ _00123_
function GMOD.pad_left_zeros(digits, value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if type(digits) ~= "number" then return "" end
    if type(value) ~= "number" then return "" end
    return string.format("%0" .. digits .. "d", value)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Valida si el nombre contiene el id indicado
--- @param name string
--- @param id string
--- @return boolean
function GMOD.has_id(name, id)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    return name:find("%-" .. id .. "%-") ~= nil

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

--- Copia cada tabla se copia siempre, sin compartir referencias
--- @param value any
--- @return any
function GMOD.copy(value)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valdación
    if type(value) ~= "table" then
        return value
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable de salida
    local Copy = {}

    --- Copiar la información
    for k, v in pairs(value) do
        local New_key = (type(k) == "table") and GMOD.copy(k) or k
        local New_val = (type(v) == "table") and GMOD.copy(v) or v
        Copy[New_key] = New_val
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver la copia
    return Copy

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Muestra información detallada de las variables dadas
--- @param ... any
function GMOD.var_dump(...)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar los parametros dados
    local Args = { ... }
    if #Args == 0 then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Convierte una variable a string legible
    --- @param value any
    --- @param indent string|nil
    --- @param seen table<table, string>  -- Guarda referencias ya vistas y sus rutas
    --- @param path string
    local function to_string(value, indent, seen, path)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---[ Variables a usar
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        indent = indent or ""
        seen = seen or {}
        path = path or "<root>"

        local Type = type(value)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---[ Timpo de valor simple
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Type == "string" then
            if string.find(value, "\n") then
                value = value:match("^%s*(.-)%s*$")
                value = value:gsub("\t", "")
                value = value:gsub("  ", " ")
                value = "[[\n\t" .. value .. "\n]]"
                for i = 1, GMOD.get_length(seen), 1 do
                    value = value:gsub("\n", "\n\t")
                end
                return value
            else
                return "'" .. string.gsub(value, "'", '"') .. "'"
            end
        end

        if Type == "number" or Type == "boolean" or Type == "nil" then
            return tostring(value)
        end

        if Type == "function" or Type == "thread" then
            return Type .. "( ) end"
        end

        if Type == "userdata" then
            return Type
        end

        if Type ~= "table" then
            return '"<unknown>"'
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---[ Tablas
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Evitar referencias circular
        if seen[value] then
            return '"<circular reference to ' .. seen[value] .. '>"'
        end

        --- Ruta hata este valor
        seen[value] = path

        --- Convertir los valores de la taba dada
        local Items = {}
        local Has_items = false
        for k, v in pairs(value) do
            Has_items = true
            local Key_str = "[" .. to_string(k, nil, seen, path .. "." .. tostring(k)) .. "]"
            local New_path = path .. "." .. tostring(k)
            local Val_str = to_string(v, indent .. "  ", seen, New_path)
            Val_str = "\n" .. indent .. "  " .. Key_str .. " = " .. Val_str
            table.insert(Items, Val_str)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Permite reutilizar la tabla en otras ramas sin error
        seen[value] = nil

        --- Tabla vicia
        if not Has_items then
            return "{ }"
        end

        --- Devolver el resultado
        return "{" .. table.concat(Items, ",") .. "\n" .. indent .. "}"

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contendor del texto de salida
    local Output = {}

    --- Recorrer los valores dados
    for i, v in ipairs(Args) do
        local Name = (type(v) == "table" and type(v.name) == "string") and "'" .. v.name .. "'" or "" .. i
        local Result = "[" .. Name .. "] = " .. to_string(v, "", {}, Name)
        table.insert(Output, Result)
    end

    ---[ Mostrar el resultado
    log("\n>>>\n" .. table.concat(Output, "\n") .. "\n<<<")

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------
