local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Flying = false
local AutoSlapping = false
local Speed = 40

local BodyGyro, BodyVelocity
local FlyConnection, SlapConnection

-- 1. إنشاء واجهة السكربت باسم FOX
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FOX_Script"
ScreenGui.Parent = game:GetService("CoreGui")

-- لوحة خلفية لتنظيم الأزرار
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 140, 0, 240)
MainFrame.Position = UDim2.new(0, 20, 0.4, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
MainFrame.Parent = ScreenGui

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "قائمة فوكس"
Title.TextColor3 = Color3.fromRGB(255, 100, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = MainFrame

-- زر تفعيل/إيقاف الطيران
local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0, 120, 0, 40)
FlyButton.Position = UDim2.new(0, 10, 0, 40)
FlyButton.BackgroundColor3 = Color3.fromRGB(240, 50, 50)
FlyButton.Text = "الطيران: معطل"
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 16
FlyButton.Parent = MainFrame

-- زر تفعيل/إيقاف الصفع التلقائي
local SlapButton = Instance.new("TextButton")
SlapButton.Size = UDim2.new(0, 120, 0, 40)
SlapButton.Position = UDim2.new(0, 10, 0, 90)
SlapButton.BackgroundColor3 = Color3.fromRGB(240, 50, 50)
SlapButton.Text = "صفع تلقائي: قفل"
SlapButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SlapButton.Font = Enum.Font.SourceSansBold
SlapButton.TextSize = 15
SlapButton.Parent = MainFrame

-- زر الصعود للأعلى
local UpButton = Instance.new("TextButton")
UpButton.Size = UDim2.new(0, 55, 0, 40)
UpButton.Position = UDim2.new(0, 10, 0, 140)
UpButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
UpButton.Text = "فوق"
UpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UpButton.Font = Enum.Font.SourceSansBold
UpButton.TextSize = 16
UpButton.Parent = MainFrame

-- زر النزول للأسفل
local DownButton = Instance.new("TextButton")
DownButton.Size = UDim2.new(0, 55, 0, 40)
DownButton.Position = UDim2.new(0, 75, 0, 140)
DownButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
DownButton.Text = "تحت"
DownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DownButton.Font = Enum.Font.SourceSansBold
DownButton.TextSize = 16
DownButton.Parent = MainFrame

-- زر إخفاء الواجهة بالكامل
local CloseButton = Instance.new "TextButton"
CloseButton.Size = UDim2.new(0, 120, 0, 35)
CloseButton.Position = UDim2.new(0, 10, 0, 195)
CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CloseButton.Text = "تصغير القائمة"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local GoingUp, GoingDown = false, false
UpButton.MouseButton1Down:Connect(function() GoingUp = true end)
UpButton.MouseButton1Up:Connect(function() GoingUp = false end)
DownButton.MouseButton1Down:Connect(function() GoingDown = true end)
DownButton.MouseButton1Up:Connect(function() GoingDown = false end)

-- دالة التحكم بالطيران
local function StopFlying()
    Flying = false
    FlyButton.Text = "الطيران: معطل"
    FlyButton.BackgroundColor3 = Color3.fromRGB(240, 50, 50)
    if FlyConnection then FlyConnection:Disconnect() end
    if BodyGyro then BodyGyro:Destroy() end
    if BodyVelocity then BodyVelocity:Destroy() end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid.PlatformStand = false end
end

local function StartFlying()
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if not Root or not Humanoid then return end
    
    Flying = true
    FlyButton.Text = "الطيران: يعمل"
    FlyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    Humanoid.PlatformStand = true
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.cframe = Root.CFrame
    BodyGyro.Parent = Root
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = Root
    
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not Root or not Humanoid then return end
        local Camera = workspace.CurrentCamera
        local MoveVector = Vector3.new(0, 0, 0)
        
        if Humanoid.MoveDirection.Magnitude > 0 then
            MoveVector = Camera.CFrame.LookVector * (Humanoid.MoveDirection.Magnitude)
        end
        if GoingUp then MoveVector = MoveVector + Vector3.new(0, 1, 0) end
        if GoingDown then MoveVector = MoveVector - Vector3.new(0, 1, 0) end
        
        if MoveVector.Magnitude > 0 then
            BodyVelocity.velocity = MoveVector.Unit * Speed
        else
            BodyVelocity.velocity = Vector3.new(0, 0, 0)
        end
        BodyGyro.cframe = Camera.CFrame
    end)
end

FlyButton.MouseButton1Click:Connect(function()
    if Flying then StopFlying() else StartFlying() end
end)

-- دالة الصفع التلقائي
local function StopSlapping()
    AutoSlapping = false
    SlapButton.Text = "صفع تلقائي: قفل"
    SlapButton.BackgroundColor3 = Color3.fromRGB(240, 50, 50)
    if SlapConnection then SlapConnection:Disconnect() end
end

local function StartSlapping()
    AutoSlapping = true
    SlapButton.Text = "صفع تلقائي: تشغيل"
    SlapButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    
    SlapConnection = RunService.RenderStepped:Connect(function()
        if not AutoSlapping then return end
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local Tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") or Character:FindFirstChildOfClass("Tool")
        if Tool then
            if Tool.Parent == LocalPlayer.Backpack then
                Tool.Parent = Character
            end
            Tool:Activate()
        end
    end)
end

SlapButton.MouseButton1Click:Connect(function()
    if AutoSlapping then StopSlapping() else StartSlapping() end
end)

-- زر التصغير
local Minimal = false
CloseButton.MouseButton1Click:Connect(function()
    Minimal = not Minimal
    if Minimal then
        MainFrame.Size = UDim2.new(0, 140, 0, 30)
        FlyButton.Visible = false
        SlapButton.Visible = false
        UpButton.Visible = false
        DownButton.Visible = false
        CloseButton.Text = "تكبير القائمة"
        CloseButton.Position = UDim2.new(0, 10, 0, 35)
        MainFrame.Size = UDim2.new(0, 140, 0, 75)
    else
        MainFrame.Size = UDim2.new(0, 140, 0, 240)
        FlyButton.Visible = true
        SlapButton.Visible = true
        UpButton.Visible = true
        DownButton.Visible = true
        CloseButton.Text = "تصغير القائمة"
        CloseButton.Position = UDim2.new(0, 10, 0, 195)
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    StopFlying()
    StopSlapping()
end)
