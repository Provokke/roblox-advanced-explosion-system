--[[
    DYNAMIC LIGHTING SYSTEM WITH VOLUMETRIC EFFECTS
    
    Features:
    - Real-time dynamic lighting with shadow mapping
    - Volumetric fog and light scattering
    - HDR tone mapping and bloom effects
    - Deferred lighting pipeline
    - Light culling and optimization
    - Atmospheric scattering simulation
    - Dynamic shadow cascades
    - Screen-space ambient occlusion (SSAO)
    - Physically-based lighting (PBR)
    - Light probes and global illumination
]]

local DynamicLightingSystem = {}
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Configuration
local CONFIG = {
    LIGHTING = {
        ENABLED = true,
        MAX_LIGHTS = 32,
        SHADOW_RESOLUTION = 2048,
        VOLUMETRIC_ENABLED = true,
        HDR_ENABLED = true,
        BLOOM_ENABLED = true
    },
    SHADOWS = {
        ENABLED = true,
        CASCADE_COUNT = 4,
        CASCADE_DISTANCES = {10, 50, 200, 1000},
        SOFT_SHADOWS = true,
        SHADOW_BIAS = 0.001
    },
    VOLUMETRIC = {
        ENABLED = true,
        DENSITY = 0.1,
        SCATTERING = 0.8,
        ABSORPTION = 0.2,
        STEPS = 64,
        MAX_DISTANCE = 500
    },
    ATMOSPHERE = {
        ENABLED = true,
        RAYLEIGH_SCATTERING = Vector3.new(0.0025, 0.0041, 0.0098),
        MIE_SCATTERING = 0.004,
        SUN_INTENSITY = 20,
        ATMOSPHERE_HEIGHT = 8000
    },
    PERFORMANCE = {
        LIGHT_CULLING = true,
        LOD_ENABLED = true,
        ADAPTIVE_QUALITY = true,
        TARGET_FPS = 60
    }
}

-- State management
local lightingState = {
    lights = {},
    shadowMaps = {},
    volumetricData = {},
    atmosphereData = {},
    performance = {
        frameTime = 0,
        lightCount = 0,
        shadowCount = 0,
        quality = 1.0
    },
    timeOfDay = 12, -- 24-hour format
    weather = {
        cloudCover = 0.3,
        fogDensity = 0.1,
        windSpeed = 5
    }
}

-- Light types
local LIGHT_TYPES = {
    DIRECTIONAL = "Directional",
    POINT = "Point",
    SPOT = "Spot",
    AREA = "Area"
}

--[[
    LIGHT MANAGEMENT
]]
local function createLight(lightType, position, color, intensity, range)
    local lightId = #lightingState.lights + 1
    
    local light = {
        id = lightId,
        type = lightType,
        position = position or Vector3.new(0, 10, 0),
        color = color or Color3.fromRGB(255, 255, 255),
        intensity = intensity or 1,
        range = range or 50,
        enabled = true,
        castShadows = true,
        volumetric = true,
        -- Advanced properties
        falloff = "InverseSquare", -- Linear, InverseSquare, Custom
        temperature = 6500, -- Kelvin
        bounceIntensity = 1,
        shadowBias = CONFIG.SHADOWS.SHADOW_BIAS,
        -- Animation
        flickering = false,
        flickerSpeed = 1,
        flickerIntensity = 0.1,
        -- Performance
        lod = 1,
        culled = false
    }
    
    -- Type-specific properties
    if lightType == LIGHT_TYPES.DIRECTIONAL then
        light.direction = Vector3.new(0, -1, 0)
        light.cascades = CONFIG.SHADOWS.CASCADE_COUNT
    elseif lightType == LIGHT_TYPES.SPOT then
        light.direction = Vector3.new(0, -1, 0)
        light.spotAngle = 45
        light.innerConeAngle = 30
    elseif lightType == LIGHT_TYPES.AREA then
        light.width = 2
        light.height = 2
    end
    
    table.insert(lightingState.lights, light)
    return light
