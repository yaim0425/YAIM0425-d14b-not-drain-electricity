---------------------------------------------------------------------------------------------------
---[ __CONSTANTS__.lua ]---
---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Valiación ]---
---------------------------------------------------------------------------------------------------

--- Validar si se cargó antes
if _G.GMOD then return end

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Inicializar el contenedor ]---
---------------------------------------------------------------------------------------------------

--- Contenedor global para TODOS los MODs de YAIM0425
_G.GMOD = _G.GMOD or {}

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Constantes globales ]---
---------------------------------------------------------------------------------------------------

--- Prefijo a usar en los MODs
GMOD.name = "YAIM0425"

---------------------------------------------------------------------------------------------------





---------------------------------------------------------------------------------------------------
---[ Constantes adicionales ]---
---------------------------------------------------------------------------------------------------

--- Validación
if not data then return end
if not data.raw then return end
if not data.raw["item-subgroup"] then return end
if not data.raw["virtual-signal"] then return end

--- Para que Visual Studio Code no moleste
_G.log = _G.log or function(...) end
_G.prototypes = _G.prototypes or {}
_G.settings = _G.settings or {}
_G.defines = _G.defines or {}
_G.script = _G.script or {}
_G.game = _G.game or {}
_G.mods = _G.mods or {}

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
