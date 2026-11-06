# 🚀 NexusUI - Advanced Roblox UI Library

NexusUI is a fully customizable, purely visual UI library for Roblox. It does not contain any game logic (like Killaura or ESP), giving you complete freedom to build your own scripts. 

Inspired by modern libraries like Rayfield and Fluent.

## 🔗 Library Link

**Raw Link (for scripts):**
```text
https://raw.githubusercontent.com/kazzqa/NexusUI/refs/heads/main/NexusUI.lua
```

**Ready-to-use Loadstring:**
```lua
local NexusUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/kazzqa/NexusUI/refs/heads/main/NexusUI.lua"))()
```

---

## 🛠 Installation

1. Create a new file in your script editor (e.g., `NexusUI.lua`).
2. Paste the NexusUI source code.
3. Upload it to GitHub (or any raw text hosting service).
4. Get the **Raw URL** of your file.

## 📖 Quick Start

To load the library into your script, use the loadstring above and create your first window:

```lua
local Window = NexusUI:CreateWindow({
    Title = "MY SCRIPT",
    SubTitle = "visuals • combat • misc",
    Icon = "⚔",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = UDim2.fromOffset(440, 480) -- Optional
})
```

## 🧩 UI Components

### 1. Creating Tabs
The library automatically adjusts the width and position of tabs based on how many you add.

```lua
local TabCombat = Window:AddTab("⚔ Combat")
local TabVisuals = Window:AddTab("👁 Visuals")
local TabSettings = Window:AddTab("⚙ Settings")
```

### 2. Adding Elements

**Master Toggle (Big Button):**
```lua
TabCombat:AddMasterToggle("MAIN FEATURE", "Active state", function(state)
    print("Master toggle:", state)
end)
```

**Section Divider:**
```lua
TabCombat:AddSection("SETTINGS")
```

**Standard Toggle:**
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

**Color Picker (with Rainbow Mode):**
Includes a built-in rainbow gradient option. If the user selects it, the callback returns the string `"Rainbow"`.
```lua
TabVisuals:AddColorPicker("Enemy Color", Color3.fromRGB(255, 50, 50), function(color)
    if color == "Rainbow" then
        print("Rainbow mode enabled!")
    else
        print("Color:", color)
    end
end)
```

### 3. 🆕 Expandable Settings (Right-Click Menu)
You can create a toggle that reveals hidden sub-settings when the user **Right-Clicks** on it or clicks the arrow `▼`. 

To put elements inside the sub-menu, just pass the `parent` variable (provided by the `buildSettings` function) as the last argument to your Sliders or ColorPickers.

```lua
TabVisuals:AddExpandableToggle("Skeleton ESP", false, function(state)
    print("Skeleton:", state)
end, function(parent)
    -- These elements will appear inside the expandable menu!
    TabVisuals:AddSlider("Thickness", 1, 5, 2, function(val)
        print("Thickness:", val)
    end, " px", parent) 
end)
```

### 4. Universal Player List
A smart component for Whitelists, Blacklists, or targeting. It handles avatars and dynamic updates.

```lua
local function getPlayers()
    local list = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer then table.insert(list, p) end
    end
    return list
end

local PlayerList = TabSettings:AddPlayerList(
    getPlayers, 
    function(player) return false end, -- Is Selected? (e.g., return isBlacklisted(player))
    function(player, isSelected)
        Window:Notify(player.Name .. (isSelected and " selected" or " unselected"))
    end
)
```