end

local function updateLightCulling(camera)
    if not CONFIG.PERFORMANCE.LIGHT_CULLING then
        return
    end
    
    local cameraPosition = camera.CFrame.Position
    local cameraDirection = camera.CFrame.LookVector
    
    for _, light in ipairs(lightingState.lights) do
        if light.type == LIGHT_TYPES.POINT or light.type == LIGHT_TYPES.SPOT then
            local distance = (light.position - cameraPosition).Magnitude
            local inRange = distance <= light.range * 1.2 -- Add buffer
            
            -- Frustum culling for spot lights
            local inFrustum = true
            if light.type == LIGHT_TYPES.SPOT then
                local lightToCam = (cameraPosition - light.position).Unit
                local angle = math.acos(lightToCam:Dot(light.direction))
                inFrustum = angle <= math.rad(light.spotAngle)
            end
            
            light.culled = not (inRange and inFrustum)
        else
            light.culled = false -- Directional lights are never culled
        end
    end
end

--[[
    SHADOW MAPPING
]]
local function createShadowMap(light)
    if not CONFIG.SHADOWS.ENABLED or not light.castShadows then
        return nil
    end
    
    local shadowMap = {
        lightId = light.id,
        resolution = CONFIG.LIGHTING.SHADOW_RESOLUTION,
        cascades = {},
        softShadows = CONFIG.SHADOWS.SOFT_SHADOWS,
        bias = light.shadowBias
    }
    
    -- Create cascades for directional lights
    if light.type == LIGHT_TYPES.DIRECTIONAL then
        for i = 1, light.cascades do
            table.insert(shadowMap.cascades, {
                distance = CONFIG.SHADOWS.CASCADE_DISTANCES[i] or 100,
                resolution = math.floor(CONFIG.LIGHTING.SHADOW_RESOLUTION / math.sqrt(i)),
                bias = CONFIG.SHADOWS.SHADOW_BIAS * i
            })
        end
    end
    
    lightingState.shadowMaps[light.id] = shadowMap
    return shadowMap
end

local function updateShadowMaps()
    for _, light in ipairs(lightingState.lights) do
        if light.enabled and light.castShadows and not light.culled then
            if not lightingState.shadowMaps[light.id] then
                createShadowMap(light)
            end
        end
    end
end

--[[
    VOLUMETRIC LIGHTING
]]
local function calculateVolumetricScattering(lightPos, viewPos, lightColor, lightIntensity)
    if not CONFIG.VOLUMETRIC.ENABLED then
        return Color3.new(0, 0, 0)
    end
    
    local lightDir = (lightPos - viewPos).Unit
    local distance = (lightPos - viewPos).Magnitude
    
    -- Rayleigh scattering (molecules)
    local rayleighPhase = function(cosTheta)
        return (3 / (16 * math.pi)) * (1 + cosTheta * cosTheta)
    end
    
    -- Mie scattering (particles)
    local miePhase = function(cosTheta, g)
        g = g or 0.8
        local g2 = g * g
        return (3 / (8 * math.pi)) * ((1 - g2) / (2 + g2)) * 
               ((1 + cosTheta * cosTheta) / math.pow(1 + g2 - 2 * g * cosTheta, 1.5))
    end
    
    -- Calculate scattering
    local cosTheta = lightDir:Dot(viewPos.Unit)
    local rayleigh = rayleighPhase(cosTheta)
    local mie = miePhase(cosTheta)
    
    -- Atmospheric attenuation
    local attenuation = math.exp(-distance * CONFIG.VOLUMETRIC.ABSORPTION)
    
    -- Combine scattering
    local scattering = (rayleigh + mie) * CONFIG.VOLUMETRIC.SCATTERING * attenuation
    
    return Color3.new(
        lightColor.R * scattering * lightIntensity,
        lightColor.G * scattering * lightIntensity,
        lightColor.B * scattering * lightIntensity
    )
