---------------------------------------------------------------------------------------------------
---> __FUNCTIONS__.lua <---
---------------------------------------------------------------------------------------------------

--- Obtiener información del nombre de la carpeta
--- that_mod.id
--- that_mod.name
--- that_mod.prefix
function GMOD.get_id_and_name(that_mod)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nivel 2 porque se llama desde otra función
    local Info = debug.getinfo(2, "S")
    local Source = Info.source

    --- Elimina el prefijo @ si viene de un archivo
    local Path = Source:sub(1, 1) == "@" and Source:sub(2) or Source

    --- Objetener el nombre del directorio
    local Mod_name = Path:match("__([^/]+)__")
    if not Mod_name then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Separa de la cadena dada los IDs y el resto del nombre
    --- @param full_name string
    --- @return table|nil # IDs encontrados como lista
    --- @return string|nil # Nombre sin los IDs ni el prefijo
    local function get_id_and_name(full_name)
        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Contenedor del nombre en partes
        local Parts = {}

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        -- Dividir en partes separadas por guiones
        for segment in string.gmatch(full_name, "[^%-]+") do
            if segment ~= GMOD.name then
                table.insert(Parts, segment)
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        -- Extraer los IDs válidos
        local IDs, Rest_parts = {}, {}
        for _, Part in ipairs(Parts) do
            if Part:match("^[a-z]%d[A-Z]%d%d[a-z]$") then
                table.insert(IDs, Part)
            else
                table.insert(Rest_parts, Part)
            end
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- No hay IDs
        if #IDs == 0 then return nil, nil end

        --- Devolver IDs y resto del nombre directamente
        return IDs, #Rest_parts > 0 and table.concat(Rest_parts, "-") or nil

        --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Dividir el nombre por guiones
    local IDs, Name = get_id_and_name(Mod_name)

    --- Información propia del mod
    that_mod.id = IDs and IDs[1] or nil
    that_mod.name = Name
    that_mod.prefix = GMOD.name .. "-" .. IDs .. "-"

    return that_mod

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------

--- Copia cada tabla se copia siempre, sin compartir referencias
--- @param orig any
--- @return any
function GMOD.copy(orig)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valdación
    if type(orig) ~= "table" then
        return orig
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Variable de salida
    local Copy = {}

    --- Copiar la información
    for k, v in pairs(orig) do
        local New_key = (type(k) == "table") and GPrefix.copy(k) or k
        local New_val = (type(v) == "table") and GPrefix.copy(v) or v
        Copy[New_key] = New_val
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Devolver la copia
    return Copy

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

--- Muestra información detallada de las variables dadas
--- @param ... any
function GMOD.var_dump(...)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Renombrar los parametros dados
    local Args = { ... }
    if #Args == 0 then return end

    --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Convierte una variable a string legible
    --- @param value any
    --- @param indent string|nil
    --- @param seen table<table, string>  -- Guarda referencias ya vistas y sus rutas
    --- @param path string
    local function to_string(value, indent, seen, path)
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Variables a usar
        --- --- --- --- --- --- --- --- --- --- --- --- ---
        indent = indent or ""
        seen = seen or {}
        path = path or "<root>"

        local Type = type(value)

        --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Timpo de valor simple
        --- --- --- --- --- --- --- --- --- --- --- --- ---

        if Type == "string" then
            if string.find(value, "\n") then
                value = value:match("^%s*(.-)%s*$")
                value = value:gsub("\t", "")
                value = value:gsub("  ", " ")
                value = "[[\n\t" .. value .. "\n]]"
                for i = 1, GPrefix.get_length(seen), 1 do
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

        --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- ---
        ---> Tablas
        --- --- --- --- --- --- --- --- --- --- --- --- ---

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

        --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Permite reutilizar la tabla en otras ramas sin error
        seen[value] = nil

        --- Tabla vicia
        if not Has_items then
            return "{ }"
        end

        --- Devolver el resultado
        return "{" .. table.concat(Items, ",") .. "\n" .. indent .. "}"

        --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contendor del texto de salida
    local Output = {}

    --- Recorrer los valores dados
    for i, v in ipairs(Args) do
        local Name = (type(v) == "table" and type(v.name) == "string") and "'" .. v.name .. "'" or "" .. i
        local Result = "[" .. Name .. "] = " .. to_string(v, "", {}, Name)
        table.insert(Output, Result)
    end

    ---> Mostrar el resultado
    log("\n>>>\n" .. table.concat(Output, "\n") .. "\n<<<")

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------------------------------
