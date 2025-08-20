--[[
    Advanced Performance Profiler System
    
    Features:
    - Real-time performance monitoring
    - Memory usage tracking and leak detection
    - Frame rate analysis with statistical metrics
    - CPU profiling with function-level timing
    - Network performance monitoring
    - Automatic optimization suggestions
    - Performance bottleneck identification
    - Resource usage alerts
    - Historical performance data
    - Adaptive quality scaling
--]]

local PerformanceProfiler = {}
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

-- Performance tracking data
local performanceData = {
    frameRate = {
        current = 0,
        average = 0,
        min = math.huge,
        max = 0,
        history = {},
        samples = 0
    },
    memory = {
        current = 0,
        peak = 0,
        baseline = 0,
        leakDetection = {
            samples = {},
            threshold = 50 * 1024 * 1024, -- 50MB leak threshold
            alertCount = 0
        }
    },
    cpu = {
        totalTime = 0,
        functionTimes = {},
        bottlenecks = {},
        averageFrameTime = 0
    },
    network = {
        bytesReceived = 0,
        bytesSent = 0,
        packetsReceived = 0,
        packetsSent = 0,
        latency = 0,
        bandwidth = 0
    },
    quality = {
        currentLevel = 3, -- 1-5 scale
        autoAdjust = true,
        thresholds = {
            excellent = 55, -- FPS thresholds
            good = 45,
            fair = 30,
            poor = 20
        }
    }
}

-- Profiling configuration
local config = {
    enabled = false,
    sampleInterval = 0.1, -- Sample every 100ms
    historySize = 300, -- Keep 30 seconds of history at 0.1s intervals
    memoryCheckInterval = 1.0, -- Check memory every second
    optimizationInterval = 5.0, -- Check for optimizations every 5 seconds
    alertThresholds = {
        lowFPS = 25,
        highMemory = 200 * 1024 * 1024, -- 200MB
        highCPU = 16.67 -- 16.67ms per frame (60 FPS)
    }
}

-- Performance monitoring connections
local connections = {}
local startTime = tick()
local lastSampleTime = 0
local lastMemoryCheck = 0
local lastOptimizationCheck = 0

-- Function profiling utilities
local functionProfiler = {
    activeProfiles = {},
    results = {}
}

function PerformanceProfiler:initialize()
    print("[PerformanceProfiler] Initializing advanced performance monitoring...")
    
    -- Record baseline memory
    performanceData.memory.baseline = self:getCurrentMemoryUsage()
    performanceData.memory.current = performanceData.memory.baseline
    
    -- Start performance monitoring
    self:startMonitoring()
    
    print("[PerformanceProfiler] Performance profiler initialized")
    print("[PerformanceProfiler] Baseline memory:", math.floor(performanceData.memory.baseline / 1024 / 1024), "MB")
end

function PerformanceProfiler:startMonitoring()
    -- Main performance monitoring loop
    connections.heartbeat = RunService.Heartbeat:Connect(function(deltaTime)
        local currentTime = tick()
        
        -- Update frame rate data
        self:updateFrameRate(deltaTime)
        
        -- Sample performance data at intervals
        if currentTime - lastSampleTime >= config.sampleInterval then
            self:samplePerformance()
            lastSampleTime = currentTime
        end
        
        -- Check memory at intervals
        if currentTime - lastMemoryCheck >= config.memoryCheckInterval then
            self:checkMemoryUsage()
            lastMemoryCheck = currentTime
        end
        
        -- Run optimization checks
        if currentTime - lastOptimizationCheck >= config.optimizationInterval then
            self:checkOptimizations()
            lastOptimizationCheck = currentTime
        end
    end)
end

function PerformanceProfiler:updateFrameRate(deltaTime)
    local fps = 1 / deltaTime
    
    performanceData.frameRate.current = fps
    performanceData.frameRate.samples = performanceData.frameRate.samples + 1
    
    -- Update statistics
    performanceData.frameRate.min = math.min(performanceData.frameRate.min, fps)
    performanceData.frameRate.max = math.max(performanceData.frameRate.max, fps)
    
    -- Calculate running average
    local samples = performanceData.frameRate.samples
    performanceData.frameRate.average = ((performanceData.frameRate.average * (samples - 1)) + fps) / samples
    
    -- Add to history
    table.insert(performanceData.frameRate.history, fps)
    if #performanceData.frameRate.history > config.historySize then
        table.remove(performanceData.frameRate.history, 1)
    end
end

