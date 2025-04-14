-- Botão flutuante para simular Right Control
-- Script independente

-- Cria um ScreenGui para hospedar o botão
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CtrlButtonGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game.CoreGui

-- Cria o botão
local ctrlButton = Instance.new("TextButton")
ctrlButton.Name = "CtrlButton"
ctrlButton.Size = UDim2.new(0, 60, 0, 30)
ctrlButton.Position = UDim2.new(0.98, -60, 0.1, 0) -- Posicionado no canto superior direito
ctrlButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ctrlButton.BorderColor3 = Color3.fromRGB(255, 0, 86)
ctrlButton.BorderSizePixel = 2
ctrlButton.Font = Enum.Font.SourceSansBold
ctrlButton.Text = "Ctrl"
ctrlButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ctrlButton.TextSize = 18
ctrlButton.Parent = screenGui

-- Arredondar os cantos do botão
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 5)
uiCorner.Parent = ctrlButton

-- Adicionar efeito de hover
local originalColor = ctrlButton.BackgroundColor3
ctrlButton.MouseEnter:Connect(function()
    ctrlButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
end)

ctrlButton.MouseLeave:Connect(function()
    ctrlButton.BackgroundColor3 = originalColor
end)

-- Função para simular o pressionamento do Right Control
ctrlButton.MouseButton1Click:Connect(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightControl, false, game)
    
    -- Feedback visual
    ctrlButton.BackgroundColor3 = Color3.fromRGB(255, 0, 86)
    wait(0.1)
    ctrlButton.BackgroundColor3 = originalColor
end)

-- Tornar o botão arrastável
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput
local dragStart
local startPos

local function updatePosition(input)
    local delta = input.Position - dragStart
    ctrlButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

ctrlButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ctrlButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ctrlButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updatePosition(input)
    end
end)

-- Notificar que o botão foi criado
local function notify(text)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.9, 0)
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BorderSizePixel = 0
    notification.Text = text
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Font = Enum.Font.SourceSans
    notification.TextSize = 16
    notification.Parent = screenGui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 5)
    uiCorner.Parent = notification
    
    spawn(function()
        wait(2)
        notification:Destroy()
    end)
end

notify("Botão Ctrl criado com sucesso! Você pode arrastá-lo na tela.") 