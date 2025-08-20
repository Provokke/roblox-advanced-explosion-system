--[[
    ADVANCED PARTICLE EXPLOSION SYSTEM
    Portfolio Showcase - Professional Roblox Development
    
    Features Demonstrated:
    - Modular Architecture with Shared Libraries
    - Advanced Mathematical Applications
    - Sophisticated Visual Effects
    - Performance Optimization Techniques
    - Event-Driven Programming
    - Resource Management Systems
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Import shared modules
local MathUtils = require(ReplicatedStorage.Shared.MathUtils)
local ExplosionEffects = require(ReplicatedStorage.Shared.ExplosionEffects)
local AdvancedParticleSystem = require(ReplicatedStorage.Shared.AdvancedParticleSystem)
local AudioVisualizationSystem = require(ReplicatedStorage.Shared.AudioVisualizationSystem)
local ProceduralPatternGenerator = require(ReplicatedStorage.Shared.ProceduralPatternGenerator)
local NetworkOptimizer = require(ReplicatedStorage.Shared.NetworkOptimizer)
local DynamicLightingSystem = require(ReplicatedStorage.Shared.DynamicLightingSystem)
local PerformanceProfiler = require(ReplicatedStorage.Shared.PerformanceProfiler)

-- Create RemoteEvents for client communication
print("[DEBUG] ParticleExplosionSystem.server.lua is loading...")
local explosionEvent = Instance.new("RemoteEvent")
explosionEvent.Name = "ExplosionEvent"
explosionEvent.Parent = ReplicatedStorage

local uiUpdateEvent = Instance.new("RemoteEvent")
uiUpdateEvent.Name = "UIUpdateEvent"
uiUpdateEvent.Parent = ReplicatedStorage

local commandEvent = Instance.new("RemoteEvent")
commandEvent.Name = "CommandEvent"
commandEvent.Parent = ReplicatedStorage
print("[DEBUG] All RemoteEvents created and parented to ReplicatedStorage")

-- Advanced Configuration System
local CONFIG = {
    EXPLOSION_PATTERNS = {
        {name = "Random", weight = 25, func = "createRandomExplosion"},
        {name = "Chain", weight = 15, func = "createChainExplosion"},
        {name = "Spiral", weight = 15, func = "createSpiralExplosion"},
        {name = "Grid", weight = 10, func = "createGridExplosion"},
        {name = "Wave", weight = 10, func = "createWaveExplosion"},
        {name = "Plasma", weight = 10, func = "createPlasmaExplosion"},
         {name = "FireTornado", weight = 8, func = "createFireTornadoExplosion"},
         {name = "AdvancedChain", weight = 7, func = "createAdvancedChainExplosion"},
         {name = "AudioReactive", weight = 5, func = "createAudioReactiveExplosion"},
         {name = "Fractal", weight = 6, func = "createFractalExplosion"},
         {name = "LSystem", weight = 4, func = "createLSystemExplosion"},
         {name = "Cellular", weight = 5, func = "createCellularExplosion"},
         {name = "Voronoi", weight = 3, func = "createVoronoiExplosion"}
    },
    
    TIMING = {
        BASE_INTERVAL = 4,
        RANDOM_VARIANCE = 3,
        CHAIN_DELAY = 0.3,
        WAVE_DELAY = 0.1
    },
    
    BOUNDARIES = {
        MIN_X = -150, MAX_X = 150,
        MIN_Y = 10, MAX_Y = 80,
        MIN_Z = -150, MAX_Z = 150
    },
    
    PERFORMANCE = {
        TARGET_FPS = 30,
        MAX_CONCURRENT_EFFECTS = 5,
        ADAPTIVE_QUALITY = true
    }
}

-- System State
local systemState = {
    explosionCount = 0,
    activeEffects = 0,
    averageFPS = 60,
    lastFrameTime = tick(),
    frameCount = 0,
    isRunning = false, -- Start disabled, require button press to enable
    currentQuality = 1.0
}

-- Statistics tracking
local statistics = {
    totalExplosions = 0,
    patternCounts = {},
    playerTriggers = {},
    performanceHistory = {}
}

-- Initialize Advanced Particle System
local advancedParticles = AdvancedParticleSystem.new({
    maxParticles = 5000,
    enableGPUInstancing = true,
    enableLOD = true
})

-- Add global forces for realistic physics
advancedParticles:addGlobalForce(Vector3.new(0, -20, 0)) -- Gravity
advancedParticles:addGlobalForce(Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))) -- Wind

