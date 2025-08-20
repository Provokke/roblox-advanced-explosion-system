# 🎆 Advanced Particle Explosion System for Roblox

[![GitHub](https://img.shields.io/github/license/Provokke/roblox-advanced-explosion-system)](LICENSE)
[![Roblox Studio](https://img.shields.io/badge/Roblox%20Studio-Compatible-00A2FF)](https://www.roblox.com/create)
[![Rojo](https://img.shields.io/badge/Rojo-Supported-FF6B35)](https://rojo.space/)

A professional-grade particle explosion system for Roblox featuring advanced mathematical applications, modular architecture, GPU instancing, and comprehensive performance optimization.

## 🚀 Features

### 🎯 Core Systems
- **13 Unique Explosion Patterns**: Random, Chain, Spiral, Grid, Wave, Plasma, Fire Tornado, Advanced Chain, Audio Reactive, Fractal, L-System, Cellular Automata, and Voronoi
- **Toggle Control System**: Explosions start disabled and can be enabled/disabled via UI button
- **Manual Explosion Triggers**: Click-to-explode functionality with customizable intensity
- **Advanced Particle System**: GPU instancing, LOD system, and custom shader effects
- **Dynamic Lighting**: Volumetric effects and HDR rendering
- **Network Optimization**: Data compression and predictive algorithms

### 🧮 Mathematical Applications
- **Procedural Pattern Generation**: L-System algorithms, fractal mathematics
- **Cellular Automata**: Game of Life, High Life, and Maze patterns
- **Voronoi Diagrams**: Advanced spatial partitioning
- **Physics Simulation**: Realistic particle behavior with gravity and wind forces

### ⚡ Performance Optimization
- **Adaptive Quality System**: Automatic performance scaling based on FPS
- **Memory Management**: Comprehensive cleanup and leak prevention
- **GPU Instancing**: Efficient particle rendering
- **Network Compression**: LZ77-based data optimization

## 📁 Project Structure

```
roblox-advanced-explosion-system/
├── src/
│   ├── client/                    # Client-side scripts
│   │   ├── ExplosionUI.client.lua # UI system and user interactions
│   │   └── init.client.lua        # Client initialization
│   ├── server/                    # Server-side scripts
│   │   ├── ParticleExplosionSystem.server.lua # Main explosion logic
│   │   └── init.server.lua        # Server initialization
│   └── shared/                    # Shared modules
│       ├── AdvancedParticleSystem.lua      # GPU particle system
│       ├── AudioVisualizationSystem.lua   # Audio-reactive effects
│       ├── DynamicLightingSystem.lua      # Lighting effects
│       ├── ExplosionEffects.lua           # Core explosion logic
│       ├── MathUtils.lua                  # Mathematical utilities
│       ├── NetworkOptimizer.lua           # Network compression
│       ├── PerformanceProfiler.lua       # Performance monitoring
│       ├── ProceduralPatternGenerator.lua # Pattern algorithms
│       └── UIAnimationSystem.lua          # UI animations
├── default.project.json           # Rojo project configuration
├── rokit.toml                     # Toolchain configuration
└── README.md                      # This file
```

## 🛠️ Installation & Setup

### Method 1: Direct Roblox Studio Import (Recommended)

1. **Download the Project**:
   ```bash
   git clone https://github.com/Provokke/roblox-advanced-explosion-system.git
   cd roblox-advanced-explosion-system
   ```

2. **Install Rojo** (if not already installed):
   - Download from [rojo.space](https://rojo.space/)
   - Or install via Foreman/Aftman: `rojo install`

3. **Sync to Roblox Studio**:
   ```bash
   rojo serve
   ```
   - Open Roblox Studio
   - Install the Rojo plugin from the toolbox
   - Click "Connect" in the Rojo plugin
   - The project will sync automatically

4. **Test the System**:
   - Press F5 to run the game in Studio
   - Use the toggle button to enable explosions
   - Click anywhere to create manual explosions

### Method 2: Manual File Import

1. **Create a new Roblox place**
2. **Set up the folder structure**:
   - Create `ReplicatedStorage > Shared`
   - Create `ServerScriptService > Server`
   - Create `StarterPlayer > StarterPlayerScripts > Client`

3. **Import the files**:
   - Copy all files from `src/shared/` to `ReplicatedStorage.Shared`
   - Copy all files from `src/server/` to `ServerScriptService.Server`
   - Copy all files from `src/client/` to `StarterPlayer.StarterPlayerScripts.Client`

4. **Configure Lighting** (Optional but recommended):
   - Set `Lighting.Technology` to "Voxel" or "ShadowMap"
   - Set `Lighting.Brightness` to 2
   - Disable `Lighting.Outlines`

## 🎮 Usage

### Basic Controls
- **Toggle System**: Click the toggle button in the UI to start/stop automatic explosions
- **Manual Explosions**: Click anywhere in the workspace to create an explosion at that location
- **Pattern Selection**: Use the force pattern command to trigger specific explosion types

### Available Explosion Patterns
1. **Random** - Single random explosions
2. **Chain** - Sequential linked explosions
3. **Spiral** - Rotating spiral patterns
4. **Grid** - Organized grid formations
5. **Wave** - Ripple wave effects
6. **Plasma** - Energy-based plasma effects
7. **Fire Tornado** - Swirling fire vortex
8. **Advanced Chain** - Complex chain reactions
9. **Audio Reactive** - Music-synchronized effects
10. **Fractal** - Mathematical fractal patterns
11. **L-System** - Algorithmic growth patterns
12. **Cellular** - Cellular automata-based
13. **Voronoi** - Spatial partitioning patterns

### Performance Settings
The system automatically adjusts quality based on performance:
- **High Performance**: Full particle counts and effects
- **Medium Performance**: Reduced particle density
- **Low Performance**: Minimal effects for smooth gameplay

## 🔧 Configuration

### Explosion Boundaries
Modify the boundaries in `ParticleExplosionSystem.server.lua`:
```lua
BOUNDARIES = {
    MIN_X = -150, MAX_X = 150,
    MIN_Y = 10, MAX_Y = 80,
    MIN_Z = -150, MAX_Z = 150
}
```

### Timing Settings
Adjust explosion intervals:
```lua
TIMING = {
    BASE_INTERVAL = 4,      -- Base time between explosions
    RANDOM_VARIANCE = 3,    -- Random variation
    CHAIN_DELAY = 0.3,      -- Delay between chain explosions
    WAVE_DELAY = 0.1        -- Delay between wave explosions
}
```

### Performance Limits
Control system performance:
```lua
PERFORMANCE = {
    TARGET_FPS = 30,
    MAX_CONCURRENT_EFFECTS = 5,
    ADAPTIVE_QUALITY = true
}
```

## 🚨 Troubleshooting

### Common Issues

1. **"MathUtils.lerp is nil" Error**:
   - This has been fixed in the latest version
   - Ensure you have the updated `MathUtils.lua` file

2. **"chain is not a valid member of Tween" Error**:
   - This has been resolved with proper Tween event handling
   - Update to the latest `ExplosionUI.client.lua`

3. **"Invalid explosion data received" Warning**:
   - Fixed with improved compression detection
   - Ensure `NetworkOptimizer.lua` is properly imported

4. **Performance Issues**:
   - The adaptive quality system should handle this automatically
   - Manually reduce `MAX_CONCURRENT_EFFECTS` if needed

5. **Explosions Not Starting**:
   - Click the toggle button to enable the system
   - Check that `systemState.isRunning` is set to `true`

### Debug Mode
Enable debug logging by uncommenting debug print statements in:
- `ParticleExplosionSystem.server.lua`
- `ExplosionUI.client.lua`

## 📥 Installation

### Method 1: Direct Download (.rbxl file) - **RECOMMENDED**
1. Go to the [Releases page](https://github.com/Provokke/roblox-advanced-explosion-system/releases)
2. Download the `roblox-advanced-explosion-system.rbxl` file from the latest release
3. Open the `.rbxl` file directly in Roblox Studio
4. The system is ready to use immediately with all 13 explosion patterns!

### Method 2: Rojo Build (For Developers)
1. Clone this repository:
   ```bash
   git clone https://github.com/Provokke/roblox-advanced-explosion-system.git
   cd roblox-advanced-explosion-system
   ```

2. Install Rojo (if not already installed):
   ```bash
   # Using Aftman (recommended)
   aftman install
   
   # Or install Rojo directly
   # Visit: https://rojo.space/docs/installation/
   ```

3. Build the project:
   ```bash
   rojo build --output explosion-system.rbxl
   ```

4. Open the generated `.rbxl` file in Roblox Studio

## 🚀 Quick Start

### Basic Usage

```lua
-- Server Script
local ExplosionSystem = require(game.ServerScriptService.ExplosionSystem)

-- Create a simple explosion
ExplosionSystem:createExplosion({
    position = Vector3.new(0, 10, 0),
    intensity = 1.0,
    radius = 20
})
```

### Advanced Configuration

```lua
-- Custom explosion with all parameters
ExplosionSystem:createExplosion({
    position = Vector3.new(0, 10, 0),
    intensity = 2.5,
    radius = 35,
    duration = 3.0,
    particleCount = 150,
    lightColor = Color3.new(1, 0.5, 0),
    soundId = "rbxasset://sounds/electronicpingshort.wav",
    pattern = "burst" -- "burst", "ring", "spiral"
})
```

## 🎮 Usage Guide

### Server-Side Implementation

```lua
-- ServerScriptService/ExplosionHandler.server.lua
local ExplosionSystem = require(script.Parent.ExplosionSystem)
local Players = game:GetService("Players")

-- Handle player requests
local explosionEvent = Instance.new("RemoteEvent")
explosionEvent.Name = "RequestExplosion"
explosionEvent.Parent = game.ReplicatedStorage

explosionEvent.OnServerEvent:Connect(function(player, position)
    -- Validate player permissions and position
    if isValidExplosionRequest(player, position) then
        ExplosionSystem:createExplosion({
            position = position,
            intensity = 1.5,
            radius = 25
        })
    end
end)
```

### Client-Side Integration

```lua
-- StarterPlayerScripts/ExplosionClient.client.lua
local ExplosionUI = require(game.ReplicatedStorage.ExplosionUI)
local UserInputService = game:GetService("UserInputService")

-- Handle explosion effects on client
ExplosionUI:initialize()

-- Example: Trigger explosion on key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
        local character = game.Players.LocalPlayer.Character
        if character and character.HumanoidRootPart then
            local position = character.HumanoidRootPart.Position
            game.ReplicatedStorage.RequestExplosion:FireServer(position)
        end
    end
end)
```

## ⚙️ Configuration

### Performance Settings

```lua
-- Adjust performance based on device capabilities
local config = {
    maxParticles = 100,        -- Reduce for mobile devices
    lightingQuality = "High",  -- "Low", "Medium", "High"
    networkCompression = true, -- Enable for better multiplayer performance
    audioEnabled = true,       -- Disable for performance
    statisticsEnabled = false  -- Enable for debugging
}
```

### Visual Customization

```lua
-- Customize explosion appearance
local visualConfig = {
    particleTexture = "rbxasset://textures/particles/fire_main.dds",
    lightColor = Color3.new(1, 0.8, 0.4),
    lightIntensity = 2.0,
    lightRange = 50,
    fadeTime = 2.0
}
```

## 🔧 API Reference

### ExplosionSystem Methods

#### `createExplosion(config)`
Creates a new explosion with the specified configuration.

**Parameters:**
- `config` (table): Explosion configuration
  - `position` (Vector3): World position for the explosion
  - `intensity` (number, optional): Explosion intensity (default: 1.0)
  - `radius` (number, optional): Effect radius (default: 20)
  - `duration` (number, optional): Effect duration in seconds (default: 2.0)
  - `particleCount` (number, optional): Number of particles (default: 100)
  - `lightColor` (Color3, optional): Light color (default: orange)
  - `soundId` (string, optional): Sound effect ID
  - `pattern` (string, optional): Explosion pattern

#### `setGlobalConfig(config)`
Updates global system configuration.

#### `getStatistics()`
Returns performance statistics and metrics.

### Events

#### `ExplosionCreated`
Fired when a new explosion is created.

#### `ExplosionCompleted`
Fired when an explosion effect finishes.

## 🎯 Examples

### Weapon System Integration

```lua
-- Grenade explosion
local function createGrenadeExplosion(position)
    ExplosionSystem:createExplosion({
        position = position,
        intensity = 3.0,
        radius = 40,
        duration = 4.0,
        particleCount = 200,
        lightColor = Color3.new(1, 0.3, 0),
        soundId = "rbxassetid://131961136",
        pattern = "burst"
    })
end
```

### Environmental Effects

```lua
-- Magical spell explosion
local function createMagicExplosion(position)
    ExplosionSystem:createExplosion({
        position = position,
        intensity = 1.5,
        radius = 30,
        duration = 3.0,
        lightColor = Color3.new(0.5, 0.8, 1),
        pattern = "spiral"
    })
end
```

## 🐛 Troubleshooting

### Common Issues

**Q: Explosions not appearing**
- Ensure scripts are in correct locations
- Check that RemoteEvents are properly configured
- Verify player permissions

**Q: Performance issues**
- Reduce `maxParticles` in configuration
- Lower `lightingQuality` setting
- Enable `networkCompression`

**Q: Network errors**
- Check that NetworkOptimizer module is present
- Verify RemoteEvent connections
- Enable debug logging for diagnostics

### Debug Mode

```lua
-- Enable debug logging
ExplosionSystem:setDebugMode(true)

-- View performance statistics
local stats = ExplosionSystem:getStatistics()
print("Active explosions:", stats.activeExplosions)
print("Average FPS:", stats.averageFPS)
```

## 📊 Performance Guidelines

### Recommended Limits
- **Mobile devices**: Max 50 particles, Low lighting quality
- **Desktop**: Max 150 particles, High lighting quality
- **Concurrent explosions**: Limit to 5 for optimal performance

### Optimization Tips
1. Use network compression for multiplayer games
2. Implement explosion pooling for frequent use
3. Adjust particle counts based on device capabilities
4. Monitor FPS and adjust settings dynamically

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

1. Fork the repository
2. Install Rojo and dependencies
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Roblox Developer Community
- Rojo development team
- Contributors and testers

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/roblox-explosion-system/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/roblox-explosion-system/discussions)
- **Discord**: [Community Server](https://discord.gg/your-server)

---

**Made with ❤️ for the Roblox community**