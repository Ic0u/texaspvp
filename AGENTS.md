# Repository Guidelines

Contributor guide and architectural reference for Darling X, a modular Luau script framework for Roblox.

## Project Structure & Module Organization

- `main.lua`: Core entry point containing the liquid glass UI framework, dynamic theme engine, dock navigation, and runtime module loader (`RequireModule`).
- `modules/`: Self-contained feature domains loaded dynamically:
  - `combat/`: Aimbot core (`aimbot_core.lua`), target acquisition, FOV, and tracers.
  - `pvp/`: Combat automation (`auto_combat.lua`), fast attack, and HUD widgets.
  - `mobility/`: Flight, noclip, and tween movement engine (`movement_engine.lua`).
  - `soru/`: Infinite dash utilities and cooldown bypass logic (`soru_controller.lua`).
  - `esp/`: Visual entity indicators and highlighting layers (`esp_pvp.lua`).
  - `misc/`: Client tweaks (`client_tweaks.lua`) and performance optimizations.
  - `macro/`: Macro engine and tab bindings.
- `assets/`: UI graphics and background wallpapers (`assets/backgrounds/`).

## Build, Test, and Development Commands

This repository uses interpreted Luau scripts executed directly in Roblox runtime environments without a build step.

- **Remote Loading (In-Game Console):**
  ```lua
  loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/texaspvp/main/main.lua"))()
  ```
- **Local Testing:** Place the project into your executor's workspace folder (e.g. `DarlingX/`) and run:
  ```lua
  loadstring(readfile("DarlingX/main.lua"))()
  ```
- **Syntax Check (CLI):** If Luau/Lua CLI tools are installed:
  ```bash
  luau --check main.lua modules/**/*.lua
  luac -p main.lua
  ```

## Coding Style & Naming Conventions

- **Formatting:** 4 spaces per indentation level. Avoid hard tabs.
- **Naming Conventions:**
  - `PascalCase`: Roblox services (`RunService`), module tables (`AutoCombat`), and exported API functions (`SetAutoBuso`).
  - `camelCase`: Local functions (`checkLoopGating`), internal variables, and state flags (`needLoop`).
  - `UPPER_SNAKE_CASE`: Script constants (`APP_VERSION`, `DEFAULT_WALLPAPER_ID`).
- **Resource Gating & Safety:**
  - Wrap executor APIs (`getgenv()`, `_G`), remotes, and UI event hooks in `pcall`.
  - Enforce lifecycle cleanup: cancel threads (`task.cancel`) and disconnect listeners (`RBXScriptConnection:Disconnect()`) when features are toggled off.

## Testing Guidelines

Because tests run in the live Roblox engine, automated CI test suites are not configured. Contributors must:

1. Validate script syntax locally (`luac -p` or `luau --check`) before committing.
2. Manually test on both desktop and mobile touch controls (verifying `TouchTap` vs scroll gestures).
3. Ensure disabling modules completely stops background loops with zero lingering CPU or memory overhead.

## Commit & Pull Request Guidelines

- **Commit Format:** Use conventional commit messages:
  - `feat(combat): add player aimbot prediction toggle`
  - `fix(mobility): resolve noclip collision on respawn`
  - `perf(misc): optimize rendering tweak cleanup`
- **Pull Request Requirements:**
  - Reference affected files and modules.
  - List tested executor environments (e.g., PC, Android).
  - Confirm loop gating and cleanup verification.