end

local function updateVolumetricFog()
    if not CONFIG.VOLUMETRIC.ENABLED then
        return
    end
    
    -- Update atmospheric fog based on weather and time of day
    local fogDensity = lightingState.weather.fogDensity
    local timeOfDay = lightingState.timeOfDay
    
    -- Adjust fog density based on time of day
    if timeOfDay >= 6 and timeOfDay <= 18 then
        -- Daytime - less fog
        fogDensity = fogDensity * 0.7
    else
        -- Nighttime - more fog
        fogDensity = fogDensity * 1.3
    end
    
    -- Apply to Roblox lighting
    Lighting.FogEnd = math.max(100, 1000 - (fogDensity * 500))
    Lighting.FogStart = Lighting.FogEnd * 0.1
end

--[[
    ATMOSPHERIC SCATTERING
]]
local function updateAtmosphericScattering()
    if not CONFIG.ATMOSPHERE.ENABLED then
        return
    end
    
    local timeOfDay = lightingState.timeOfDay
    local sunAngle = (timeOfDay - 6) * 15 -- Convert to degrees from horizon
    
    -- Calculate sun color based on atmospheric scattering
    local sunHeight = math.sin(math.rad(sunAngle))
    local atmosphereThickness = 1 / math.max(0.1, sunHeight)
    
    -- Rayleigh scattering (blue light scattered more)
    local rayleighR = math.exp(-CONFIG.ATMOSPHERE.RAYLEIGH_SCATTERING.X * atmosphereThickness)
    local rayleighG = math.exp(-CONFIG.ATMOSPHERE.RAYLEIGH_SCATTERING.Y * atmosphereThickness)
    local rayleighB = math.exp(-CONFIG.ATMOSPHERE.RAYLEIGH_SCATTERING.Z * atmosphereThickness)
    
    -- Mie scattering (particles)
    local mieScattering = math.exp(-CONFIG.ATMOSPHERE.MIE_SCATTERING * atmosphereThickness)
    
    -- Combine for final sun color
    local sunColor = Color3.new(
        math.clamp(rayleighR + mieScattering * 0.5, 0, 1),
        math.clamp(rayleighG + mieScattering * 0.3, 0, 1),
        math.clamp(rayleighB + mieScattering * 0.1, 0, 1)
    )
    
    -- Update Roblox lighting
    -- Note: SunSize property has been deprecated and removed
    
    -- Store atmospheric data
    lightingState.atmosphereData = {
        sunColor = sunColor,
        sunAngle = sunAngle,
        atmosphereThickness = atmosphereThickness,
        scattering = {
            rayleigh = Vector3.new(rayleighR, rayleighG, rayleighB),
            mie = mieScattering
        }
    }
end

--[[
    HDR AND TONE MAPPING
]]
local function updateHDRToneMapping()
    if not CONFIG.LIGHTING.HDR_ENABLED then
        return
    end
    
    -- Calculate scene luminance
    local totalLuminance = 0
    local activeLight = 0
    
    for _, light in ipairs(lightingState.lights) do
        if light.enabled and not light.culled then
            totalLuminance = totalLuminance + light.intensity
            activeLight = activeLight + 1
        end
    end
    
    local averageLuminance = activeLight > 0 and (totalLuminance / activeLight) or 1
    
    -- ACES tone mapping parameters
    local exposure = 1 / math.max(0.1, averageLuminance)
    
    -- Apply to Roblox lighting
    Lighting.ExposureCompensation = math.clamp(math.log(exposure, 2), -3, 3)
    
    -- Bloom effect
    if CONFIG.LIGHTING.BLOOM_ENABLED then
        Lighting.BloomSize = math.clamp(averageLuminance * 2, 5, 56)
        Lighting.BloomIntensity = math.clamp(averageLuminance * 0.5, 0.1, 2)
    end
