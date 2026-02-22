local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI Koruma (Hangi executor olursa olsun çalışır)
local ScreenGui = Instance.new("ScreenGui")
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

-- Modern UI Tasarımı
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- UI Köşelerini Yumuşat (Daha Modern)
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Sürükleme Sistemi (Eleştirmen haklıydı, UIS en iyisidir)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Değişkenler ve Bağlantılar
local flyConnection
local activeHitbox = nil

-- Dinamik Hedefleme (Hata Vermeyen Sistem)
local function GetTargetVehicle()
    local map = workspace:FindFirstChild("Map")
    if map and map:FindFirstChild("Arabalar") then
        local carList = map.Arabalar:GetChildren()
        return carList[9] and carList[9]:FindFirstChild("Body") -- Hala 9'u istiyoruz ama yoksa hata vermez
    end
    return nil
end

-- Butonlar (Stil verilmiş)
local function CreateBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0.25, 0)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local FlyBtn = CreateBtn("Hitbox: OFF", UDim2.new(0.075, 0, 0.25, 0), Color3.fromRGB(40, 40, 40))
local TPBtn = CreateBtn("Araca Isinlan", UDim2.new(0.075, 0, 0.6, 0), Color3.fromRGB(0, 100, 200))

-- Ana Döngü (Performans Odaklı)
FlyBtn.MouseButton1Click:Connect(function()
    if not flyConnection then
        activeHitbox = GetTargetVehicle()
        if activeHitbox then
            FlyBtn.Text = "Hitbox: ON"
            FlyBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            flyConnection = RunService.Heartbeat:Connect(function()
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and activeHitbox and activeHitbox.Parent then
                    activeHitbox.CFrame = root.CFrame * CFrame.new(0, 0, -5)
                    activeHitbox.Velocity = Vector3.new(0,0,0)
                    -- Fizik Çakışmasını Engelle
                    if activeHitbox:IsA("BasePart") then activeHitbox.CanCollide = true end
                else
                    -- Bağlantı koptuğunda veya karakter ölünce temizle
                    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
                    FlyBtn.Text = "Hitbox: OFF"
                    FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                end
            end)
        end
    else
        flyConnection:Disconnect()
        flyConnection = nil
        FlyBtn.Text = "Hitbox: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

TPBtn.MouseButton1Click:Connect(function()
    local target = GetTargetVehicle()
    local char = player.Character
    if target and char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 5, 0)
    end
end)
