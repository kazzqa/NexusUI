--[[ 
    NexusUI - UI Library for Roblox
    V2.2 - Fixed Tab Indicator resizing & ZIndex.
]]

local NexusUI = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local THEME = {
    Bg = Color3.fromRGB(14, 14, 22), Panel = Color3.fromRGB(24, 24, 36),
    Panel2 = Color3.fromRGB(34, 34, 50), Line = Color3.fromRGB(52, 52, 76),
    Accent = Color3.fromRGB(145, 95, 255), Accent2 = Color3.fromRGB(55, 195, 255),
    Text = Color3.fromRGB(240, 240, 250), SubText = Color3.fromRGB(140, 140, 165),
    Off = Color3.fromRGB(62, 62, 84), Green = Color3.fromRGB(70, 235, 140),
    Red = Color3.fromRGB(255, 85, 100),
}
local WHITE = Color3.new(1, 1, 1)

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(obj, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, obj) end
local function stroke(obj, color, thick, trans) return new("UIStroke", {Color = color, Thickness = thick or 1, Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, obj) end
local function gradient(obj, c1, c2, rot) return new("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 0}, obj) end
local function tween(obj, t, props) TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end
local function hover(obj, normal, over)
    obj.MouseEnter:Connect(function() tween(obj, 0.15, {BackgroundColor3 = over}) end)
    obj.MouseLeave:Connect(function() tween(obj, 0.15, {BackgroundColor3 = normal}) end)
end

local function getGuiParent()
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then
        local test = Instance.new("Folder")
        local ok2 = pcall(function() test.Parent = cg end)
        if ok2 and test.Parent == cg then test:Destroy() return cg end
    end
    return player:WaitForChild("PlayerGui")
end

local Window = {}
Window.__index = Window

function NexusUI:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, Window)
    self.GUI_PARENT = getGuiParent()
    self.Connections = {}
    self.CurrentTab = 1
    
    local old = self.GUI_PARENT:FindFirstChild("NexusUI_Menu")
    if old then old:Destroy() end

    self.MenuGui = new("ScreenGui", {Name = "NexusUI_Menu", ResetOnSpawn = false, DisplayOrder = 1000}, self.GUI_PARENT)
    self.FULL_SIZE = config.Size or UDim2.fromOffset(440, 480)
    self.MIN_SIZE = UDim2.fromOffset(self.FULL_SIZE.X.Offset, 58)
    self.Minimized = false
    
    self.WindowFrame = new("Frame", {
        Name = "Window", Size = self.FULL_SIZE, Position = UDim2.new(0, 30, 0.5, -self.FULL_SIZE.Y.Offset/2),
        BackgroundColor3 = WHITE, BorderSizePixel = 0, ClipsDescendants = true,
    }, self.MenuGui)
    corner(self.WindowFrame, 18)
    new("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(24, 20, 40), Color3.fromRGB(10, 10, 17)), Rotation = 90}, self.WindowFrame)

    local winStroke = stroke(self.WindowFrame, WHITE, 2, 0)
    local winGrad = new("UIGradient", {
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, THEME.Accent), ColorSequenceKeypoint.new(0.5, THEME.Accent2), ColorSequenceKeypoint.new(1, THEME.Accent)}),
    }, winStroke)
    
    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt) 
        if winGrad then winGrad.Rotation = (winGrad.Rotation + dt * 70) % 360 end 
    end))

    local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1}, self.WindowFrame)
    local Icon = new("Frame", {Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(14, 10), BackgroundColor3 = WHITE, BorderSizePixel = 0}, Header)
    corner(Icon, 12)
    local iconGrad = gradient(Icon, THEME.Accent, THEME.Accent2, 45)
    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt) 
        if iconGrad then iconGrad.Rotation = (iconGrad.Rotation + dt * 40) % 360 end 
    end))
    
    new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = config.Icon or "⚔", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = WHITE}, Icon)
    new("TextLabel", {Size = UDim2.new(1, -210, 0, 20), Position = UDim2.fromOffset(62, 9), BackgroundTransparency = 1, Text = config.Title or "NEXUS UI", Font = Enum.Font.GothamBlack, TextSize = 17, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left}, Header)
    new("TextLabel", {Size = UDim2.new(1, -210, 0, 14), Position = UDim2.fromOffset(62, 30), BackgroundTransparency = 1, Text = config.SubTitle or "ui library", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = THEME.SubText, TextXAlignment = Enum.TextXAlignment.Left}, Header)

    local function titleButton(text, xOffset)
        local b = new("TextButton", {Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, xOffset, 0, 15), BackgroundColor3 = THEME.Panel, Text = text, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = THEME.Text, AutoButtonColor = false}, Header)
        corner(b, 9)
        hover(b, THEME.Panel, THEME.Panel2)
        return b
    end
    local MinBtn = titleButton("–", -70)
    local CloseBtn = titleButton("✕", -38)

    self.TabBar = new("Frame", {Size = UDim2.new(1, -24, 0, 36), Position = UDim2.fromOffset(12, 60), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0}, self.WindowFrame)
    corner(self.TabBar, 12)

    -- Инициализируем индикатор нулевого размера
    self.TabIndicator = new("Frame", {Size = UDim2.new(0, 0, 1, -6), Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 1}, self.TabBar)
    corner(self.TabIndicator, 9)
    gradient(self.TabIndicator, THEME.Accent, THEME.Accent2, 0)
    
    self.PagesHolder = new("Frame", {Size = UDim2.new(1, 0, 1, -106), Position = UDim2.fromOffset(0, 104), BackgroundTransparency = 1}, self.WindowFrame)
    self.Tabs = {}
    self.TabButtons = {}

    self.Toast = new("Frame", {Size = UDim2.new(1, -40, 0, 32), AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 50), BackgroundColor3 = THEME.Panel2, BorderSizePixel = 0, ZIndex = 20}, self.WindowFrame)
    corner(self.Toast, 10)
    stroke(self.Toast, THEME.Accent, 1.2, 0.3)
    self.ToastText = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = THEME.Text, ZIndex = 21}, self.Toast)
    self.toastToken = 0

    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.WindowFrame.Position
        end
    end)
    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            self.WindowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))

    MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        tween(self.WindowFrame, 0.25, {Size = self.Minimized and self.MIN_SIZE or self.FULL_SIZE})
        MinBtn.Text = self.Minimized and "+" or "–"
    end)
    CloseBtn.MouseButton1Click:Connect(function() self:Destroy() end)

    local Fab = new("TextButton", {Name = "Fab", Size = UDim2.fromOffset(46, 46), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 70), BackgroundColor3 = WHITE, Text = config.Icon or "⚔", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = WHITE, AutoButtonColor = false}, self.MenuGui)
    corner(Fab, 23)
    local fabGrad = gradient(Fab, THEME.Accent, THEME.Accent2, 45)
    stroke(Fab, WHITE, 1.5, 0.6)
    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt) 
        if fabGrad then fabGrad.Rotation = (fabGrad.Rotation + dt * 50) % 360 end 
    end))
    Fab.MouseButton1Click:Connect(function() self.WindowFrame.Visible = not self.WindowFrame.Visible end)
    
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then self.WindowFrame.Visible = not self.WindowFrame.Visible end
    end))

    function self:Notify(text)
        self.toastToken += 1
        local my = self.toastToken
        self.ToastText.Text = text
        tween(self.Toast, 0.25, {Position = UDim2.new(0.5, 0, 1, -12)})
        task.delay(1.6, function()
            if self.toastToken == my then tween(self.Toast, 0.25, {Position = UDim2.new(0.5, 0, 1, 50)}) end
        end)
    end
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do
            if conn then conn:Disconnect() end
        end
        self.MenuGui:Destroy()
    end
    
    function self:SelectTab(index)
        local numTabs = #self.Tabs
        if numTabs == 0 then return end
        self.CurrentTab = index
        
        for j, pg in ipairs(self.Tabs) do pg.Visible = (j == index) end
        for j, b in ipairs(self.TabButtons) do tween(b, 0.2, {TextColor3 = (j == index) and WHITE or THEME.SubText}) end
        
        local widthScale = 1 / numTabs
        tween(self.TabIndicator, 0.25, {
            Size = UDim2.new(widthScale, -6, 1, -6),
            Position = UDim2.new((index - 1) * widthScale, 3, 0, 3)
        })
    end

    return self