-- Initialize Audio Visualization System
local audioSystem = AudioVisualizationSystem
-- audioSystem:initialize() -- Disabled to prevent rainbow floor effect

-- Clean up any existing audio visualization effects
audioSystem:cleanup()

-- Initialize Network Optimizer
local networkOptimizer = NetworkOptimizer
networkOptimizer:initialize()

-- Initialize Dynamic Lighting System
local lightingSystem = DynamicLightingSystem
lightingSystem:initialize()

-- Note: Lighting.Technology should be set in default.project.json instead of script
-- to avoid capability errors

-- Initialize Performance Profiler
local profiler = PerformanceProfiler
profiler:initialize()

-- Override quality change handler for adaptive performance
function profiler:onQualityChanged(newQuality)
    -- Adjust particle counts based on performance
    if newQuality <= 2 then
        CONFIG.MAX_PARTICLES_PER_EXPLOSION = 25
        CONFIG.MAX_ACTIVE_EFFECTS = 3
    elseif newQuality <= 3 then
        CONFIG.MAX_PARTICLES_PER_EXPLOSION = 50
        CONFIG.MAX_ACTIVE_EFFECTS = 5
    else
        CONFIG.MAX_PARTICLES_PER_EXPLOSION = 100
        CONFIG.MAX_ACTIVE_EFFECTS = 10
    end
    
    -- print("[ParticleExplosionSystem] Performance quality adjusted to level", newQuality)
    -- print("[ParticleExplosionSystem] Max particles:", CONFIG.MAX_PARTICLES_PER_EXPLOSION)
end

--[[
    EXPLOSION PATTERN FUNCTIONS
--]]

--- Creates a random single explosion
local function createRandomExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    local intensity = MathUtils.map(math.random(), 0, 1, 0.6, 1.4) * systemState.currentQuality
    ExplosionEffects.createExplosion(position, intensity, workspace)
    
    return 1 -- Number of explosions created
end

--- Creates a chain of explosions
local function createChainExplosion()
    local chainLength = math.random(3, 6)
    local positions = {}
    
    -- Generate chain positions
    local startPos = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X + 20, CONFIG.BOUNDARIES.MAX_X - 20),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z + 20, CONFIG.BOUNDARIES.MAX_Z - 20)
    )
    
    table.insert(positions, startPos)
    
    for i = 2, chainLength do
        local direction = MathUtils.randomPointOnSphere()
        local distance = math.random(15, 30)
        local nextPos = positions[i-1] + direction * distance
        
        -- Keep within boundaries
        nextPos = Vector3.new(
            MathUtils.clamp(nextPos.X, CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
            MathUtils.clamp(nextPos.Y, CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
            MathUtils.clamp(nextPos.Z, CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
        )
        
        table.insert(positions, nextPos)
    end
    
    ExplosionEffects.createChainExplosion(
        positions, 
        CONFIG.TIMING.CHAIN_DELAY, 
        0.8 * systemState.currentQuality, 
        workspace
    )
    
    return chainLength
end

--- Creates a spiral explosion pattern
local function createSpiralExplosion()
    local center = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X + 30, CONFIG.BOUNDARIES.MAX_X - 30),
        math.random(CONFIG.BOUNDARIES.MIN_Y + 10, CONFIG.BOUNDARIES.MAX_Y - 10),
        math.random(CONFIG.BOUNDARIES.MIN_Z + 30, CONFIG.BOUNDARIES.MAX_Z - 30)
    )
    
    local radius = math.random(20, 40)
    local count = math.random(6, 10)
    local height = math.random(15, 25)
    
    ExplosionEffects.createSpiralExplosion(center, radius, count, height, workspace)
    
    return count
end

--- Creates a grid explosion pattern
local function createGridExplosion()
    local gridSize = math.random(2, 4)
    local spacing = math.random(20, 35)
    
    local centerX = math.random(CONFIG.BOUNDARIES.MIN_X + spacing, CONFIG.BOUNDARIES.MAX_X - spacing)
    local centerZ = math.random(CONFIG.BOUNDARIES.MIN_Z + spacing, CONFIG.BOUNDARIES.MAX_Z - spacing)
    local y = math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y)
    
    local positions = {}
    
    for x = 1, gridSize do
        for z = 1, gridSize do
            local pos = Vector3.new(
                centerX + (x - gridSize/2) * spacing,
                y + math.random(-5, 5),
                centerZ + (z - gridSize/2) * spacing
            )
            table.insert(positions, pos)
        end
    end
    
    ExplosionEffects.createChainExplosion(
        positions, 
        0.15, 
        0.6 * systemState.currentQuality, 
        workspace
    )
    
    return gridSize * gridSize
