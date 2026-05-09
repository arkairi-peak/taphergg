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

    -- Blur
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    -- Root frame
    local isMobile = Utility.IsMobile()
    local winW = isMobile and 340 or 560
    local winH = isMobile and 420 or 500

    local root = Utility.Create("Frame", {
        Name = "TapherWindow",
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = T.GlassTransparency,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, winW, 0, winH),
        ZIndex = 2,
        Parent = screenGui,
    })
    Utility.Round(root, 14)
    Utility.Stroke(root, T.Border, 1, T.BorderTransp)
    Utility.Shadow(root, 22, 0.45)

    -- Glass shimmer gradient
    local shimmer = Utility.Create("Frame", {
        BackgroundTransparency = 0.85,
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0.38, 0),
        ZIndex = root.ZIndex,
        Parent = root,
    })
    Utility.Round(shimmer, 14)
    Utility.Gradient(shimmer, {
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100,120,200)),
    }, 140)

    -- Title bar
    local titleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Logo / icon area
    local logoBox = Utility.Create("Frame", {
        BackgroundColor3 = T.Accent,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 28, 0, 28),
        ZIndex = root.ZIndex + 2,
        Parent = titleBar,
    })
    Utility.Round(logoBox, 7)
    Utility.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Text = opts.Icon or "◈",
        TextColor3 = Color3.new(1,1,1),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        ZIndex = root.ZIndex + 3,
        Parent = logoBox,
    })
    Utility.Padding(logoBox, 4,4,4,4)

    -- Title text
    Utility.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 0),
        Size = UDim2.new(0.6, 0, 1, 0),
        Text = opts.Title or "TapherLib",
        TextColor3 = T.TextPrimary,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = root.ZIndex + 2,
        Parent = titleBar,
    })

    -- Subtitle
    if opts.Subtitle then
        Utility.Create("TextLabel", {
            Name = "Subtitle",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 18),
            Size = UDim2.new(0.5, 0, 0, 14),
            Text = opts.Subtitle,
            TextColor3 = T.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
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
        Text = "✕",
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

    -- Divider
    Utility.Create("Frame", {
        BackgroundColor3 = T.Border,
        BackgroundTransparency = 0.4,
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

    -- Tab bar (left sidebar style)
    local sidebar = Utility.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = T.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 48),
        Size = UDim2.new(0, isMobile and 80 or 110, 1, -48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })
    Utility.Round(sidebar, 0)

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
    local tabLayout = Utility.ListLayout(tabList, Enum.FillDirection.Vertical, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Utility.Padding(tabList, 0, 6, 0, 6)

    -- Content area
    local contentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, isMobile and 80 or 110, 0, 48),
        Size = UDim2.new(1, -(isMobile and 80 or 110), 1, -48),
        ZIndex = root.ZIndex + 1,
        Parent = root,
    })

    -- Search bar (inside content header)
    local searchBar, searchInput
    if opts.SearchBar ~= false then
        searchBar = Utility.Create("Frame", {
            Name = "SearchBar",
            BackgroundColor3 = T.InputBg,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 8),
            Size = UDim2.new(1, -20, 0, 28),
            ZIndex = root.ZIndex + 2,
            Parent = contentArea,
        })
        Utility.Round(searchBar, 8)
        Utility.Stroke(searchBar, T.Border, 1, 0.6)

        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Text = "⌕",
            TextColor3 = T.TextMuted,
            TextSize = 14,
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

    -- Close / minimise logic
    local minimised = false
    local fullSize  = UDim2.new(0, winW, 0, winH)
    local miniSize  = UDim2.new(0, winW, 0, 48)

    closeBtn.MouseButton1Click:Connect(function()
        Utility.Tween(root, med, { Size = UDim2.new(0, winW, 0, 0), BackgroundTransparency = 1 }, function()
            screenGui:Destroy()
            blur:Destroy()
        end)
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        Utility.Tween(root, med, { Size = minimised and miniSize or fullSize })
    end)

    -- Keybind to toggle visibility
    if opts.Keybind then
        Utility.OnKeybind(opts.Keybind, function()
            root.Visible = not root.Visible
        end)
    end

    -- Entrance animation
    root.Size = UDim2.new(0, winW, 0, 0)
    root.BackgroundTransparency = 1
    Utility.Tween(root, slow, {
        Size = fullSize,
        BackgroundTransparency = T.GlassTransparency,
    })
    Utility.Tween(blur, slow, { Size = T.BlurSize })

    -- ── Tab system ────────────────────────────────────────────────────────────
    local tabs = {}
    local activeTab = nil

    local Window = {}

    function Window:AddTab(tabOpts)
        tabOpts = tabOpts or {}
        local tabName = tabOpts.Name or ("Tab " .. #tabs + 1)
        local T2 = Theme.Current

        -- Sidebar button
        local tabBtn = Utility.Create("TextButton", {
            Name = tabName,
            BackgroundColor3 = T2.TabInactive,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -12, 0, 36),
            Text = "",
            ZIndex = root.ZIndex + 3,
            Parent = tabList,
        })
        Utility.Round(tabBtn, 8)

        -- Icon
        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(0, 20, 1, 0),
            Text = tabOpts.Icon or "◉",
            TextColor3 = T2.TextMuted,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            ZIndex = root.ZIndex + 4,
            Name = "Icon",
            Parent = tabBtn,
        })

        Utility.Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 28, 0, 0),
            Size = UDim2.new(1, -30, 1, 0),
            Text = tabName,
            TextColor3 = T2.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = root.ZIndex + 4,
            Name = "Label",
            Parent = tabBtn,
        })

        -- Active indicator bar
        local indicator = Utility.Create("Frame", {
            BackgroundColor3 = T2.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.2, 0),
            Size = UDim2.new(0, 3, 0.6, 0),
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

        local tab = { btn = tabBtn, content = content, indicator = indicator, components = {} }
        table.insert(tabs, tab)

        -- Activate on click
        tabBtn.MouseButton1Click:Connect(function()
            Window:SetActiveTab(tab)
        end)

        -- Hover
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tab then
                Utility.Tween(tabBtn, fast, { BackgroundTransparency = 0.2 })
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tab then
                Utility.Tween(tabBtn, fast, { BackgroundTransparency = 0.4 })
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
                BackgroundColor3 = T3.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 8)
            Utility.Stroke(frame, T3.Border, 1, 0.65)

            local btn = Utility.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = frame.ZIndex + 1,
                Parent = frame,
            })

            Utility.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 0, 0),
                Size = UDim2.new(0.7, 0, 1, 0),
                Text = bOpts.Name or "Button",
                TextColor3 = T3.TextPrimary,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            local descLabel
            if bOpts.Description then
                Utility.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 18),
                    Size = UDim2.new(0.7, 0, 0, 14),
                    Text = bOpts.Description,
                    TextColor3 = T3.TextMuted,
                    TextSize = 10,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = frame.ZIndex + 2,
                    Parent = frame,
                })
                frame.Size = UDim2.new(1, 0, 0, 50)
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
                Utility.Tween(frame, fast, { BackgroundColor3 = T3.SurfaceLighter, BackgroundTransparency = 0.2 })
            end)
            btn.MouseLeave:Connect(function()
                Utility.Tween(frame, fast, { BackgroundColor3 = T3.SurfaceLight, BackgroundTransparency = 0.35 })
            end)
            btn.MouseButton1Click:Connect(function()
                if bOpts.Callback then bOpts.Callback() end
            end)

            table.insert(tab.components, { frame = frame, label = bOpts.Name or "" })
            return frame
        end

        -- ── Toggle ────────────────────────────────────────────────────────────
        function Tab:AddToggle(tOpts)
            tOpts = tOpts or {}
            local T3 = Theme.Current
            local state = tOpts.Default or false

            local frame = Utility.Create("Frame", {
                BackgroundColor3 = T3.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 38),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 8)
            Utility.Stroke(frame, T3.Border, 1, 0.65)

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
                BackgroundColor3 = state and T3.Accent or T3.ToggleOff,
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
                Utility.Tween(track, fast, { BackgroundColor3 = state and T3.Accent or T3.ToggleOff })
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
                BackgroundColor3 = T3.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 54),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 8)
            Utility.Stroke(frame, T3.Border, 1, 0.65)

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
                BackgroundColor3 = T3.SliderTrack,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 14, 0, 32),
                Size = UDim2.new(1, -28, 0, 6),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(track, 99)

            local fill = Utility.Create("Frame", {
                BackgroundColor3 = T3.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                ZIndex = frame.ZIndex + 3,
                Parent = track,
            })
            Utility.Round(fill, 99)

            local thumb = Utility.Create("Frame", {
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
                Text = "▾",
                TextColor3 = T3.TextMuted,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })

            -- Dropdown list
            local listFrame = Utility.Create("ScrollingFrame", {
                BackgroundColor3 = T3.Surface,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = T3.Accent,
                Visible = false,
                ZIndex = frame.ZIndex + 10,
                Parent = frame,
            })
            Utility.Round(listFrame, 8)
            Utility.Stroke(listFrame, T3.Border, 1, 0.5)
            local listLayout = Utility.ListLayout(listFrame, Enum.FillDirection.Vertical, 2)
            Utility.Padding(listFrame, 4, 4, 4, 4)

            local function populateList()
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local optBtn = Utility.Create("TextButton", {
                        BackgroundColor3 = opt == selected and T3.Accent or T3.SurfaceLight,
                        BackgroundTransparency = opt == selected and 0.3 or 0.5,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = opt,
                        TextColor3 = opt == selected and T3.TextPrimary or T3.TextSecondary,
                        TextSize = 11,
                        Font = Enum.Font.Gotham,
                        ZIndex = listFrame.ZIndex + 1,
                        Parent = listFrame,
                    })
                    Utility.Round(optBtn, 6)
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        selLabel.Text = selected
                        open = false
                        Utility.Tween(listFrame, fast, { Size = UDim2.new(1, 0, 0, 0) }, function()
                            listFrame.Visible = false
                        end)
                        Utility.Tween(arrow, fast, { Rotation = 0 })
                        if dOpts.Callback then dOpts.Callback(selected) end
                        populateList()
                    end)
                end
                local totalH = math.min(#options * 30 + 8, 150)
                listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
                listFrame._targetH = totalH
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
                listFrame.Visible = true
                local targetH = open and (listFrame._targetH or 120) or 0
                Utility.Tween(listFrame, fast, { Size = UDim2.new(1, 0, 0, targetH) }, function()
                    if not open then listFrame.Visible = false end
                end)
                Utility.Tween(arrow, fast, { Rotation = open and 180 or 0 })
            end)

            if dOpts.Flag then
                Config.Register(dOpts.Flag, function() return selected end, function(v)
                    selected = v; selLabel.Text = v; populateList()
                end)
            end

            table.insert(tab.components, { frame = frame, label = dOpts.Name or "" })

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
                BackgroundColor3 = T3.SurfaceLight,
                BackgroundTransparency = 0.35,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 54),
                ZIndex = content.ZIndex + 1,
                Parent = content,
            })
            Utility.Round(frame, 8)
            Utility.Stroke(frame, T3.Border, 1, 0.65)

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
                BackgroundColor3 = T3.InputBg,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, 24),
                Size = UDim2.new(1, -20, 0, 22),
                ZIndex = frame.ZIndex + 2,
                Parent = frame,
            })
            Utility.Round(inputBox, 6)

            local stroke = Utility.Stroke(inputBox, T3.Border, 1, 0.5)

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
                Utility.Tween(stroke, fast, { Color = T3.Border, Transparency = 0.5 })
                if iOpts.Callback then iOpts.Callback(textBox.Text, enter) end
            end)

            if iOpts.Flag then
                Config.Register(iOpts.Flag, function() return textBox.Text end, function(v) textBox.Text = v end)
            end

            table.insert(tab.components, { frame = frame, label = iOpts.Name or "" })

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
            Utility.Round(preview, 6)
            Utility.Stroke(preview, T3.Border, 1, 0.4)

            -- Expanded picker panel
            local pickerPanel = Utility.Create("Frame", {
                BackgroundColor3 = T3.Surface,
                BackgroundTransparency = 0.08,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 4),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ZIndex = frame.ZIndex + 10,
                Parent = frame,
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
            openBtn.MouseButton1Click:Connect(function()
                open = not open
                pickerPanel.Visible = true
                local targetH = open and (22 * 3 + 6 * 2 + 20) or 0
                Utility.Tween(pickerPanel, fast, { Size = UDim2.new(1, 0, 0, targetH) }, function()
                    if not open then pickerPanel.Visible = false end
                end)
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
                    BackgroundColor3 = T3.Surface,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, #label * 7 + 16, 1, 0),
                    ZIndex = sep.ZIndex + 2,
                    Parent = sep,
                })
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

        return Tab
    end

    function Window:SetActiveTab(tab)
        if activeTab then
            activeTab.content.Visible = false
            Utility.Tween(activeTab.btn, fast, {
                BackgroundColor3 = Theme.Current.TabInactive,
                BackgroundTransparency = 0.4,
            })
            activeTab.indicator.Visible = false
            activeTab.btn:FindFirstChild("Label").TextColor3 = Theme.Current.TextSecondary
            activeTab.btn:FindFirstChild("Icon").TextColor3  = Theme.Current.TextMuted
        end
        activeTab = tab
        tab.content.Visible = true
        Utility.Tween(tab.btn, fast, {
            BackgroundColor3 = Theme.Current.Accent,
            BackgroundTransparency = 0.25,
        })
        tab.indicator.Visible = true
        tab.btn:FindFirstChild("Label").TextColor3 = Theme.Current.TextPrimary
        tab.btn:FindFirstChild("Icon").TextColor3  = Color3.new(1,1,1)
    end

    function Window:Destroy()
        Utility.Tween(root, med, {
            Size = UDim2.new(0, winW, 0, 0),
            BackgroundTransparency = 1,
        }, function()
            screenGui:Destroy()
            blur:Destroy()
        end)
    end

    return Window
end

return Components