end

local Tab = {}
Tab.__index = Tab

function Window:AddTab(text)
    local tab = setmetatable({}, Tab)
    tab.Owner = self
    tab.Index = #self.TabButtons + 1
    local numTabs = tab.Index
    
    -- Кнопка вкладки (ZIndex = 2, чтобы быть поверх индикатора)
    local b = new("TextButton", {
        Size = UDim2.new(1 / numTabs, 0, 1, 0), Position = UDim2.new((numTabs - 1) / numTabs, 0, 0, 0),
        BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold,
        TextSize = 12, TextColor3 = THEME.SubText, AutoButtonColor = false,
        ZIndex = 2, TextYAlignment = Enum.TextYAlignment.Center
    }, self.TabBar)
    
    -- Подгоняем размеры всех предыдущих кнопок
    for i, btn in ipairs(self.TabButtons) do
        tween(btn, 0.2, {Size = UDim2.new(1 / numTabs, 0, 1, 0), Position = UDim2.new((i - 1) / numTabs, 0, 0, 0)})
    end
    
    b.MouseButton1Click:Connect(function() self:SelectTab(tab.Index) end)
    table.insert(self.TabButtons, b)
    
    local sf = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, self.PagesHolder)
    
    new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, sf)
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, sf)
    
    tab.Frame = sf
    table.insert(self.Tabs, sf)
    
    -- Пересчитываем индикатор при добавлении новой вкладки (без клика)
    if self.CurrentTab then
        local widthScale = 1 / numTabs
        self.TabIndicator.Size = UDim2.new(widthScale, -6, 1, -6)
        self.TabIndicator.Position = UDim2.new((self.CurrentTab - 1) * widthScale, 3, 0, 3)
    end
    
    -- Если это первая вкладка, активируем её
    if tab.Index == 1 then self:SelectTab(1) end
    
    return tab
