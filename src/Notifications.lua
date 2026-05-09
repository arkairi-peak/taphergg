--[[
    TapherLib/Notifications.lua
    Animated notification system.
    Styles: Slide, Bounce, Glitch, Hologram, Typing, Fade
]]

local Notifications = {}

local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

-- Lazy-loaded deps (injected by Main)
local Theme, Utility

function Notifications._init(t, u)
    Theme   = t
    Utility = u
end

-- ── Container setup ──────────────────────────────────────────────────────────

local container
local notifQueue = {}
local MAX_VISIBLE = 5

local function getContainer()
    if container and container.Parent then return container end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TapherLib_Notifs"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999

    local ok = pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not ok then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    container = Utility.Create("Frame", {
        Name = "NotifContainer",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.new(0, 320, 1, -36),
        Parent = screenGui,
    })

    local layout = Utility.ListLayout(container, Enum.FillDirection.Vertical, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right

    return container
end

-- ── Base notification builder ────────────────────────────────────────────────

local TYPE_COLORS = {
    success = "Success",
    warning = "Warning",
    error   = "Error",
    info    = "Info",
    default = "Accent",
}

local TYPE_ICONS = {
    success = "✓",
    warning = "⚠",
    error   = "✕",
    info    = "ℹ",
    default = "◈",
}

local function buildCard(opts)
    local c = getContainer()
    local T = Theme.Current

    local typeKey   = (opts.Type or "default"):lower()
    local accentKey = TYPE_COLORS[typeKey] or "Accent"
    local accent    = T[accentKey] or T.Accent
    local icon      = opts.Icon or TYPE_ICONS[typeKey] or "◈"

    -- Outer card
    local card = Utility.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.GlassTransparency,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 72),
        ClipsDescendants = true,
        ZIndex = 10,
        Parent = c,
    })
    Utility.Round(card, 12)
    Utility.Stroke(card, accent, 1, 0.45)
    Utility.Shadow(card, 14, 0.55)

    -- Accent side bar
    Utility.Create("Frame", {
        Name = "Bar",
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = card.ZIndex + 1,
        Parent = card,
    })

    -- Icon circle
    local iconCircle = Utility.Create("Frame", {
        Name = "IconCircle",
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 30, 0, 30),
        ZIndex = card.ZIndex + 1,
        Parent = card,
    })
    Utility.Round(iconCircle, 99)

    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = icon,
        TextColor3 = accent,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        ZIndex = card.ZIndex + 2,
        Parent = iconCircle,
    })
    Utility.Padding(iconCircle, 5, 5, 5, 5)

    -- Title
    local title = Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 10),
        Size = UDim2.new(1, -64, 0, 18),
        Text = opts.Title or "Notification",
        TextColor3 = T.TextPrimary,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = card.ZIndex + 1,
        Parent = card,
    })

    -- Description
    local desc = Utility.Create("TextLabel", {
        Name = "Desc",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 30),
        Size = UDim2.new(1, -64, 0, 32),
        Text = opts.Description or "",
        TextColor3 = T.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = card.ZIndex + 1,
        Parent = card,
    })

    -- Progress bar
    local progTrack = Utility.Create("Frame", {
        Name = "ProgressTrack",
        BackgroundColor3 = T.SliderTrack,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = card.ZIndex + 2,
        Parent = card,
    })
    local progFill = Utility.Create("Frame", {
        Name = "ProgressFill",
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = card.ZIndex + 3,
        Parent = progTrack,
    })

    return card, title, desc, progFill
end

-- ── Dismiss logic ────────────────────────────────────────────────────────────

local function dismissCard(card, style, callback)
    if style == "Slide" or style == "Bounce" then
        Utility.Tween(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1.2, 0, card.Position.Y.Scale, card.Position.Y.Offset),
        }, function()
            card:Destroy()
            if callback then callback() end
        end)
    elseif style == "Glitch" then
        -- quick flicker then destroy
        local flickers = 5
        local i = 0
        local conn
        conn = RunService.Heartbeat:Connect(function()
            i = i + 1
            card.BackgroundTransparency = (i % 2 == 0) and 0.1 or 0.9
            if i >= flickers * 2 then
                conn:Disconnect()
                card:Destroy()
                if callback then callback() end
            end
        end)
    elseif style == "Hologram" then
        Utility.Tween(card, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
        }, function()
            card:Destroy()
            if callback then callback() end
        end)
    else
        Utility.Tween(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
        }, function()
            card:Destroy()
            if callback then callback() end
        end)
    end
end

-- ── Animation drivers ────────────────────────────────────────────────────────

local animators = {}

-- SLIDE: swoops in from the right
animators.Slide = function(card, title, desc, progFill, opts)
    card.Position = UDim2.new(1.2, 0, 0, 0)
    card.AnchorPoint = Vector2.new(0, 0)
    Utility.Tween(card,
        TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 0, 0, 0) }
    )
end

-- BOUNCE: slides in with overshoot
animators.Bounce = function(card, title, desc, progFill, opts)
    card.Position = UDim2.new(0, 0, 0, 60)
    card.BackgroundTransparency = 1
    Utility.Tween(card,
        TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = Theme.Current.GlassTransparency }
    )