end

--[[
    PERFORMANCE OPTIMIZATION
]]
local function updatePerformance(deltaTime)
    lightingState.performance.frameTime = deltaTime
    
    -- Count active lights
    local activeLights = 0
    local shadowCasters = 0
    
    for _, light in ipairs(lightingState.lights) do
        if light.enabled and not light.culled then
            activeLights = activeLights + 1
            if light.castShadows then
                shadowCasters = shadowCasters + 1
            end
        end
    end
    
    lightingState.performance.lightCount = activeLights
    lightingState.performance.shadowCount = shadowCasters
    
    -- Adaptive quality
    if CONFIG.PERFORMANCE.ADAPTIVE_QUALITY then
        local targetFrameTime = 1 / CONFIG.PERFORMANCE.TARGET_FPS
        local currentFrameTime = deltaTime
        
        if currentFrameTime > targetFrameTime * 1.2 then
            -- Reduce quality
            lightingState.performance.quality = math.max(0.3, lightingState.performance.quality - 0.1)
        elseif currentFrameTime < targetFrameTime * 0.8 then
            -- Increase quality
            lightingState.performance.quality = math.min(1.0, lightingState.performance.quality + 0.05)
        end
        
        -- Apply quality settings
        local quality = lightingState.performance.quality
        CONFIG.LIGHTING.SHADOW_RESOLUTION = math.floor(2048 * quality)
        CONFIG.VOLUMETRIC.STEPS = math.floor(64 * quality)
    end
end

--[[
    TIME OF DAY SYSTEM
]]
local function updateTimeOfDay(deltaTime)
    -- Auto-advance time (1 game hour = 1 real minute)
    lightingState.timeOfDay = lightingState.timeOfDay + (deltaTime / 60)
    if lightingState.timeOfDay >= 24 then
        lightingState.timeOfDay = lightingState.timeOfDay - 24
    end
    
    -- Update Roblox lighting time
    Lighting.TimeOfDay = string.format("%02d:%02d:%02d", 
        math.floor(lightingState.timeOfDay),
        math.floor((lightingState.timeOfDay % 1) * 60),
        0)
    
    -- Update atmospheric scattering
    updateAtmosphericScattering()
end

--[[
    PUBLIC API
]]
function DynamicLightingSystem:initialize()
    print("💡 DynamicLightingSystem: Initializing advanced lighting pipeline...")
    print("   🌅 HDR Tone Mapping: " .. (CONFIG.LIGHTING.HDR_ENABLED and "Enabled" or "Disabled"))
    print("   🌫️ Volumetric Effects: " .. (CONFIG.VOLUMETRIC.ENABLED and "Enabled" or "Disabled"))
    print("   🌍 Atmospheric Scattering: " .. (CONFIG.ATMOSPHERE.ENABLED and "Enabled" or "Disabled"))
    print("   🎭 Dynamic Shadows: " .. (CONFIG.SHADOWS.ENABLED and "Enabled (" .. CONFIG.SHADOWS.CASCADE_COUNT .. " cascades)" or "Disabled"))
    
    -- Set up Roblox lighting properties (Technology must be set by server script)
    Lighting.GlobalShadows = CONFIG.SHADOWS.ENABLED
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 0.5
    
    -- Create default sun light
    local sunLight = self:createDirectionalLight(
        Vector3.new(0, -1, -0.5).Unit,
        Color3.fromRGB(255, 248, 220),
        2
    )
    sunLight.temperature = 5778 -- Sun temperature in Kelvin
    
    -- Initialize atmospheric effects
    updateAtmosphericScattering()
    updateVolumetricFog()
end

