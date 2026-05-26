--[[
    TapherLib/Components.lua
    All UI components: Window, Tabs, Button, Toggle, Slider,
    Dropdown, TextInput, ColorPicker, Label, Separator, Keybind
]]

local Components = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local Theme, Utility, Config

function Components._init(t, u, c)
    Theme   = t
    Utility = u
    Config  = c
end

-- ── Shared fast tween ─────────────────────────────────────────────────────────
local fast  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local med   = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local slow  = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ────────────────────────────────────────────────────────────────────────────
--  WINDOW
-- ────────────────────────────────────────────────────────────────────────────

function Components.CreateWindow(opts)
    local T = Theme.Current
    opts = opts or {}

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TapherLib_" .. (opts.Title or "Window")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    local ok = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if not ok then screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- Root frame — wider and more rectangular
    local isMobile = Utility.IsMobile()
    local winW = isMobile and 360 or 620
    local winH = isMobile and 400 or 480
    local sideW = isMobile and 52 or 58

    local root = Utility.Create("Frame", {
        Name = "TapherWindow",
        BackgroundColor3 = Color3.fromRGB(8, 8, 18),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, winW, 0, winH),
        ZIndex = 2,
        Parent = screenGui,
    })
    Utility.Round(root, 18)
    -- Crisp white frosted border
    Utility.Stroke(root, Color3.new(1,1,1), 1.5, 0.72)
    Utility.Shadow(root, 32, 0.42)

    -- Glass noise overlay — top left bright, bottom right dark
    local glassBase = Utility.Create("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.91,
        BorderSizePixel = 0,
        Size = UDim2.new(1,0,1,0),
        ZIndex = root.ZIndex,
        Parent = root,
    })
    Utility.Round(glassBase, 18)
    Utility.Gradient(glassBase, {
        ColorSequenceKeypoint.new(0,   Color3.new(1,   1,   1)),
        ColorSequenceKeypoint.new(0.45, Color3.new(0.5, 0.5, 0.7)),
        ColorSequenceKeypoint.new(1,   Color3.new(0.05,0.05,0.12)),
    }, 135)

    -- Bright top-edge specular line
    local specular = Utility.Create("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.65,
        BorderSizePixel = 0,
        Size = UDim2.new(0.7, 0, 0, 1),
        Position = UDim2.new(0.15, 0, 0, 0),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Title bar
    local titleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Logo / icon area — supports rbxassetid image or text symbol
    local logoBox = Utility.Create("Frame", {
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = root.ZIndex + 2,
        Parent = titleBar,
    })
    Utility.Round(logoBox, 7)

    -- Top-left logo: supports rbxassetid://, plain asset ID number, or text/emoji
    local logoRaw = tostring(opts.LogoImage or opts.Icon or "◈")
    local logoAssetId = logoRaw:match("rbxassetid://(%d+)") or (logoRaw:match("^%d+$") and logoRaw)
    if logoAssetId then
        Utility.Create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            Image = "rbxassetid://" .. logoAssetId,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = root.ZIndex + 3,
            Parent = logoBox,
        })
    else
        local logoText = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = logoRaw,
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            Font = Enum.Font.GothamBold,
            ZIndex = root.ZIndex + 3,
            Parent = logoBox,
        })
        Utility.Padding(logoText, 4, 4, 4, 4)
    end

    -- Title text — shifts up when subtitle present
    local titleYPos = opts.Subtitle and UDim2.new(0, 50, 0, 7) or UDim2.new(0, 50, 0.5, -8)
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = titleYPos,
        Size = UDim2.new(0, winW - 120, 0, 16),
        Text = opts.Title or "TapherLib",
        TextColor3 = T.TextPrimary,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = root.ZIndex + 2,
        Parent = titleBar,
    })

    -- Subtitle sits directly below title, no overlap
    if opts.Subtitle then
        Utility.Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 25),
            Size = UDim2.new(0, winW - 120, 0, 13),
            Text = opts.Subtitle,
            TextColor3 = T.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = root.ZIndex + 2,
            Parent = titleBar,
        })
    end

    -- Close button
    local closeBtn = Utility.Create("TextButton", {
        Name = "Close",
        BackgroundColor3 = Color3.fromRGB(248, 113, 113),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "✖",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        ZIndex = root.ZIndex + 3,
        Parent = titleBar,
    })
    Utility.Round(closeBtn, 99)

    -- Minimise button
    local minBtn = Utility.Create("TextButton", {
        Name = "Minimise",
        BackgroundColor3 = Color3.fromRGB(251, 191, 36),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -38, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        Text = "—",
        TextColor3 = Color3.new(1,1,1),
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        ZIndex = root.ZIndex + 3,
        Parent = titleBar,
    })
    Utility.Round(minBtn, 99)

    -- Title divider — white frosted line
    Utility.Create("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 47),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Watermark
    if opts.Watermark ~= false then
        Utility.Create("TextLabel", {
            Name = "Watermark",
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -8, 1, -4),
            Size = UDim2.new(0, 120, 0, 14),
            Text = "TapherLib v1.0",
            TextColor3 = T.TextMuted,
            TextSize = 9,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = root.ZIndex + 1,
            Parent = root,
        })
    end

    -- Sidebar — pure glass, no dark background
    local sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(0, sideW, 1, -48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 14)
    sidebarCorner.Parent = sidebar
    -- Subtle white right divider
    Utility.Create("Frame", {
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        ZIndex = root.ZIndex + 2,
        Parent = sidebar,
    })

    local tabList = Utility.Create("ScrollingFrame", {
        Name = "TabList",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        ZIndex = root.ZIndex + 2,
        Parent = sidebar,
    })
    local tabLayout = Utility.ListLayout(tabList, Enum.FillDirection.Vertical, 6)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Utility.Padding(tabList, 4, 0, 4, 0)

    -- Content area
    local contentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, sideW, 0, 48),
        Size = UDim2.new(1, -sideW, 1, -48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Search bar (inside content header)
    local searchBar, searchInput
    if opts.SearchBar ~= false then
        searchBar = Utility.Create("Frame", {
            Name = "SearchBar",
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 0.88,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 28),
            ZIndex = root.ZIndex + 2,
            Parent = contentArea,
        })
        Utility.Round(searchBar, 10)
        Utility.Stroke(searchBar, Color3.new(1,1,1), 1, 0.72)

        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Text = "🔍",
            TextColor3 = T.TextMuted,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            ZIndex = root.ZIndex + 3,
            Parent = searchBar,
        })

        searchInput = Utility.Create("TextBox", {
            Name = "SearchInput",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -36, 1, 0),
            Text = "",
            PlaceholderText = "Search...",
            TextColor3 = T.TextPrimary,
            PlaceholderColor3 = T.TextMuted,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            ZIndex = root.ZIndex + 3,
            Parent = searchBar,
        })
    end

    local tabContentStart = opts.SearchBar ~= false and 44 or 8

    -- Dragging
    Utility.MakeDraggable(titleBar, root)

    -- Bottom drag handle bar — glass style, rounded bottom corners
    local dragHandle = Utility.Create("Frame", {
        Name = "DragHandle",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.92,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 18),
        ZIndex = root.ZIndex + 2,
        Parent = root,
    })
    -- Only round bottom corners by applying UICorner (rounds all 4, but bottom is inside window so top looks fine)
    local dhCorner = Instance.new("UICorner")
    dhCorner.CornerRadius = UDim.new(0, 18)
    dhCorner.Parent = dragHandle
    -- White drag line pill
    local dragLine = Utility.Create("Frame", {
        Name = "DragLine",
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 36, 0, 4),
        ZIndex = dragHandle.ZIndex + 1,
        Parent = dragHandle,
    })
    Utility.Round(dragLine, 99)
    Utility.MakeDraggable(dragHandle, root)

    -- Floating toggle button (shown when UI is fully minimised via MinimiseMode = "Float")
    local floatBtn = Utility.Create("TextButton", {
        Name = "FloatToggle",
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 48, 0, 48),
        Text = "",
        Visible = false,
        ZIndex = 500,
        Parent = screenGui,
    })
    Utility.Round(floatBtn, 15)
    Utility.Stroke(floatBtn, T.Border, 1, 0.4)
    Utility.Shadow(floatBtn, 10, 0.5)

    -- Float button logo (image or text icon)
    local floatIcon
    if opts.FloatImage then
        floatIcon = Utility.Create("ImageLabel", {
            Name = "FloatIcon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0, 3, 0, 3),
            Image = opts.FloatImage,
            ImageColor3 = Color3.new(1, 1, 1),
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = floatBtn.ZIndex + 1,
            Parent = floatBtn,
        })
        Utility.Round(floatIcon, 12)

        -- If direct assetid doesn't load, try fetching the decal's Texture property
        task.spawn(function()
            task.wait(2)
            if floatIcon and floatIcon.Parent and floatIcon.IsLoaded ~= nil and not floatIcon.IsLoaded then
                -- Try prefixing with rbxthumb for thumbnails
                local id = opts.FloatImage:match("%d+")
                if id then
                    floatIcon.Image = "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
                end
            end
        end)
    else
        floatIcon = Utility.Create("TextLabel", {
            Name = "FloatIcon",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = opts.Icon or "◈",
            TextColor3 = Color3.new(1, 1, 1),
            TextScaled = true,
            Font = Enum.Font.GothamBold,
            ZIndex = floatBtn.ZIndex + 1,
            Parent = floatBtn,
        })
        Utility.Padding(floatIcon, 10, 10, 10, 10)
    end
    Utility.MakeDraggable(floatBtn, floatBtn)

    -- Close / minimise logic
    local minimised = false
    local fullSize  = UDim2.new(0, winW, 0, winH)
    local miniSize  = UDim2.new(0, winW, 0, 48)
    local minimiseMode = opts.MinimiseMode or "Bar" -- "Bar" or "Float"

    local function setMinimised(state)
        minimised = state
        if minimised then
            if minimiseMode == "Float" then
                if searchBar then searchBar.Visible = false end
                -- Scale down only — no transparency change avoids white flash
                Utility.Tween(root, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, winW * 0.88, 0, winH * 0.88),
                }, function()
                    Utility.Tween(root, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(0, 0, 0, 0),
                    }, function()
                        root.Visible = false
                    end)
                end)
            else
                if searchBar then searchBar.Visible = false end
                Utility.Tween(root, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = miniSize })
            end
        else
            if minimiseMode == "Float" then
                root.Visible = true
                root.Size = UDim2.new(0, winW * 0.88, 0, winH * 0.88)
                -- Spring open — size only, no transparency
                Utility.Tween(root, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = fullSize,
                }, function()
                    if searchBar then searchBar.Visible = true end
                end)
            else
                Utility.Tween(root, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = fullSize }, function()
                    if searchBar then searchBar.Visible = true end
                end)
            end
        end
    end

    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(root, med, { Size = UDim2.new(0, 0, 0, 0) }, function()
            screenGui:Destroy()
        end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        setMinimised(not minimised)
    end)

    floatBtn.MouseButton1Click:Connect(function()
        setMinimised(not minimised)
    end)

    -- Keybind to toggle visibility
    if opts.Keybind then
        Utility.OnKeybind(opts.Keybind, function()
            if minimiseMode == "Float" then
                setMinimised(not minimised)
            else
                root.Visible = not root.Visible
            end
        end)
    end

    -- Float button always visible from start in Float mode
    if minimiseMode == "Float" then
        floatBtn.Visible = true
    end

    -- Entrance animation — size only, no transparency tween (avoids white flash)
    root.Size = UDim2.new(0, winW * 0.85, 0, winH * 0.85)
    Utility.Tween(root, slow, { Size = fullSize })

    -- ── Tab system ────────────────────────────────────────────────────────────
    local tabs = {}
    local activeTab = nil

    local Window = {}

    -- Defined FIRST so AddTab can call it safely on the first tab
    function Window:SetActiveTab(tab)
        if activeTab then
            activeTab.content.Visible = false
            -- Use Accent at high transparency so color stays correct regardless of theme
            Utility.Tween(activeTab.btn, fast, {
                BackgroundColor3 = Theme.Current.Accent,
                BackgroundTransparency = 0.78,
            })
            activeTab.indicator.Visible = false
            local icon = activeTab.btn:FindFirstChild("Icon")
            if icon then
                if icon:IsA("TextLabel") then
                    icon.TextColor3 = Theme.Current.TextMuted
                elseif icon:IsA("ImageLabel") then
                    icon.ImageColor3 = Theme.Current.TextMuted
                end
            end
        end
        activeTab = tab
        tab.content.Visible = true
        Utility.Tween(tab.btn, fast, {
            BackgroundColor3 = Theme.Current.Accent,
            BackgroundTransparency = 0.15,
        })
        tab.indicator.Visible = true
        local icon = tab.btn:FindFirstChild("Icon")
        if icon then
            if icon:IsA("TextLabel") then
                icon.TextColor3 = Color3.new(1,1,1)
            elseif icon:IsA("ImageLabel") then
                icon.ImageColor3 = Color3.new(1,1,1)
            end
        end
    end

    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or ("Tab " .. #tabs + 1)
        local T2 = Theme.Current

        -- Sidebar button — icon only, square
        local tabBtn = Utility.Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = T2.Accent,
            BackgroundTransparency = 0.78,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -10, 0, 38),
            Text = "",
            ZIndex = root.ZIndex + 3,
            Parent = tabList,
        })
        Utility.Round(tabBtn, 10)

        -- Icon — supports rbxassetid:// or emoji/text
        local iconStr = tabOpts.Icon or "◉"
        local isAsset = type(iconStr) == "string" and iconStr:find("rbxassetid://") ~= nil

        if isAsset then
            Utility.Create("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -12, 1, -12),
                Image = iconStr,
                ScaleType = Enum.ScaleType.Fit,
                ImageColor3 = T2.TextMuted,
                ZIndex = root.ZIndex + 4,
                Name = "Icon",
                Parent = tabBtn,
            })
        else
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, -8, 1, -8),
                Text = iconStr,
                TextColor3 = T2.TextMuted,
                TextScaled = true,
                Font = Enum.Font.GothamBold,
                ZIndex = root.ZIndex + 4,
                Name = "Icon",
                Parent = tabBtn,
            })
        end

        -- Hidden label (kept for SetActiveTab compatibility)
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            Text = tabName,
            TextColor3 = T2.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            Visible = false,
            ZIndex = root.ZIndex + 4,
            Name = "Label",
            Parent = tabBtn,
        })

        -- Tooltip on hover
        local tooltip = Utility.Create("TextLabel", {
            BackgroundColor3 = T2.SurfaceLighter,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(1, 8, 0.5, 0),
            Size = UDim2.new(0, #tabName * 7 + 16, 0, 22),
            Text = tabName,
            TextColor3 = T2.TextPrimary,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            Visible = false,
            ZIndex = root.ZIndex + 20,
            Parent = tabBtn,
        })
        Utility.Round(tooltip, 6)
        Utility.Stroke(tooltip, T2.Border, 1, 0.4)

        tabBtn.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        tabBtn.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)

        -- Active indicator bar (left edge)
        local indicator = Utility.Create("Frame", {
            BackgroundColor3 = T2.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.15, 0),
            Size = UDim2.new(0, 3, 0.7, 0),
            ZIndex = root.ZIndex + 4,
            Visible = false,
            Parent = tabBtn,
        })
        Utility.Round(indicator, 99)

        -- Scrollable content frame for this tab
        local content = Utility.Create("ScrollingFrame", {
            Name = tabName .. "_Content",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, tabContentStart),
            Size = UDim2.new(1, 0, 1, -tabContentStart),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T2.Accent,
            Visible = false,
            ZIndex = root.ZIndex + 2,
            Parent = contentArea,
        })
        local contentLayout = Utility.ListLayout(content, Enum.FillDirection.Vertical, 6)
        Utility.Padding(content, 8, 10, 8, 10)

        -- Auto-resize canvas
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
        end)

    local tab = { btn = tabBtn, content = content, indicator = indicator, components = {}, dropdownRefs = {}, componentFrames = {} }
        table.insert(tabs, tab)

        -- Activate on click
        tabBtn.MouseButton1Click:Connect(function()
            Window:SetActiveTab(tab)
        end)

        -- Hover
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tab then
                Utility.Tween(tabBtn, fast, { BackgroundTransparency = 0.45 })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tab then
                Utility.Tween(tabBtn, fast, { BackgroundTransparency = 0.78 })
            end
        end)

        -- First tab auto-activate
        if #tabs == 1 then
            Window:SetActiveTab(tab)
        end

        -- Search filtering
        if searchInput then
            searchInput:GetPropertyChangedSignal("Text"):Connect(function()
                local query = searchInput.Text:lower()
                if activeTab == tab then
                    for _, comp in ipairs(tab.components) do
                        if comp.frame then
                            local label = comp.label or ""
                            comp.frame.Visible = query == "" or label:lower():find(query, 1, true) ~= nil
                        end
                    end
                end
            end)
        end

        -- Tab component API
        local Tab = {}
        tab.api = Tab

        -- ── Button ────────────────────────────────────────────────────────────
        function Tab:AddButton(bOpts)
            bOpts = bOpts or {}
            local T3 = Theme.Current

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = Theme.Current.SurfaceLighter,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 10)
            Utility.Stroke(frame, Color3.new(1,1,1), 1, 0.60)

            local btn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = frame.ZIndex + 1,
                Parent = frame,
            })

            local hasDesc = bOpts.Description ~= nil
            frame.Size = UDim2.new(1, 0, 0, hasDesc and 52 or 38)

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = hasDesc and UDim2.new(0, 14, 0, 8) or UDim2.new(0, 14, 0.5, -7),
                Size = UDim2.new(1, -60, 0, 16),
                Text = bOpts.Name or "Button",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            if hasDesc then
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 28),
                    Size = UDim2.new(1, -60, 0, 14),
                    Text = bOpts.Description,
                    TextColor3 = T3.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = frame.ZIndex + 2,
                    Parent = frame,
                })
            end

            -- Right arrow
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Text = "›",
                TextColor3 = T3.Accent,
                TextSize = 18,
                Font = Enum.Font.GothamBold,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            Utility.AddRipple(btn, T3.Accent)

            btn.MouseEnter:Connect(function()
                Utility.Tween(frame, fast, { BackgroundColor3 = Theme.Current.Accent, BackgroundTransparency = 0.55 })
            end)
            btn.MouseLeave:Connect(function()
                Utility.Tween(frame, fast, { BackgroundColor3 = Theme.Current.SurfaceLighter, BackgroundTransparency = 0.15 })
            end)
            btn.MouseButton1Click:Connect(function()
                if bOpts.Callback then bOpts.Callback() end
            end)

            table.insert(tab.components, { frame = frame, label = bOpts.Name or "" })
            table.insert(tab.componentFrames, frame)
            return frame
        end

        -- ── Toggle ────────────────────────────────────────────────────────────
        function Tab:AddToggle(tOpts)
            tOpts = tOpts or {}
            local T3 = Theme.Current
            local state = tOpts.Default or false

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = Theme.Current.SurfaceLighter,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 10)
            Utility.Stroke(frame, Color3.new(1,1,1), 1, 0.74)

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Text = tOpts.Name or "Toggle",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            -- Track
            local track = Utility.Create("Frame", {
                Name = "ToggleTrack",
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.78,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 40, 0, 20),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(track, 99)

            -- Knob
            local knob = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = state and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = frame.ZIndex + 3,
                Parent = track,
            })
            Utility.Round(knob, 99)

            local btn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = frame.ZIndex + 4,
                Parent = frame,
            })

            local function setState(val)
                state = val
                Utility.Tween(track, fast, {
                    BackgroundColor3 = state and T3.Accent or Color3.new(1,1,1),
                    BackgroundTransparency = state and 0.1 or 0.78,
                })
                Utility.Tween(knob, fast, { Position = state and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
                if tOpts.Callback then tOpts.Callback(state) end
            end

            btn.MouseButton1Click:Connect(function()
                setState(not state)
            end)

            if tOpts.Flag then
                Config.Register(tOpts.Flag, function() return state end, function(v) setState(v) end)
            end

            table.insert(tab.components, { frame = frame, label = tOpts.Name or "" })
            table.insert(tab.componentFrames, frame)

            local obj = {}
            function obj:Set(val) setState(val) end
            function obj:Get() return state end
            return obj
        end

        -- ── Slider ───────────────────────────────────────────────────────────
        function Tab:AddSlider(sOpts)
            sOpts = sOpts or {}
            local T3   = Theme.Current
            local min  = sOpts.Min     or 0
            local max  = sOpts.Max     or 100
            local step = sOpts.Step    or 1
            local val  = sOpts.Default or min

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = Theme.Current.SurfaceLighter,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 54),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 10)
            Utility.Stroke(frame, Color3.new(1,1,1), 1, 0.74)

            local nameLabel = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 6),
                Size = UDim2.new(0.65, 0, 0, 16),
                Text = sOpts.Name or "Slider",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local valLabel = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 6),
                Size = UDim2.new(0, 50, 0, 16),
                Text = tostring(val),
                TextColor3 = T3.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local track = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.82,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 32),
                Size = UDim2.new(1, -28, 0, 5),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(track, 99)

            local fill = Utility.Create("Frame", {
                Name = "SliderFill",
                BackgroundColor3 = T3.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                ZIndex = frame.ZIndex + 3,
                Parent = track,
            })
            Utility.Round(fill, 99)

            local thumb = Utility.Create("Frame", {
                Name = "SliderThumb",
                BackgroundColor3 = Color3.new(1,1,1),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0),
                Size = UDim2.new(0, 14, 0, 14),
                ZIndex = frame.ZIndex + 4,
                Parent = track,
            })
            Utility.Round(thumb, 99)
            Utility.Stroke(thumb, T3.Accent, 2, 0)

            local dragging = false
            local btn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 22),
                Text = "",
                ZIndex = frame.ZIndex + 5,
                Parent = frame,
            })

            local function updateSlider(inputX)
                local trackAbs = track.AbsolutePosition.X
                local trackW   = track.AbsoluteSize.X
                local rel = math.clamp((inputX - trackAbs) / trackW, 0, 1)
                local rawVal = min + (max - min) * rel
                local stepped = math.round(rawVal / step) * step
                stepped = math.clamp(stepped, min, max)
                val = stepped
                local pct = (val - min) / (max - min)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                valLabel.Text = tostring(val)
                if sOpts.Callback then sOpts.Callback(val) end
            end

            btn.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(i.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
                or i.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(i.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            if sOpts.Flag then
                Config.Register(sOpts.Flag, function() return val end, function(v) updateSlider(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v-min)/(max-min))) end)
            end

            table.insert(tab.components, { frame = frame, label = sOpts.Name or "" })
            table.insert(tab.componentFrames, frame)

            local obj = {}
            function obj:Set(v) updateSlider(track.AbsolutePosition.X + track.AbsoluteSize.X * ((math.clamp(v,min,max)-min)/(max-min))) end
            function obj:Get() return val end
            return obj
        end

        -- ── Dropdown ─────────────────────────────────────────────────────────
        function Tab:AddDropdown(dOpts)
            dOpts = dOpts or {}
            local T3      = Theme.Current
            local options = dOpts.Options or {}
            local selected = dOpts.Default or (options[1] or "Select...")
            local open = false

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = T3.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                ClipsDescendants = false,
                Parent = content,
            })
            Utility.Round(frame, 8)
            Utility.Stroke(frame, T3.Border, 1, 0.65)

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.55, 0, 1, 0),
                Text = dOpts.Name or "Dropdown",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local selLabel = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -30, 0.5, 0),
                Size = UDim2.new(0.35, 0, 0, 14),
                Text = selected,
                TextColor3 = T3.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local arrow = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                Text = "v",
                TextColor3 = T3.TextMuted,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            -- Dropdown list — parented to contentArea so ScrollingFrame doesn't clip it
            local listFrame = Utility.Create("ScrollingFrame", {
                BackgroundColor3 = Color3.fromRGB(6, 5, 16),
                BackgroundTransparency = 0.12,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Current.Accent,
                Visible = false,
                ZIndex = 9000,
                Parent = contentArea,
            })
            Utility.Round(listFrame, 10)
            Utility.Stroke(listFrame, Color3.new(1,1,1), 1, 0.74)
            local listLayout = Utility.ListLayout(listFrame, Enum.FillDirection.Vertical, 2)
            Utility.Padding(listFrame, 4, 4, 4, 4)

            local listTargetH = math.min(#options * 30 + 8, 150)

            local function populateList()
                local TC = Theme.Current  -- always fresh
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                -- Update listFrame background to match current theme
                listFrame.BackgroundColor3 = TC.Background
                listFrame.ScrollBarImageColor3 = TC.Accent
                for _, opt in ipairs(options) do
                    local optBtn = Utility.Create("TextButton", {
                        BackgroundColor3 = opt == selected and TC.Accent or Color3.new(1,1,1),
                        BackgroundTransparency = opt == selected and 0.15 or 0.92,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = opt,
                        TextColor3 = opt == selected and Color3.new(1,1,1) or TC.TextSecondary,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        ZIndex = listFrame.ZIndex + 1,
                        Parent = listFrame,
                    })
                    Utility.Round(optBtn, 7)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = selected
                        open = false
                        local w = listFrame.AbsoluteSize.X
                        Utility.Tween(listFrame, fast, { Size = UDim2.new(0, w, 0, 0) }, function()
                            listFrame.Visible = false
                        end)
                        Utility.Tween(arrow, fast, { Rotation = 0 })
                        if dOpts.Callback then dOpts.Callback(selected) end
                        populateList()
                    end)
                end
                listTargetH = math.min(#options * 30 + 8, 150)
                listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
            end
            populateList()

            local openBtn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = frame.ZIndex + 3,
                Parent = frame,
            })

            openBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local absPos  = frame.AbsolutePosition
                    local absSize = frame.AbsoluteSize
                    local caPos   = contentArea.AbsolutePosition
                    listFrame.Position = UDim2.new(0, absPos.X - caPos.X, 0, absPos.Y - caPos.Y + absSize.Y + 4)
                    listFrame.Size = UDim2.new(0, absSize.X, 0, 0)
                    listFrame.Visible = true
                    Utility.Tween(listFrame, fast, { Size = UDim2.new(0, absSize.X, 0, listTargetH) })
                else
                    local w = listFrame.AbsoluteSize.X
                    Utility.Tween(listFrame, fast, { Size = UDim2.new(0, w, 0, 0) }, function()
                        listFrame.Visible = false
                    end)
                end
                Utility.Tween(arrow, fast, { Rotation = open and 180 or 0 })
            end)

            if dOpts.Flag then
                Config.Register(dOpts.Flag, function() return selected end, function(v)
                    selected = v; selLabel.Text = v; populateList()
                end)
            end

            table.insert(tab.components, { frame = frame, label = dOpts.Name or "" })
            table.insert(tab.componentFrames, frame)
            -- Register for live accent refresh
            table.insert(tab.dropdownRefs, { listFrame = listFrame, repopulate = populateList })

            local obj = {}
            function obj:Get() return selected end
            function obj:Set(v) selected = v; selLabel.Text = v; populateList() end
            function obj:Refresh(newOptions) options = newOptions; populateList() end
            return obj
        end

        -- ── TextInput ─────────────────────────────────────────────────────────
        function Tab:AddTextInput(iOpts)
            iOpts = iOpts or {}
            local T3 = Theme.Current

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = Theme.Current.SurfaceLighter,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 54),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 10)
            Utility.Stroke(frame, Color3.new(1,1,1), 1, 0.74)

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 6),
                Size = UDim2.new(1, -28, 0, 14),
                Text = iOpts.Name or "Input",
                TextColor3 = T3.TextPrimary,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local inputBox = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.84,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 24),
                Size = UDim2.new(1, -20, 0, 22),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(inputBox, 7)

            local stroke = Utility.Stroke(inputBox, Color3.new(1,1,1), 1, 0.72)

            local textBox = Utility.Create("TextBox", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0, 0),
                Size = UDim2.new(1, -16, 1, 0),
                Text = iOpts.Default or "",
                PlaceholderText = iOpts.Placeholder or "Enter text...",
                TextColor3 = T3.TextPrimary,
                PlaceholderColor3 = T3.TextMuted,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = iOpts.ClearOnFocus ~= false,
                ZIndex = frame.ZIndex + 3,
                Parent = inputBox,
            })

            textBox.Focused:Connect(function()
                Utility.Tween(stroke, fast, { Color = T3.Accent, Transparency = 0 })
            end)
            textBox.FocusLost:Connect(function(enter)
                Utility.Tween(stroke, fast, { Color = Color3.new(1,1,1), Transparency = 0.72 })
                if iOpts.Callback then iOpts.Callback(textBox.Text, enter) end
            end)

            if iOpts.Flag then
                Config.Register(iOpts.Flag, function() return textBox.Text end, function(v) textBox.Text = v end)
            end

            table.insert(tab.components, { frame = frame, label = iOpts.Name or "" })
            table.insert(tab.componentFrames, frame)

            local obj = {}
            function obj:Get() return textBox.Text end
            function obj:Set(v) textBox.Text = v end
            return obj
        end

        -- ── ColorPicker ───────────────────────────────────────────────────────
        function Tab:AddColorPicker(cOpts)
            cOpts = cOpts or {}
            local T3   = Theme.Current
            local color = cOpts.Default or Color3.fromRGB(99, 102, 241)
            local open  = false

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = Theme.Current.SurfaceLighter,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                ClipsDescendants = false,
                Parent = content,
            })
            Utility.Round(frame, 10)
            Utility.Stroke(frame, Color3.new(1,1,1), 1, 0.74)

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.65, 0, 1, 0),
                Text = cOpts.Name or "Color",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local preview = Utility.Create("Frame", {
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 22, 0, 22),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(preview, 7)
            Utility.Stroke(preview, Color3.new(1,1,1), 1, 0.6)

            -- Expanded picker panel — parented to contentArea
            local pickerPanel = Utility.Create("Frame", {
                BackgroundColor3 = Color3.fromRGB(8, 8, 20),
                BackgroundTransparency = 0.18,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(0, 0, 0, 0),
                Visible = false,
                ZIndex = 9000,
                Parent = contentArea,
            })
            Utility.Round(pickerPanel, 10)
            Utility.Stroke(pickerPanel, T3.Border, 1, 0.4)
            Utility.Padding(pickerPanel, 10, 10, 10, 10)

            -- Hue, Sat, Val sliders (simple approach)
            local h, s, v = Color3.toHSV(color)

            local function makeHSVSlider(label, default, callback2)
                local row = Utility.Create("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22),
                    ZIndex = pickerPanel.ZIndex + 1,
                    Parent = pickerPanel,
                })
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 24, 1, 0),
                    Text = label,
                    TextColor3 = T3.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })
                local trk = Utility.Create("Frame", {
                    BackgroundColor3 = T3.SliderTrack,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 28, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, -28, 0, 6),
                    ZIndex = row.ZIndex + 1,
                    Parent = row,
                })
                Utility.Round(trk, 99)
                local fl = Utility.Create("Frame", {
                    BackgroundColor3 = T3.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(default, 0, 1, 0),
                    ZIndex = trk.ZIndex + 1,
                    Parent = trk,
                })
                Utility.Round(fl, 99)
                local kb = Utility.Create("TextButton", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 28, 0, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    Text = "",
                    ZIndex = row.ZIndex + 2,
                    Parent = row,
                })
                local drag2 = false
                kb.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag2 = true
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag2 and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        local rel = math.clamp((i.Position.X - trk.AbsolutePosition.X) / trk.AbsoluteSize.X, 0, 1)
                        fl.Size = UDim2.new(rel, 0, 1, 0)
                        callback2(rel)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        drag2 = false
                    end
                end)
            end

            local function refreshColor()
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                if cOpts.Callback then cOpts.Callback(color) end
            end

            makeHSVSlider("H", h, function(val2) h = val2; refreshColor() end)
            makeHSVSlider("S", s, function(val2) s = val2; refreshColor() end)
            makeHSVSlider("V", v, function(val2) v = val2; refreshColor() end)

            local pickerLayout = Utility.ListLayout(pickerPanel, Enum.FillDirection.Vertical, 6)

            local openBtn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = frame.ZIndex + 3,
                Parent = frame,
            })
            local pickerTargetH = 22 * 3 + 6 * 2 + 20

            openBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    local absPos  = frame.AbsolutePosition
                    local absSize = frame.AbsoluteSize
                    local caPos   = contentArea.AbsolutePosition
                    pickerPanel.Position = UDim2.new(0, absPos.X - caPos.X, 0, absPos.Y - caPos.Y + absSize.Y + 4)
                    pickerPanel.Size = UDim2.new(0, absSize.X, 0, 0)
                    pickerPanel.Visible = true
                    Utility.Tween(pickerPanel, fast, { Size = UDim2.new(0, absSize.X, 0, pickerTargetH) })
                else
                    local w = pickerPanel.AbsoluteSize.X
                    Utility.Tween(pickerPanel, fast, { Size = UDim2.new(0, w, 0, 0) }, function()
                        pickerPanel.Visible = false
                    end)
                end
            end)

            if cOpts.Flag then
                Config.Register(cOpts.Flag, function()
                    return { R = color.R, G = color.G, B = color.B }
                end, function(val2)
                    color = Color3.new(val2.R, val2.G, val2.B)
                    preview.BackgroundColor3 = color
                end)
            end

            table.insert(tab.components, { frame = frame, label = cOpts.Name or "" })
            table.insert(tab.componentFrames, frame)

            local obj = {}
            function obj:Get() return color end
            function obj:Set(c) color = c; preview.BackgroundColor3 = c; h,s,v = Color3.toHSV(c) end
            return obj
        end

        -- ── Label ─────────────────────────────────────────────────────────────
        function Tab:AddLabel(text, size)
            local T3 = Theme.Current
            local lbl = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, size or 20),
                Text = text or "",
                TextColor3 = T3.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Padding(lbl, 0, 0, 0, 14)
            table.insert(tab.components, { frame = lbl, label = text or "" })
            return lbl
        end

        -- ── Separator ─────────────────────────────────────────────────────────
        function Tab:AddSeparator(label)
            local T3 = Theme.Current
            local sep = Utility.Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Create("Frame", {
                BackgroundColor3 = T3.Border,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, 1),
                ZIndex = sep.ZIndex + 1,
                Parent = sep,
            })
            if label then
                local bg = Utility.Create("Frame", {
                    BackgroundColor3 = T3.SurfaceLight,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, #label * 7 + 20, 0, 16),
                    ZIndex = sep.ZIndex + 2,
                    Parent = sep,
                })
                Utility.Round(bg, 99)
                Utility.Stroke(bg, T3.Border, 1, 0.5)
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = label,
                    TextColor3 = T3.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    ZIndex = bg.ZIndex + 1,
                    Parent = bg,
                })
            end
            table.insert(tab.components, { frame = sep, label = label or "" })
            return sep
        end

        Tab._content = content
        return Tab
    end

    -- Registry of accent-colored elements for live recoloring
    local accentElements = {
        logoBox = logoBox,
        tabIndicators = {},
        activeBtns = {},
    }

    -- Live full theme recolor
    function Window:RefreshAccent()
        local T2 = Theme.Current
        print("[TapherLib] RefreshAccent running, accent:", tostring(T2.Accent), "tabs:", #tabs)

        -- Root window background tints to theme
        Utility.Tween(root, med, { BackgroundColor3 = T2.Background })
        local rootStroke = root:FindFirstChildWhichIsA("UIStroke")
        if rootStroke then rootStroke.Color = Color3.new(1,1,1) end

        -- Logo box accent
        Utility.Tween(logoBox, fast, { BackgroundColor3 = T2.Accent })

        -- Float button accent
        Utility.Tween(floatBtn, fast, { BackgroundColor3 = T2.Accent })

        -- All tabs
        for _, tab in ipairs(tabs) do
            -- Scroll bar
            tab.content.ScrollBarImageColor3 = T2.Accent

            -- Indicator bar
            Utility.Tween(tab.indicator, fast, { BackgroundColor3 = T2.Accent })

            -- Tab button — active=accent, inactive=accent at high transparency so tint is visible
            if tab == activeTab then
                Utility.Tween(tab.btn, fast, {
                    BackgroundColor3 = T2.Accent,
                    BackgroundTransparency = 0.15,
                })
            else
                Utility.Tween(tab.btn, fast, {
                    BackgroundColor3 = T2.Accent,
                    BackgroundTransparency = 0.78,
                })
            end

            -- Recolor all component frames (buttons, toggles, sliders, dropdowns, inputs)
            for _, f in ipairs(tab.componentFrames) do
                if f and f.Parent then
                    Utility.Tween(f, fast, {
                        BackgroundColor3 = T2.SurfaceLighter,
                        BackgroundTransparency = 0.15,
                    })
                end
            end

            -- Repopulate all dropdowns with fresh accent colors
            for _, dRef in ipairs(tab.dropdownRefs) do
                if dRef.listFrame and dRef.listFrame.Parent then
                    dRef.listFrame.BackgroundColor3 = T2.Background
                    dRef.listFrame.ScrollBarImageColor3 = T2.Accent
                    pcall(dRef.repopulate)
                end
            end

            -- Home tab accent refs (cards, bars, rings, etc.)
            if tab._accentRefs then
                print("[TapherLib] Found _accentRefs, count:", #tab._accentRefs)
                for _, ref in ipairs(tab._accentRefs) do
                    if ref.inst and ref.inst.Parent then
                        local newVal = T2[ref.key]
                        if newVal then
                            if ref.prop == "Color" then
                                ref.inst[ref.prop] = newVal
                            elseif ref.prop == "BackgroundColor3" then
                                -- For surface-colored cards, also ensure transparency is visible
                                local trans = ref.transparency or (ref.key == "SurfaceLight" and 0.35 or 0.2)
                                Utility.Tween(ref.inst, med, {
                                    BackgroundColor3 = newVal,
                                    BackgroundTransparency = trans,
                                })
                            else
                                Utility.Tween(ref.inst, fast, { [ref.prop] = newVal })
                            end
                        end
                    end
                end
            end

            -- Walk content for named accent elements
            local function recolorDescendants(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    local n = child.Name

                    if n == "ToggleTrack" and child:IsA("Frame") then
                        local isOff = child.BackgroundTransparency > 0.5
                        if not isOff then
                            Utility.Tween(child, fast, { BackgroundColor3 = T2.Accent, BackgroundTransparency = 0.1 })
                        end

                    elseif n == "SliderFill" and child:IsA("Frame") then
                        Utility.Tween(child, fast, { BackgroundColor3 = T2.Accent })

                    elseif n == "SliderThumb" and child:IsA("Frame") then
                        local st = child:FindFirstChildWhichIsA("UIStroke")
                        if st then st.Color = T2.Accent end

                    elseif child:IsA("TextLabel") then
                        local c = child.TextColor3
                        local sat = math.max(c.R, c.G, c.B) - math.min(c.R, c.G, c.B)
                        local isWhite = c.R > 0.9 and c.G > 0.9 and c.B > 0.9
                        if sat > 0.15 and not isWhite then
                            child.TextColor3 = T2.Accent
                        end
                    end

                    recolorDescendants(child)
                end
            end
            recolorDescendants(tab.content)
        end
    end

    -- ── Home Page ──────────────────────────────────────────────────────────────
    function Window:AddHomePage(hOpts)
        hOpts = hOpts or {}
        local T2      = Theme.Current
        local Players = game:GetService("Players")
        local lp      = Players.LocalPlayer

        local homeTab = self:AddTab({ Name = hOpts.TabName or "Home", Icon = hOpts.TabIcon or "⌂" })
        local content = homeTab._content

        -- Track accent elements for live recolor
        local homeAccentRefs = {}

        -- ── Player header card ───────────────────────────────────────────────
        local headerCard = Utility.Create("Frame", {
            BackgroundColor3 = T2.SurfaceLight,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 70),
            ZIndex = content.ZIndex + 1,
            Parent = content,
        })
        Utility.Round(headerCard, 14)
        Utility.Stroke(headerCard, Color3.new(1,1,1), 1, 0.80)
        table.insert(homeAccentRefs, { inst = headerCard, prop = "BackgroundColor3", key = "SurfaceLight" })

        -- Top glass highlight strip
        local hGlass = Utility.Create("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 0.92,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0.45, 0),
            ZIndex = headerCard.ZIndex,
            Parent = headerCard,
        })
        Utility.Round(hGlass, 14)

        -- Accent left edge bar
        local accentBar = Utility.Create("Frame", {
            BackgroundColor3 = T2.Accent,
            BackgroundTransparency = 0.25,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 0.65, 0),
            Position = UDim2.new(0, 0, 0.175, 0),
            ZIndex = headerCard.ZIndex + 1,
            Parent = headerCard,
        })
        Utility.Round(accentBar, 99)
        table.insert(homeAccentRefs, { inst = accentBar, prop = "BackgroundColor3", key = "Accent" })

        -- Avatar with accent ring
        local avatarRing = Utility.Create("Frame", {
            BackgroundColor3 = T2.Accent,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 14, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.new(0, 48, 0, 48),
            ZIndex = content.ZIndex + 2,
            Parent = headerCard,
        })
        Utility.Round(avatarRing, 99)
        table.insert(homeAccentRefs, { inst = avatarRing, prop = "BackgroundColor3", key = "Accent" })

        local avatarImg = Utility.Create("ImageLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -4, 1, -4),
            Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150",
            ZIndex = content.ZIndex + 3,
            Parent = avatarRing,
        })
        Utility.Round(avatarImg, 99)

        -- Greeting + username
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 72, 0, 14),
            Size = UDim2.new(1, -160, 0, 20),
            Text = "Hello, " .. lp.DisplayName .. "!",
            TextColor3 = Color3.fromRGB(252, 252, 255),
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = content.ZIndex + 2,
            Parent = headerCard,
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 72, 0, 36),
            Size = UDim2.new(1, -160, 0, 13),
            Text = "@" .. lp.Name,
            TextColor3 = T2.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = content.ZIndex + 2,
            Parent = headerCard,
        })

        -- Badge pill top-right
        if hOpts.Badge then
            local badge = Utility.Create("Frame", {
                BackgroundColor3 = T2.Accent,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, #hOpts.Badge * 7 + 20, 0, 24),
                ZIndex = content.ZIndex + 2,
                Parent = headerCard,
            })
            Utility.Round(badge, 99)
            Utility.Stroke(badge, T2.Accent, 1, 0.55)
            table.insert(homeAccentRefs, { inst = badge, prop = "BackgroundColor3", key = "Accent" })
            local bStroke = badge:FindFirstChildWhichIsA("UIStroke")
            if bStroke then
                table.insert(homeAccentRefs, { inst = bStroke, prop = "Color", key = "Accent" })
            end
            local badgeInner = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.88,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0.5,0),
                ZIndex = badge.ZIndex,
                Parent = badge,
            })
            Utility.Round(badgeInner, 99)
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = hOpts.Badge,
                TextColor3 = Color3.new(1,1,1),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                ZIndex = badge.ZIndex + 1,
                Parent = badge,
            })
        end

        -- ── Executor card ─────────────────────────────────────────────────────
        local execName = "Unknown"
        pcall(function()
            if identifyexecutor then
                execName = identifyexecutor()
            elseif getexecutorname then
                execName = getexecutorname()
            elseif syn then
                execName = "Synapse X"
            end
        end)

        local execCard = Utility.Create("Frame", {
            BackgroundColor3 = T2.SurfaceLight,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            ZIndex = content.ZIndex + 1,
            Parent = content,
        })
        Utility.Round(execCard, 10)
        Utility.Stroke(execCard, Color3.new(1,1,1), 1, 0.80)
        table.insert(homeAccentRefs, { inst = execCard, prop = "BackgroundColor3", key = "SurfaceLight" })
        -- Top shimmer
        local execGlass = Utility.Create("Frame", {
            BackgroundColor3 = Color3.new(1,1,1),
            BackgroundTransparency = 0.93,
            BorderSizePixel = 0,
            Size = UDim2.new(1,0,0.5,0),
            ZIndex = execCard.ZIndex,
            Parent = execCard,
        })
        Utility.Round(execGlass, 10)

        -- Small executor icon dot
        local execDot = Utility.Create("Frame", {
            BackgroundColor3 = T2.Accent,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 12, 0.5, 0),
            Size = UDim2.new(0, 7, 0, 7),
            ZIndex = execCard.ZIndex + 1,
            Parent = execCard,
        })
        Utility.Round(execDot, 99)
        table.insert(homeAccentRefs, { inst = execDot, prop = "BackgroundColor3", key = "Accent" })

        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 26, 0, 0),
            Size = UDim2.new(0, 70, 1, 0),
            Text = "EXECUTOR",
            TextColor3 = T2.TextMuted,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = execCard.ZIndex + 1,
            Parent = execCard,
        })
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 100, 0, 0),
            Size = UDim2.new(1, -110, 1, 0),
            Text = execName,
            TextColor3 = T2.TextPrimary,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = execCard.ZIndex + 1,
            Parent = execCard,
        })

        -- ── Server info section label ──────────────────────────────────────────
        local sLabel = Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
            Text = "SERVER INFO",
            TextColor3 = T2.TextMuted,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = content.ZIndex + 1,
            Parent = content,
        })
        Utility.Padding(sLabel, 0, 0, 0, 2)

        -- ── Server info 2×2 grid ───────────────────────────────────────────────
        local grid = Utility.Create("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 116),
            ZIndex = content.ZIndex + 1,
            Parent = content,
        })
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellSize    = UDim2.new(0.5, -4, 0, 54)
        gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
        gridLayout.SortOrder   = Enum.SortOrder.LayoutOrder
        gridLayout.Parent      = grid

        local function makeInfoCard(title, valueFunc, icon, clickCopy)
            local card = Utility.Create("Frame", {
                BackgroundColor3 = T2.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                ZIndex = content.ZIndex + 2,
                Parent = grid,
            })
            Utility.Round(card, 12)
            Utility.Stroke(card, Color3.new(1,1,1), 1, 0.80)
            -- Register for live theme recolor
            table.insert(homeAccentRefs, { inst = card, prop = "BackgroundColor3", key = "SurfaceLight" })

            -- Top glass highlight
            local cGlass = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.92,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0.45,0),
                ZIndex = card.ZIndex,
                Parent = card,
            })
            Utility.Round(cGlass, 12)

            -- Title row
            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 8),
                Size = UDim2.new(1, -14, 0, 11),
                Text = (icon and icon .. "  " or "") .. title:upper(),
                TextColor3 = T2.TextMuted,
                TextSize = 9,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = card.ZIndex + 1,
                Parent = card,
            })

            local valLabel = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 23),
                Size = UDim2.new(1, -14, 0, 22),
                Text = "...",
                TextColor3 = T2.TextPrimary,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = card.ZIndex + 1,
                Parent = card,
            })

            -- Copy hint for Job ID
            local copyHint
            if clickCopy then
                copyHint = Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, -8, 1, -4),
                    Size = UDim2.new(0, 50, 0, 11),
                    Text = "tap to copy",
                    TextColor3 = T2.Accent,
                    TextSize = 8,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = card.ZIndex + 1,
                    BackgroundColor3 = Color3.new(0,0,0),
                    Parent = card,
                })

                local copyBtn = Utility.Create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                    Text = "",
                    ZIndex = card.ZIndex + 3,
                    Parent = card,
                })
                copyBtn.MouseEnter:Connect(function()
                    Utility.Tween(card, fast, { BackgroundTransparency = 0.1 })
                    valLabel.TextColor3 = T2.Accent
                end)
                copyBtn.MouseLeave:Connect(function()
                    Utility.Tween(card, fast, { BackgroundTransparency = 0.22 })
                    valLabel.TextColor3 = T2.TextPrimary
                end)
                copyBtn.MouseButton1Click:Connect(function()
                    local fullId = game.JobId ~= "" and game.JobId or "Studio"
                    pcall(function() setclipboard(fullId) end)
                    local prev = valLabel.Text
                    valLabel.Text = "✓ Copied!"
                    valLabel.TextColor3 = T2.Success or Color3.fromRGB(48,209,148)
                    if copyHint then copyHint.Text = "" end
                    task.delay(2, function()
                        if valLabel and valLabel.Parent then
                            valLabel.TextColor3 = T2.TextPrimary
                            if copyHint then copyHint.Text = "tap to copy" end
                        end
                    end)
                end)
            end

            -- Live update loop
            task.spawn(function()
                while valLabel and valLabel.Parent do
                    local ok2, val2 = pcall(valueFunc)
                    if valLabel.Text ~= "✓ Copied!" then
                        valLabel.Text = ok2 and tostring(val2) or "N/A"
                    end
                    task.wait(2)
                end
            end)

            return card
        end

        makeInfoCard("Players", function()
            return #Players:GetPlayers() .. " / " .. game.Players.MaxPlayers
        end, "👥", false)

        makeInfoCard("Latency", function()
            local ok2, ping = pcall(function()
                return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            return ok2 and (ping .. " ms") or "N/A"
        end, "📶", false)

        makeInfoCard("Job ID", function()
            local jid = game.JobId
            return jid ~= "" and jid:sub(1,8) .. "…" or "Studio"
        end, "🌐", true)

        local joinTime = os.time()
        makeInfoCard("In Server For", function()
            local e = os.time() - joinTime
            return string.format("%02d:%02d", math.floor(e/60), e%60)
        end, "⏱", false)

        -- ── Script info bar ────────────────────────────────────────────────────
        if hOpts.ScriptName or hOpts.ScriptVersion then
            local infoCard = Utility.Create("Frame", {
                BackgroundColor3 = T2.Accent,
                BackgroundTransparency = 0.72,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 44),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(infoCard, 10)
            local infoStroke = Utility.Stroke(infoCard, T2.Accent, 1, 0.5)
            table.insert(homeAccentRefs, { inst = infoCard,   prop = "BackgroundColor3", key = "Accent" })
            table.insert(homeAccentRefs, { inst = infoStroke, prop = "Color",            key = "Accent" })

            -- Inner glass sheen
            local iGlass = Utility.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                BackgroundTransparency = 0.90,
                BorderSizePixel = 0,
                Size = UDim2.new(1,0,0.5,0),
                ZIndex = infoCard.ZIndex,
                Parent = infoCard,
            })
            Utility.Round(iGlass, 10)

            local iconStartX = 14

            -- Optional icon (emoji text OR rbxassetid)
            if hOpts.ScriptIcon then
                local isAsset = tostring(hOpts.ScriptIcon):find("rbxassetid") or tostring(hOpts.ScriptIcon):match("^%d+$")
                if isAsset then
                    local id = tostring(hOpts.ScriptIcon):match("%d+") or hOpts.ScriptIcon
                    local iconImg = Utility.Create("ImageLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 10, 0.5, 0),
                        Size = UDim2.new(0, 26, 0, 26),
                        Image = "rbxassetid://" .. id,
                        ScaleType = Enum.ScaleType.Fit,
                        ZIndex = infoCard.ZIndex + 1,
                        Parent = infoCard,
                    })
                    Utility.Round(iconImg, 6)
                    iconStartX = 44
                else
                    Utility.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 10, 0.5, 0),
                        Size = UDim2.new(0, 24, 0, 24),
                        Text = hOpts.ScriptIcon,
                        TextScaled = true,
                        Font = Enum.Font.GothamBold,
                        TextColor3 = Color3.new(1,1,1),
                        ZIndex = infoCard.ZIndex + 1,
                        Parent = infoCard,
                    })
                    iconStartX = 40
                end
            end

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, iconStartX, 0, 0),
                Size = UDim2.new(0.55, 0, 1, 0),
                Text = hOpts.ScriptName or opts.Title or "TapherLib",
                TextColor3 = Color3.fromRGB(252, 252, 255),
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = infoCard.ZIndex + 1,
                Parent = infoCard,
            })

            local verLabel = Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0),
                Size = UDim2.new(0.3, 0, 0, 16),
                Text = hOpts.ScriptVersion or "v1.0",
                TextColor3 = T2.AccentHover,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = infoCard.ZIndex + 1,
                Parent = infoCard,
            })
            table.insert(homeAccentRefs, { inst = verLabel, prop = "TextColor3", key = "AccentHover" })
        end

        -- Expose refs on BOTH the Tab API and the internal tab object
        homeTab._accentRefs = homeAccentRefs
        -- Find the internal tab object and store refs there too (for RefreshAccent)
        for _, t in ipairs(tabs) do
            if t.api == homeTab then
                t._accentRefs = homeAccentRefs
                break
            end
        end

        return homeTab
    end

    function Window:Destroy()
        Utility.Tween(root, med, {
            Size = UDim2.new(0, winW, 0, 0),
            BackgroundTransparency = 1,
        }, function()
            screenGui:Destroy()
        end)
    end

    return Window
end

return Components