end

local function nextOrder(page)
    local n = (page.Frame:GetAttribute("o") or 0) + 1
    page.Frame:SetAttribute("o", n)
    return n
end

function Tab:AddSection(text)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = string.upper(text),
        Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = THEME.SubText,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(self),
    }, self.Frame)
end

function Tab:AddButton(text, callback)
    local btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = THEME.Panel, Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, AutoButtonColor = false, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(btn, 10)
    stroke(btn, THEME.Line, 1, 0.5)
    hover(btn, THEME.Panel, THEME.Panel2)
    btn.MouseButton1Click:Connect(callback)
end

function Tab:AddCard(height)
    local c = new("Frame", {Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(c, 12)
    stroke(c, THEME.Line, 1, 0.55)
    return c
end

function Tab:AddMasterToggle(title, desc, callback)
    local row = new("TextButton", {Size = UDim2.new(1, 0, 0, 64), BackgroundColor3 = WHITE, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(row, 14)
    local g = new("UIGradient", {Rotation = 0}, row)
    new("TextLabel", {Size = UDim2.new(1, -80, 0, 22), Position = UDim2.fromOffset(16, 11), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamBlack, TextSize = 17, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local sub = new("TextLabel", {Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(16, 34), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(230, 230, 245), TextXAlignment = Enum.TextXAlignment.Left, Text = desc}, row)
    local power = new("TextLabel", {Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -54, 0.5, -20), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.7, Text = "⏻", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = WHITE}, row)
    corner(power, 20)

    local state = false
    local function update()
        if state then
            g.Color = ColorSequence.new(THEME.Accent, THEME.Accent2)
            sub.Text = desc
        else
            g.Color = ColorSequence.new(Color3.fromRGB(62, 62, 84), Color3.fromRGB(42, 42, 58))
            sub.Text = "Выключено"
        end
    end
    update()
    row.MouseButton1Click:Connect(function()
        state = not state
        update()
        callback(state)
        self.Owner:Notify(title .. (state and " вкл" or " выкл"))
    end)
end

function Tab:AddToggle(text, default, callback)
    local state = default or false
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(row, 12)
    stroke(row, THEME.Line, 1, 0.55)
    new("TextLabel", {Size = UDim2.new(1, -80, 0, 18), Position = UDim2.fromOffset(14, 7), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left}, row)
    
    local pill = new("TextButton", {Size = UDim2.fromOffset(46, 26), Position = UDim2.new(1, -60, 0.5, -13), Text = "", AutoButtonColor = false, BackgroundColor3 = WHITE}, row)
    corner(pill, 13)
    local pg = new("UIGradient", {Rotation = 0}, pill)
    local knob = new("Frame", {Size = UDim2.fromOffset(20, 20), BackgroundColor3 = WHITE, BorderSizePixel = 0}, pill)
    corner(knob, 10)

    local function render(animate)
        pg.Color = state and ColorSequence.new(THEME.Accent, THEME.Accent2) or ColorSequence.new(THEME.Off, THEME.Off)
        local pos = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        if animate then tween(knob, 0.18, {Position = pos}) else knob.Position = pos end
    end
    render(false)
    pill.MouseButton1Click:Connect(function()
        state = not state
        render(true)
        callback(state)
    end)
end

function Tab:AddSlider(text, min, max, default, callback, suffix)
    local val = default or min
    local step = (max - min) / 100
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(row, 12)
    stroke(row, THEME.Line, 1, 0.55)
    new("TextLabel", {Size = UDim2.new(0.6, 0, 0, 20), Position = UDim2.fromOffset(14, 8), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local valBg = new("Frame", {Size = UDim2.fromOffset(74, 22), Position = UDim2.new(1, -88, 0, 7), BackgroundColor3 = THEME.Panel2, BorderSizePixel = 0}, row)
    corner(valBg, 8)
    local valText = new("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = THEME.Accent2}, valBg)
    local track = new("TextButton", {Text = "", AutoButtonColor = false, Size = UDim2.new(1, -28, 0, 6), Position = UDim2.fromOffset(14, 42), BackgroundColor3 = THEME.Off}, row)
    corner(track, 3)
    local fill = new("Frame", {BackgroundColor3 = WHITE, BorderSizePixel = 0}, track)
    corner(fill, 3)
    gradient(fill, THEME.Accent, THEME.Accent2, 0)
    local knob = new("Frame", {Size = UDim2.fromOffset(16, 16), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 3}, track)
    corner(knob, 8)
    stroke(knob, THEME.Accent, 2.5, 0)

    local function fmt(v) return tostring(math.floor(v * 1000 + 0.5) / 1000) end
    local function render()
        local a = math.clamp((val - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valText.Text = fmt(val) .. (suffix or "")
    end
    local activeSlider = nil
    local function setFromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = min + (max - min) * a
        val = math.floor(val / step + 0.5) * step
        val = math.clamp(val, min, max)
        render()
        callback(val)
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tween(knob, 0.12, {Size = UDim2.fromOffset(20, 20)})
            activeSlider = {move = setFromX, done = function() tween(knob, 0.12, {Size = UDim2.fromOffset(16, 16)}) end}
            setFromX(input.Position.X)
        end
    end)
    table.insert(self.Owner.Connections, UserInputService.InputChanged:Connect(function(input)
        if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then activeSlider.move(input.Position.X) end
    end))
    table.insert(self.Owner.Connections, UserInputService.InputEnded:Connect(function(input)
        if activeSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then activeSlider.done() activeSlider = nil end
    end))
    render()
end

function Tab:AddColorPicker(text, default, callback)
    local currentColor = default or Color3.fromRGB(255, 50, 50)
    local SWATCHES = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 150, 40), Color3.fromRGB(255, 225, 60), Color3.fromRGB(50, 255, 50), Color3.fromRGB(50, 220, 255), Color3.fromRGB(80, 120, 255), Color3.fromRGB(170, 90, 255), Color3.fromRGB(255, 90, 200)}
    local row = new("Frame", {Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = nextOrder(self)}, self.Frame)
    corner(row, 12)
    stroke(row, THEME.Line, 1, 0.55)
    new("TextLabel", {Size = UDim2.new(1, -28, 0, 20), Position = UDim2.fromOffset(14, 8), BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left}, row)
    local holder = new("Frame", {Size = UDim2.new(1, -28, 0, 24), Position = UDim2.fromOffset(14, 31), BackgroundTransparency = 1}, row)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, holder)

    local list = {}
    for i, c in ipairs(SWATCHES) do
        local b = new("TextButton", {Size = UDim2.fromOffset(24, 24), BackgroundColor3 = c, Text = "", AutoButtonColor = false, LayoutOrder = i}, holder)
        corner(b, 12)
        local st = stroke(b, WHITE, 2, currentColor == c and 0 or 1)
        list[i] = {st = st, color = c}
        b.MouseButton1Click:Connect(function()
            currentColor = c
            for _, it in ipairs(list) do tween(it.st, 0.15, {Transparency = (it.color == c) and 0 or 1}) end
            callback(c)
        end)
    end
end

function Tab:AddPlayerList(getPlayers, isSelected, onSelect)
    local FriendsList = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(self)}, self.Frame)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, FriendsList)

    local addRow = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = 1}, FriendsList)
    corner(addRow, 12)
    stroke(addRow, THEME.Line, 1, 0.55)
    local box = new("TextBox", {Size = UDim2.new(1, -64, 1, -12), Position = UDim2.fromOffset(14, 6), BackgroundTransparency = 1, PlaceholderText = "Впиши ник вручную...", PlaceholderColor3 = THEME.SubText, Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, addRow)
    local addBtn = new("TextButton", {Size = UDim2.fromOffset(36, 26), Position = UDim2.new(1, -46, 0.5, -13), BackgroundColor3 = WHITE, Text = "+", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = WHITE, AutoButtonColor = false}, addRow)
    corner(addBtn, 9)
    gradient(addBtn, THEME.Accent, THEME.Accent2, 0)

    local thumbCache = {}
    local rebuild
    local function loadThumb(img, userId)
        if thumbCache[userId] then img.Image = thumbCache[userId] return end
        task.spawn(function()
            local ok, url = pcall(function() return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if ok and url then thumbCache[userId] = url img.Image = url end
        end)
    end

    rebuild = function()
        for _, c in ipairs(FriendsList:GetChildren()) do
            if not c:IsA("UIListLayout") and c ~= addRow then c:Destroy() end
        end
        local players = getPlayers()
        table.sort(players, function(a, b) return string.lower(a.DisplayName or a.Name) < string.lower(b.DisplayName or b.Name) end)
        local idx = 1
        for _, p in ipairs(players) do
            idx += 1
            local friend = isSelected(p)
            local row = new("Frame", {Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = THEME.Panel, BorderSizePixel = 0, LayoutOrder = idx}, FriendsList)
            corner(row, 12)
            stroke(row, friend and THEME.Green or THEME.Line, 1, friend and 0.5 or 0.55)
            local av = new("ImageLabel", {Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(9, 7), BackgroundColor3 = THEME.Panel2, BorderSizePixel = 0, Image = ""}, row)
            corner(av, 17)
            stroke(av, friend and THEME.Green or THEME.Red, 2, 0)
            if p.UserId then loadThumb(av, p.UserId) end
            new("TextLabel", {Size = UDim2.new(1, -140, 0, 18), Position = UDim2.fromOffset(52, 7), BackgroundTransparency = 1, Text = p.DisplayName or p.Name, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = THEME.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
            new("TextLabel", {Size = UDim2.new(1, -140, 0, 14), Position = UDim2.fromOffset(52, 26), BackgroundTransparency = 1, Text = "@" .. (p.Name or "unknown"), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = THEME.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
            local btn = new("TextButton", {Size = UDim2.fromOffset(66, 28), Position = UDim2.new(1, -76, 0.5, -14), BorderSizePixel = 0, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 11}, row)
            corner(btn, 9)
            btn.Text = friend and "ВЫБРАН" or "ВЫБРАТЬ"
            btn.TextColor3 = friend and THEME.Green or THEME.SubText
            btn.BackgroundColor3 = friend and Color3.fromRGB(26, 62, 46) or THEME.Off
            btn.MouseButton1Click:Connect(function()
                onSelect(p, not friend)
                rebuild()
            end)
        end
    end

    addBtn.MouseButton1Click:Connect(function()
        local text = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if text ~= "" then onSelect({Name = text, DisplayName = text}, true) box.Text = "" rebuild() end
    end)
    box.FocusLost:Connect(function(enter) 
        if enter then 
            local text = box.Text:gsub("^%s+", ""):gsub("%s+$", "")
            if text ~= "" then onSelect({Name = text, DisplayName = text}, true) box.Text = "" rebuild() end
        end 
    end)
    table.insert(self.Owner.Connections, Players.PlayerAdded:Connect(function() task.delay(0.3, rebuild) end))
    table.insert(self.Owner.Connections, Players.PlayerRemoving:Connect(function() task.delay(0.1, rebuild) end))
    rebuild()
    return {Refresh = rebuild}
end

return NexusUI
