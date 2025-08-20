--[[
    ADVANCED EXPLOSION UI CLIENT
    Portfolio Showcase - Professional Client-Side Interface
    
    Features Demonstrated:
    - Sophisticated UI Architecture
    - Real-time Data Visualization
    - Interactive Control Systems
    - Advanced Animation Techniques
    - Performance Monitoring
    - Modular Component Design
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Import shared utilities
local MathUtils = require(ReplicatedStorage.Shared.MathUtils)
local UIAnimationSystem = require(ReplicatedStorage.Shared.UIAnimationSystem)
local NetworkOptimizer = require(ReplicatedStorage.Shared.NetworkOptimizer)
local DynamicLightingSystem = require(ReplicatedStorage.Shared.DynamicLightingSystem)
local PerformanceProfiler = require(ReplicatedStorage.Shared.PerformanceProfiler)

-- Wait for RemoteEvents
print("[DEBUG] ExplosionUI.client.lua is loading...")
local explosionEvent = ReplicatedStorage:WaitForChild("ExplosionEvent")
local uiUpdateEvent = ReplicatedStorage:WaitForChild("UIUpdateEvent")
local commandEvent = ReplicatedStorage:WaitForChild("CommandEvent")
print("[DEBUG] All RemoteEvents loaded successfully")

-- Advanced UI Configuration
local UI_CONFIG = {
    ANIMATIONS = {
        FLASH_DURATION = 0.4,
        SHAKE_INTENSITY = 8,
        NOTIFICATION_LIFETIME = 4,
        CHART_UPDATE_SPEED = 0.5,
        BUTTON_HOVER_SCALE = 1.1
    },
    
    COLORS = {
        PRIMARY = Color3.fromHSV(0.08, 0.9, 1), -- Orange
        SECONDARY = Color3.fromHSV(0.0, 0.8, 1), -- Red
        SUCCESS = Color3.fromHSV(0.33, 0.8, 1), -- Green
        WARNING = Color3.fromHSV(0.17, 0.9, 1), -- Yellow
        INFO = Color3.fromHSV(0.6, 0.8, 1), -- Blue
        BACKGROUND = Color3.fromRGB(20, 20, 25),
        SURFACE = Color3.fromRGB(35, 35, 40),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(180, 180, 185)
    },
    
    PATTERNS = {
        {name = "Random", icon = "🎲", color = Color3.fromHSV(0.08, 0.9, 1)},
        {name = "Chain", icon = "⛓️", color = Color3.fromHSV(0.0, 0.8, 1)},
        {name = "Spiral", icon = "🌀", color = Color3.fromHSV(0.6, 0.8, 1)},
        {name = "Grid", icon = "⬜", color = Color3.fromHSV(0.33, 0.8, 1)},
        {name = "Wave", icon = "🌊", color = Color3.fromHSV(0.17, 0.9, 1)}
    }
}

-- System State
local clientState = {
    explosionCount = 0,
    lastExplosionTime = 0,
    isShaking = false,
    notifications = {},
    performanceHistory = {},
    selectedPattern = "Random",
    systemRunning = true,
    controlsVisible = true
}

--[[
    UI COMPONENT CLASSES
--]]

--- Modern Button Component
local function createModernButton(parent, text, size, position, color, callback)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = UI_CONFIG.COLORS.TEXT_PRIMARY
    button.TextScaled = true
    button.Font = Enum.Font.SourceSansBold
    button.Parent = parent
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Hover effects
    local originalSize = size
    button.MouseEnter:Connect(function()
        -- Advanced hover animation with bounce effect
        UIAnimationSystem:bounce(button, UI_CONFIG.ANIMATIONS.BUTTON_HOVER_SCALE, 0.4)
        UIAnimationSystem:morphColor(button, Color3.fromRGB(
            math.min(255, color.R * 255 + 30),
            math.min(255, color.G * 255 + 30),
            math.min(255, color.B * 255 + 30)
        ), 0.2, "QuadOut")
    end)
    
    button.MouseLeave:Connect(function()
        -- Smooth return animation
        UIAnimationSystem:animate(button, {Size = originalSize}, 0.3, "ElasticOut")
        UIAnimationSystem:morphColor(button, color, 0.2, "QuadOut")
    end)
    
    -- Add click animation
    button.MouseButton1Down:Connect(function()
        UIAnimationSystem:animate(button, {
            Size = UDim2.new(
                originalSize.X.Scale * 0.95,
                originalSize.X.Offset,
                originalSize.Y.Scale * 0.95,
                originalSize.Y.Offset
            )
        }, 0.1, "QuadOut")
    end)
    
    button.MouseButton1Up:Connect(function()
        UIAnimationSystem:animate(button, {Size = originalSize}, 0.2, "BackOut")
    end)
    
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end





--- Control Panel
local function createControlPanel(parent)
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlPanel"
    controlFrame.Size = UDim2.new(1, -20, 0.75, 0) -- Responsive height
    controlFrame.Position = UDim2.new(0, 10, 0, 5)
    controlFrame.BackgroundColor3 = UI_CONFIG.COLORS.SURFACE
    controlFrame.BorderSizePixel = 0
    controlFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = controlFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "🎮 Control Panel"
    title.TextColor3 = UI_CONFIG.COLORS.TEXT_PRIMARY
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = controlFrame
    
    -- Manual explosion button
    local manualBtn = createModernButton(
        controlFrame,
        "💥 Manual Explosion",
        UDim2.new(0.48, 0, 0, 30),
        UDim2.new(0, 10, 0, 30),
        UI_CONFIG.COLORS.PRIMARY,
        function()
            print("[DEBUG] Manual explosion button clicked!")
            local position = Vector3.new(
                math.random(-75, 75),
                math.random(20, 60),
                math.random(-75, 75)
            )
            local intensity = MathUtils.map(math.random(), 0, 1, 0.8, 1.5)
            print(string.format("[DEBUG] Firing manual explosion to server: position=%s, intensity=%f", tostring(position), intensity))
            
            local success, err = pcall(function()
                commandEvent:FireServer("manual_explosion", {
                    position = position,
                    intensity = intensity
                })
            end)
            
            if not success then
                warn(string.format("[ERROR] Failed to fire remote event: %s", tostring(err)))
            else
                print("[SUCCESS] Remote event fired successfully")
            end
        end
    )
    
    -- Toggle system button
    local toggleBtn = createModernButton(
        controlFrame,
        "⏸️ Toggle System",
        UDim2.new(0.48, 0, 0, 30),
        UDim2.new(0.52, 0, 0, 30),
        UI_CONFIG.COLORS.WARNING,
        function()
            commandEvent:FireServer("toggle_system")
            clientState.systemRunning = not clientState.systemRunning
        end
    )
    
    -- Pattern buttons
    for i, pattern in ipairs(UI_CONFIG.PATTERNS) do
        local row = math.floor((i - 1) / 3)
        local col = (i - 1) % 3
        
        local patternBtn = createModernButton(
            controlFrame,
            pattern.icon .. " " .. pattern.name,
            UDim2.new(0.31, 0, 0, 25),
            UDim2.new(col * 0.33 + 0.02, 0, 0, 70 + row * 30),
            pattern.color,
            function()
                commandEvent:FireServer("force_pattern", {pattern = pattern.name})
                clientState.selectedPattern = pattern.name
            end
        )
    end
    
    return controlFrame
end

--- Creates the performance monitoring panel
local function createPerformancePanel(parent)
    local perfFrame = Instance.new("Frame")
    perfFrame.Name = "PerformancePanel"
    perfFrame.Size = UDim2.new(1, -20, 0.6, 0) -- Responsive height
    perfFrame.Position = UDim2.new(0, 10, 0.75, 5) -- Responsive positioning
    perfFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    perfFrame.BorderSizePixel = 0
    perfFrame.Parent = parent
    
    local perfCorner = Instance.new("UICorner")
    perfCorner.CornerRadius = UDim.new(0, 8)
    perfCorner.Parent = perfFrame
    
    -- Performance title
    local perfTitle = Instance.new("TextLabel")
    perfTitle.Size = UDim2.new(1, -10, 0, 20)
    perfTitle.Position = UDim2.new(0, 5, 0, 5)
    perfTitle.BackgroundTransparency = 1
    perfTitle.Text = "📊 PERFORMANCE MONITOR"
    perfTitle.TextColor3 = Color3.new(0.8, 0.9, 1)
    perfTitle.TextScaled = true
    perfTitle.Font = Enum.Font.SourceSansBold
    perfTitle.Parent = perfFrame
    
    -- Performance metrics
    local metricsFrame = Instance.new("Frame")
    metricsFrame.Size = UDim2.new(1, -10, 1, -30)
    metricsFrame.Position = UDim2.new(0, 5, 0, 25)
    metricsFrame.BackgroundTransparency = 1
    metricsFrame.Parent = perfFrame
    
    -- FPS Display
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(0.5, -5, 0.33, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.new(0.7, 1, 0.7)
    fpsLabel.TextScaled = true
    fpsLabel.Font = Enum.Font.SourceSans
    fpsLabel.Parent = metricsFrame
    
    -- Memory Display
    local memoryLabel = Instance.new("TextLabel")
    memoryLabel.Name = "MemoryLabel"
    memoryLabel.Size = UDim2.new(0.5, -5, 0.33, 0)
    memoryLabel.Position = UDim2.new(0.5, 5, 0, 0)
    memoryLabel.BackgroundTransparency = 1
    memoryLabel.Text = "Memory: -- MB"
    memoryLabel.TextColor3 = Color3.new(0.7, 0.9, 1)
    memoryLabel.TextScaled = true
    memoryLabel.Font = Enum.Font.SourceSans
    memoryLabel.Parent = metricsFrame
    
    -- Quality Display
    local qualityLabel = Instance.new("TextLabel")
    qualityLabel.Name = "QualityLabel"
    qualityLabel.Size = UDim2.new(0.5, -5, 0.33, 0)
    qualityLabel.Position = UDim2.new(0, 0, 0.33, 0)
    qualityLabel.BackgroundTransparency = 1
    qualityLabel.Text = "Quality: Level --"
    qualityLabel.TextColor3 = Color3.new(1, 0.9, 0.7)
    qualityLabel.TextScaled = true
    qualityLabel.Font = Enum.Font.SourceSans
    qualityLabel.Parent = metricsFrame
    
    -- Network Display
    local networkLabel = Instance.new("TextLabel")
    networkLabel.Name = "NetworkLabel"
    networkLabel.Size = UDim2.new(0.5, -5, 0.33, 0)
    networkLabel.Position = UDim2.new(0.5, 5, 0.33, 0)
    networkLabel.BackgroundTransparency = 1
    networkLabel.Text = "Network: -- ms"
    networkLabel.TextColor3 = Color3.new(1, 0.8, 0.9)
    networkLabel.TextScaled = true
    networkLabel.Font = Enum.Font.SourceSans
    networkLabel.Parent = metricsFrame
    
    -- Status Display
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0.34, 0)
    statusLabel.Position = UDim2.new(0, 0, 0.66, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Status: Monitoring..."
    statusLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = metricsFrame
    
    return perfFrame
end

--[[
    MAIN UI CREATION
--]]

--- Creates the main dashboard
local function createMainDashboard()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExplosionDashboard"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main container with responsive sizing
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.25, 0, 0.5, 0) -- Responsive: 25% width, 50% height
    mainFrame.Position = UDim2.new(0.02, 0, 0.02, 0) -- Responsive positioning
    mainFrame.BackgroundColor3 = UI_CONFIG.COLORS.BACKGROUND
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = UI_CONFIG.COLORS.PRIMARY
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    -- Fix header corners
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 10)
    headerFix.Position = UDim2.new(0, 0, 1, -10)
    headerFix.BackgroundColor3 = UI_CONFIG.COLORS.PRIMARY
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -20, 1, 0)
    headerTitle.Position = UDim2.new(0, 10, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "🎆 EXPLOSION SYSTEM DASHBOARD"
    headerTitle.TextColor3 = Color3.new(1, 1, 1)
    headerTitle.TextScaled = true
    headerTitle.Font = Enum.Font.SourceSansBold
    headerTitle.Parent = header
    
    -- Content area
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -30)
    contentFrame.Position = UDim2.new(0, 0, 0, 30)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 180)
    contentFrame.Parent = mainFrame
    
    -- Create components
    local controlPanel = createControlPanel(contentFrame)
    local performancePanel = createPerformancePanel(contentFrame)
    
    return screenGui, {
        controlPanel = controlPanel,
        performancePanel = performancePanel,
        mainFrame = mainFrame
    }
