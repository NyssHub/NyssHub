-- Modificação para compatibilidade com KRNL
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success then
    -- Caso falhe, tenta um método alternativo
    Fluent = loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end

-- Global variables to track feature states
_G.PlayerESPActive = false
_G.SpeedMultiplier = 1
_G.HitboxSize = 5
_G.HitboxTransparency = 0.5
_G.HitboxViewerActive = false
_G.HitboxExpanderActive = false

-- UI Colors
local Colors = {
    Primary = Color3.fromRGB(33, 150, 243),
    Accent = Color3.fromRGB(255, 0, 86),
    Background = Color3.fromRGB(21, 21, 30),
    Text = Color3.fromRGB(240, 240, 240)
}

-- Create UI Window (interface reduzida)
local Window = Fluent:CreateWindow({
    Title = "Aimbot Hub",
    SubTitle = "by Aham",
    TabWidth = 120,
    Size = UDim2.fromOffset(380, 350), -- Interface bem menor
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Notification on load
Fluent:Notify({
    Title = "Script Carregado",
    Content = "Aimbot Game Hub inicializado com sucesso!",
    Duration = 3
})

-- Create tabs (reduzido)
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10723407389" }),
    Players = Window:AddTab({ Title = "Players", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Main section
local MainSection = Tabs.Main:AddSection("Funcionalidades")

MainSection:AddParagraph({
    Title = "Aimbot Game Hub",
    Content = "Script com funcionalidades para jogos."
})

-- Function to start player ESP
local function startPlayerESP()
    if _G.PlayerESPActive then return end
    _G.PlayerESPActive = true
    
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    
    -- Clean up any existing ESP folders
    for _, obj in pairs(game.CoreGui:GetChildren()) do
        if obj.Name == "PlayerESPFolder" then
            obj:Destroy()
        end
    end
    
    -- Create a new folder for ESP objects
    local PlayerESPFolder = Instance.new("Folder")
    PlayerESPFolder.Name = "PlayerESPFolder"
    PlayerESPFolder.Parent = game.CoreGui
    
    -- Table to track all players
    local playerESPObjects = {}
    
    -- Function to create ESP for a player
    local function createPlayerESP(player)
        if player == LocalPlayer then return end
        
        -- Create or update ESP objects for this player
        if not playerESPObjects[player.Name] then
            playerESPObjects[player.Name] = {
                highlight = nil,
                billboard = nil
            }
        end
        
        -- Remove old ESP objects if they exist
        if playerESPObjects[player.Name].highlight then
            playerESPObjects[player.Name].highlight:Destroy()
        end
        
        if playerESPObjects[player.Name].billboard then
            playerESPObjects[player.Name].billboard:Destroy()
        end
        
        -- Check if player has a character
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        -- Create new highlight
        local PlayerHighlight = Instance.new("Highlight")
        PlayerHighlight.Name = player.Name .. "Highlight"
        PlayerHighlight.FillColor = Colors.Primary
        PlayerHighlight.OutlineColor = Colors.Primary
        PlayerHighlight.FillTransparency = 0.5
        PlayerHighlight.OutlineTransparency = 0
        PlayerHighlight.Adornee = player.Character
        PlayerHighlight.Parent = PlayerESPFolder
        
        -- Create new billboard
        local PlayerBillboard = Instance.new("BillboardGui")
        PlayerBillboard.Name = player.Name .. "Billboard"
        PlayerBillboard.AlwaysOnTop = true
        PlayerBillboard.Size = UDim2.new(0, 200, 0, 50)
        PlayerBillboard.StudsOffset = Vector3.new(0, 3, 0)
        PlayerBillboard.Adornee = player.Character:FindFirstChild("Head")
        PlayerBillboard.Parent = PlayerESPFolder
        
        local PlayerNameLabel = Instance.new("TextLabel")
        PlayerNameLabel.Name = "NameLabel"
        PlayerNameLabel.BackgroundTransparency = 1
        PlayerNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        PlayerNameLabel.Text = player.Name
        PlayerNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayerNameLabel.TextStrokeTransparency = 0
        PlayerNameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        PlayerNameLabel.Font = Enum.Font.SourceSansBold
        PlayerNameLabel.TextSize = 14
        PlayerNameLabel.Parent = PlayerBillboard
        
        -- Store the ESP objects
        playerESPObjects[player.Name].highlight = PlayerHighlight
        playerESPObjects[player.Name].billboard = PlayerBillboard
    end
    
    -- Update ESP for all players every second
    local updateESPConnection = nil
    updateESPConnection = RunService.Heartbeat:Connect(function()
        if not _G.PlayerESPActive then
            if updateESPConnection then
                updateESPConnection:Disconnect()
            end
            return
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createPlayerESP(player)
            end
        end
    end)
    
    Fluent:Notify({
        Title = "Player ESP",
        Content = "ESP de jogadores ativado!",
        Duration = 3
    })
    
    return function()
        _G.PlayerESPActive = false
        if updateESPConnection then
            updateESPConnection:Disconnect()
        end
        
        if PlayerESPFolder then
            PlayerESPFolder:Destroy()
        end
        
        playerESPObjects = {}
    end
end

-- Game Info section
local InfoSection = Tabs.Main:AddSection("Informações do Jogo")

local GameInfoParagraph = InfoSection:AddParagraph({
    Title = "Status",
    Content = "Carregando informações..."
})

-- Update game info periodically
spawn(function()
    while wait(1) do
        local playerCount = #game:GetService("Players"):GetPlayers()
        local time = os.date("%H:%M:%S")
        
        if GameInfoParagraph and GameInfoParagraph.SetDesc then
            pcall(function()
                GameInfoParagraph:SetDesc(string.format(
                    "Jogadores: %d\nHorário: %s",
                    playerCount, time
                ))
            end)
        end
    end
end)

-- ESP section on Main Tab
local ESPSection = Tabs.Main:AddSection("ESP Features")

local PlayerESPToggle = Tabs.Main:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Description = "Destaca jogadores e mostra informações",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisablePlayerESP = startPlayerESP()
        else
            if _G.DisablePlayerESP then
                _G.DisablePlayerESP()
                _G.DisablePlayerESP = nil
            end
        end
    end
})

-- Function to update player speed
local function updatePlayerSpeed(value)
    _G.SpeedMultiplier = value
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    
    -- Apply immediately
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16 * value -- 16 is the default value
    end
    
    Fluent:Notify({
        Title = "Velocidade",
        Content = "Velocidade definida para " .. value .. "x",
        Duration = 2
    })
end

-- Function to start hitbox expander
local function startHitboxExpander()
    if _G.HitboxExpanderActive then return end
    _G.HitboxExpanderActive = true
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    local function updateHitboxes()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = player.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                    hrp.Transparency = _G.HitboxTransparency
                    hrp.CanCollide = false
                end
            end
        end
    end
    
    local hitboxConnection = RunService.Heartbeat:Connect(function()
        if not _G.HitboxExpanderActive then return end
        updateHitboxes()
    end)
    
    Fluent:Notify({
        Title = "Hitbox Expander",
        Content = "Hitbox Expander ativado! Tamanho: " .. _G.HitboxSize,
        Duration = 3
    })
    
    return function()
        _G.HitboxExpanderActive = false
        if hitboxConnection then
            hitboxConnection:Disconnect()
        end
        
        -- Reset hitboxes
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                    player.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end
end

-- Function to start hitbox viewer
local function startHitboxViewer()
    if _G.HitboxViewerActive then return end
    _G.HitboxViewerActive = true
    
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    
    -- Clean up any existing hitbox viewer folders
    for _, obj in pairs(game.CoreGui:GetChildren()) do
        if obj.Name == "HitboxViewerFolder" then
            obj:Destroy()
        end
    end
    
    -- Create a new folder for hitbox viewer objects
    local HitboxViewerFolder = Instance.new("Folder")
    HitboxViewerFolder.Name = "HitboxViewerFolder"
    HitboxViewerFolder.Parent = game.CoreGui
    
    local hitboxHighlights = {}
    
    local function updateHitboxViewer()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Remove old highlight if it exists
                    if hitboxHighlights[player.Name] then
                        hitboxHighlights[player.Name]:Destroy()
                        hitboxHighlights[player.Name] = nil
                    end
                    
                    -- Create new highlight
                    local highlight = Instance.new("Highlight")
                    highlight.Name = player.Name .. "HitboxHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = player.Character.HumanoidRootPart
                    highlight.Parent = HitboxViewerFolder
                    
                    hitboxHighlights[player.Name] = highlight
                end
            end
        end
    end
    
    local hitboxViewerConnection = RunService.Heartbeat:Connect(function()
        if not _G.HitboxViewerActive then return end
        updateHitboxViewer()
    end)
    
    Fluent:Notify({
        Title = "Hitbox Viewer",
        Content = "Hitbox Viewer ativado!",
        Duration = 3
    })
    
    return function()
        _G.HitboxViewerActive = false
        if hitboxViewerConnection then
            hitboxViewerConnection:Disconnect()
        end
        
        if HitboxViewerFolder then
            HitboxViewerFolder:Destroy()
        end
        
        hitboxHighlights = {}
    end
end

-- Connection to apply speed to new characters
local function setupPlayerModifications()
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    
    local function modifyCharacter(character)
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16 * _G.SpeedMultiplier
        end
    end
    
    if Player.Character then
        modifyCharacter(Player.Character)
    end
    
    Player.CharacterAdded:Connect(modifyCharacter)
    
    -- Constant loop to force speed settings
    local connectionStep = RunService.Stepped:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            local humanoid = Player.Character.Humanoid
            
            -- If values were changed by the game, restore to our values
            if humanoid.WalkSpeed ~= 16 * _G.SpeedMultiplier then
                humanoid.WalkSpeed = 16 * _G.SpeedMultiplier
            end
        end
    end)
    
    -- Store the connection in a global variable to prevent garbage collection
    _G.PlayerModConnection = connectionStep
end

setupPlayerModifications()

-- Add Player Tab sections and controls
local PlayerSection = Tabs.Players:AddSection("Modificações de Jogador")

local SpeedSlider = Tabs.Players:AddSlider("SpeedSlider", {
    Title = "Velocidade",
    Description = "Ajusta a velocidade do personagem",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(value)
        updatePlayerSpeed(value)
    end
})

-- Hitbox section
local HitboxSection = Tabs.Players:AddSection("Hitbox Modifications")

local HitboxSizeSlider = Tabs.Players:AddSlider("HitboxSize", {
    Title = "Tamanho da Hitbox",
    Description = "Ajusta o tamanho da hitbox dos jogadores",
    Default = 5,
    Min = 2,
    Max = 50, -- Aumentado de 20 para 50
    Rounding = 1,
    Callback = function(value)
        _G.HitboxSize = value
        Fluent:Notify({
            Title = "Hitbox Size",
            Content = "Tamanho da hitbox definido para " .. value,
            Duration = 2
        })
    end
})

local HitboxTransparencySlider = Tabs.Players:AddSlider("HitboxTransparency", {
    Title = "Transparência da Hitbox",
    Description = "Ajusta a transparência da hitbox dos jogadores",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        _G.HitboxTransparency = value
        Fluent:Notify({
            Title = "Hitbox Transparency",
            Content = "Transparência da hitbox definida para " .. value,
            Duration = 2
        })
    end
})

local HitboxExpanderToggle = Tabs.Players:AddToggle("HitboxExpander", {
    Title = "Hitbox Expander",
    Description = "Aumenta a hitbox dos jogadores para facilitar acertos",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisableHitboxExpander = startHitboxExpander()
        else
            if _G.DisableHitboxExpander then
                _G.DisableHitboxExpander()
                _G.DisableHitboxExpander = nil
            end
            
            Fluent:Notify({
                Title = "Hitbox Expander",
                Content = "Hitbox Expander desativado!",
                Duration = 3
            })
        end
    end
})

local HitboxViewerToggle = Tabs.Players:AddToggle("HitboxViewer", {
    Title = "Hitbox Viewer",
    Description = "Mostra a hitbox dos jogadores",
    Default = false,
    Callback = function(state)
        if state then
            _G.DisableHitboxViewer = startHitboxViewer()
        else
            if _G.DisableHitboxViewer then
                _G.DisableHitboxViewer()
                _G.DisableHitboxViewer = nil
            end
            
            Fluent:Notify({
                Title = "Hitbox Viewer",
                Content = "Hitbox Viewer desativado!",
                Duration = 3
            })
        end
    end
})

-- Settings section for credits
local CreditsSection = Tabs.Settings:AddSection("Créditos")

CreditsSection:AddParagraph({
    Title = "Créditos",
    Content = "Script feito por Aham / Nyss\nUI baseada na biblioteca Fluent"
})