end

-- GLITCH: digital corruption effect
animators.Glitch = function(card, title, desc, progFill, opts)
    local T = Theme.Current
    card.BackgroundTransparency = 1
    card.Position = UDim2.new(0, 0, 0, 0)

    local glitchSteps = 8
    local step = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        step = step + 1
        if step <= glitchSteps then
            -- Random horizontal shake + flicker
            local shakeX = math.random(-8, 8)
            card.Position = UDim2.new(0, shakeX, 0, 0)
            card.BackgroundTransparency = step % 2 == 0 and 0.1 or 0.85
            -- Color flash on title
            title.TextColor3 = step % 2 == 0 and T.TextPrimary or T.AccentHover
        else
            conn:Disconnect()
            card.Position = UDim2.new(0, 0, 0, 0)
            card.BackgroundTransparency = T.GlassTransparency
            title.TextColor3 = T.TextPrimary
        end
    end)
end

-- HOLOGRAM: scan-line reveal from top
animators.Hologram = function(card, title, desc, progFill, opts)
    local T = Theme.Current
    card.ClipsDescendants = true
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundTransparency = 0.15

    -- Scanline overlay
    local scanline = Utility.Create("Frame", {
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = card.ZIndex + 5,
        Parent = card,
    })

    local targetH = 72
    local elapsed = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        local progress = math.min(elapsed / 0.5, 1)
        card.Size = UDim2.new(1, 0, 0, math.floor(targetH * progress))
        scanline.Position = UDim2.new(0, 0, progress, -2)

        -- Flicker alpha
        local flicker = 0.5 + math.sin(elapsed * 30) * 0.08
        card.BackgroundTransparency = flicker

        if progress >= 1 then
            conn:Disconnect()
            card.Size = UDim2.new(1, 0, 0, targetH)
            card.BackgroundTransparency = T.GlassTransparency
            Utility.Tween(scanline, TweenInfo.new(0.2), { BackgroundTransparency = 1 }, function()
                scanline:Destroy()
            end)
        end
    end)
end

-- TYPING: title types character by character
animators.Typing = function(card, title, desc, progFill, opts)
    local T = Theme.Current
    card.Position = UDim2.new(0, 0, 0, 0)
    Utility.Tween(card,
        TweenInfo.new(0.25, Enum.EasingStyle.Quad),
        { BackgroundTransparency = T.GlassTransparency }
    )

    local fullTitle = opts.Title or "Notification"
    local fullDesc  = opts.Description or ""
    title.Text = ""
    desc.Text = ""

    -- Type title first, then description
    Utility.Typewrite(title, fullTitle, 1.5, function()
        task.wait(0.1)
        Utility.Typewrite(desc, fullDesc, 1.2)
    end)
end

-- FADE (fallback)
animators.Fade = function(card, title, desc, progFill, opts)
    card.BackgroundTransparency = 1
    Utility.Tween(card,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad),
        { BackgroundTransparency = Theme.Current.GlassTransparency }
    )
end

-- ── Public API ───────────────────────────────────────────────────────────────

--[[
    Notifications.Send({
        Title       = "Hello!",
        Description = "This is a notification.",
        Type        = "success",   -- success | warning | error | info | default
        Style       = "Glitch",    -- Slide | Bounce | Glitch | Hologram | Typing | Fade
        Duration    = 5,           -- seconds
        Icon        = "★",         -- optional custom icon
    })
]]
function Notifications.Send(opts)
    opts = opts or {}
    local style    = opts.Style    or "Slide"
    local duration = opts.Duration or 5

    local card, title, desc, progFill = buildCard(opts)

    -- Run entrance animation
    local animator = animators[style] or animators.Slide
    animator(card, title, desc, progFill, opts)

    -- Progress bar countdown
    Utility.Tween(progFill,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        { Size = UDim2.new(0, 0, 1, 0) }
    )

    -- Click to dismiss early
    local btn = Utility.Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = card.ZIndex + 10,
        Parent = card,
    })
    local dismissed = false
    btn.MouseButton1Click:Connect(function()
        if not dismissed then
            dismissed = true
            dismissCard(card, style)
        end
    end)

    -- Auto dismiss
    task.delay(duration, function()
        if not dismissed and card and card.Parent then
            dismissed = true
            dismissCard(card, style)
        end
    end)

    return card
end

-- Shorthand helpers
function Notifications.Success(title, desc, style)
    return Notifications.Send({ Title = title, Description = desc, Type = "success", Style = style or "Bounce" })
end

function Notifications.Error(title, desc, style)
    return Notifications.Send({ Title = title, Description = desc, Type = "error", Style = style or "Glitch" })
end

function Notifications.Warning(title, desc, style)
    return Notifications.Send({ Title = title, Description = desc, Type = "warning", Style = style or "Slide" })
end

function Notifications.Info(title, desc, style)
    return Notifications.Send({ Title = title, Description = desc, Type = "info", Style = style or "Hologram" })
end

function Notifications.Typing(title, desc)
    return Notifications.Send({ Title = title, Description = desc, Type = "default", Style = "Typing" })
end

return Notifications