end

--[[
    VISUAL EFFECTS
--]]

--- Enhanced screen flash with pattern-based colors
local function createEnhancedFlash(pattern, intensity)
    local patternData = nil
    for _, p in ipairs(UI_CONFIG.PATTERNS) do
        if p.name == pattern then
            patternData = p
            break
        end
    end
    
    local color = patternData and patternData.color or UI_CONFIG.COLORS.PRIMARY
    intensity = MathUtils.clamp(intensity or 0.3, 0, 0.5)
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PatternFlash"
    screenGui.Parent = playerGui
    
    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.BackgroundColor3 = color
    flashFrame.BackgroundTransparency = 1 - intensity
    flashFrame.BorderSizePixel = 0
    flashFrame.Parent = screenGui
    
    local fadeTween = TweenService:Create(flashFrame,
        TweenInfo.new(UI_CONFIG.ANIMATIONS.FLASH_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

--- Advanced camera shake with pattern-specific behavior
local function createAdvancedShake(pattern, intensity)
    if clientState.isShaking then return end
    
    clientState.isShaking = true
    local duration = 0.6
    local shakeIntensity = MathUtils.clamp(intensity or 5, 1, 12)
    
    -- Pattern-specific shake behavior
    if pattern == "Chain" then
        duration = 1.2
        shakeIntensity = shakeIntensity * 0.7
    elseif pattern == "Wave" then
        duration = 0.8
    elseif pattern == "Grid" then
        shakeIntensity = shakeIntensity * 1.3
        duration = 0.4
    end
    
    local camera = workspace.CurrentCamera
    local originalCFrame = camera.CFrame
    local startTime = tick()
    
    local shakeConnection
    shakeConnection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local progress = elapsed / duration
        
        if progress >= 1 then
            camera.CFrame = originalCFrame
            shakeConnection:Disconnect()
            clientState.isShaking = false
            return
        end
        
        local currentIntensity = shakeIntensity * MathUtils.smoothStep(1, 0, progress)
        local frequency = 20 + progress * 10
        
        local shakeX = math.sin(elapsed * frequency) * currentIntensity * (math.random() - 0.5)
        local shakeY = math.cos(elapsed * frequency * 1.3) * currentIntensity * (math.random() - 0.5)
        local shakeZ = math.sin(elapsed * frequency * 0.7) * currentIntensity * (math.random() - 0.5)
        
        camera.CFrame = originalCFrame * CFrame.new(shakeX, shakeY, shakeZ)
    end)
end

--[[
    DATA MANAGEMENT
--]]





--[[
    EVENT HANDLERS
--]]

-- Create main dashboard
local dashboard = {}
dashboard.gui, dashboard.components = createMainDashboard()

-- Handle explosion events
explosionEvent.OnClientEvent:Connect(function(networkData)
    -- Validate network data
    if not networkData or type(networkData) ~= "table" then
        warn("Invalid network data received")
        return
    end
    
    -- Decompress network data if compressed
    local data
    -- Check if data looks like compressed data (contains LZ77 tokens)
    local isActuallyCompressed = networkData.compressed or (type(networkData.data) == "string" and string.find(networkData.data, "<[0-9]+,[0-9]+,"))
    
    if isActuallyCompressed then
        local success, decompressedJson = pcall(function()
            return NetworkOptimizer:decompressData(networkData.data, true)
        end)
        
        if not success then
            warn("Failed to decompress network data")
            return
        end
        
        local success2, decodedData = pcall(function()
            return HttpService:JSONDecode(decompressedJson)
        end)
        
        if not success2 then
            warn("Failed to decode JSON data")
            return
        end
        
        data = decodedData
        
        -- Log compression stats
        local compressionRatio = networkData.originalSize > 0 and (#networkData.data / networkData.originalSize) or 1
        print(string.format("📦 Network: Received compressed data (%.1f%% of original size)", compressionRatio * 100))
    else
        -- For uncompressed data, still need to JSON decode
        local success, decodedData = pcall(function()
            return HttpService:JSONDecode(networkData.data)
        end)
        
        if not success then
            warn("Failed to decode uncompressed JSON data")
            return
        end
        
        data = decodedData
    end
    
    -- Validate decompressed data
    if not data or type(data) ~= "table" then
        warn("Invalid explosion data received")
        return
    end
    
    clientState.explosionCount = clientState.explosionCount + 1
    clientState.lastExplosionTime = tick()
    
    if data.pattern then
        createEnhancedFlash(data.pattern, 0.2)
        createAdvancedShake(data.pattern, 6)
        
        -- Advanced UI animations for explosion feedback
        if dashboard and dashboard.components.mainFrame then
            -- Pulse animation for main frame
            UIAnimationSystem:pulse(dashboard.components.mainFrame, 1.05, 0.3)
            
            -- Shake animation for intense patterns
            if data.pattern == "AdvancedChain" or data.pattern == "AudioReactive" then
                UIAnimationSystem:shake(dashboard.components.mainFrame, 3, 0.4)
            end
            
            -- Color flash based on pattern
            local flashColor = Color3.fromRGB(255, 100, 0) -- Default orange
            if data.pattern == "Plasma" then
                flashColor = Color3.fromRGB(255, 0, 255) -- Magenta
            elseif data.pattern == "FireTornado" then
                flashColor = Color3.fromRGB(255, 50, 0) -- Red-orange
            elseif data.pattern == "Fractal" then
                flashColor = Color3.fromRGB(0, 255, 255) -- Cyan
            elseif data.pattern == "AudioReactive" then
                flashColor = Color3.fromRGB(0, 255, 0) -- Green
            end
            
            -- Brief color flash
            local originalColor = dashboard.components.mainFrame.BackgroundColor3
            local flashTween = UIAnimationSystem:morphColor(dashboard.components.mainFrame, flashColor, 0.1, "QuadOut")
            flashTween.Completed:Connect(function()
                UIAnimationSystem:morphColor(dashboard.components.mainFrame, originalColor, 0.3, "QuadOut")
            end)
            
            -- Add dynamic lighting effects for visual feedback
            local lightingData = {
                position = data.position or Vector3.new(0, 10, 0),
                intensity = math.min((data.particleCount or 50) / 25, 8),
                color = flashColor,
                radius = math.min((data.particleCount or 50) / 5, 40),
                pattern = data.pattern,
                duration = 1.5
            }
            
            DynamicLightingSystem:createExplosionLighting(lightingData)
        end
        
        -- Show pattern notification
        local patternData = nil
        for _, p in ipairs(UI_CONFIG.PATTERNS) do
            if p.name == data.pattern then
                patternData = p
                break
            end
        end
        
        if patternData then
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title = patternData.icon .. " " .. data.pattern .. " Pattern",
                    Text = string.format("%d explosions created", data.explosionCount or 1),
                    Duration = 3
                })
            end)
        end
    end
