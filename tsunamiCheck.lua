local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

repeat task.wait() until player and UserInputService

repeat task.wait() until UserInputService.TouchEnabled ~= nil and UserInputService.KeyboardEnabled ~= nil

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Fabricz20a/dfds/refs/heads/main/EscapetsunamiMobile.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Fabricz20a/dfds/refs/heads/main/Escapetsunamipc.lua"))()
end

local guiFolder = game.CoreGui:WaitForChild("larp")
local gui = guiFolder:WaitForChild("UnsupportedGameGUI")

-- Optional extra wait before destroying
task.wait(1)  -- wait 1 second
gui:Destroy()