function PerformanceProfiler:samplePerformance()
    -- Update CPU timing
    performanceData.cpu.averageFrameTime = 1000 / performanceData.frameRate.current -- ms per frame
    
    -- Update network stats (if available)
    self:updateNetworkStats()
    
    -- Auto-adjust quality if enabled
    if performanceData.quality.autoAdjust then
        self:adjustQuality()
    end
end

function PerformanceProfiler:getCurrentMemoryUsage()
    -- Get memory usage from Stats service
    local memoryStats = Stats:GetTotalMemoryUsageMb()
    return memoryStats * 1024 * 1024 -- Convert to bytes
end

function PerformanceProfiler:checkMemoryUsage()
    local currentMemory = self:getCurrentMemoryUsage()
    performanceData.memory.current = currentMemory
    performanceData.memory.peak = math.max(performanceData.memory.peak, currentMemory)
    
    -- Memory leak detection
    local leakData = performanceData.memory.leakDetection
    table.insert(leakData.samples, {
        time = tick(),
        memory = currentMemory
    })
    
    -- Keep only recent samples (last 5 minutes)
    local cutoffTime = tick() - 300
    for i = #leakData.samples, 1, -1 do
        if leakData.samples[i].time < cutoffTime then
            table.remove(leakData.samples, i)
        end
    end
    
    -- Check for memory leaks
    if #leakData.samples >= 10 then
        local oldestSample = leakData.samples[1]
        local newestSample = leakData.samples[#leakData.samples]
        local memoryIncrease = newestSample.memory - oldestSample.memory
        
        if memoryIncrease > leakData.threshold then
            leakData.alertCount = leakData.alertCount + 1
            -- warn("[PerformanceProfiler] Potential memory leak detected! Increase:", 
            --      math.floor(memoryIncrease / 1024 / 1024), "MB over", 
            --      math.floor(newestSample.time - oldestSample.time), "seconds")
        end
    end
end

function PerformanceProfiler:updateNetworkStats()
    -- Update network performance metrics
    local networkStats = game:GetService("Stats")
    if networkStats then
        -- Use current API properties (DataReceiveKbps/DataSendKbps instead of deprecated DataReceived/DataSent)
        performanceData.network.bytesReceived = networkStats.DataReceiveKbps * 1024 -- Convert Kbps to bytes
        performanceData.network.bytesSent = networkStats.DataSendKbps * 1024 -- Convert Kbps to bytes
    end
end

function PerformanceProfiler:adjustQuality()
    local currentFPS = performanceData.frameRate.current
    local thresholds = performanceData.quality.thresholds
    local newQuality = performanceData.quality.currentLevel
    
    if currentFPS >= thresholds.excellent then
        newQuality = 5
    elseif currentFPS >= thresholds.good then
        newQuality = 4
    elseif currentFPS >= thresholds.fair then
        newQuality = 3
    elseif currentFPS >= thresholds.poor then
        newQuality = 2
    else
        newQuality = 1
    end
    
    if newQuality ~= performanceData.quality.currentLevel then
        performanceData.quality.currentLevel = newQuality
        -- print("[PerformanceProfiler] Quality adjusted to level", newQuality, "(FPS:", math.floor(currentFPS), ")")
        
        -- Fire quality change event
        self:onQualityChanged(newQuality)
    end
end

function PerformanceProfiler:onQualityChanged(newQuality)
    -- Override this function to handle quality changes
    -- This can be used to adjust particle counts, lighting quality, etc.
end

function PerformanceProfiler:checkOptimizations()
    local suggestions = {}
    
    -- Check frame rate
    if performanceData.frameRate.average < config.alertThresholds.lowFPS then
        table.insert(suggestions, {
            type = "performance",
            severity = "high",
            message = "Low frame rate detected (" .. math.floor(performanceData.frameRate.average) .. " FPS)",
            recommendations = {
                "Reduce particle count",
                "Lower lighting quality",
                "Disable expensive effects",
                "Optimize script performance"
            }
        })
    end
    
    -- Check memory usage
    local memoryMB = performanceData.memory.current / 1024 / 1024
    if performanceData.memory.current > config.alertThresholds.highMemory then
        table.insert(suggestions, {
            type = "memory",
            severity = "medium",
            message = "High memory usage (" .. math.floor(memoryMB) .. " MB)",
            recommendations = {
                "Clear unused objects",
                "Reduce texture quality",
                "Implement object pooling",
                "Check for memory leaks"
            }
        })
    end
    
    -- Check CPU usage
    if performanceData.cpu.averageFrameTime > config.alertThresholds.highCPU then
        table.insert(suggestions, {
            type = "cpu",
            severity = "medium",
            message = "High CPU usage (" .. string.format("%.2f", performanceData.cpu.averageFrameTime) .. " ms/frame)",
            recommendations = {
                "Optimize script loops",
                "Reduce calculation frequency",
                "Use coroutines for heavy tasks",
                "Profile function performance"
            }
        })
    end
    
    -- Report suggestions
    if #suggestions > 0 then
        self:reportOptimizationSuggestions(suggestions)
    end
end

function PerformanceProfiler:reportOptimizationSuggestions(suggestions)
    -- print("[PerformanceProfiler] === OPTIMIZATION SUGGESTIONS ===")
    -- for i, suggestion in ipairs(suggestions) do
    --     print("[" .. suggestion.severity:upper() .. "] " .. suggestion.message)
    --     for j, rec in ipairs(suggestion.recommendations) do
    --         print("  • " .. rec)
    --     end
    -- end
    -- print("[PerformanceProfiler] ===========================================")
end

-- Function profiling utilities
function PerformanceProfiler:profileFunction(functionName, func)
    return function(...)
        local startTime = tick()
        local results = {func(...)}
        local endTime = tick()
        local duration = (endTime - startTime) * 1000 -- Convert to milliseconds
        
        -- Record timing data
        if not performanceData.cpu.functionTimes[functionName] then
            performanceData.cpu.functionTimes[functionName] = {
                totalTime = 0,
                callCount = 0,
                averageTime = 0,
                maxTime = 0
            }
        end
        
        local funcData = performanceData.cpu.functionTimes[functionName]
        funcData.totalTime = funcData.totalTime + duration
        funcData.callCount = funcData.callCount + 1
        funcData.averageTime = funcData.totalTime / funcData.callCount
        funcData.maxTime = math.max(funcData.maxTime, duration)
        
        return unpack(results)
    end
end

function PerformanceProfiler:getPerformanceReport()
    local report = {
        timestamp = tick(),
        uptime = tick() - startTime,
        frameRate = {
            current = math.floor(performanceData.frameRate.current),
            average = math.floor(performanceData.frameRate.average),
            min = math.floor(performanceData.frameRate.min),
            max = math.floor(performanceData.frameRate.max)
        },
        memory = {
            current = math.floor(performanceData.memory.current / 1024 / 1024), -- MB
            peak = math.floor(performanceData.memory.peak / 1024 / 1024), -- MB
            baseline = math.floor(performanceData.memory.baseline / 1024 / 1024) -- MB
        },
        quality = {
            level = performanceData.quality.currentLevel,
            autoAdjust = performanceData.quality.autoAdjust
        },
        cpu = {
            averageFrameTime = string.format("%.2f", performanceData.cpu.averageFrameTime)
        }
    }
    
    return report
end

function PerformanceProfiler:getDetailedReport()
    local report = self:getPerformanceReport()
    
    -- Add function timing data
    report.functionTimes = {}
    for funcName, data in pairs(performanceData.cpu.functionTimes) do
        report.functionTimes[funcName] = {
            averageTime = string.format("%.3f", data.averageTime),
            maxTime = string.format("%.3f", data.maxTime),
            callCount = data.callCount,
            totalTime = string.format("%.3f", data.totalTime)
        }
    end
    
    -- Add frame rate history
    report.frameRateHistory = performanceData.frameRate.history
    
    return report
end

function PerformanceProfiler:exportReport()
    local report = self:getDetailedReport()
    local jsonReport = HttpService:JSONEncode(report)
    return jsonReport
end

function PerformanceProfiler:cleanup()
    for _, connection in pairs(connections) do
        if connection then
            connection:Disconnect()
        end
    end
    connections = {}
    print("[PerformanceProfiler] Performance monitoring stopped")
end

function PerformanceProfiler:setConfig(newConfig)
    for key, value in pairs(newConfig) do
        if config[key] ~= nil then
            config[key] = value
        end
    end
end

function PerformanceProfiler:getQualityLevel()
    return performanceData.quality.currentLevel
end

function PerformanceProfiler:setQualityLevel(level)
    performanceData.quality.currentLevel = math.clamp(level, 1, 5)
    self:onQualityChanged(performanceData.quality.currentLevel)
end

function PerformanceProfiler:enableAutoQuality(enabled)
    performanceData.quality.autoAdjust = enabled
end

return PerformanceProfiler