end

--- Creates a wave explosion pattern
local function createWaveExplosion()
    local waveCount = math.random(8, 12)
    local radius = math.random(30, 50)
    
    local center = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X + radius, CONFIG.BOUNDARIES.MAX_X - radius),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z + radius, CONFIG.BOUNDARIES.MAX_Z - radius)
    )
    
    local positions = {}
    
    for i = 1, waveCount do
        local angle = (i / waveCount) * MathUtils.TAU
        local waveRadius = radius * (0.5 + 0.5 * math.sin(angle * 3))
        
        local pos = Vector3.new(
            center.X + math.cos(angle) * waveRadius,
            center.Y + math.random(-5, 5),
            center.Z + math.sin(angle) * waveRadius
        )
        
        table.insert(positions, pos)
    end
    
    ExplosionEffects.createChainExplosion(
        positions, 
        CONFIG.TIMING.WAVE_DELAY, 
        0.7 * systemState.currentQuality, 
        workspace
    )
    
    return waveCount
end

--- Creates an advanced plasma explosion with GPU particles
local function createPlasmaExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    -- Create main explosion effect
    ExplosionEffects.createExplosion(position, 1.2 * systemState.currentQuality, workspace)
    
    -- Add advanced particle emitter
    local emitter = advancedParticles:createEmitter(position, {
        rate = 200,
        lifetime = 3,
        spread = 60,
        speed = {min = 15, max = 40},
        size = {min = 0.8, max = 2.5},
        shaderEffect = "PLASMA",
        physicsModel = "ELECTROMAGNETIC"
    })
    
    -- Create secondary energy rings
    spawn(function()
        for i = 1, 3 do
            wait(0.2 * i)
            local ringEmitter = advancedParticles:createEmitter(position, {
                rate = 100,
                lifetime = 2,
                spread = 15,
                speed = {min = 25, max = 35},
                size = {min = 0.5, max = 1.2},
                shaderEffect = "ENERGY",
                physicsModel = "FLUID_DYNAMICS"
            })
            
            -- Deactivate emitter after short burst
            wait(0.5)
            ringEmitter.active = false
        end
    end)
    
    -- Deactivate main emitter after burst
    spawn(function()
        wait(1)
        emitter.active = false
    end)
    
    return 1
end

--- Creates a fire tornado explosion
local function createFireTornadoExplosion()
    local basePosition = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        CONFIG.BOUNDARIES.MIN_Y,
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    -- Create base explosion
    ExplosionEffects.createExplosion(basePosition, 0.8 * systemState.currentQuality, workspace)
    
    -- Create tornado effect with multiple emitters
    local tornadoHeight = 40
    local emitters = {}
    
    for height = 0, tornadoHeight, 5 do
        local radius = 3 + (height / tornadoHeight) * 8
        local position = basePosition + Vector3.new(0, height, 0)
        
        local emitter = advancedParticles:createEmitter(position, {
            rate = 80 - (height / tornadoHeight) * 40,
            lifetime = 4,
            spread = 30,
            speed = {min = 10, max = 25},
            size = {min = 0.6, max = 1.8},
            shaderEffect = "FIRE",
            physicsModel = "FLUID_DYNAMICS"
        })
        
        table.insert(emitters, emitter)
    end
    
    -- Animate tornado rotation
    spawn(function()
        local startTime = tick()
        while tick() - startTime < 6 do
            local elapsed = tick() - startTime
            local rotationSpeed = 2 + elapsed * 0.5
            
            for i, emitter in ipairs(emitters) do
                local height = (i - 1) * 5
                local radius = 3 + (height / tornadoHeight) * 8
                local angle = elapsed * rotationSpeed + (height * 0.1)
                
                emitter.position = basePosition + Vector3.new(
                    math.cos(angle) * radius,
                    height,
                    math.sin(angle) * radius
                )
            end
            
            wait(0.1)
        end
        
        -- Deactivate all emitters
        for _, emitter in ipairs(emitters) do
            emitter.active = false
        end
    end)
    
    return 1
