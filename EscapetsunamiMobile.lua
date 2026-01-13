-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- CREATE WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Escape Tsunami For Brainrots",
    LoadingTitle = "Loading UI",
    LoadingSubtitle = "By Moskvv",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BrainrotsScripts",
        FileName = "MainConfig"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

-- TABS
local MainTab = Window:CreateTab("Main")
local AntiAFKTab = Window:CreateTab("Anti AFK")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")

-- PLAYER VARIABLES
local player = Players.LocalPlayer
local humanoid
local TARGET_WALKSPEED = 200
local enabledWalkSpeed = false
local autoCollect = false
local autoUpgrade = false
local instantProx = false
local AntiAFK = true

-- REMOTES
local CollectMoney = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")
local UpgradeSpeed = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeSpeed")
local Rebirth = ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("Rebirth")

-- ORIGINAL PROX DURATIONS
local originalDurations = {}

-- FUNCTIONS
local function getDefaultSpeed()
    local gui = player:WaitForChild("PlayerGui")
    local label = gui:WaitForChild("SpeedShop")
        :WaitForChild("Frame")
        :WaitForChild("Speed1")
        :WaitForChild("CurrentSpeed")
    return tonumber(label.Text) or 16
end

local function hookCharacter(char)
    humanoid = char:WaitForChild("Humanoid")
    task.wait(0.1)
    humanoid.WalkSpeed = enabledWalkSpeed and TARGET_WALKSPEED or getDefaultSpeed()
end

if player.Character then hookCharacter(player.Character) end
player.CharacterAdded:Connect(hookCharacter)

local function ResetCharacter()
    if player.Character then
        player.Character:BreakJoints()
    end
end

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

-- Instant Proximity Functions
local function SetAllProxDuration(duration)
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if not originalDurations[prompt] then
                originalDurations[prompt] = prompt.HoldDuration
            end
            prompt.HoldDuration = duration
        end
    end
end

local function RestoreAllProxDurations()
    for prompt, dur in pairs(originalDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = dur
        end
    end
end

-- LOOPS
RunService.RenderStepped:Connect(function()
    if enabledWalkSpeed and humanoid and humanoid.WalkSpeed ~= TARGET_WALKSPEED then
        humanoid.WalkSpeed = TARGET_WALKSPEED
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if autoCollect then
            for i = 1, 30 do
                CollectMoney:FireServer("Slot"..i)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if autoUpgrade then
            local current, max = getSpeedValues()
            if current >= max then
                Rebirth:InvokeServer()
                autoUpgrade = false
            else
                UpgradeSpeed:InvokeServer(1)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if instantProx then
            SetAllProxDuration(0)
        end
    end
end)

-- MAIN TAB UI
local WalkSpeedToggle = MainTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(val)
        enabledWalkSpeed = val
        if humanoid then
            humanoid.WalkSpeed = enabledWalkSpeed and TARGET_WALKSPEED or getDefaultSpeed()
        end
    end
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = TARGET_WALKSPEED,
    Flag = "WalkSpeedSlider",
    Callback = function(val)
        TARGET_WALKSPEED = val
        if enabledWalkSpeed and humanoid then
            humanoid.WalkSpeed = TARGET_WALKSPEED
        end
    end
})

-- WalkSpeed Keybind
local WalkSpeedKeybind = MainTab:CreateKeybind({
    Name = "Toggle WalkSpeed Keybind",
    CurrentKeybind = "F",
    HoldToInteract = false,
    Flag = "WalkSpeedKeybind",
    Callback = function()
        enabledWalkSpeed = not enabledWalkSpeed
        WalkSpeedToggle:Set(enabledWalkSpeed)
        if humanoid then
            humanoid.WalkSpeed = enabledWalkSpeed and TARGET_WALKSPEED or getDefaultSpeed()
        end
    end
})
WalkSpeedKeybind:Set("F")

MainTab:CreateToggle({Name = "Auto Collect Money", CurrentValue = false, Flag = "AutoCollectToggle", Callback = function(val) autoCollect = val end})
MainTab:CreateToggle({Name = "Auto Upgrade & Rebirth", CurrentValue = false, Flag = "AutoUpgradeToggle", Callback = function(val) autoUpgrade = val end})
MainTab:CreateToggle({Name = "Instant Proximity", CurrentValue = false, Flag = "InstantProxToggle", Callback = function(val)
    instantProx = val
    if not val then RestoreAllProxDurations() end
end})

MainTab:CreateButton({Name = "Collect All Money", Callback = function() for i=1,30 do CollectMoney:FireServer("Slot"..i) end end})
MainTab:CreateButton({Name = "Rebirth", Callback = function() 
    local current,max = getSpeedValues() 
    while current < max do UpgradeSpeed:InvokeServer(1) current,max = getSpeedValues() task.wait(0.05) end 
    Rebirth:InvokeServer() 
end})

-- ANTI AFK TAB
-- MOBILE-FRIENDLY ANTI AFK
local AntiAFKToggle = AntiAFKTab:CreateToggle({
    Name = "Enable Anti-AFK",
    CurrentValue = true,
    Callback = function(val) AntiAFK = val end
})

task.spawn(function()
    while task.wait(45) do
        if AntiAFKToggle.CurrentValue then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            -- simulate a tap on screen at center (0.5, 0.5)
            vu:ClickButton1(Vector2.new(0.5, 0.5))
        end
    end
end)


-- RESET CHARACTER OPTIONAL
task.wait(2)
if player.Character then
    player.Character:BreakJoints()
end
