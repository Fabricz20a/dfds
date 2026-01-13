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
