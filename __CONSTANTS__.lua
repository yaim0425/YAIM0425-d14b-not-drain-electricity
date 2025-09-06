---------------------------------------------------------------------------------------------------
---> __CONSTANTS__.lua <---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Inicializar el contenedor <---
---------------------------------------------------------------------------------------------------

--- Contenedor global para TODOS los MODs de YAIM0425
_G.GMOD = _G.GMOD or {}

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Constantes globales <---
---------------------------------------------------------------------------------------------------

--- Prefijo a usar en los MODs
GMOD.name = "YAIM0425"

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---> Constantes adicionales <---
---------------------------------------------------------------------------------------------------

--- Validación
if not (data and data.raw) then return end

--- Subgrupos existentes, se usa con frecuencia
GMOD.subgroups = data.raw["item-subgroup"]

--- Colores para el fondo de los indicadres
GMOD.color = {
    black = data.raw["virtual-signal"]["signal-black"].icon,
    blue = data.raw["virtual-signal"]["signal-blue"].icon,
    cyan = data.raw["virtual-signal"]["signal-cyan"].icon,
    green = data.raw["virtual-signal"]["signal-green"].icon,
    grey = data.raw["virtual-signal"]["signal-grey"].icon,
    pink = data.raw["virtual-signal"]["signal-pink"].icon,
    red = data.raw["virtual-signal"]["signal-red"].icon,
    white = data.raw["virtual-signal"]["signal-white"].icon,
    yellow = data.raw["virtual-signal"]["signal-yellow"].icon,
}

---------------------------------------------------------------------------------------------------