end)

-- Handle UI updates
uiUpdateEvent.OnClientEvent:Connect(function(data)
    -- UI updates no longer needed since statistics were removed
end)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        -- Manual explosion
        local position = Vector3.new(
            math.random(-75, 75),
            math.random(20, 60),
            math.random(-75, 75)
        )
        commandEvent:FireServer("manual_explosion", {
            position = position,
            intensity = MathUtils.map(math.random(), 0, 1, 0.8, 1.5)
        })
        
    elseif input.KeyCode == Enum.KeyCode.T then
        -- Toggle system
        commandEvent:FireServer("toggle_system")
        
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Toggle dashboard visibility with smooth animations
        clientState.controlsVisible = not clientState.controlsVisible
        
        if clientState.controlsVisible then
            dashboard.components.mainFrame.Visible = true
            -- Slide in from top with bounce
            UIAnimationSystem:slideIn(dashboard.components.mainFrame, "up", 0.8, "BackOut")
            UIAnimationSystem:fadeIn(dashboard.components.mainFrame, 0.5, "QuadOut")
        else
            -- Slide out to top with fade
            UIAnimationSystem:fadeOut(dashboard.components.mainFrame, 0.3, "QuadOut")
            UIAnimationSystem:animate(dashboard.components.mainFrame, {
                Position = UDim2.new(0.02, 0, -1, 0)
            }, 0.5, "BackIn", function()
                dashboard.components.mainFrame.Visible = false
                -- Reset position for next show
                dashboard.components.mainFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
            end)
        end
    end