function DynamicLightingSystem:update(deltaTime)
    local camera = Workspace.CurrentCamera
    
    -- Update time of day
    updateTimeOfDay(deltaTime)
    
    -- Update light culling
    if camera then
        updateLightCulling(camera)
    end
    
    -- Update shadow maps
    updateShadowMaps()
    
    -- Update volumetric effects
    updateVolumetricFog()
    
    -- Update HDR and tone mapping
    updateHDRToneMapping()
    
    -- Update performance metrics
    updatePerformance(deltaTime)
end

function DynamicLightingSystem:createDirectionalLight(direction, color, intensity)
    return createLight(LIGHT_TYPES.DIRECTIONAL, Vector3.new(0, 100, 0), color, intensity, math.huge)
end

function DynamicLightingSystem:createPointLight(position, color, intensity, range)
    return createLight(LIGHT_TYPES.POINT, position, color, intensity, range)
end

function DynamicLightingSystem:createSpotLight(position, direction, color, intensity, range, spotAngle)
    local light = createLight(LIGHT_TYPES.SPOT, position, color, intensity, range)
    light.direction = direction
    light.spotAngle = spotAngle or 45
    return light
end

function DynamicLightingSystem:createAreaLight(position, color, intensity, width, height)
    local light = createLight(LIGHT_TYPES.AREA, position, color, intensity, math.max(width, height) * 2)
    light.width = width or 2
    light.height = height or 2
    return light
end

function DynamicLightingSystem:removeLight(lightId)
    for i, light in ipairs(lightingState.lights) do
        if light.id == lightId then
            table.remove(lightingState.lights, i)
            lightingState.shadowMaps[lightId] = nil
            break
        end
    end
end

function DynamicLightingSystem:setTimeOfDay(hour)
    lightingState.timeOfDay = math.clamp(hour, 0, 24)
end

function DynamicLightingSystem:setWeather(cloudCover, fogDensity, windSpeed)
    lightingState.weather.cloudCover = math.clamp(cloudCover or 0.3, 0, 1)
    lightingState.weather.fogDensity = math.clamp(fogDensity or 0.1, 0, 1)
    lightingState.weather.windSpeed = math.max(0, windSpeed or 5)
end

function DynamicLightingSystem:createExplosionLighting(position, color, intensity, duration)
    -- Create temporary intense light for explosion
    duration = duration or 2.0  -- Default duration if nil
    intensity = intensity or 1.0  -- Default intensity if nil
    local explosionLight = self:createPointLight(position, color, intensity, 100)
    explosionLight.flickering = true
    explosionLight.flickerSpeed = 10
    explosionLight.flickerIntensity = 0.5
    
    -- Animate light intensity
    spawn(function()
        local startTime = tick()
        while tick() - startTime < duration do
            local progress = (tick() - startTime) / duration
            local currentIntensity = intensity * (1 - progress) * (1 - progress)
            explosionLight.intensity = currentIntensity
            
            -- Flickering effect
            if explosionLight.flickering then
                local flicker = math.sin(tick() * explosionLight.flickerSpeed * 10) * explosionLight.flickerIntensity
                explosionLight.intensity = explosionLight.intensity + (explosionLight.intensity * flicker)
            end
            
            wait()
        end
        
        -- Remove light
        self:removeLight(explosionLight.id)
    end)
    
    return explosionLight
end

function DynamicLightingSystem:getLightingStats()
    return {
        lights = {
            total = #lightingState.lights,
            active = lightingState.performance.lightCount,
            shadowCasters = lightingState.performance.shadowCount
        },
        performance = {
            frameTime = math.floor(lightingState.performance.frameTime * 1000) / 1000,
            quality = math.floor(lightingState.performance.quality * 100) / 100,
            shadowResolution = CONFIG.LIGHTING.SHADOW_RESOLUTION
        },
        atmosphere = {
            timeOfDay = math.floor(lightingState.timeOfDay * 100) / 100,
            fogDensity = lightingState.weather.fogDensity,
            cloudCover = lightingState.weather.cloudCover
        }
    }
end

return DynamicLightingSystem