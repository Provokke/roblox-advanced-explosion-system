--[[
    Procedural Pattern Generation System
    Features: L-Systems, Fractals, Cellular Automata, Voronoi Diagrams,
    Perlin Noise Patterns, and Mathematical Function Visualization
    
    Portfolio Skills Demonstrated:
    - L-System (Lindenmayer System) implementation
    - Fractal geometry (Mandelbrot, Julia sets, Dragon curves)
    - Cellular Automata (Conway's Game of Life variants)
    - Voronoi diagram generation
    - Advanced noise functions (Perlin, Simplex, Worley)
    - Mathematical function visualization
    - Procedural content generation
--]]

local ProceduralPatternGenerator = {}
local MathUtils = require(script.Parent.MathUtils)

-- L-System Configuration
local LSYSTEM_RULES = {
    -- Dragon Curve
    dragon = {
        axiom = "FX",
        rules = {
            X = "X+YF+",
            Y = "-FX-Y"
        },
        angle = 90,
        iterations = 10
    },
    
    -- Sierpinski Triangle
    sierpinski = {
        axiom = "F-G-G",
        rules = {
            F = "F-G+F+G-F",
            G = "GG"
        },
        angle = 120,
        iterations = 5
    },
    
    -- Plant Growth
    plant = {
        axiom = "X",
        rules = {
            X = "F+[[X]-X]-F[-FX]+X",
            F = "FF"
        },
        angle = 25,
        iterations = 6
    },
    
    -- Koch Snowflake
    koch = {
        axiom = "F--F--F",
        rules = {
            F = "F+F--F+F"
        },
        angle = 60,
        iterations = 4
    }
}

-- Fractal Configuration
local FRACTAL_CONFIG = {
    mandelbrot = {
        maxIterations = 100,
        escapeRadius = 2,
        zoom = 1,
        centerX = -0.5,
        centerY = 0
    },
    
    julia = {
        maxIterations = 100,
        escapeRadius = 2,
        cReal = -0.7269,
        cImag = 0.1889
    }
}

-- Cellular Automata Rules
local CA_RULES = {
    -- Conway's Game of Life
    gameOfLife = {
        birth = {3},
        survival = {2, 3}
    },
    
    -- High Life
    highLife = {
        birth = {3, 6},
        survival = {2, 3}
    },
    
    -- Day & Night
    dayNight = {
        birth = {3, 6, 7, 8},
        survival = {3, 4, 6, 7, 8}
    },
    
    -- Maze Generation
    maze = {
        birth = {3},
        survival = {1, 2, 3, 4, 5}
    }
}

-- L-System Implementation
local LSystem = {}

function LSystem.generate(ruleName, customIterations)
    local rule = LSYSTEM_RULES[ruleName]
    if not rule then return nil end
    
    local iterations = customIterations or rule.iterations
    local current = rule.axiom
    
    for i = 1, iterations do
        local next = ""
        for j = 1, #current do
            local char = current:sub(j, j)
            next = next .. (rule.rules[char] or char)
        end
        current = next
    end
    
    return current, rule.angle
end

function LSystem.interpret(lstring, angle, startPos, startDir)
    local positions = {}
    local directions = {}
    local stack = {}
    
    local currentPos = startPos or Vector3.new(0, 0, 0)
    local currentDir = startDir or Vector3.new(1, 0, 0)
    local currentAngle = 0
    
    table.insert(positions, currentPos)
    table.insert(directions, currentDir)
    
    for i = 1, #lstring do
        local char = lstring:sub(i, i)
        
        if char == "F" or char == "G" then
            -- Move forward and draw
            currentPos = currentPos + currentDir * 2
            table.insert(positions, currentPos)
            table.insert(directions, currentDir)
            
        elseif char == "+" then
            -- Turn right
            currentAngle = currentAngle + math.rad(angle)
            currentDir = Vector3.new(math.cos(currentAngle), math.sin(currentAngle), 0)
            
        elseif char == "-" then
            -- Turn left
            currentAngle = currentAngle - math.rad(angle)
            currentDir = Vector3.new(math.cos(currentAngle), math.sin(currentAngle), 0)
            
        elseif char == "[" then
            -- Push state
            table.insert(stack, {pos = currentPos, dir = currentDir, angle = currentAngle})
            
        elseif char == "]" then
            -- Pop state
            if #stack > 0 then
                local state = table.remove(stack)
                currentPos = state.pos
                currentDir = state.dir
                currentAngle = state.angle
            end
        end
    end
    
    return positions, directions
end

-- Fractal Generation
local Fractals = {}

function Fractals.mandelbrot(x, y, config)
    config = config or FRACTAL_CONFIG.mandelbrot
    
    local zx, zy = 0, 0
    local cx = (x - config.centerX) / config.zoom
    local cy = (y - config.centerY) / config.zoom
    
    for i = 1, config.maxIterations do
        local zx2, zy2 = zx * zx, zy * zy
        
        if zx2 + zy2 > config.escapeRadius * config.escapeRadius then
            return i / config.maxIterations
        end
        
        zy = 2 * zx * zy + cy
        zx = zx2 - zy2 + cx
    end
    
    return 0
end

function Fractals.julia(x, y, config)
    config = config or FRACTAL_CONFIG.julia
    
    local zx, zy = x, y
    
    for i = 1, config.maxIterations do
        local zx2, zy2 = zx * zx, zy * zy
        
        if zx2 + zy2 > config.escapeRadius * config.escapeRadius then
            return i / config.maxIterations
        end
        
        zy = 2 * zx * zy + config.cImag
        zx = zx2 - zy2 + config.cReal
    end
    
    return 0
end

function Fractals.sierpinskiTriangle(x, y, iterations)
    iterations = iterations or 8
    
    for i = 1, iterations do
        if math.floor(x) % 2 == 1 and math.floor(y) % 2 == 1 then
            return 0
        end
        x = x / 2
        y = y / 2
    end
    
    return 1
end

-- Cellular Automata
local CellularAutomata = {}

function CellularAutomata.create(width, height, density)
    density = density or 0.3
    local grid = {}
    
    for x = 1, width do
        grid[x] = {}
        for y = 1, height do
            grid[x][y] = math.random() < density and 1 or 0
        end
    end
    
    return grid
end

function CellularAutomata.countNeighbors(grid, x, y)
    local count = 0
    local width, height = #grid, #grid[1]
    
    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
                local nx, ny = x + dx, y + dy
                if nx >= 1 and nx <= width and ny >= 1 and ny <= height then
                    count = count + grid[nx][ny]
                end
            end
        end
    end
    
    return count
end

function CellularAutomata.evolve(grid, ruleName)
    local rule = CA_RULES[ruleName] or CA_RULES.gameOfLife
    local width, height = #grid, #grid[1]
    local newGrid = {}
    
    for x = 1, width do
        newGrid[x] = {}
        for y = 1, height do
            local neighbors = CellularAutomata.countNeighbors(grid, x, y)
            local currentCell = grid[x][y]
            
            if currentCell == 1 then
                -- Cell is alive
                newGrid[x][y] = 0
                for _, survivalCount in ipairs(rule.survival) do
                    if neighbors == survivalCount then
                        newGrid[x][y] = 1
                        break
                    end
                end
            else
                -- Cell is dead
                newGrid[x][y] = 0
                for _, birthCount in ipairs(rule.birth) do
                    if neighbors == birthCount then
                        newGrid[x][y] = 1
                        break
                    end
                end
            end
        end
    end
    
    return newGrid
end

-- Voronoi Diagram Generation
local Voronoi = {}

function Voronoi.generate(width, height, seedCount)
    local seeds = {}
    local diagram = {}
    
    -- Generate random seed points
    for i = 1, seedCount do
        table.insert(seeds, {
            x = math.random(1, width),
            y = math.random(1, height),
            id = i
        })
    end
    
    -- Calculate Voronoi diagram
    for x = 1, width do
        diagram[x] = {}
        for y = 1, height do
            local minDistance = math.huge
            local closestSeed = 1
            
            for _, seed in ipairs(seeds) do
                local distance = math.sqrt((x - seed.x)^2 + (y - seed.y)^2)
                if distance < minDistance then
                    minDistance = distance
                    closestSeed = seed.id
                end
            end
            
            diagram[x][y] = {
                seedId = closestSeed,
                distance = minDistance
            }
        end
    end
    
    return diagram, seeds
end

-- Advanced Noise Functions
local NoisePatterns = {}

function NoisePatterns.worleyNoise(x, y, scale, seedPoints)
    scale = scale or 10
    seedPoints = seedPoints or 16
    
    local cellX = math.floor(x * scale)
    local cellY = math.floor(y * scale)
    
    local minDistance = math.huge
    
    -- Check surrounding cells
    for dx = -1, 1 do
        for dy = -1, 1 do
            local checkX = cellX + dx
            local checkY = cellY + dy
            
            -- Generate deterministic random point in cell
            math.randomseed(checkX * 73856093 + checkY * 19349663)
            local pointX = checkX + math.random()
            local pointY = checkY + math.random()
            
            local distance = math.sqrt((x * scale - pointX)^2 + (y * scale - pointY)^2)
            minDistance = math.min(minDistance, distance)
        end
    end
    
    return minDistance / scale
end

function NoisePatterns.ridgedNoise(x, y, octaves, persistence, scale)
    octaves = octaves or 4
    persistence = persistence or 0.5
    scale = scale or 1
    
    local value = 0
    local amplitude = 1
    local frequency = scale
    
    for i = 1, octaves do
        local noise = MathUtils.perlinNoise2D(x * frequency, y * frequency)
        noise = 1 - math.abs(noise)
        noise = noise * noise
        
        value = value + noise * amplitude
        amplitude = amplitude * persistence
        frequency = frequency * 2
    end
    
    return value
end

-- Pattern Generation Functions
function ProceduralPatternGenerator:generateLSystemPattern(ruleName, iterations, scale)
    scale = scale or 1
    local lstring, angle = LSystem.generate(ruleName, iterations)
    if not lstring then return nil end
    
    local positions, directions = LSystem.interpret(lstring, angle)
    
    -- Scale positions
    for i, pos in ipairs(positions) do
        positions[i] = pos * scale
    end
    
    return {
        type = "lsystem",
        rule = ruleName,
        positions = positions,
        directions = directions,
        scale = scale
    }
end

function ProceduralPatternGenerator:generateFractalPattern(fractalType, width, height, config)
    local pattern = {}
    
    for x = 1, width do
        pattern[x] = {}
        for y = 1, height do
            local normalizedX = (x - width/2) / (width/4)
            local normalizedY = (y - height/2) / (height/4)
            
            if fractalType == "mandelbrot" then
                pattern[x][y] = Fractals.mandelbrot(normalizedX, normalizedY, config)
            elseif fractalType == "julia" then
                pattern[x][y] = Fractals.julia(normalizedX, normalizedY, config)
            elseif fractalType == "sierpinski" then
                pattern[x][y] = Fractals.sierpinskiTriangle(x, y, config and config.iterations or 8)
            end
        end
    end
    
    return {
        type = "fractal",
        subtype = fractalType,
        width = width,
        height = height,
        data = pattern
    }
end

function ProceduralPatternGenerator:generateCellularAutomataPattern(width, height, ruleName, generations, density)
    local grid = CellularAutomata.create(width, height, density)
    local history = {grid}
    
    for i = 1, generations do
        grid = CellularAutomata.evolve(grid, ruleName)
        table.insert(history, grid)
    end
    
    return {
        type = "cellular_automata",
        rule = ruleName,
        width = width,
        height = height,
        generations = generations,
        history = history,
        finalState = grid
    }
end

function ProceduralPatternGenerator:generateVoronoiPattern(width, height, seedCount)
    local diagram, seeds = Voronoi.generate(width, height, seedCount)
    
    return {
        type = "voronoi",
        width = width,
        height = height,
        seedCount = seedCount,
        diagram = diagram,
        seeds = seeds
    }
end

function ProceduralPatternGenerator:generateNoisePattern(width, height, noiseType, config)
    local pattern = {}
    config = config or {}
    
    for x = 1, width do
        pattern[x] = {}
        for y = 1, height do
            local normalizedX = x / width
            local normalizedY = y / height
            
            if noiseType == "perlin" then
                pattern[x][y] = MathUtils.perlinNoise2D(normalizedX * (config.scale or 10), normalizedY * (config.scale or 10))
            elseif noiseType == "worley" then
                pattern[x][y] = NoisePatterns.worleyNoise(normalizedX, normalizedY, config.scale, config.seedPoints)
            elseif noiseType == "ridged" then
                pattern[x][y] = NoisePatterns.ridgedNoise(normalizedX, normalizedY, config.octaves, config.persistence, config.scale)
            elseif noiseType == "fractal" then
                pattern[x][y] = MathUtils.fractalNoise2D(normalizedX, normalizedY, config.octaves or 4, config.persistence or 0.5, config.scale or 10)
            end
        end
    end
    
    return {
        type = "noise",
        subtype = noiseType,
        width = width,
        height = height,
        config = config,
        data = pattern
    }
end

-- Generate explosion pattern based on procedural algorithms
function ProceduralPatternGenerator:generateExplosionPattern(patternType, config)
    config = config or {}
    
    if patternType == "lsystem" then
        return self:generateLSystemPattern(
            config.rule or "dragon",
            config.iterations or 8,
            config.scale or 5
        )
    elseif patternType == "fractal" then
        return self:generateFractalPattern(
            config.fractalType or "mandelbrot",
            config.width or 64,
            config.height or 64,
            config.fractalConfig
        )
    elseif patternType == "cellular" then
        return self:generateCellularAutomataPattern(
            config.width or 32,
            config.height or 32,
            config.rule or "gameOfLife",
            config.generations or 10,
            config.density or 0.3
        )
    elseif patternType == "voronoi" then
        return self:generateVoronoiPattern(
            config.width or 32,
            config.height or 32,
            config.seedCount or 8
        )
    elseif patternType == "noise" then
        return self:generateNoisePattern(
            config.width or 32,
            config.height or 32,
            config.noiseType or "perlin",
            config.noiseConfig or {scale = 5}
        )
    end
    
    return nil
end

-- Get available pattern types
function ProceduralPatternGenerator:getAvailablePatterns()
    return {
        lsystem = {"dragon", "sierpinski", "plant", "koch"},
        fractal = {"mandelbrot", "julia", "sierpinski"},
        cellular = {"gameOfLife", "highLife", "dayNight", "maze"},
        voronoi = {"standard"},
        noise = {"perlin", "worley", "ridged", "fractal"}
    }
end

return ProceduralPatternGenerator