end)

-- Initialize UI Animation System
UIAnimationSystem:initialize()

-- Initialize Network Optimizer
NetworkOptimizer:initialize()

-- Initialize Dynamic Lighting System
DynamicLightingSystem:initialize()

-- Initialize Performance Profiler
local profiler = PerformanceProfiler
profiler:initialize()

-- Performance monitoring update loop
local function updatePerformanceDisplay()
    if dashboard and dashboard.components.performancePanel then
        local perfPanel = dashboard.components.performancePanel
        local report = profiler:getPerformanceReport()
        
        -- Update FPS
        local metricsFrame = perfPanel:FindFirstChild("Frame") -- metricsFrame
        if metricsFrame then
            local fpsLabel = metricsFrame:FindFirstChild("FPSLabel")
            if fpsLabel then
                local fpsColor = Color3.new(0.7, 1, 0.7)
                if report.frameRate.current < 30 then
                    fpsColor = Color3.new(1, 0.7, 0.7) -- Red for low FPS
                elseif report.frameRate.current < 45 then
                    fpsColor = Color3.new(1, 1, 0.7) -- Yellow for medium FPS
                end
                fpsLabel.Text = "FPS: " .. report.frameRate.current
                fpsLabel.TextColor3 = fpsColor
            end
        end
        
            -- Update Memory
            local memoryLabel = metricsFrame:FindFirstChild("MemoryLabel")
            if memoryLabel then
                local memColor = Color3.new(0.7, 0.9, 1)
                if report.memory.current > 150 then
                    memColor = Color3.new(1, 0.7, 0.7) -- Red for high memory
                elseif report.memory.current > 100 then
                    memColor = Color3.new(1, 1, 0.7) -- Yellow for medium memory
                end
                memoryLabel.Text = "Memory: " .. report.memory.current .. " MB"
                memoryLabel.TextColor3 = memColor
            end
            
            -- Update Quality
            local qualityLabel = metricsFrame:FindFirstChild("QualityLabel")
            if qualityLabel then
                qualityLabel.Text = "Quality: Level " .. report.quality.level
                local qualityColors = {
                    Color3.new(1, 0.5, 0.5), -- Level 1 - Red
                    Color3.new(1, 0.8, 0.5), -- Level 2 - Orange
                    Color3.new(1, 1, 0.7),   -- Level 3 - Yellow
                    Color3.new(0.8, 1, 0.7), -- Level 4 - Light Green
                    Color3.new(0.7, 1, 0.7)  -- Level 5 - Green
                }
                qualityLabel.TextColor3 = qualityColors[report.quality.level] or Color3.new(1, 0.9, 0.7)
            end
            
            -- Update Status
            local statusLabel = metricsFrame:FindFirstChild("StatusLabel")
            if statusLabel then
                local status = "Optimal"
                local statusColor = Color3.new(0.7, 1, 0.7)
                
                if report.frameRate.current < 25 then
                    status = "Performance Issues Detected"
                    statusColor = Color3.new(1, 0.7, 0.7)
                elseif report.memory.current > 150 then
                    status = "High Memory Usage"
                    statusColor = Color3.new(1, 1, 0.7)
                elseif not report.quality.autoAdjust then
                    status = "Manual Quality Mode"
                    statusColor = Color3.new(0.8, 0.8, 1)
                end
                
                statusLabel.Text = "Status: " .. status
                statusLabel.TextColor3 = statusColor
            end
    end
end

-- Start performance monitoring
spawn(function()
    while true do
        updatePerformanceDisplay()
        wait(0.5) -- Update every 500ms
    end
end)

-- Initial welcome with animation
wait(2)
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🎆 Advanced Explosion System",
        Text = "Dashboard loaded! Press H to toggle, E for manual explosions",
        Duration = 5
    })
end)

-- Animate dashboard entrance
if dashboard and dashboard.components.mainFrame then
    UIAnimationSystem:slideIn(dashboard.components.mainFrame, "up", 1.2, "BackOut")
end

print("✨ Advanced Explosion UI Loaded with Sophisticated Animations!")
print("🎮 Controls: E=Manual, T=Toggle, H=Hide Dashboard")
print("🎨 UI Animation System: Advanced easing functions and smooth transitions enabled")
print("📊 Real-time dashboard with performance monitoring active")
print("🌐 Network Optimizer: Data compression and optimization enabled")
print("💡 Dynamic Lighting System: Real-time lighting effects enabled")