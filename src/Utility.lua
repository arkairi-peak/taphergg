--[[
    TapherLib/Utility.lua
    Helper functions: instance creation, tweening, dragging, mobile input, ripple, etc.
]]

local Utility = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

-- ── Instance Factory ─────────────────────────────────────────────────────────

function Utility.Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- ── Tweening ─────────────────────────────────────────────────────────────────

function Utility.Tween(instance, info, props, callback)
    local t = TweenService:Create(instance, info, props)
    t:Play()
    if callback then
        t.Completed:Connect(callback)
    end
    return t
end

function Utility.Spring(instance, props, speed, dampening)
    -- Simulate spring via stepped lerp for smooth feel
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        local done = true
        for prop, target in pairs(props) do
            local current = instance[prop]
            if typeof(current) == "number" then
                local new = current + (target - current) * math.min(1, dt * (speed or 14))
                instance[prop] = new
                if math.abs(new - target) > 0.001 then done = false end
            elseif typeof(current) == "Color3" then
                local r = current.R + (target.R - current.R) * math.min(1, dt * (speed or 14))
                local g = current.G + (target.G - current.G) * math.min(1, dt * (speed or 14))
                local b = current.B + (target.B - current.B) * math.min(1, dt * (speed or 14))
                instance[prop] = Color3.new(r, g, b)
                done = false
            end
        end
        if done then conn:Disconnect() end
    end)
    return conn
end

-- ── UI Decorators ────────────────────────────────────────────────────────────

function Utility.Round(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = frame
    return c
end

function Utility.Stroke(frame, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = frame
    return s
end

function Utility.Gradient(frame, colorList, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colorList)
    g.Rotation = rotation or 90
    g.Parent = frame
    return g
end

function Utility.Padding(frame, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.Parent = frame
    return p
end

function Utility.ListLayout(frame, direction, padding, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection = direction or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, padding or 6)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = frame
    return l
end

-- ── Glow / Shadow ────────────────────────────────────────────────────────────

function Utility.GlowEffect(parent, color, size, transparency)
    local glow = Utility.Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = color,
        ImageTransparency = transparency or 0.5,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(1, size or 40, 1, size or 40),
        ZIndex = parent.ZIndex - 1,
        Parent = parent,
    })
    return glow
end

function Utility.Shadow(parent, offset, transparency)
    local s = Utility.Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.65,
        Position = UDim2.new(0, -(offset or 12), 0, -(offset or 12)),
        Size = UDim2.new(1, (offset or 12) * 2, 1, (offset or 12) * 2),
        ZIndex = parent.ZIndex - 1,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ScaleType = Enum.ScaleType.Slice,
        Parent = parent,
    })
    return s
end

-- ── Ripple Effect ────────────────────────────────────────────────────────────

function Utility.AddRipple(button, color)
    button.ClipsDescendants = true
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Utility.Create("Frame", {
            Name = "Ripple",
            BackgroundColor3 = color or Color3.new(1, 1, 1),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            ZIndex = button.ZIndex + 5,
            Parent = button,
        })
        Utility.Round(ripple, 9999)

        local pos = button.AbsolutePosition
        local relX = x - pos.X
        local relY = y - pos.Y
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.2

        ripple.Position = UDim2.new(0, relX, 0, relY)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)

        Utility.Tween(ripple,
            TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1 },
            function() ripple:Destroy() end
        )
    end)
end

-- ── Dragging ─────────────────────────────────────────────────────────────────

function Utility.MakeDraggable(handle, target)
    local dragging, dragStart, startPos
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    local function onInputBegan(input)
        local validInput = input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        if validInput then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
        end
    end

    local function onInputChanged(input)
        local validInput = input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        if dragging and validInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end

    local function onInputEnded(input)
        local validInput = input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        if validInput then
            dragging = false
        end
    end

    handle.InputBegan:Connect(onInputBegan)
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(onInputEnded)
end

-- ── Keybind Detection ────────────────────────────────────────────────────────

function Utility.OnKeybind(key, callback)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == key then
            callback()
        end
    end)
end

-- ── Device Detection ─────────────────────────────────────────────────────────

function Utility.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility.IsTablet()
    local viewport = workspace.CurrentCamera.ViewportSize
    return UserInputService.TouchEnabled and viewport.X >= 768
end

-- ── Typewriter text ──────────────────────────────────────────────────────────

function Utility.Typewrite(label, text, speed, callback)
    label.Text = ""
    local len = #text
    local i = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        i = i + (speed or 1)
        local chars = math.floor(i)
        if chars > len then chars = len end
        label.Text = string.sub(text, 1, chars)
        if chars >= len then
            conn:Disconnect()
            if callback then callback() end
        end
    end)
    return conn
end

-- ── Color Utilities ──────────────────────────────────────────────────────────

function Utility.LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

function Utility.HexToColor3(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber("0x" .. hex:sub(1,2)),
        tonumber("0x" .. hex:sub(3,4)),
        tonumber("0x" .. hex:sub(5,6))
    )
end

function Utility.Color3ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

return Utility
