--[[
    TapherLib/Theme.lua
    Handles all colors, glassmorphism values, and customisable accent system.
]]

local Theme = {}

-- ── Default Palette ──────────────────────────────────────────────────────────
Theme.Default = {
    -- Backgrounds (glassmorphism layers)
    Background        = Color3.fromRGB(8,   12,  28),    -- deepest bg
    Surface           = Color3.fromRGB(14,  20,  45),    -- window glass
    SurfaceLight      = Color3.fromRGB(20,  28,  60),    -- element bg
    SurfaceLighter    = Color3.fromRGB(28,  38,  80),    -- hover / active
    GlassTransparency = 0.35,                             -- main glass opacity
    BlurSize          = 24,                               -- BlurEffect size

    -- Borders
    Border            = Color3.fromRGB(60,  80,  140),
    BorderLight       = Color3.fromRGB(80,  110, 200),
    BorderTransp      = 0.55,

    -- Accent (customisable — dark blue default)
    Accent            = Color3.fromRGB(50,  100, 220),
    AccentHover       = Color3.fromRGB(80,  130, 255),
    AccentDim         = Color3.fromRGB(30,  60,  140),
    AccentGlow        = Color3.fromRGB(50,  100, 220),

    -- Status
    Success           = Color3.fromRGB(52,  211, 153),
    Warning           = Color3.fromRGB(251, 191, 36),
    Error             = Color3.fromRGB(248, 113, 113),
    Info              = Color3.fromRGB(96,  165, 250),

    -- Text
    TextPrimary       = Color3.fromRGB(240, 240, 240),
    TextSecondary     = Color3.fromRGB(216, 216, 216),
    TextMuted         = Color3.fromRGB(160,  160,  160),
    TextAccent        = Color3.fromRGB(250,  250, 250),

    -- Components
    ToggleOff         = Color3.fromRGB(30,  35,  70),
    SliderTrack       = Color3.fromRGB(22,  28,  58),
    TabInactive       = Color3.fromRGB(16,  22,  50),
    InputBg           = Color3.fromRGB(12,  18,  40),

    -- Shadows / glow
    Shadow            = Color3.fromRGB(0,   5,   20),
    Glow              = Color3.fromRGB(50,  100, 220),
}

-- Active theme (starts as default, mutated by SetAccent / SetTheme)
Theme.Current = {}
for k, v in pairs(Theme.Default) do
    Theme.Current[k] = v
end

-- ── Accent Presets ───────────────────────────────────────────────────────────
Theme.Presets = {
    Blue    = { Accent = Color3.fromRGB(50,  100, 220), AccentHover = Color3.fromRGB(80,  130, 255), AccentDim = Color3.fromRGB(30, 60, 140), AccentGlow = Color3.fromRGB(50, 100, 220) },
    Purple  = { Accent = Color3.fromRGB(139, 92,  246), AccentHover = Color3.fromRGB(167, 130, 255), AccentDim = Color3.fromRGB(80, 50, 160), AccentGlow = Color3.fromRGB(139, 92, 246) },
    Cyan    = { Accent = Color3.fromRGB(34,  211, 238), AccentHover = Color3.fromRGB(100, 230, 255), AccentDim = Color3.fromRGB(20, 130, 160), AccentGlow = Color3.fromRGB(34, 211, 238) },
    Pink    = { Accent = Color3.fromRGB(236, 72,  153), AccentHover = Color3.fromRGB(255, 120, 190), AccentDim = Color3.fromRGB(140, 40, 100), AccentGlow = Color3.fromRGB(236, 72, 153) },
    Green   = { Accent = Color3.fromRGB(52,  211, 153), AccentHover = Color3.fromRGB(100, 240, 190), AccentDim = Color3.fromRGB(30, 130, 90),  AccentGlow = Color3.fromRGB(52, 211, 153) },
    Red     = { Accent = Color3.fromRGB(239, 68,  68),  AccentHover = Color3.fromRGB(255, 110, 110), AccentDim = Color3.fromRGB(140, 40, 40),  AccentGlow = Color3.fromRGB(239, 68, 68)  },
    Orange  = { Accent = Color3.fromRGB(251, 146, 60),  AccentHover = Color3.fromRGB(255, 180, 100), AccentDim = Color3.fromRGB(150, 80, 20),  AccentGlow = Color3.fromRGB(251, 146, 60)  },
}

-- ── API ──────────────────────────────────────────────────────────────────────

-- Set accent by preset name OR custom Color3
-- Also shifts background/surface to a dark tinted version of the accent hue
function Theme.SetAccent(accentOrPreset)
    local preset
    if type(accentOrPreset) == "string" then
        preset = Theme.Presets[accentOrPreset]
    elseif typeof(accentOrPreset) == "Color3" then
        local h, s, v = Color3.toHSV(accentOrPreset)
        preset = {
            Accent      = accentOrPreset,
            AccentHover = Color3.fromHSV(h, math.max(0, s - 0.15), math.min(1, v + 0.15)),
            AccentDim   = Color3.fromHSV(h, s, math.max(0, v - 0.25)),
            AccentGlow  = accentOrPreset,
        }
    end
    if preset then
        for k, v in pairs(preset) do
            Theme.Current[k] = v
        end
        -- Derive dark background tints from accent hue
        local acc = Theme.Current.Accent
        local h, s, _ = Color3.toHSV(acc)
        -- Keep saturation low and value very dark for backgrounds
        Theme.Current.Background     = Color3.fromHSV(h, math.min(s, 0.55), 0.07)
        Theme.Current.Surface        = Color3.fromHSV(h, math.min(s, 0.50), 0.10)
        Theme.Current.SurfaceLight   = Color3.fromHSV(h, math.min(s, 0.45), 0.14)
        Theme.Current.SurfaceLighter = Color3.fromHSV(h, math.min(s, 0.40), 0.18)
        Theme.Current.Border         = Color3.fromHSV(h, math.min(s, 0.50), 0.28)
        Theme.Current.BorderLight    = Color3.fromHSV(h, math.min(s, 0.45), 0.38)
        Theme.Current.SliderTrack    = Color3.fromHSV(h, math.min(s, 0.45), 0.12)
        Theme.Current.TabInactive    = Color3.fromHSV(h, math.min(s, 0.45), 0.10)
        Theme.Current.InputBg        = Color3.fromHSV(h, math.min(s, 0.50), 0.07)
        Theme.Current.ToggleOff      = Color3.fromHSV(h, math.min(s, 0.35), 0.15)
    end
end

-- Override any theme value
function Theme.Set(key, value)
    Theme.Current[key] = value
end

-- Get shorthand
function Theme.Get(key)
    return Theme.Current[key]
end

-- Reset to default
function Theme.Reset()
    for k, v in pairs(Theme.Default) do
        Theme.Current[k] = v
    end
end

return Theme
