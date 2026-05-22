--[[
    TapherLib/Theme.lua
    Premium dark glass palette — obvious tinted backgrounds, rich accents.
]]

local Theme = {}

Theme.Default = {
    Background        = Color3.fromRGB(5,    4,    14),
    Surface           = Color3.fromRGB(10,   8,    24),
    SurfaceLight      = Color3.fromRGB(18,   15,   40),
    SurfaceLighter    = Color3.fromRGB(28,   23,   58),
    GlassTransparency = 0.22,
    BlurSize          = 0,
    Border            = Color3.fromRGB(255,  255,  255),
    BorderLight       = Color3.fromRGB(255,  255,  255),
    BorderTransp      = 0.78,
    Accent            = Color3.fromRGB(120,  88,   255),
    AccentHover       = Color3.fromRGB(152,  122,  255),
    AccentDim         = Color3.fromRGB(68,   46,   185),
    AccentGlow        = Color3.fromRGB(120,  88,   255),
    Success           = Color3.fromRGB(48,   209,  148),
    Warning           = Color3.fromRGB(255,  185,  40),
    Error             = Color3.fromRGB(255,  75,   75),
    Info              = Color3.fromRGB(80,   150,  255),
    TextPrimary       = Color3.fromRGB(252,  252,  255),
    TextSecondary     = Color3.fromRGB(160,  160,  198),
    TextMuted         = Color3.fromRGB(72,   72,   105),
    TextAccent        = Color3.fromRGB(152,  122,  255),
    ToggleOff         = Color3.fromRGB(18,   15,   40),
    SliderTrack       = Color3.fromRGB(10,   8,    24),
    TabInactive       = Color3.fromRGB(10,   8,    24),
    InputBg           = Color3.fromRGB(5,    4,    14),
    Shadow            = Color3.fromRGB(0,    0,    0),
    Glow              = Color3.fromRGB(120,  88,   255),
}

Theme.Current = {}
for k, v in pairs(Theme.Default) do Theme.Current[k] = v end

-- ── Accent + Background presets ───────────────────────────────────────────────
Theme.Presets = {
    -- Deep violet — default
    Purple = {
        Accent         = Color3.fromRGB(120,  88,   255),
        AccentHover    = Color3.fromRGB(152,  122,  255),
        AccentDim      = Color3.fromRGB(68,   46,   185),
        AccentGlow     = Color3.fromRGB(120,  88,   255),
        Background     = Color3.fromRGB(5,    4,    14),
        Surface        = Color3.fromRGB(10,   8,    24),
        SurfaceLight   = Color3.fromRGB(18,   15,   40),
        SurfaceLighter = Color3.fromRGB(28,   23,   58),
    },
    -- Deep ocean blue
    Blue = {
        Accent         = Color3.fromRGB(30,   90,   210),
        AccentHover    = Color3.fromRGB(65,   125,  245),
        AccentDim      = Color3.fromRGB(15,   48,   130),
        AccentGlow     = Color3.fromRGB(30,   90,   210),
        Background     = Color3.fromRGB(2,    6,    22),
        Surface        = Color3.fromRGB(4,    10,   36),
        SurfaceLight   = Color3.fromRGB(7,    17,   55),
        SurfaceLighter = Color3.fromRGB(10,   25,   72),
    },
    -- Electric teal
    Cyan = {
        Accent         = Color3.fromRGB(0,    165,  210),
        AccentHover    = Color3.fromRGB(30,   200,  240),
        AccentDim      = Color3.fromRGB(0,    88,   130),
        AccentGlow     = Color3.fromRGB(0,    165,  210),
        Background     = Color3.fromRGB(2,    10,   18),
        Surface        = Color3.fromRGB(3,    16,   28),
        SurfaceLight   = Color3.fromRGB(5,    26,   42),
        SurfaceLighter = Color3.fromRGB(7,    36,   58),
    },
    -- Deep magenta
    Pink = {
        Accent         = Color3.fromRGB(220,  40,   145),
        AccentHover    = Color3.fromRGB(248,  85,   178),
        AccentDim      = Color3.fromRGB(130,  18,   82),
        AccentGlow     = Color3.fromRGB(220,  40,   145),
        Background     = Color3.fromRGB(18,   3,    12),
        Surface        = Color3.fromRGB(28,   5,    19),
        SurfaceLight   = Color3.fromRGB(44,   8,    30),
        SurfaceLighter = Color3.fromRGB(60,   11,   42),
    },
    -- Forest emerald
    Green = {
        Accent         = Color3.fromRGB(8,    172,  110),
        AccentHover    = Color3.fromRGB(42,   208,  148),
        AccentDim      = Color3.fromRGB(4,    98,   62),
        AccentGlow     = Color3.fromRGB(8,    172,  110),
        Background     = Color3.fromRGB(2,    12,   8),
        Surface        = Color3.fromRGB(3,    20,   13),
        SurfaceLight   = Color3.fromRGB(5,    32,   20),
        SurfaceLighter = Color3.fromRGB(7,    44,   28),
    },
    -- Dark crimson
    Red = {
        Accent         = Color3.fromRGB(188,  32,   32),
        AccentHover    = Color3.fromRGB(225,  65,   65),
        AccentDim      = Color3.fromRGB(110,  15,   15),
        AccentGlow     = Color3.fromRGB(188,  32,   32),
        Background     = Color3.fromRGB(18,   2,    2),
        Surface        = Color3.fromRGB(28,   4,    4),
        SurfaceLight   = Color3.fromRGB(45,   7,    7),
        SurfaceLighter = Color3.fromRGB(62,   10,   10),
    },
    -- Molten orange
    Orange = {
        Accent         = Color3.fromRGB(228,  92,   8),
        AccentHover    = Color3.fromRGB(255,  132,  45),
        AccentDim      = Color3.fromRGB(135,  52,   4),
        AccentGlow     = Color3.fromRGB(228,  92,   8),
        Background     = Color3.fromRGB(16,   7,    1),
        Surface        = Color3.fromRGB(26,   11,   2),
        SurfaceLight   = Color3.fromRGB(40,   17,   3),
        SurfaceLighter = Color3.fromRGB(56,   24,   4),
    },
    -- Liquid gold
    Gold = {
        Accent         = Color3.fromRGB(210,  162,  4),
        AccentHover    = Color3.fromRGB(242,  202,  45),
        AccentDim      = Color3.fromRGB(122,  92,   2),
        AccentGlow     = Color3.fromRGB(210,  162,  4),
        Background     = Color3.fromRGB(14,   11,   1),
        Surface        = Color3.fromRGB(22,   17,   2),
        SurfaceLight   = Color3.fromRGB(36,   28,   3),
        SurfaceLighter = Color3.fromRGB(50,   38,   5),
    },
}

