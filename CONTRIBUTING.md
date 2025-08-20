# Contributing to Roblox Advanced Explosion System

We love your input! We want to make contributing to this project as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Pull Requests

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Development Setup

### Prerequisites

- [Rojo](https://rojo.space/) - For syncing code with Roblox Studio
- [Roblox Studio](https://www.roblox.com/create) - For testing
- Git - For version control

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/roblox-explosion-system.git
   cd roblox-explosion-system
   ```

2. **Start the development server**:
   ```bash
   rojo serve
   ```

3. **Connect Roblox Studio**:
   - Open Roblox Studio
   - Install the Rojo plugin
   - Connect to `localhost:34872`

4. **Make your changes**:
   - Edit the Lua files in your preferred editor
   - Changes will sync automatically to Studio

5. **Test your changes**:
   - Test in Roblox Studio
   - Verify performance impact
   - Check for errors in output

## Coding Standards

### Lua Style Guide

- **Indentation**: Use 4 spaces (no tabs)
- **Naming**: Use camelCase for variables and functions, PascalCase for modules
- **Comments**: Use `--` for single-line, `--[[]]` for multi-line
- **Line Length**: Keep lines under 100 characters when possible

### Code Structure

```lua
-- Module header with description
--[[
    ModuleName.lua
    Description of what this module does
    
    Author: Your Name
    Date: YYYY-MM-DD
]]

-- Services and dependencies
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Module definition
local ModuleName = {}

-- Constants
local DEFAULT_INTENSITY = 1.0
local MAX_PARTICLES = 200

-- Private functions
local function privateFunction()
    -- Implementation
end

-- Public functions
function ModuleName:publicFunction(parameter)
    -- Validate parameters
    if not parameter then
        warn("ModuleName:publicFunction - parameter is required")
        return
    end
    
    -- Implementation
end

return ModuleName
```

### Error Handling

- Always validate function parameters
- Use `pcall` for operations that might fail
- Provide meaningful error messages
- Include fallback behavior when possible

```lua
function ModuleName:safeFunction(data)
    -- Parameter validation
    if type(data) ~= "table" then
        warn("ModuleName:safeFunction - data must be a table")
        return false
    end
    
    -- Safe operation
    local success, result = pcall(function()
        return processData(data)
    end)
    
    if not success then
        warn("ModuleName:safeFunction - Failed to process data:", result)
        return false
    end
    
    return result
end
```

## Testing Guidelines

### Manual Testing

1. **Performance Testing**:
   - Test with multiple simultaneous explosions
   - Monitor FPS impact
   - Test on different device types (mobile, desktop)

2. **Visual Testing**:
   - Verify particle effects render correctly
   - Check lighting effects
   - Ensure UI elements display properly

3. **Network Testing**:
   - Test in multiplayer scenarios
   - Verify data compression works
   - Check for network errors

### Test Scenarios

- Single explosion
- Multiple simultaneous explosions
- Rapid-fire explosions
- Large-scale explosions
- Network-intensive scenarios
- Low-performance devices

## Bug Reports

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/yourusername/roblox-explosion-system/issues).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

### Bug Report Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - Roblox Studio Version: [e.g. 0.556.0.5560472]
 - Rojo Version: [e.g. 7.4.4]
 - OS: [e.g. Windows 10]

**Additional context**
Add any other context about the problem here.
```

## Feature Requests

We welcome feature requests! Please provide:

- **Use case**: Why do you need this feature?
- **Description**: What should the feature do?
- **Examples**: How would you use it?
- **Alternatives**: What alternatives have you considered?

## Code Review Process

The core team looks at Pull Requests on a regular basis. After feedback has been given we expect responses within two weeks. After two weeks we may close the pull request if it isn't showing any activity.

## Community Guidelines

### Our Pledge

In the interest of fostering an open and welcoming environment, we as contributors and maintainers pledge to making participation in our project and our community a harassment-free experience for everyone.

### Our Standards

**Examples of behavior that contributes to creating a positive environment include:**

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Examples of unacceptable behavior include:**

- The use of sexualized language or imagery and unwelcome sexual attention or advances
- Trolling, insulting/derogatory comments, and personal or political attacks
- Public or private harassment
- Publishing others' private information without explicit permission
- Other conduct which could reasonably be considered inappropriate in a professional setting

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Don't hesitate to reach out if you have questions:

- Open an issue for bugs or feature requests
- Start a discussion for general questions
- Contact the maintainers directly for sensitive issues

Thank you for contributing! 🎉