# 🚀 NexusUI - Advanced Roblox UI Library

NexusUI is a fully customizable, purely visual UI library for Roblox. It does not contain any game logic (like Killaura or ESP), giving you complete freedom to build your own scripts. 

Inspired by modern libraries like Rayfield and Fluent.

# 🔗 Library Link

**Raw Link (for scripts):**
```text
https://raw.githubusercontent.com/kazzqa/NexusUI/refs/heads/main/NexusUI.lua
```

## 🛠 Installation

1. Create a new file in your script editor (e.g., `NexusUI.lua`).
2. Paste the NexusUI source code.
3. Upload it to GitHub (or any raw text hosting service).
4. Get the **Raw URL** of your file (e.g., `https://raw.githubusercontent.com/username/repo/main/NexusUI.lua`).

## 📖 Quick Start

To load the library into your script, use:

```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/kazzqa/NexusUI/refs/heads/main/NexusUI.lua"))()
```

## 🧩 UI Components

### 1. Creating a Window

```lua
local Window = NexusUI:CreateWindow({
    Title = "MY SCRIPT",
    SubTitle = "visuals • combat • misc",
    Icon = "⚔",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(340, 450)
})
```

### 2. Creating Tabs

```lua
local TabCombat = Window:AddTab("⚔ COMBAT")
local TabVisuals = Window:AddTab("👁 VISUALS")
```

### 3. Adding Elements

**Master Toggle:**
```lua
TabCombat:AddMasterToggle("MAIN FEATURE", "Description", function(state)
    print("State:", state)
end)
```

**Section Divider:**
```lua
TabCombat:AddSection("SETTINGS")
```

**Button:**
```lua
TabCombat:AddButton("Click Me", function()
    Window:Notify("Clicked!")
end)
```

**Toggle:**
```lua
TabCombat:AddToggle("Wall Check", true, function(state)
    print("Wall check:", state)
end)
```

**Slider:**
```lua
TabCombat:AddSlider("Range", 1, 50, 15, function(value)
    print("Range:", value)
end, " studs")
```

**Color Picker:**
```lua
TabVisuals:AddColorPicker("Enemy Color", Color3.fromRGB(255, 50, 50), function(color)
    print("Color:", color)
end)
```

**Universal Player List:**
```lua
local function getPlayers()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(list, p) end
    end
    return list
end

local PlayerList = TabVisuals:AddPlayerList(
    getPlayers, 
    function(player) return false end, -- Is Selected?
    function(player, isSelected)
        Window:Notify(player.Name .. (isSelected and " selected" or " unselected"))
    end
)
```
