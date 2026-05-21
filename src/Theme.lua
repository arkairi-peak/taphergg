--[[
    TapherLib/Theme.lua
    Premium dark glass palette — deep, rich, moody.
]]

local Theme = {}

Theme.Default = {
    Background        = Color3.fromRGB(5,    4,    12),
    Surface           = Color3.fromRGB(10,   9,    22),
    SurfaceLight      = Color3.fromRGB(18,   16,   36),
    SurfaceLighter    = Color3.fromRGB(28,   25,   52),
    GlassTransparency = 0.22,
    BlurSize          = 0,
    Border            = Color3.fromRGB(255, 255, 255),
    BorderLight       = Color3.fromRGB(255, 255, 255),
    BorderTransp      = 0.78,
    Accent            = Color3.fromRGB(120, 88,  255),
    AccentHover       = Color3.fromRGB(152, 122, 255),
    AccentDim         = Color3.fromRGB(68,  46,  185),
    AccentGlow        = Color3.fromRGB(120, 88,  255),
    Success           = Color3.fromRGB(48,  209, 148),
    Warning           = Color3.fromRGB(255, 185, 40),
    Error             = Color3.fromRGB(255, 75,  75),
    Info              = Color3.fromRGB(80,  150, 255),
    TextPrimary       = Color3.fromRGB(252, 252, 255),
    TextSecondary     = Color3.fromRGB(160, 160, 198),
    TextMuted         = Color3.fromRGB(72,  72,  105),
    TextAccent        = Color3.fromRGB(152, 122, 255),
    ToggleOff         = Color3.fromRGB(18,  16,  36),
    SliderTrack       = Color3.fromRGB(12,  11,  26),
    TabInactive       = Color3.fromRGB(12,  11,  24),
    InputBg           = Color3.fromRGB(6,   5,   14),
    Shadow            = Color3.fromRGB(0,   0,   0),
    Glow              = Color3.fromRGB(120, 88,  255),
}

Theme.Current = {}
for k, v in pairs(Theme.Default) do Theme.Current[k] = v end

-- ── Accent presets — each has full background tinting built in ────────────────
-- Format: accent colors + background tint (bg, surf, surfL, surfLighter)
Theme.Presets = {
    -- Deep violet — default premium
    Purple = {
        Accent = Color3.fromRGB(120, 88,  255),
        AccentHover = Color3.fromRGB(152, 122, 255),
        AccentDim   = Color3.fromRGB(68,  46,  185),
        AccentGlow  = Color3.fromRGB(120, 88,  255),
        Background     = Color3.fromRGB(5,   4,   12),
        Surface        = Color3.fromRGB(10,  9,   22),
        SurfaceLight   = Color3.fromRGB(18,  16,  36),
        SurfaceLighter = Color3.fromRGB(28,  25,  52),
    },
    -- Deep navy — rich dark blue, not bright
    Blue = {
        Accent = Color3.fromRGB(48,  105, 230),
        AccentHover = Color3.fromRGB(82,  138, 255),
        AccentDim   = Color3.fromRGB(24,  58,  155),
        AccentGlow  = Color3.fromRGB(48,  105, 230),
        Background     = Color3.fromRGB(3,   6,   18),
        Surface        = Color3.fromRGB(6,   11,  30),
        SurfaceLight   = Color3.fromRGB(10,  18,  48),
        SurfaceLighter = Color3.fromRGB(16,  26,  65),
    },
    -- Electric cyan — deep ocean
    Cyan = {
        Accent = Color3.fromRGB(0,   168, 208),
        AccentHover = Color3.fromRGB(30,  200, 235),
        AccentDim   = Color3.fromRGB(0,   95,  130),
        AccentGlow  = Color3.fromRGB(0,   168, 208),
        Background     = Color3.fromRGB(2,   8,   14),
        Surface        = Color3.fromRGB(4,   14,  22),
        SurfaceLight   = Color3.fromRGB(6,   22,  34),
        SurfaceLighter = Color3.fromRGB(9,   32,  48),
    },
    -- Hot pink — deep magenta
    Pink = {
        Accent = Color3.fromRGB(225, 48,  148),
        AccentHover = Color3.fromRGB(250, 90,  180),
        AccentDim   = Color3.fromRGB(135, 22,  85),
        AccentGlow  = Color3.fromRGB(225, 48,  148),
        Background     = Color3.fromRGB(14,  3,   10),
        Surface        = Color3.fromRGB(22,  6,   16),
        SurfaceLight   = Color3.fromRGB(35,  9,   26),
        SurfaceLighter = Color3.fromRGB(48,  13,  36),
    },
    -- Forest green — deep emerald
    Green = {
        Accent = Color3.fromRGB(10,  178, 118),
        AccentHover = Color3.fromRGB(45,  210, 152),
        AccentDim   = Color3.fromRGB(5,   102, 68),
        AccentGlow  = Color3.fromRGB(10,  178, 118),
        Background     = Color3.fromRGB(2,   10,  7),
        Surface        = Color3.fromRGB(4,   16,  11),
        SurfaceLight   = Color3.fromRGB(6,   26,  18),
        SurfaceLighter = Color3.fromRGB(9,   36,  25),
    },
    -- Crimson — deep dark red, not bright
    Red = {
        Accent = Color3.fromRGB(195, 38,  38),
        AccentHover = Color3.fromRGB(230, 72,  72),
        AccentDim   = Color3.fromRGB(115, 18,  18),
        AccentGlow  = Color3.fromRGB(195, 38,  38),
        Background     = Color3.fromRGB(14,  2,   2),
        Surface        = Color3.fromRGB(22,  4,   4),
        SurfaceLight   = Color3.fromRGB(36,  7,   7),
        SurfaceLighter = Color3.fromRGB(50,  10,  10),
    },
    -- Molten orange
    Orange = {
        Accent = Color3.fromRGB(235, 98,  10),
        AccentHover = Color3.fromRGB(255, 138, 50),
        AccentDim   = Color3.fromRGB(140, 55,  5),
        AccentGlow  = Color3.fromRGB(235, 98,  10),
        Background     = Color3.fromRGB(14,  6,   1),
        Surface        = Color3.fromRGB(22,  9,   2),
        SurfaceLight   = Color3.fromRGB(36,  14,  3),
        SurfaceLighter = Color3.fromRGB(50,  20,  5),
    },
    -- Liquid gold
    Gold = {
        Accent = Color3.fromRGB(212, 165, 5),
        AccentHover = Color3.fromRGB(245, 205, 50),
        AccentDim   = Color3.fromRGB(125, 95,  3),
        AccentGlow  = Color3.fromRGB(212, 165, 5),
        Background     = Color3.fromRGB(12,  9,   1),
        Surface        = Color3.fromRGB(18,  14,  2),
        SurfaceLight   = Color3.fromRGB(28,  22,  3),
        SurfaceLighter = Color3.fromRGB(40,  30,  5),
    },
}