-- ── SetAccent ──────────────────────────────────────────────────────────────────
function Theme.SetAccent(accentOrPreset)
    -- Always reset to default first so switching back to Purple works cleanly
    for k, v in pairs(Theme.Default) do
        Theme.Current[k] = v
    end

    local preset
    if type(accentOrPreset) == "string" then
        preset = Theme.Presets[accentOrPreset]
    elseif typeof(accentOrPreset) == "Color3" then
        local h, s, v2 = Color3.toHSV(accentOrPreset)
        preset = {
            Accent         = accentOrPreset,
            AccentHover    = Color3.fromHSV(h, math.max(0, s - 0.12), math.min(1, v2 + 0.12)),
            AccentDim      = Color3.fromHSV(h, s, math.max(0, v2 - 0.25)),
            AccentGlow     = accentOrPreset,
            Background     = Color3.fromHSV(h, math.min(s * 0.7, 0.55), 0.045),
            Surface        = Color3.fromHSV(h, math.min(s * 0.6, 0.48), 0.075),
            SurfaceLight   = Color3.fromHSV(h, math.min(s * 0.5, 0.40), 0.115),
            SurfaceLighter = Color3.fromHSV(h, math.min(s * 0.40, 0.32), 0.165),
        }
    end

    if preset then
        for k, v in pairs(preset) do
            Theme.Current[k] = v
        end
        -- Always keep text readable
        Theme.Current.TextPrimary   = Color3.fromRGB(252, 252, 255)
        Theme.Current.TextSecondary = Color3.fromRGB(160, 160, 198)
        Theme.Current.TextMuted     = Color3.fromRGB(72,  72,  105)
        Theme.Current.TextAccent    = Theme.Current.AccentHover
        Theme.Current.Glow          = Theme.Current.Accent
    end
end

function Theme.Set(key, value)  Theme.Current[key] = value end
function Theme.Get(key)         return Theme.Current[key]  end
function Theme.Reset()
    for k, v in pairs(Theme.Default) do Theme.Current[k] = v end
end

return Theme
