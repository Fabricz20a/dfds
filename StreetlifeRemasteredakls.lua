local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Fabricz20a/dfds/refs/heads/main/Streetmob.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Fabricz20a/dfds/refs/heads/main/Streetlifepc.lua"))()
end
