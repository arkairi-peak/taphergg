--[[
    Example.lua — TapherLib demo script
    Replace BASE_URL in Main.lua with your raw GitHub/Pastebin URL first.
]]

local Tapher = loadstring(game:HttpGet('YOUR_RAW_URL/TapherLib/Main.lua'))()

-- ── Create window ────────────────────────────────────────────────────────────
local Window = Tapher:CreateWindow({
    Title     = "Tapher Hub",
    Subtitle  = "v1.0 • by you",
    Icon      = "◈",
    Keybind   = Enum.KeyCode.RightShift,
    Watermark = true,
    SearchBar = true,
})

-- ── Tab: Combat ──────────────────────────────────────────────────────────────
local Combat = Window:AddTab({ Name = "Combat", Icon = "⚔" })

Combat:AddSeparator("Player")

Combat:AddToggle({
    Name     = "Infinite Jump",
    Default  = false,
    Flag     = "InfJump",
    Callback = function(val)
        -- your logic here
    end,
})

Combat:AddSlider({
    Name     = "Walk Speed",
    Min      = 16,
    Max      = 500,
    Step     = 2,
    Default  = 16,
    Flag     = "WalkSpeed",
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end,
})

Combat:AddSlider({
    Name     = "Jump Power",
    Min      = 50,
    Max      = 500,
    Step     = 10,
    Default  = 50,
    Flag     = "JumpPower",
    Callback = function(val)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
    end,
})

Combat:AddSeparator("ESP")

local espColor = Combat:AddColorPicker({
    Name     = "ESP Color",
    Default  = Color3.fromRGB(99, 102, 241),
    Flag     = "ESPColor",
    Callback = function(color)
        print("ESP Color changed:", color)
    end,
})

Combat:AddToggle({
    Name     = "ESP Enabled",
    Default  = false,
    Flag     = "ESPEnabled",
    Callback = function(val)
        print("ESP:", val, "Color:", espColor:Get())
    end,
})

-- ── Tab: Settings ────────────────────────────────────────────────────────────
local Settings = Window:AddTab({ Name = "Settings", Icon = "⚙" })

Settings:AddLabel("Accent Theme")

Settings:AddDropdown({
    Name     = "Accent Color",
    Options  = { "Blue", "Purple", "Cyan", "Pink", "Green", "Red", "Orange" },
    Default  = "Blue",
    Callback = function(val)
        Tapher:SetAccent(val)
    end,
})

Settings:AddSeparator("Config")

Settings:AddButton({
    Name        = "Save Config",
    Description = "Saves current settings to file",
    Callback    = function()
        local ok = Tapher:SaveConfig("default")
        if ok then
            Tapher:NotifySuccess("Saved!", "Config saved to TapherLib/default.json", "Bounce")
        else
            Tapher:NotifyError("Failed", "Could not save config (writefile unavailable)", "Glitch")
        end
    end,
})

Settings:AddButton({
    Name        = "Load Config",
    Description = "Loads settings from file",
    Callback    = function()
        local ok = Tapher:LoadConfig("default")
        if ok then
            Tapher:NotifyInfo("Loaded", "Config restored successfully", "Hologram")
        else
            Tapher:NotifyWarning("Not found", "No saved config found", "Slide")
        end
    end,
})

Settings:AddSeparator("Notifications (Demo)")

Settings:AddButton({
    Name = "Test Slide",
    Callback = function()
        Tapher:Notify({ Title = "Slide!", Description = "Standard slide notification.", Style = "Slide", Type = "info", Duration = 4 })
    end,
})

Settings:AddButton({
    Name = "Test Bounce",
    Callback = function()
        Tapher:NotifySuccess("Success!", "Bounced in!", "Bounce")
    end,
})

Settings:AddButton({
    Name = "Test Glitch",
    Callback = function()
        Tapher:NotifyError("Glitch!", "Something went wrong.", "Glitch")
    end,
})

Settings:AddButton({
    Name = "Test Hologram",
    Callback = function()
        Tapher:NotifyInfo("Hologram", "Scanned in from the future.", "Hologram")
    end,
})

Settings:AddButton({
    Name = "Test Typing",
    Callback = function()
        Tapher:NotifyTyping("Typing...", "Characters appear one by one like a terminal.")
    end,
})

-- ── Tab: About ───────────────────────────────────────────────────────────────
local About = Window:AddTab({ Name = "About", Icon = "◈" })

About:AddLabel("TapherLib v1.0.0")
About:AddLabel("A modern glassmorphism Roblox UI library.")
About:AddSeparator("Links")
About:AddButton({
    Name        = "Discord",
    Description = "Join the community",
    Callback    = function()
        setclipboard("YOUR_DISCORD_LINK")
        Tapher:NotifySuccess("Copied!", "Discord link copied to clipboard.", "Bounce")
    end,
})

-- ── Startup notification ──────────────────────────────────────────────────────
task.wait(0.5)
Tapher:Notify({
    Title       = "Tapher Hub",
    Description = "Loaded successfully! Press RightShift to toggle.",
    Type        = "success",
    Style       = "Hologram",
    Duration    = 5,
})
