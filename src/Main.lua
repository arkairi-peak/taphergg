--[[
    TapherLib/Main.lua
    Core loader — entry point for the library.
    
    Usage:
        local Tapher = loadstring(game:HttpGet('YOUR_RAW_URL/TapherLib/Main.lua'))()

        local Window = Tapher:CreateWindow({
            Title    = "My Script",
            Subtitle = "by you",
            Icon     = "◈",
            Keybind  = Enum.KeyCode.RightShift,   -- toggle hide/show
            Watermark = true,
            SearchBar = true,
        })

        local Tab = Window:AddTab({ Name = "Main", Icon = "⚡" })

        Tab:AddButton({
            Name        = "Click Me",
            Description = "Does something cool",
            Callback    = function() print("clicked!") end,
        })

        Tab:AddToggle({
            Name     = "God Mode",
            Default  = false,
            Flag     = "GodMode",   -- used for config save/load
            Callback = function(val) print("Toggle:", val) end,
        })

        Tab:AddSlider({
            Name     = "Walk Speed",
            Min      = 16,
            Max      = 500,
            Step     = 1,
            Default  = 16,
            Flag     = "WalkSpeed",
            Callback = function(val)
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
            end,
        })

        Tab:AddDropdown({
            Name     = "Team",
            Options  = { "Red", "Blue", "Green" },
            Default  = "Red",
            Flag     = "Team",
            Callback = function(val) print("Selected:", val) end,
        })

        Tab:AddTextInput({
            Name        = "Player Name",
            Placeholder = "Enter name...",
            Flag        = "PlayerName",
            Callback    = function(text, enter) print("Input:", text) end,
        })

        Tab:AddColorPicker({
            Name     = "ESP Color",
            Default  = Color3.fromRGB(255, 0, 0),
            Flag     = "ESPColor",
            Callback = function(color) print("Color:", color) end,
        })

        -- Notifications
        Tapher:Notify({
            Title       = "Loaded!",
            Description = "TapherLib is ready.",
            Type        = "success",
            Style       = "Bounce",
            Duration    = 4,
        })

        -- Save/load config
        Tapher:SaveConfig("default")
        Tapher:LoadConfig("default")

        -- Change accent at runtime
        Tapher:SetAccent("Purple")                         -- preset
        Tapher:SetAccent(Color3.fromRGB(255, 50, 150))     -- custom
]]

-- ── Module paths (update BASE_URL before hosting) ───────────────────────────
local BASE_URL = "YOUR_RAW_URL_HERE"   -- e.g. https://raw.githubusercontent.com/you/repo/main/TapherLib

local function req(path)
    -- Try loadstring from URL first, fall back to require for local dev
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. "/" .. path))()
    end)
    if ok then return result end
    -- Local fallback (for Studio testing with file system)
    return require(script.Parent[path:gsub("%.lua$", "")])
end

-- ── Load modules ────────────────────────────────────────────────────────────
local Theme         = req("Theme.lua")
local Utility       = req("Utility.lua")
local Config        = req("Config.lua")
local Components    = req("Components.lua")
local Notifications = req("Notifications.lua")

-- Inject cross-dependencies
Components._init(Theme, Utility, Config)
Notifications._init(Theme, Utility)

-- ── TapherLib public API ─────────────────────────────────────────────────────
local TapherLib = {}
TapherLib.__index = TapherLib

-- Create a new window
function TapherLib:CreateWindow(opts)
    return Components.CreateWindow(opts)
end

-- Send a notification
function TapherLib:Notify(opts)
    return Notifications.Send(opts)
end

-- Shorthand notifications
function TapherLib:NotifySuccess(title, desc, style)
    return Notifications.Success(title, desc, style)
end

function TapherLib:NotifyError(title, desc, style)
    return Notifications.Error(title, desc, style)
end

function TapherLib:NotifyWarning(title, desc, style)
    return Notifications.Warning(title, desc, style)
end

function TapherLib:NotifyInfo(title, desc, style)
    return Notifications.Info(title, desc, style)
end

function TapherLib:NotifyTyping(title, desc)
    return Notifications.Typing(title, desc)
end

-- Change accent color at runtime
-- accentOrPreset: "Blue"|"Purple"|"Cyan"|"Pink"|"Green"|"Red"|"Orange" OR a Color3
function TapherLib:SetAccent(accentOrPreset)
    Theme.SetAccent(accentOrPreset)
end

-- Override any individual theme value
function TapherLib:SetTheme(key, value)
    Theme.Set(key, value)
end

-- Save all registered flags to a profile
function TapherLib:SaveConfig(profileName)
    return Config.SaveAll(profileName)
end

-- Load all registered flags from a profile
function TapherLib:LoadConfig(profileName)
    return Config.LoadAll(profileName)
end

-- Expose submodules for advanced usage
TapherLib.Theme         = Theme
TapherLib.Utility       = Utility
TapherLib.Config        = Config
TapherLib.Notifications = Notifications

-- Version info
TapherLib.Version = "1.0.0"

print("[TapherLib] v" .. TapherLib.Version .. " loaded successfully.")

return TapherLib