-- ── SetAccent ─────────────────────────────────────────────────────────────────
function Theme.SetAccent(accentOrPreset)
    -- Always reset to default first so switching back to Purple works cleanly
    for k, v in pairs(Theme.Default) do
        Theme.Current[k] = v
    end

    local preset
    if type(accentOrPreset) == "string" then
        preset = Theme.Presets[accentOrPreset]
        -- Try Purple alias
        if not preset and accentOrPreset == "Violet" then
            preset = Theme.Presets["Purple"]
        end
    elseif typeof(accentOrPreset) == "Color3" then
        local h, s, v2 = Color3.toHSV(accentOrPreset)
        preset = {
            Accent      = accentOrPreset,
            AccentHover = Color3.fromHSV(h, math.max(0, s - 0.12), math.min(1, v2 + 0.12)),
            AccentDim   = Color3.fromHSV(h, s, math.max(0, v2 - 0.25)),
            AccentGlow  = accentOrPreset,
            Background     = Color3.fromHSV(h, math.min(s * 0.65, 0.48), 0.038),
            Surface        = Color3.fromHSV(h, math.min(s * 0.55, 0.42), 0.068),
            SurfaceLight   = Color3.fromHSV(h, math.min(s * 0.45, 0.36), 0.105),
            SurfaceLighter = Color3.fromHSV(h, math.min(s * 0.36, 0.30), 0.155),
        }
    end

    if preset then
        for k, v in pairs(preset) do
            Theme.Current[k] = v
        end
        -- Derived values
        Theme.Current.TextAccent  = Theme.Current.AccentHover
        Theme.Current.Glow        = Theme.Current.Accent
        -- Keep text colors consistent regardless of theme
        Theme.Current.TextPrimary   = Color3.fromRGB(252, 252, 255)
        Theme.Current.TextSecondary = Color3.fromRGB(160, 160, 198)
        Theme.Current.TextMuted     = Color3.fromRGB(72,  72,  105)
    end
end

function Theme.Set(key, value)  Theme.Current[key] = value end
function Theme.Get(key)         return Theme.Current[key]  end
function Theme.Reset()
    for k, v in pairs(Theme.Default) do Theme.Current[k] = v end
end

return Theme
