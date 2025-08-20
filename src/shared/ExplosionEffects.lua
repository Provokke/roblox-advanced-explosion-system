--[[
    EXPLOSION EFFECTS MODULE
    Portfolio Showcase - Advanced Visual Effects System
    
    Features Demonstrated:
    - Complex Particle Systems
    - Advanced Animation Techniques
    - Performance Optimization
    - Modular Architecture
    - Mathematical Applications
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local MathUtils = require(script.Parent.MathUtils)

local ExplosionEffects = {}

-- Track active connections for cleanup
local activeConnections = {}

-- Configuration
local CONFIG = {
    PARTICLE_COUNT = 50,
    SHOCKWAVE_RINGS = 3,
    DEBRIS_COUNT = 0,
    SPARK_COUNT = 25,
    EFFECT_DURATION = 3,
    MAX_DISTANCE = 100
}

-- Object pools for performance
local particlePool = {}
local debrisPool = {}
local sparkPool = {}

--[[
    OBJECT POOLING SYSTEM
--]]

--- Creates a new particle object
--- @return BasePart: New particle part
local function createParticle()
    local particle = Instance.new("Part")
    particle.Name = "ExplosionParticle"
    particle.Size = Vector3.new(0.5, 0.5, 0.5)
    particle.Shape = Enum.PartType.Ball
    particle.Material = Enum.Material.Neon
    particle.CanCollide = false
    particle.Anchored = true
    particle.TopSurface = Enum.SurfaceType.Smooth
    particle.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Add glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Range = 10
    pointLight.Parent = particle
    
    return particle
end

--- Gets a particle from the pool or creates a new one
--- @return BasePart: Particle object
local function getParticle()
    if #particlePool > 0 then
        return table.remove(particlePool)
    else
        return createParticle()
    end
end

--- Returns a particle to the pool
--- @param particle BasePart: Particle to return
local function returnParticle(particle)
    particle.Parent = nil
    particle.CFrame = CFrame.new()
    particle.Velocity = Vector3.new()
    table.insert(particlePool, particle)
end

--- Creates a debris object
--- @return BasePart: New debris part
local function createDebris()
    local debris = Instance.new("Part")
    debris.Name = "ExplosionDebris"
    debris.Material = Enum.Material.Concrete
    debris.CanCollide = false
    debris.Shape = Enum.PartType.Block
    
    -- Random size for variety
    local size = math.random(50, 200) / 100
    debris.Size = Vector3.new(size, size, size)
    
    -- Add some rotation
    local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
    bodyAngularVelocity.AngularVelocity = Vector3.new(
        math.random(-50, 50),
        math.random(-50, 50),
        math.random(-50, 50)
    )
    bodyAngularVelocity.Parent = debris
    
    return debris
end

--- Gets debris from pool or creates new
--- @return BasePart: Debris object
local function getDebris()
    if #debrisPool > 0 then
        return table.remove(debrisPool)
    else
        return createDebris()
    end
end

--- Returns debris to pool
--- @param debris BasePart: Debris to return
local function returnDebris(debris)
    debris.Parent = nil
    debris.CFrame = CFrame.new()
    debris.Velocity = Vector3.new()
    table.insert(debrisPool, debris)
end

--[[
    EFFECT CREATION FUNCTIONS
--]]

--- Creates a shockwave ring effect
--- @param position Vector3: Center position
--- @param radius number: Ring radius
--- @param delay number: Animation delay
--- @param parent Instance: Parent for the ring
local function createShockwaveRing(position, radius, delay, parent)
    local ring = Instance.new("Part")
    ring.Name = "ShockwaveRing"
    ring.Size = Vector3.new(0.2, 0.2, 0.2)
    ring.Material = Enum.Material.ForceField
    ring.BrickColor = BrickColor.new("Bright blue")
    ring.CanCollide = false
    ring.Anchored = true
    ring.CFrame = CFrame.new(position)
    ring.Parent = parent
    
    -- Create ring mesh
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://3270017"
    mesh.Scale = Vector3.new(0, 0, 0)
    mesh.Parent = ring
    
    -- Animation
    wait(delay)
    
    local expandInfo = TweenInfo.new(
        1.5,
        Enum.EasingStyle.Quart,
        Enum.EasingDirection.Out
    )
    
    local fadeInfo = TweenInfo.new(
        1.5,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local success, err = pcall(function()
        local expandTween = TweenService:Create(mesh, expandInfo, {
            Scale = Vector3.new(radius, radius, radius)
        })
        
        local fadeTween = TweenService:Create(ring, fadeInfo, {
            Transparency = 1
        })
        
        expandTween:Play()
        fadeTween:Play()
        
        fadeTween.Completed:Connect(function()
            ring:Destroy()
        end)
    end)
    
    if not success then
        warn("ExplosionEffects: Shockwave animation failed:", err)
        -- Fallback cleanup
        if ring and ring.Parent then
            ring:Destroy()
        end
        return
    end
end

--- Creates sparks effect
--- @param position Vector3: Origin position
--- @param parent Instance: Parent for sparks
local function createSparks(position, parent)
    for i = 1, CONFIG.SPARK_COUNT do
        local spark = Instance.new("Part")
        spark.Name = "Spark"
        spark.Size = Vector3.new(0.1, 0.1, 2)
        spark.Material = Enum.Material.Neon
        spark.BrickColor = BrickColor.new("Bright yellow")
        spark.CanCollide = false
        spark.Anchored = true
        spark.Parent = parent
        
        -- Random direction
        local direction = MathUtils.randomPointOnSphere()
        local distance = math.random(5, 15)
        local endPosition = position + direction * distance
        
        -- Random rotation for spark orientation
        local lookDirection = (endPosition - position).Unit
        spark.CFrame = CFrame.new(position, position + lookDirection)
        
        -- Animate spark
        local sparkInfo = TweenInfo.new(
            math.random(50, 150) / 100,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local sparkTween = TweenService:Create(spark, sparkInfo, {
            CFrame = CFrame.new(endPosition, endPosition + lookDirection),
            Transparency = 1,
            Size = Vector3.new(0.05, 0.05, 0.5)
        })
        
        sparkTween:Play()
        sparkTween.Completed:Connect(function()
            spark:Destroy()
        end)
    end
end

--- Creates screen shake effect
--- @param intensity number: Shake intensity
--- @param duration number: Shake duration
local function createScreenShake(intensity, duration)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local originalCFrame = camera.CFrame
    local shakeStart = tick()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - shakeStart
        if elapsed >= duration then
            camera.CFrame = originalCFrame
            connection:Disconnect()
            -- Remove from tracking
            for i, conn in ipairs(activeConnections) do
                if conn == connection then
                    table.remove(activeConnections, i)
                    break
                end
            end
            return
        end
        
        local progress = elapsed / duration
        local currentIntensity = intensity * (1 - progress)
        
        local shakeX = (math.random() - 0.5) * currentIntensity
        local shakeY = (math.random() - 0.5) * currentIntensity
        local shakeZ = (math.random() - 0.5) * currentIntensity
        
        camera.CFrame = originalCFrame * CFrame.new(shakeX, shakeY, shakeZ)
    end)
    
    -- Track connection for cleanup
    table.insert(activeConnections, connection)
end

--[[
    MAIN EXPLOSION FUNCTION
--]]

--- Creates a complete explosion effect
--- @param position Vector3: Explosion center
--- @param intensity number: Effect intensity (0.1 to 2.0)
--- @param parent Instance: Parent for effect objects
function ExplosionEffects.createExplosion(position, intensity, parent)
    -- Input validation
    if typeof(position) ~= "Vector3" then
        warn("ExplosionEffects: Invalid position provided, expected Vector3")
        return
    end
    
    intensity = MathUtils.clamp(tonumber(intensity) or 1, 0.1, 5.0)
    parent = parent or workspace
    
    if not parent or not parent.Parent then
        warn("ExplosionEffects: Invalid parent provided")
        return
    end
    
    -- Calculate scaled values
    local particleCount = math.floor(CONFIG.PARTICLE_COUNT * intensity)
    local debrisCount = math.floor(CONFIG.DEBRIS_COUNT * intensity)
    local maxDistance = CONFIG.MAX_DISTANCE * intensity
    
    -- Create main explosion flash
    local flash = Instance.new("Part")
    flash.Name = "ExplosionFlash"
    flash.Size = Vector3.new(1, 1, 1)
    flash.Material = Enum.Material.Neon
    flash.BrickColor = BrickColor.new("Bright orange")
    flash.CanCollide = false
    flash.Anchored = true
    flash.Shape = Enum.PartType.Ball
    flash.CFrame = CFrame.new(position)
    flash.Parent = parent
    
    -- Flash animation
    local flashInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local flashTween = TweenService:Create(flash, flashInfo, {
        Size = Vector3.new(20 * intensity, 20 * intensity, 20 * intensity),
        Transparency = 1
    })
    
    flashTween:Play()
    flashTween.Completed:Connect(function()
        flash:Destroy()
    end)
    
    -- Create particles
    for i = 1, particleCount do
        local particle = getParticle()
        particle.Parent = parent
        particle.CFrame = CFrame.new(position)
        
        -- Random color based on temperature
        local hue = math.random(0, 60) -- Orange to red range
        particle.Color = MathUtils.hsvToRgb(hue, 1, 1)
        
        -- Random direction and speed
        local direction = MathUtils.randomPointOnSphere()
        local speed = math.random(10, 30) * intensity
        local distance = math.random(5, maxDistance)
        
        local endPosition = position + direction * distance
        
        -- Particle animation
        local particleInfo = TweenInfo.new(
            math.random(100, 300) / 100,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        
        local particleTween = TweenService:Create(particle, particleInfo, {
            CFrame = CFrame.new(endPosition),
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1
        })
        
        particleTween:Play()
        particleTween.Completed:Connect(function()
            returnParticle(particle)
        end)
    end
    
    -- Create debris
    for i = 1, debrisCount do
        local debris = getDebris()
        debris.Parent = parent
        debris.CFrame = CFrame.new(position)
        
        -- Random material and color
        local materials = {
            Enum.Material.Concrete,
            Enum.Material.Brick,
            Enum.Material.Rock,
            Enum.Material.Metal
        }
        debris.Material = materials[math.random(#materials)]
        
        -- Physics-based movement
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        
        local direction = MathUtils.randomPointOnSphere()
        local speed = math.random(20, 50) * intensity
        bodyVelocity.Velocity = direction * speed
        bodyVelocity.Parent = debris
        
        -- Clean up debris after some time
        Debris:AddItem(debris, CONFIG.EFFECT_DURATION + math.random())
    end
    
    -- Create shockwave rings
    for i = 1, CONFIG.SHOCKWAVE_RINGS do
        spawn(function()
            createShockwaveRing(
                position,
                (15 + i * 10) * intensity,
                (i - 1) * 0.2,
                parent
            )
        end)
    end
    
    -- Create sparks
    spawn(function()
        createSparks(position, parent)
    end)
    
    -- Screen shake for nearby players
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = MathUtils.distance(
                position,
                player.Character.HumanoidRootPart.Position
            )
            
            if distance <= maxDistance then
                local shakeIntensity = MathUtils.map(
                    distance,
                    0, maxDistance,
                    2 * intensity, 0
                )
                
                spawn(function()
                    createScreenShake(shakeIntensity, 0.5)
                end)
            end
        end
    end
    
    -- Sound effect (if SoundService is available)
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://3636730677" -- Explosion sound
        sound.Volume = MathUtils.clamp(intensity, 0.1, 1) * 0.1
        sound.Pitch = math.random(80, 120) / 100
        sound.Parent = parent
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

--- Creates a chain explosion effect
--- @param positions table: Array of Vector3 positions
--- @param delay number: Delay between explosions
--- @param intensity number: Base intensity
--- @param parent Instance: Parent for effects
function ExplosionEffects.createChainExplosion(positions, delay, intensity, parent)
    delay = delay or 0.3
    intensity = intensity or 1
    
    for i, position in ipairs(positions) do
        spawn(function()
            wait((i - 1) * delay)
            ExplosionEffects.createExplosion(position, intensity, parent)
        end)
    end
end

--- Creates a spiral explosion pattern
--- @param center Vector3: Center position
--- @param radius number: Spiral radius
--- @param count number: Number of explosions
--- @param height number: Spiral height
--- @param parent Instance: Parent for effects
function ExplosionEffects.createSpiralExplosion(center, radius, count, height, parent)
    radius = radius or 20
    count = count or 8
    height = height or 10
    
    local positions = {}
    
    for i = 1, count do
        local angle = (i / count) * MathUtils.TAU
        local spiralHeight = (i / count) * height
        
        local x = center.X + math.cos(angle) * radius
        local y = center.Y + spiralHeight
        local z = center.Z + math.sin(angle) * radius
        
        table.insert(positions, Vector3.new(x, y, z))
    end
    
    ExplosionEffects.createChainExplosion(positions, 0.2, 0.8, parent)
end

-- Cleanup function to prevent memory leaks
function ExplosionEffects.cleanup()
    -- Disconnect all tracked connections
    for _, connection in ipairs(activeConnections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    activeConnections = {}
    
    -- Clear pools
    particlePool = {}
    debrisPool = {}
    
    print("💥 Explosion Effects cleaned up")
end

return ExplosionEffects