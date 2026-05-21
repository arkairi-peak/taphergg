--[[
    TapherLib/Theme.lua
    Premium obsidian glass palette — iPhone-quality frosted dark UI.
    Deep blacks, crisp white borders at low opacity, electric violet accent.
]]

local Theme = {}

-- ── Default: Deep Obsidian Glass ─────────────────────────────────────────────
Theme.Default = {
    -- Core backgrounds — near-black with a whisper of violet depth
    Background        = Color3.fromRGB(5,    5,    9),
    Surface           = Color3.fromRGB(11,   11,   19),
    SurfaceLight      = Color3.fromRGB(19,   19,   32),
    SurfaceLighter    = Color3.fromRGB(29,   29,   46),

    -- Glass values
    GlassTransparency = 0.38,   -- window pane opacity (lower = more opaque)
    BlurSize          = 0,      -- no engine blur (glassmorphism from transparency)

    -- Borders — pure white at very low opacity = frosted glass edge
    Border            = Color3.fromRGB(255, 255, 255),
    BorderLight       = Color3.fromRGB(255, 255, 255),
    BorderTransp      = 0.82,

    -- Accent — premium electric violet (like iOS purple / Vision Pro)
    Accent            = Color3.fromRGB(124, 95,  255),
    AccentHover       = Color3.fromRGB(155, 128, 255),
    AccentDim         = Color3.fromRGB(72,  52,  190),
    AccentGlow        = Color3.fromRGB(124, 95,  255),

    -- Status
    Success           = Color3.fromRGB(48,  209, 148),
    Warning           = Color3.fromRGB(255, 185, 40),
    Error             = Color3.fromRGB(255, 95,  95),
    Info              = Color3.fromRGB(90,  160, 255),

    -- Text — ultra crisp white hierarchy
    TextPrimary       = Color3.fromRGB(252, 252, 255),
    TextSecondary     = Color3.fromRGB(165, 165, 200),
    TextMuted         = Color3.fromRGB(75,  75,  108),
    TextAccent        = Color3.fromRGB(155, 128, 255),

    -- Component internals
    ToggleOff         = Color3.fromRGB(20,  20,  34),
    SliderTrack       = Color3.fromRGB(14,  14,  24),
    TabInactive       = Color3.fromRGB(13,  13,  22),
    InputBg           = Color3.fromRGB(7,   7,   13),

    Shadow            = Color3.fromRGB(0,   0,   0),
    Glow              = Color3.fromRGB(124, 95,  255),
}

Theme.Current = {}
for k, v in pairs(Theme.Default) do Theme.Current[k] = v end

-- ── Accent presets ────────────────────────────────────────────────────────────
Theme.Presets = {
    Violet  = { Accent = Color3.fromRGB(124, 95,  255), AccentHover = Color3.fromRGB(155, 128, 255), AccentDim = Color3.fromRGB(72,  52,  190), AccentGlow = Color3.fromRGB(124, 95,  255) },
    Blue    = { Accent = Color3.fromRGB(55,  125, 255), AccentHover = Color3.fromRGB(90,  160, 255), AccentDim = Color3.fromRGB(28,  68,  170), AccentGlow = Color3.fromRGB(55,  125, 255) },
    Cyan    = { Accent = Color3.fromRGB(2,   178, 214), AccentHover = Color3.fromRGB(30,  210, 240), AccentDim = Color3.fromRGB(5,   105, 140), AccentGlow = Color3.fromRGB(2,   178, 214) },
    Pink    = { Accent = Color3.fromRGB(240, 68,  150), AccentHover = Color3.fromRGB(255, 115, 185), AccentDim = Color3.fromRGB(145, 36,  95),  AccentGlow = Color3.fromRGB(240, 68,  150) },
    Green   = { Accent = Color3.fromRGB(12,  183, 125), AccentHover = Color3.fromRGB(48,  209, 155), AccentDim = Color3.fromRGB(8,   108, 76),  AccentGlow = Color3.fromRGB(12,  183, 125) },
    Red     = { Accent = Color3.fromRGB(242, 62,  62),  AccentHover = Color3.fromRGB(255, 105, 105), AccentDim = Color3.fromRGB(145, 35,  35),  AccentGlow = Color3.fromRGB(242, 62,  62)  },
    Orange  = { Accent = Color3.fromRGB(252, 110, 18),  AccentHover = Color3.fromRGB(255, 155, 65),  AccentDim = Color3.fromRGB(152, 62,  8),   AccentGlow = Color3.fromRGB(252, 110, 18)  },
    Gold    = { Accent = Color3.fromRGB(238, 180, 8),   AccentHover = Color3.fromRGB(255, 222, 65),  AccentDim = Color3.fromRGB(145, 102, 4),   AccentGlow = Color3.fromRGB(238, 180, 8)   },
    Rose    = { Accent = Color3.fromRGB(248, 58,  90),  AccentHover = Color3.fromRGB(255, 98,  128), AccentDim = Color3.fromRGB(152, 28,  52),   AccentGlow = Color3.fromRGB(248, 58,  90)  },
    Silver  = { Accent = Color3.fromRGB(168, 168, 192), AccentHover = Color3.fromRGB(210, 210, 230), AccentDim = Color3.fromRGB(90,  90,  115),  AccentGlow = Color3.fromRGB(168, 168, 192) },
}

-- ── SetAccent — also tints all background/surface layers to match hue ─────────
function Theme.SetAccent(accentOrPreset)
    local preset
    if type(accentOrPreset) == "string" then
        preset = Theme.Presets[accentOrPreset]
    elseif typeof(accentOrPreset) == "Color3" then
        local h, s, v = Color3.toHSV(accentOrPreset)
        preset = {
            Accent      = accentOrPreset,
            AccentHover = Color3.fromHSV(h, math.max(0, s - 0.14), math.min(1, v + 0.14)),
            AccentDim   = Color3.fromHSV(h, s, math.max(0, v - 0.26)),
            AccentGlow  = accentOrPreset,
        }
    end
    if preset then
        for k, v in pairs(preset) do Theme.Current[k] = v end
        local acc     = Theme.Current.Accent
        local h, s, _ = Color3.toHSV(acc)
        -- Keep saturation very low so backgrounds stay near-black, just hue-tinted
        Theme.Current.Background     = Color3.fromHSV(h, math.min(s * 0.60, 0.45), 0.035)
        Theme.Current.Surface        = Color3.fromHSV(h, math.min(s * 0.50, 0.40), 0.065)
        Theme.Current.SurfaceLight   = Color3.fromHSV(h, math.min(s * 0.42, 0.35), 0.10)
        Theme.Current.SurfaceLighter = Color3.fromHSV(h, math.min(s * 0.34, 0.30), 0.15)
        Theme.Current.SliderTrack    = Color3.fromHSV(h, math.min(s * 0.42, 0.35), 0.075)
        Theme.Current.TabInactive    = Color3.fromHSV(h, math.min(s * 0.42, 0.35), 0.065)
        Theme.Current.InputBg        = Color3.fromHSV(h, math.min(s * 0.52, 0.42), 0.032)
        Theme.Current.ToggleOff      = Color3.fromHSV(h, math.min(s * 0.32, 0.28), 0.09)
        Theme.Current.TextAccent     = Theme.Current.AccentHover
        Theme.Current.Glow           = acc
    end
end

function Theme.Set(key, value)  Theme.Current[key] = value end
function Theme.Get(key)         return Theme.Current[key]  end
function Theme.Reset()
    for k, v in pairs(Theme.Default) do Theme.Current[k] = v end
end

return Theme
