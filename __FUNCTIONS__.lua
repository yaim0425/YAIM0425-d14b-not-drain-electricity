---------------------------------------------------------------------------------------------------
---> __FUNCTIONS__.lua <---
---------------------------------------------------------------------------------------------------



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

---------------------------------------------------------------------------------------------------
