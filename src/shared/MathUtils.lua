--[[
    MATHEMATICAL UTILITIES MODULE
    Portfolio Showcase - Advanced Math & Algorithms
    
    Features Demonstrated:
    - Advanced Mathematical Functions
    - Algorithm Implementation
    - Performance Optimization
    - Modular Design
    - Documentation Standards
--]]

local MathUtils = {}

-- Constants
MathUtils.PI = math.pi
MathUtils.TAU = 2 * math.pi
MathUtils.GOLDEN_RATIO = (1 + math.sqrt(5)) / 2
MathUtils.EULER = 2.718281828459045

--[[
    VECTOR MATHEMATICS
--]]

--- Generates a random point on a unit sphere using Marsaglia's method
--- @return Vector3: Normalized vector representing a point on unit sphere
function MathUtils.randomPointOnSphere()
    local x1, x2
    local w
    
    repeat
        x1 = 2 * math.random() - 1
        x2 = 2 * math.random() - 1
        w = x1 * x1 + x2 * x2
    until w < 1
    
    local w_sqrt = math.sqrt(1 - w)
    return Vector3.new(
        2 * x1 * w_sqrt,
        2 * x2 * w_sqrt,
        1 - 2 * w
    )
end

--- Generates a random point within a sphere
--- @param radius number: Radius of the sphere
--- @return Vector3: Random point within the sphere
function MathUtils.randomPointInSphere(radius)
    radius = radius or 1
    local direction = MathUtils.randomPointOnSphere()
    local distance = math.random() ^ (1/3) * radius -- Cube root for uniform distribution
    return direction * distance
end

--- Calculates the distance between two Vector3 points
--- @param a Vector3: First point
--- @param b Vector3: Second point
--- @return number: Distance between points
function MathUtils.distance(a, b)
    local diff = a - b
    return math.sqrt(diff.X^2 + diff.Y^2 + diff.Z^2)
end

--- Linear interpolation between two numbers
--- @param a number: Start value
--- @param b number: End value
--- @param t number: Interpolation factor (0-1)
--- @return number: Interpolated value
function MathUtils.lerp(a, b, t)
    return a + (b - a) * math.max(0, math.min(1, t))
end

--- Linear interpolation between two Vector3 values
--- @param a Vector3: Start value
--- @param b Vector3: End value
--- @param t number: Interpolation factor (0-1)
--- @return Vector3: Interpolated value
function MathUtils.lerpVector3(a, b, t)
    return a + (b - a) * math.max(0, math.min(1, t))
end

--[[
    EASING FUNCTIONS
--]]

--- Smooth step function for smooth transitions
--- @param t number: Input value (0-1)
--- @return number: Smoothed output (0-1)
function MathUtils.smoothStep(t)
    t = math.max(0, math.min(1, t))
    return t * t * (3 - 2 * t)
end

--- Smoother step function (even smoother than smoothStep)
--- @param t number: Input value (0-1)
--- @return number: Smoothed output (0-1)
function MathUtils.smootherStep(t)
    t = math.max(0, math.min(1, t))
    return t * t * t * (t * (t * 6 - 15) + 10)
end

