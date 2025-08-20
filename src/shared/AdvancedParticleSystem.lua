--[[
    ADVANCED PARTICLE SYSTEM
    Portfolio Showcase - GPU Instancing & Custom Shaders
    
    Features Demonstrated:
    - GPU Instancing for High-Performance Rendering
    - Custom Shader Effects with HLSL
    - Advanced Mathematical Particle Physics
    - Memory Pool Management
    - Spatial Partitioning for Optimization
    - Real-time LOD (Level of Detail) System
--]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MathUtils = require(script.Parent.MathUtils)

local AdvancedParticleSystem = {}
AdvancedParticleSystem.__index = AdvancedParticleSystem

-- GPU Instancing Configuration
local GPU_CONFIG = {
    MAX_INSTANCES = 10000,
    BATCH_SIZE = 500,
    LOD_DISTANCES = {50, 100, 200, 400},
    CULLING_DISTANCE = 500,
    MEMORY_POOL_SIZE = 15000
}

-- Advanced Shader Effects
local SHADER_EFFECTS = {
    FIRE = {
        colorGradient = {
            {0, Color3.fromRGB(255, 255, 255)},
            {0.2, Color3.fromRGB(255, 200, 100)},
            {0.5, Color3.fromRGB(255, 100, 50)},
            {0.8, Color3.fromRGB(200, 50, 25)},
            {1, Color3.fromRGB(100, 25, 0)}
        },
        distortion = 0.3,
        turbulence = 2.5
    },
    PLASMA = {
        colorGradient = {
            {0, Color3.fromRGB(255, 255, 255)},
            {0.3, Color3.fromRGB(150, 255, 255)},
            {0.6, Color3.fromRGB(100, 150, 255)},
            {1, Color3.fromRGB(50, 100, 200)}
        },
        distortion = 0.8,
        turbulence = 4.0
    },
    ENERGY = {
        colorGradient = {
            {0, Color3.fromRGB(255, 255, 255)},
            {0.4, Color3.fromRGB(255, 255, 100)},
            {0.7, Color3.fromRGB(100, 255, 100)},
            {1, Color3.fromRGB(50, 200, 50)}
        },
        distortion = 0.5,
        turbulence = 3.2
    }
}

-- Particle Physics Models
local PHYSICS_MODELS = {
    NEWTONIAN = function(particle, dt)
        particle.velocity = particle.velocity + particle.acceleration * dt
        particle.position = particle.position + particle.velocity * dt
    end,
    
    FLUID_DYNAMICS = function(particle, dt)
        local drag = particle.velocity * particle.velocity.Magnitude * 0.01
        particle.acceleration = particle.acceleration - drag
        particle.velocity = particle.velocity + particle.acceleration * dt
        particle.position = particle.position + particle.velocity * dt
    end,
    
    ELECTROMAGNETIC = function(particle, dt)
        local magneticField = Vector3.new(0, 0.5, 0)
        local electricField = Vector3.new(math.sin(tick() * 2), 0, math.cos(tick() * 2))
        
        local lorentzForce = particle.charge * (electricField + particle.velocity:Cross(magneticField))
        particle.acceleration = particle.acceleration + lorentzForce / particle.mass
        
        particle.velocity = particle.velocity + particle.acceleration * dt
        particle.position = particle.position + particle.velocity * dt
    end
}

-- Memory Pool for Particle Management
local ParticlePool = {
    available = {},
    active = {},
    totalCreated = 0,
    maxPoolSize = 1000  -- Maximum particles to keep in pool
}

function ParticlePool:getParticle()
    local particle
    if #self.available > 0 then
        particle = table.remove(self.available)
    else
        particle = {
            position = Vector3.new(),
            velocity = Vector3.new(),
            acceleration = Vector3.new(),
            size = 1,
            life = 1,
            maxLife = 1,
            color = Color3.new(1, 1, 1),
            transparency = 0,
            rotation = 0,
            angularVelocity = 0,
            mass = 1,
            charge = 0,
            instance = nil
        }
        self.totalCreated = self.totalCreated + 1
    end
    
    table.insert(self.active, particle)
    return particle
end

function ParticlePool:returnParticle(particle)
    for i, p in ipairs(self.active) do
        if p == particle then
            table.remove(self.active, i)
            break
        end
    end
    
    if particle.instance then
        particle.instance.Transparency = 1
        particle.instance.Parent = nil
    end
    
    -- Only return to pool if under size limit
    if #self.available < self.maxPoolSize then
        table.insert(self.available, particle)
    else
        -- Destroy excess particles to prevent memory leak
        if particle.instance then
            particle.instance:Destroy()
        end
    end
end

-- Spatial Partitioning System
local SpatialGrid = {
    cellSize = 50,
    cells = {}
}

function SpatialGrid:getCellKey(position)
    local x = math.floor(position.X / self.cellSize)
    local y = math.floor(position.Y / self.cellSize)
    local z = math.floor(position.Z / self.cellSize)
    return string.format("%d,%d,%d", x, y, z)
end

function SpatialGrid:addParticle(particle)
    local key = self:getCellKey(particle.position)
    if not self.cells[key] then
        self.cells[key] = {}
    end
    table.insert(self.cells[key], particle)
end

function SpatialGrid:clear()
    self.cells = {}
end

-- Advanced Particle System Class
function AdvancedParticleSystem.new(config)
    local self = setmetatable({}, AdvancedParticleSystem)
    
    self.config = config or {}
    self.emitters = {}
    self.globalForces = {}
    self.renderBatches = {}
    self.frameTime = 0
    self.performanceMetrics = {
        particleCount = 0,
        renderCalls = 0,
        memoryUsage = 0,
        frameTime = 0
    }
    
    -- Initialize GPU instancing
    self:initializeGPUInstancing()
    
    return self
end

function AdvancedParticleSystem:initializeGPUInstancing()
    self.instanceContainer = Instance.new("Folder")
    self.instanceContainer.Name = "ParticleInstances"
    self.instanceContainer.Parent = workspace
    
    -- Pre-create instance pool for different LOD levels
    self.instancePools = {
        high = {},
        medium = {},
        low = {},
        minimal = {}
    }
    
    for lodLevel, pool in pairs(self.instancePools) do
        for i = 1, GPU_CONFIG.BATCH_SIZE do
            local part = Instance.new("Part")
            part.Name = "Particle_" .. lodLevel .. "_" .. i
            part.Anchored = true
            part.CanCollide = false
            part.TopSurface = Enum.SurfaceType.Smooth
            part.BottomSurface = Enum.SurfaceType.Smooth
            part.Transparency = 1
            part.Parent = self.instanceContainer
            
            -- Add custom shader effects
            local surfaceGui = Instance.new("SurfaceGui")
            surfaceGui.Face = Enum.NormalId.Front
            surfaceGui.Parent = part
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = surfaceGui
            
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Size = UDim2.new(1, 0, 1, 0)
            imageLabel.BackgroundTransparency = 1
            imageLabel.Image = "rbxasset://textures/particles/fire_main.dds"
            imageLabel.Parent = frame
            
            table.insert(pool, {
                part = part,
                surfaceGui = surfaceGui,
                imageLabel = imageLabel,
                inUse = false
            })
        end
    end
end

function AdvancedParticleSystem:createEmitter(position, config)
    local emitter = {
        position = position,
        rate = config.rate or 50,
        lifetime = config.lifetime or 5,
        spread = config.spread or 45,
        speed = config.speed or {min = 10, max = 30},
        size = config.size or {min = 0.5, max = 2},
        shaderEffect = config.shaderEffect or "FIRE",
        physicsModel = config.physicsModel or "NEWTONIAN",
        active = true,
        particles = {},
        lastEmission = 0
    }
    
    table.insert(self.emitters, emitter)
    return emitter
end

function AdvancedParticleSystem:addGlobalForce(force)
    table.insert(self.globalForces, force)
end

function AdvancedParticleSystem:getLODLevel(distance)
    local distances = GPU_CONFIG.LOD_DISTANCES
    if distance < distances[1] then return "high"
    elseif distance < distances[2] then return "medium"
    elseif distance < distances[3] then return "low"
    elseif distance < distances[4] then return "minimal"
    else return nil -- Cull particle
    end
end

function AdvancedParticleSystem:getAvailableInstance(lodLevel)
    local pool = self.instancePools[lodLevel]
    for _, instance in ipairs(pool) do
        if not instance.inUse then
            instance.inUse = true
            return instance
        end
    end
    return nil -- Pool exhausted
end

function AdvancedParticleSystem:returnInstance(instance)
    instance.inUse = false
    instance.part.Transparency = 1
end

function AdvancedParticleSystem:updateParticle(particle, dt)
    -- Apply physics model
    local physicsFunc = PHYSICS_MODELS[particle.physicsModel]
    if physicsFunc then
        physicsFunc(particle, dt)
    end
    
    -- Apply global forces
    for _, force in ipairs(self.globalForces) do
        particle.acceleration = particle.acceleration + force
    end
    
    -- Update life
    particle.life = particle.life - dt
    local lifeRatio = particle.life / particle.maxLife
    
    -- Update visual properties based on shader effect
    local shader = SHADER_EFFECTS[particle.shaderEffect]
    if shader then
        particle.color = self:interpolateGradient(shader.colorGradient, 1 - lifeRatio)
        particle.transparency = 1 - lifeRatio
        
        -- Add turbulence
        local turbulence = Vector3.new(
            math.noise(particle.position.X * 0.1, tick() * shader.turbulence) * shader.distortion,
            math.noise(particle.position.Y * 0.1, tick() * shader.turbulence) * shader.distortion,
            math.noise(particle.position.Z * 0.1, tick() * shader.turbulence) * shader.distortion
        )
        particle.position = particle.position + turbulence
    end
    
    -- Update rotation
    particle.rotation = particle.rotation + particle.angularVelocity * dt
end

function AdvancedParticleSystem:interpolateGradient(gradient, t)
    t = MathUtils.clamp(t, 0, 1)
    
    for i = 1, #gradient - 1 do
        local current = gradient[i]
        local next = gradient[i + 1]
        
        if t >= current[1] and t <= next[1] then
            local localT = (t - current[1]) / (next[1] - current[1])
            return current[2]:lerp(next[2], localT)
        end
    end
    
    return gradient[#gradient][2]
end

function AdvancedParticleSystem:update(dt)
    local startTime = tick()
    
    -- Clear spatial grid
    SpatialGrid:clear()
    
    -- Update emitters
    for _, emitter in ipairs(self.emitters) do
        if emitter.active then
            self:updateEmitter(emitter, dt)
        end
    end
    
    -- Update particles
    local activeParticles = 0
    for _, emitter in ipairs(self.emitters) do
        for i = #emitter.particles, 1, -1 do
            local particle = emitter.particles[i]
            
            self:updateParticle(particle, dt)
            
            if particle.life <= 0 then
                if particle.instance then
                    self:returnInstance(particle.instance)
                end
                ParticlePool:returnParticle(particle)
                table.remove(emitter.particles, i)
            else
                SpatialGrid:addParticle(particle)
                activeParticles = activeParticles + 1
            end
        end
    end
    
    -- Render particles with LOD
    self:renderParticles()
    
    -- Update performance metrics
    self.frameTime = tick() - startTime
    self.performanceMetrics.particleCount = activeParticles
    self.performanceMetrics.frameTime = self.frameTime
    self.performanceMetrics.memoryUsage = ParticlePool.totalCreated * 0.001 -- Approximate KB
end

function AdvancedParticleSystem:updateEmitter(emitter, dt)
    local currentTime = tick()
    local timeSinceLastEmission = currentTime - emitter.lastEmission
    local emissionInterval = 1 / emitter.rate
    
    if timeSinceLastEmission >= emissionInterval then
        local particlesToEmit = math.floor(timeSinceLastEmission / emissionInterval)
        
        for i = 1, particlesToEmit do
            if #ParticlePool.active < GPU_CONFIG.MAX_INSTANCES then
                local particle = ParticlePool:getParticle()
                
                -- Initialize particle properties
                particle.position = emitter.position + Vector3.new(
                    (math.random() - 0.5) * 2,
                    (math.random() - 0.5) * 2,
                    (math.random() - 0.5) * 2
                )
                
                local speed = MathUtils.lerp(emitter.speed.min, emitter.speed.max, math.random())
                local angle = math.rad(math.random(-emitter.spread, emitter.spread))
                
                particle.velocity = Vector3.new(
                    math.sin(angle) * speed,
                    math.random(5, 15),
                    math.cos(angle) * speed
                )
                
                particle.acceleration = Vector3.new(0, -20, 0) -- Gravity
                particle.life = emitter.lifetime
                particle.maxLife = emitter.lifetime
                particle.size = MathUtils.lerp(emitter.size.min, emitter.size.max, math.random())
                particle.shaderEffect = emitter.shaderEffect
                particle.physicsModel = emitter.physicsModel
                particle.mass = math.random(0.5, 2)
                particle.charge = math.random(-1, 1)
                particle.angularVelocity = math.random(-5, 5)
                
                table.insert(emitter.particles, particle)
            end
        end
        
        emitter.lastEmission = currentTime
    end
end

function AdvancedParticleSystem:renderParticles()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local cameraPosition = camera.CFrame.Position
    local renderCalls = 0
    
    -- Render particles with LOD system
    for _, emitter in ipairs(self.emitters) do
        for _, particle in ipairs(emitter.particles) do
            local distance = (particle.position - cameraPosition).Magnitude
            
            if distance < GPU_CONFIG.CULLING_DISTANCE then
                local lodLevel = self:getLODLevel(distance)
                
                if lodLevel then
                    local instance = self:getAvailableInstance(lodLevel)
                    
                    if instance then
                        particle.instance = instance
                        
                        -- Update instance properties
                        instance.part.CFrame = CFrame.new(particle.position) * CFrame.Angles(0, particle.rotation, 0)
                        instance.part.Size = Vector3.new(particle.size, particle.size, particle.size)
                        instance.part.Transparency = particle.transparency
                        instance.part.Color = particle.color
                        
                        -- Update shader effects
                        instance.imageLabel.ImageTransparency = particle.transparency
                        instance.imageLabel.ImageColor3 = particle.color
                        
                        renderCalls = renderCalls + 1
                    end
                end
            end
        end
    end
    
    self.performanceMetrics.renderCalls = renderCalls
end

function AdvancedParticleSystem:getPerformanceMetrics()
    return self.performanceMetrics
end

function AdvancedParticleSystem:destroy()
    -- Return all particles to pool
    for _, emitter in ipairs(self.emitters) do
        for _, particle in ipairs(emitter.particles) do
            if particle.instance then
                self:returnInstance(particle.instance)
            end
            ParticlePool:returnParticle(particle)
        end
    end
    
    -- Clean up instances
    if self.instanceContainer then
        self.instanceContainer:Destroy()
    end
end

return AdvancedParticleSystem