-- LOAD FLUENT
local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()
local SaveManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
))()
local InterfaceManager = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
))()

-- WINDOW
local Window = Fluent:CreateWindow({
    Title = "Escape Tsunami For Brainrots",
    SubTitle = "By Moskvv",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Q
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "menu" }),
    Antiafk = Window:AddTab({ Title = "Anti afk", Icon = "aperture" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

-- PLAYER
local player = Players.LocalPlayer
local humanoid
local TARGET_WALKSPEED = 200
local enabled = false
local autoCollect = false
local AutoUpgradeEnabled = false
local InstantProxEnabled = false

-- REMOTES
local CollectMoney = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")
local UpgradeSpeed = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed")
local Rebirth = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("Rebirth")

-- STORE ORIGINAL PROX DURATIONS
local originalDurations = {}

-- FUNCTIONS

-- Get default WalkSpeed from GUI
local function getDefaultSpeed()
    local gui = player:WaitForChild("PlayerGui")
    local label = gui:WaitForChild("SpeedShop")
        :WaitForChild("Frame")
        :WaitForChild("Speed1")
        :WaitForChild("CurrentSpeed")
    return tonumber(label.Text) or 16
end

-- Respawn-safe character hook
local function hookCharacter(char)
    humanoid = char:WaitForChild("Humanoid")
    task.wait(0.1)
    humanoid.WalkSpeed = enabled and TARGET_WALKSPEED or getDefaultSpeed()
end

-- Reset character instantly
local function ResetCharacter()
    if player.Character then
        player.Character:BreakJoints()
    end
end

-- Get Speed progress for Upgrade/Rebirth
local function getSpeedValues()
    local gui = player:WaitForChild("PlayerGui")
    local speedLabel = gui:WaitForChild("Menus")
        :WaitForChild("Rebirth")
        :WaitForChild("ProgressBar")
        :WaitForChild("Speed")
    local text = speedLabel.Text
    local first, second = text:match("Speed (%d+)/(%d+)")
    return tonumber(first), tonumber(second)
end

-- Fire all proximity prompts
local function FireAllProximityPrompts()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end
end

-- Update Prox Durations every 0.1s
local function UpdateProxDurations()
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if not originalDurations[prompt] then
                originalDurations[prompt] = prompt.HoldDuration
            end
            if InstantProxEnabled then
                prompt.HoldDuration = 0
            else
                prompt.HoldDuration = originalDurations[prompt]
            end
        end
    end
end

-- HOOK CHARACTER
if player.Character then
    hookCharacter(player.Character)
end
player.CharacterAdded:Connect(hookCharacter)

-- LOOPS

-- WalkSpeed enforcement
RunService.RenderStepped:Connect(function()
    if enabled and humanoid and humanoid.WalkSpeed ~= TARGET_WALKSPEED then
        humanoid.WalkSpeed = TARGET_WALKSPEED
    end
end)

-- Auto collect money
task.spawn(function()
    while true do
        if autoCollect then
            for i = 1, 30 do
                CollectMoney:FireServer("Slot"..i)
            end
        end
        task.wait(0.5)
    end
end)

-- Auto Upgrade & Rebirth
task.spawn(function()
    while true do
        if AutoUpgradeEnabled then
            local current, max = getSpeedValues()
            while current < max do
                UpgradeSpeed:InvokeServer(1)
                task.wait(0.05)
                current, max = getSpeedValues()
            end
            Rebirth:InvokeServer()
            AutoUpgradeEnabled = false
        end
        task.wait(0.1)
    end
end)

-- Instant Prox Duration updater
task.spawn(function()
    while true do
        if InstantProxEnabled then
            UpdateProxDurations()
        end
        task.wait(0.1)
    end
end)

-- UI ELEMENTS

-- WalkSpeed Toggle
local SpeedToggle = Tabs.Main:AddToggle("SpeedToggle", {
    Title = "Enable WalkSpeed",
    Default = false
})
SpeedToggle:OnChanged(function(Value)
    enabled = Value
    if humanoid then
        humanoid.WalkSpeed = enabled and TARGET_WALKSPEED or getDefaultSpeed()
    end
end)

-- WalkSpeed Slider
local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
    Title = "WalkSpeed",
    Description = "Adjust WalkSpeed",
    Default = TARGET_WALKSPEED,
    Min = 16,
    Max = 300,
    Rounding = 1,
    Callback = function(Value)
        TARGET_WALKSPEED = Value
        if enabled and humanoid then
            humanoid.WalkSpeed = TARGET_WALKSPEED
        end
    end
})

-- WalkSpeed Keybind
local SpeedKeybind = Tabs.Main:AddKeybind("SpeedKeybind", {
    Title = "Toggle WalkSpeed Keybind",
    Mode = "Toggle",
    Default = "F",
    Callback = function(Value)
        enabled = Value
        SpeedToggle:SetValue(Value)
    end
})
SpeedKeybind:OnClick(function()
    enabled = SpeedKeybind:GetState()
    SpeedToggle:SetValue(enabled)
end)

-- Auto Collect Toggle
local AutoCollectToggle = Tabs.Main:AddToggle("AutoCollectToggle", {
    Title = "Auto Collect Money",
    Default = false
})
AutoCollectToggle:OnChanged(function(Value)
    autoCollect = Value
end)

-- Instant Prox Toggle
local InstantProxToggle = Tabs.Main:AddToggle("InstantProxToggle", {
    Title = "Instant Proximity",
    Default = false
})
InstantProxToggle:OnChanged(function(Value)
    InstantProxEnabled = Value
end)

-- Auto Upgrade & Rebirth Toggle
local AutoUpgradeToggle = Tabs.Main:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade Speed & Rebirth",
    Default = false
})
AutoUpgradeToggle:OnChanged(function(Value)
    AutoUpgradeEnabled = Value
end)

-- Collect Money Button
Tabs.Main:AddButton({
    Title = "Collect All Money",
    Description = "Collects all brainrot money",
    Callback = function()
        for i = 1, 30 do
            CollectMoney:FireServer("Slot"..i)
        end
    end
})

-- Rebirth Button
Tabs.Main:AddButton({
    Title = "Rebirth",
    Description = "Upgrade speed until max, then Rebirth",
    Callback = function()
        local current, max = getSpeedValues()
        while current < max do
            UpgradeSpeed:InvokeServer(1)
            task.wait(0.05)
            current, max = getSpeedValues()
        end
        Rebirth:InvokeServer()
    end
})

-- Anti-AFK
local AntiAFK = true
Tabs.Antiafk:AddToggle("AntiAFK", {
    Title = "Enable Anti-AFK",
    Description = "Prevents Kicks from afk",
    Default = true
}):OnChanged(function(Value)
    AntiAFK = Value
    Fluent:Notify({
        Title = "Anti-AFK",
        Content = Value and "Enabled" or "Disabled",
        Duration = 3
    })
end)

task.spawn(function()
    while task.wait(45) do
        if AntiAFK then
            VirtualInput:SendKeyEvent(true, Enum.KeyCode.H, false, game)
            task.wait(0.05)
            VirtualInput:SendKeyEvent(false, Enum.KeyCode.H, false, game)
        end
    end
end)

-- SETTINGS / SAVE
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/WalkSpeedMoney")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- SELECT DEFAULT TAB
Window:SelectTab(1)

-- NOTIFICATION
Fluent:Notify({
    Title = "Loaded",
    Content = "Script has been loaded successfully",
    Duration = 6
})

-- OPTIONAL: reset character on start
task.wait(2)
ResetCharacter()