--- Elastic ease out function
--- @param t number: Input value (0-1)
--- @return number: Eased output
function MathUtils.elasticOut(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    
    local p = 0.3
    local s = p / 4
    return math.pow(2, -10 * t) * math.sin((t - s) * MathUtils.TAU / p) + 1
end

--- Bounce ease out function
--- @param t number: Input value (0-1)
--- @return number: Eased output
function MathUtils.bounceOut(t)
    if t < 1/2.75 then
        return 7.5625 * t * t
    elseif t < 2/2.75 then
        t = t - 1.5/2.75
        return 7.5625 * t * t + 0.75
    elseif t < 2.5/2.75 then
        t = t - 2.25/2.75
        return 7.5625 * t * t + 0.9375
    else
        t = t - 2.625/2.75
        return 7.5625 * t * t + 0.984375
    end
end

--[[
    NOISE FUNCTIONS
--]]

--- Simple 1D noise function using sine waves
--- @param x number: Input coordinate
--- @param frequency number: Frequency of the noise
--- @param amplitude number: Amplitude of the noise
--- @return number: Noise value
function MathUtils.noise1D(x, frequency, amplitude)
    frequency = frequency or 1
    amplitude = amplitude or 1
    
    local value = 0
    local freq = frequency
    local amp = amplitude
    
    -- Octaves for more complex noise
    for i = 1, 4 do
        value = value + math.sin(x * freq) * amp
        freq = freq * 2
        amp = amp * 0.5
    end
    
    return value
end

--- Perlin-like noise function for 2D coordinates
--- @param x number: X coordinate
--- @param y number: Y coordinate
--- @return number: Noise value (-1 to 1)
function MathUtils.noise2D(x, y)
    local n = math.sin(x * 12.9898 + y * 78.233) * 43758.5453
    return 2 * (n - math.floor(n)) - 1
end

--[[
    COLOR UTILITIES
--]]

--- Converts HSV to RGB color
--- @param h number: Hue (0-360)
--- @param s number: Saturation (0-1)
--- @param v number: Value (0-1)
--- @return Color3: RGB color
function MathUtils.hsvToRgb(h, s, v)
    h = h % 360
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c
    
    local r, g, b
    
    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    
    return Color3.new(r + m, g + m, b + m)
end

--- Interpolates between two colors
--- @param color1 Color3: Start color
--- @param color2 Color3: End color
--- @param t number: Interpolation factor (0-1)
--- @return Color3: Interpolated color
function MathUtils.lerpColor(color1, color2, t)
    t = math.max(0, math.min(1, t))
    return Color3.new(
        color1.R + (color2.R - color1.R) * t,
        color1.G + (color2.G - color1.G) * t,
        color1.B + (color2.B - color1.B) * t
    )
end

--[[
    UTILITY FUNCTIONS
--]]

--- Maps a value from one range to another
--- @param value number: Input value
--- @param inMin number: Input range minimum
--- @param inMax number: Input range maximum
--- @param outMin number: Output range minimum
--- @param outMax number: Output range maximum
--- @return number: Mapped value
function MathUtils.map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

--- Clamps a value between min and max
--- @param value number: Input value
--- @param min number: Minimum value
--- @param max number: Maximum value
--- @return number: Clamped value
function MathUtils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Rounds a number to specified decimal places
--- @param value number: Input value
--- @param decimals number: Number of decimal places
--- @return number: Rounded value
function MathUtils.round(value, decimals)
    decimals = decimals or 0
    local mult = 10^decimals
    return math.floor(value * mult + 0.5) / mult
end

--- Generates a weighted random choice from a table
--- @param choices table: Array of {value, weight} pairs or objects with weight property
--- @return any: Randomly selected value based on weights
function MathUtils.weightedRandom(choices)
    if not choices or #choices == 0 then
        return nil
    end
    
    local totalWeight = 0
    for _, choice in ipairs(choices) do
        local weight = choice.weight or choice[2] or 1 -- Support both formats
        totalWeight = totalWeight + weight
    end
    
    local random = math.random() * totalWeight
    local currentWeight = 0
    
    for _, choice in ipairs(choices) do
        local weight = choice.weight or choice[2] or 1 -- Support both formats
        currentWeight = currentWeight + weight
        if random <= currentWeight then
            return choice[1] or choice -- Return value or entire object
        end
    end
    
    return choices[#choices][1] or choices[#choices] -- Fallback
end

--- Calculates factorial of a number (with memoization)
local factorialCache = {[0] = 1, [1] = 1}
function MathUtils.factorial(n)
    if n < 0 then return nil end
    if factorialCache[n] then return factorialCache[n] end
    
    factorialCache[n] = n * MathUtils.factorial(n - 1)
    return factorialCache[n]
end

--- Fibonacci sequence with memoization
local fibCache = {[0] = 0, [1] = 1}
function MathUtils.fibonacci(n)
    if n < 0 then return nil end
    if fibCache[n] then return fibCache[n] end
    
    fibCache[n] = MathUtils.fibonacci(n - 1) + MathUtils.fibonacci(n - 2)
    return fibCache[n]
end

--[[
    PERFORMANCE TESTING
--]]

--- Benchmarks a function's execution time
--- @param func function: Function to benchmark
--- @param iterations number: Number of iterations to run
--- @return number: Average execution time in seconds
function MathUtils.benchmark(func, iterations)
    iterations = iterations or 1000
    
    local startTime = tick()
    for i = 1, iterations do
        func()
    end
    local endTime = tick()
    
    return (endTime - startTime) / iterations
end

return MathUtils