end

--- Creates a chain reaction with advanced particles
local function createAdvancedChainExplosion()
    local chainLength = math.random(4, 8)
    local positions = {}
    
    -- Generate chain positions
    local startPos = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X + 30, CONFIG.BOUNDARIES.MAX_X - 30),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z + 30, CONFIG.BOUNDARIES.MAX_Z - 30)
    )
    
    table.insert(positions, startPos)
    
    for i = 2, chainLength do
        local direction = MathUtils.randomPointOnSphere()
        local distance = math.random(20, 35)
        local nextPos = positions[i-1] + direction * distance
        
        -- Clamp to boundaries
        nextPos = Vector3.new(
            MathUtils.clamp(nextPos.X, CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
            MathUtils.clamp(nextPos.Y, CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
            MathUtils.clamp(nextPos.Z, CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
        )
        
        table.insert(positions, nextPos)
    end
    
    -- Create chain with advanced particles
    spawn(function()
        for i, position in ipairs(positions) do
            -- Create main explosion
            ExplosionEffects.createExplosion(position, 0.9 * systemState.currentQuality, workspace)
            
            -- Add particle emitter
            local emitter = advancedParticles:createEmitter(position, {
                rate = 150,
                lifetime = 2.5,
                spread = 45,
                speed = {min = 12, max = 28},
                size = {min = 0.7, max = 1.5},
                shaderEffect = i % 2 == 0 and "FIRE" or "ENERGY",
                physicsModel = "NEWTONIAN"
            })
            
            -- Deactivate after burst
            spawn(function()
                wait(0.8)
                emitter.active = false
            end)
            
            wait(CONFIG.TIMING.CHAIN_DELAY)
        end
    end)
    
    return chainLength
end

--- Creates an audio-reactive explosion pattern
local function createAudioReactiveExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    print("🎵 Creating Audio-Reactive Explosion at", position)
    
    -- Get current audio state
    local audioState = audioSystem:getAudioState()
    
    -- Create base explosion with audio-influenced parameters
    local intensity = 1 + audioState.overallEnergy * 2
    local particleCount = math.floor(50 + audioState.bassLevel * 100)
    
    -- Create main explosion
    ExplosionEffects.createExplosion(position, intensity * systemState.currentQuality, workspace)
    
    -- Create advanced particles with audio-reactive properties
    local emitter = advancedParticles:createEmitter(position, {
        rate = particleCount,
        lifetime = 2 + audioState.trebleLevel * 3,
        spread = 60,
        speed = {min = 10 + audioState.midLevel * 20, max = 30 + audioState.midLevel * 40},
        size = {min = 0.5 * (1 + audioState.bassLevel), max = 1.5 * (1 + audioState.bassLevel)},
        shaderEffect = audioState.beatDetected and "PLASMA" or "FIRE",
        physicsModel = "ELECTROMAGNETIC"
    })
    
    -- Create audio visualization particles
    audioSystem:createAudioExplosion(position)
    
    -- Beat-synchronized chain reactions
    if audioState.beatDetected then
        spawn(function()
            wait(0.2)
            for i = 1, 3 do
                local chainPos = position + MathUtils.randomPointOnSphere() * (20 + i * 10)
                -- Clamp to boundaries
                chainPos = Vector3.new(
                    MathUtils.clamp(chainPos.X, CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
                    MathUtils.clamp(chainPos.Y, CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
                    MathUtils.clamp(chainPos.Z, CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
                )
                ExplosionEffects.createExplosion(chainPos, 0.6 * systemState.currentQuality, workspace)
                wait(0.1)
            end
        end)
    end
    
    -- Deactivate emitter after burst
    spawn(function()
        wait(1.5)
        emitter.active = false
    end)
    
    return 1
end

-- Fractal Explosion Pattern
local function createFractalExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    print("🌀 Creating Fractal Explosion at", position)
    
    -- Generate fractal pattern
    local fractalTypes = {"mandelbrot", "julia"}
    local fractalType = fractalTypes[math.random(#fractalTypes)]
    local pattern = ProceduralPatternGenerator:generateFractalPattern(fractalType, 32, 32)
    
    -- Create particles based on fractal pattern
    local particleCount = 0
    for x = 1, pattern.width do
        for y = 1, pattern.height do
            local intensity = pattern.data[x][y]
            if intensity > 0.1 then -- Only create particles for significant values
                local offset = Vector3.new(
                    (x - pattern.width/2) * 2,
                    (y - pattern.height/2) * 2,
                    math.sin(intensity * math.pi) * 5
                )
                
                local particlePos = position + offset
                local emitter = advancedParticles:createEmitter(particlePos, {
                    rate = math.floor(intensity * 20),
                    lifetime = 1 + intensity * 2,
                    spread = 30,
                    speed = {min = 5, max = 15},
                    size = {min = 0.3, max = 0.8},
                    shaderEffect = "PLASMA",
                    physicsModel = "GRAVITATIONAL"
                })
                
                particleCount = particleCount + 1
                
                -- Deactivate emitter after burst
                spawn(function()
                    wait(0.5 + intensity)
                    emitter.active = false
                end)
            end
        end
    end
    
    -- Create main explosion
    ExplosionEffects.createExplosion(position, 8 * systemState.currentQuality, workspace)
    
    return particleCount
end

-- L-System Explosion Pattern
local function createLSystemExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    print("🌿 Creating L-System Explosion at", position)
    
    -- Generate L-System pattern
    local lsystemTypes = {"dragon", "plant", "koch"}
    local lsystemType = lsystemTypes[math.random(#lsystemTypes)]
    local pattern = ProceduralPatternGenerator:generateLSystemPattern(lsystemType, 6, 3)
    
    if pattern then
        -- Create particles along L-System path
        for i, pos in ipairs(pattern.positions) do
            if i % 3 == 0 then -- Sample every 3rd position to avoid too many particles
                local worldPos = position + pos
                
                -- Clamp to boundaries
                worldPos = Vector3.new(
                    MathUtils.clamp(worldPos.X, CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
                    MathUtils.clamp(worldPos.Y, CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
                    MathUtils.clamp(worldPos.Z, CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
                )
                
                local emitter = advancedParticles:createEmitter(worldPos, {
                    rate = 15,
                    lifetime = 2,
                    spread = 20,
                    speed = {min = 3, max = 8},
                    size = {min = 0.2, max = 0.5},
                    shaderEffect = "FIRE",
                    physicsModel = "EXPLOSION"
                })
                
                -- Deactivate emitter after burst
                spawn(function()
                    wait(1)
                    emitter.active = false
                end)
            end
        end
    end
    
    -- Create main explosion
    ExplosionEffects.createExplosion(position, 6 * systemState.currentQuality, workspace)
    
    return pattern and #pattern.positions or 1
end

-- Cellular Automata Explosion Pattern
local function createCellularExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    print("🔬 Creating Cellular Automata Explosion at", position)
    
    -- Generate cellular automata pattern
    local caRules = {"gameOfLife", "highLife", "maze"}
    local caRule = caRules[math.random(#caRules)]
    local pattern = ProceduralPatternGenerator:generateCellularAutomataPattern(16, 16, caRule, 5, 0.4)
    
    -- Create particles based on final cellular automata state
    local particleCount = 0
    for x = 1, pattern.width do
        for y = 1, pattern.height do
            if pattern.finalState[x][y] == 1 then
                local offset = Vector3.new(
                    (x - pattern.width/2) * 3,
                    (y - pattern.height/2) * 3,
                    math.random(-2, 2)
                )
                
                local particlePos = position + offset
                local emitter = advancedParticles:createEmitter(particlePos, {
                    rate = 25,
                    lifetime = 1.5,
                    spread = 45,
                    speed = {min = 8, max = 18},
                    size = {min = 0.4, max = 0.9},
                    shaderEffect = "ELECTROMAGNETIC",
                    physicsModel = "EXPLOSION"
                })
                
                particleCount = particleCount + 1
                
                -- Deactivate emitter after burst
                spawn(function()
                    wait(0.8)
                    emitter.active = false
                end)
            end
        end
    end
    
    -- Create main explosion
    ExplosionEffects.createExplosion(position, 7 * systemState.currentQuality, workspace)
    
    return particleCount
end

-- Voronoi Explosion Pattern
local function createVoronoiExplosion()
    local position = Vector3.new(
        math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
        math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
        math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
    )
    
    print("🔷 Creating Voronoi Explosion at", position)
    
    -- Generate Voronoi pattern
    local pattern = ProceduralPatternGenerator:generateVoronoiPattern(20, 20, 6)
    
    -- Create particles at Voronoi seed points
    for _, seed in ipairs(pattern.seeds) do
        local offset = Vector3.new(
            (seed.x - pattern.width/2) * 2,
            (seed.y - pattern.height/2) * 2,
            0
        )
        
        local seedPos = position + offset
        local emitter = advancedParticles:createEmitter(seedPos, {
            rate = 40,
            lifetime = 2.5,
            spread = 60,
            speed = {min = 12, max = 25},
            size = {min = 0.6, max = 1.2},
            shaderEffect = "PLASMA",
            physicsModel = "GRAVITATIONAL"
        })
        
        -- Create explosion at seed point
        ExplosionEffects.createExplosion(seedPos, 4 * systemState.currentQuality, workspace)
        
        -- Deactivate emitter after burst
        spawn(function()
            wait(1.2)
            emitter.active = false
        end)
    end
    
    return #pattern.seeds
end

--[[
    SYSTEM MANAGEMENT
--]]

--- Updates performance metrics and adaptive quality
local function updatePerformanceMetrics()
    systemState.frameCount = systemState.frameCount + 1
    local currentTime = tick()
    local deltaTime = currentTime - systemState.lastFrameTime
    
    if deltaTime >= 1 then -- Update every second
        systemState.averageFPS = systemState.frameCount / deltaTime
        systemState.frameCount = 0
        systemState.lastFrameTime = currentTime
        
        -- Adaptive quality adjustment
        if CONFIG.PERFORMANCE.ADAPTIVE_QUALITY then
            if systemState.averageFPS < CONFIG.PERFORMANCE.TARGET_FPS then
                systemState.currentQuality = math.max(0.3, systemState.currentQuality * 0.9)
            elseif systemState.averageFPS > CONFIG.PERFORMANCE.TARGET_FPS + 10 then
                systemState.currentQuality = math.min(1.0, systemState.currentQuality * 1.05)
            end
        end
        
        -- Store performance history
        table.insert(statistics.performanceHistory, {
            timestamp = currentTime,
            fps = systemState.averageFPS,
            quality = systemState.currentQuality,
            activeEffects = systemState.activeEffects
        })
        
        -- Keep only last 60 seconds of history
        while #statistics.performanceHistory > 60 do
            table.remove(statistics.performanceHistory, 1)
        end
        
        -- UI updates no longer needed since statistics were removed
    end
end

--- Executes a random explosion pattern
local function executeRandomPattern()
    if systemState.activeEffects >= CONFIG.PERFORMANCE.MAX_CONCURRENT_EFFECTS then
        return -- Skip if too many effects are active
    end
    
    -- Select pattern using weighted random
    local selectedPatternObj = MathUtils.weightedRandom(CONFIG.EXPLOSION_PATTERNS)
    local selectedPattern = selectedPatternObj and selectedPatternObj.name or "Random"
    
    -- Update statistics
    statistics.patternCounts[selectedPattern] = (statistics.patternCounts[selectedPattern] or 0) + 1
    
    -- Execute pattern
    local explosionCount = 0
    if selectedPattern == "Random" then
        explosionCount = createRandomExplosion()
    elseif selectedPattern == "Chain" then
        explosionCount = createChainExplosion()
    elseif selectedPattern == "Spiral" then
        explosionCount = createSpiralExplosion()
    elseif selectedPattern == "Grid" then
        explosionCount = createGridExplosion()
    elseif selectedPattern == "Wave" then
        explosionCount = createWaveExplosion()
    elseif selectedPattern == "Plasma" then
        explosionCount = createPlasmaExplosion()
    elseif selectedPattern == "FireTornado" then
        explosionCount = createFireTornadoExplosion()
    elseif selectedPattern == "AdvancedChain" then
        explosionCount = createAdvancedChainExplosion()
    elseif selectedPattern == "AudioReactive" then
        explosionCount = createAudioReactiveExplosion()
    elseif selectedPattern == "Fractal" then
        explosionCount = createFractalExplosion()
    elseif selectedPattern == "LSystem" then
        explosionCount = createLSystemExplosion()
    elseif selectedPattern == "Cellular" then
        explosionCount = createCellularExplosion()
    elseif selectedPattern == "Voronoi" then
        explosionCount = createVoronoiExplosion()
    end
    
    systemState.activeEffects = systemState.activeEffects + 1
    statistics.totalExplosions = statistics.totalExplosions + explosionCount
    
    -- Prepare explosion data with network optimization
    local explosionData = {
        pattern = selectedPattern,
        explosionCount = explosionCount,
        totalExplosions = statistics.totalExplosions,
        quality = systemState.currentQuality,
        timestamp = tick(),
        networkStats = networkOptimizer:getNetworkStats()
    }
    
    -- Use NetworkOptimizer for efficient data transmission
    local success, encodedData = pcall(function()
        return HttpService:JSONEncode(explosionData)
    end)
    
    if not success or not encodedData then
        warn("[ParticleExplosionSystem] Failed to encode explosion data")
        return
    end
    
    local compressedData, wasCompressed = networkOptimizer:compressData(encodedData)
    
    -- Validate compressed data before sending
    if not compressedData then
        warn("[ParticleExplosionSystem] Failed to compress explosion data")
        return
    end
    
    -- Fire to all clients with optimized data
    explosionEvent:FireAllClients({
        data = compressedData,
        compressed = wasCompressed,
        originalSize = #encodedData
    })
    
    -- Add dynamic lighting effects for the explosion
    local lightingData = {
        position = Vector3.new(
            math.random(CONFIG.BOUNDARIES.MIN_X, CONFIG.BOUNDARIES.MAX_X),
            math.random(CONFIG.BOUNDARIES.MIN_Y, CONFIG.BOUNDARIES.MAX_Y),
            math.random(CONFIG.BOUNDARIES.MIN_Z, CONFIG.BOUNDARIES.MAX_Z)
        ),
        intensity = math.min(explosionCount * 2, 10), -- Scale intensity based on explosion count
        color = Color3.new(1, 0.8, 0.4), -- Default warm explosion color
        radius = math.min(explosionCount * 5, 50), -- Scale radius based on explosion count
        pattern = selectedPattern
    }
    
    lightingSystem:createExplosionLighting(lightingData)
    
    -- Decrease active effects after some time
    spawn(function()
        wait(5) -- Average effect duration
        systemState.activeEffects = math.max(0, systemState.activeEffects - 1)
    end)
    
    print(string.format("🎆 %s explosion pattern executed (%d explosions)", 
        selectedPattern.name or selectedPattern, explosionCount))
end

--- Main explosion system loop
local function runExplosionSystem()
    print("🚀 Advanced Particle Explosion System Started!")
    print("📊 Features: Modular Design, Adaptive Quality, Pattern Variety")
    print("✨ GPU Instancing, Advanced Physics, Custom Shaders")
    
    while systemState.isRunning do
        local interval = CONFIG.TIMING.BASE_INTERVAL + math.random() * CONFIG.TIMING.RANDOM_VARIANCE
        wait(interval)
        
        executeRandomPattern()
    end
end

--[[
    EVENT HANDLERS
--]]

-- Handle client commands
-- Security: Rate limiting and input validation
local playerCooldowns = {}
local COOLDOWN_TIME = 1 -- seconds
local MAX_DISTANCE = 200
local VALID_PATTERNS = {"Random", "Chain", "Spiral", "Grid", "Wave", "Plasma", "FireTornado", "AdvancedChain", "AudioReactive", "Fractal", "LSystem", "Cellular", "Voronoi"}

commandEvent.OnServerEvent:Connect(function(player, command, data)
    -- Rate limiting
    local currentTime = tick()
    if playerCooldowns[player.UserId] and currentTime - playerCooldowns[player.UserId] < COOLDOWN_TIME then
        return -- Ignore rapid requests
    end
    playerCooldowns[player.UserId] = currentTime
    
    -- Input validation
    if type(command) ~= "string" then return end
    
    statistics.playerTriggers[player.Name] = (statistics.playerTriggers[player.Name] or 0) + 1
    
    if command == "manual_explosion" and data and data.position then
        -- Validate position is Vector3 and within bounds
        if typeof(data.position) ~= "Vector3" then return end
        if data.position.Magnitude > MAX_DISTANCE then return end
        
        -- Clamp intensity to prevent abuse
        local intensity = math.clamp(tonumber(data.intensity) or 1, 0.1, 2.0)
        
        print(string.format("[DEBUG] Creating manual explosion by %s at %s with intensity %f", player.Name, tostring(data.position), intensity))
        
        local success, err = pcall(function()
            ExplosionEffects.createExplosion(
                data.position, 
                intensity * systemState.currentQuality, 
                workspace
            )
        end)
        
        if not success then
            warn(string.format("[ERROR] Failed to create explosion: %s", tostring(err)))
        else
            print(string.format("[SUCCESS] Manual explosion created by %s at %s", player.Name, tostring(data.position)))
        end
        
    elseif command == "toggle_system" then
        systemState.isRunning = not systemState.isRunning
        print(string.format("System %s by %s", systemState.isRunning and "started" or "stopped", player.Name))
        
        if systemState.isRunning then
            spawn(runExplosionSystem)
        end
        
    elseif command == "force_pattern" and data and data.pattern then
        -- Validate pattern is in allowed list
        if type(data.pattern) ~= "string" then return end
        local isValidPattern = false
        for _, validPattern in ipairs(VALID_PATTERNS) do
            if data.pattern == validPattern then
                isValidPattern = true
                break
            end
        end
        if not isValidPattern then return end
        
        if data.pattern == "Random" then createRandomExplosion()
        elseif data.pattern == "Chain" then createChainExplosion()
        elseif data.pattern == "Spiral" then createSpiralExplosion()
        elseif data.pattern == "Grid" then createGridExplosion()
        elseif data.pattern == "Wave" then createWaveExplosion()
        elseif data.pattern == "Plasma" then createPlasmaExplosion()
        elseif data.pattern == "FireTornado" then createFireTornadoExplosion()
        elseif data.pattern == "AdvancedChain" then createAdvancedChainExplosion()
        elseif data.pattern == "AudioReactive" then createAudioReactiveExplosion()
        elseif data.pattern == "Fractal" then createFractalExplosion()
        elseif data.pattern == "LSystem" then createLSystemExplosion()
        elseif data.pattern == "Cellular" then createCellularExplosion()
        elseif data.pattern == "Voronoi" then createVoronoiExplosion()
        end
        
        print(string.format("%s pattern forced by %s", data.pattern, player.Name))
    end
end)

-- Connection tracking for cleanup
local connections = {}

-- Performance monitoring
connections.performanceMonitor = RunService.Heartbeat:Connect(updatePerformanceMetrics)

-- Advanced particle system update loop
connections.particleUpdate = RunService.Heartbeat:Connect(function(deltaTime)
    advancedParticles:update(deltaTime)
    -- audioSystem:update(deltaTime) -- Disabled to prevent rainbow floor effect
end)

-- Cleanup function to prevent memory leaks
local function cleanup()
    for name, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
            connections[name] = nil
        end
    end
    
    -- Clean up particle systems
    if advancedParticles and advancedParticles.cleanup then
        advancedParticles:cleanup()
    end
    
    -- Clean up audio system
    if audioSystem and audioSystem.cleanup then
        audioSystem:cleanup()
    end
    
    -- Clean up explosion effects
    if ExplosionEffects and ExplosionEffects.cleanup then
        ExplosionEffects.cleanup()
    end
end

-- Handle game shutdown
game:BindToClose(cleanup)

-- Initialize pattern statistics
for _, pattern in ipairs(CONFIG.EXPLOSION_PATTERNS) do
    statistics.patternCounts[pattern.name] = 0
end

-- System will start when toggle button is pressed
-- spawn(runExplosionSystem) -- Removed auto-start

print("✨ Advanced Explosion System Loaded Successfully!")
print("🎯 Patterns: Random, Chain, Spiral, Grid, Wave, Plasma, FireTornado, AdvancedChain, AudioReactive, Fractal, LSystem, Cellular, Voronoi")
print("⚡ Adaptive quality system enabled")
print("🚀 GPU Instancing & Advanced Physics enabled")
print("🧮 Procedural Pattern Generation with L-Systems, Fractals, Cellular Automata, and Voronoi Diagrams")
print("🌐 Network Optimization: Data compression and prediction algorithms enabled")
print("💡 Dynamic Lighting System: Volumetric effects and HDR rendering enabled")
print("🔧 Client commands: manual_explosion, toggle_system, force_pattern")