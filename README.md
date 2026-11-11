# TEXAS CHICKEN™

High-performance, modular Roblox script architecture powered by the **Obsidian UI Library** (`deividcomsono/Obsidian`). Features Linoria-derived groupboxes, native ThemeManager & SaveManager config profiles, multi-column navigation, and mobile support.

## Architecture

- **UI Framework**: Obsidian UI Library (Linoria-derived clean layout, custom cursors, notifications, and mobile support).
- **Branding**: Title `  TEXAS CHICKEN™ `, Main Accent `#ECB33D`, and Icon Asset `9712354122`.
- **Config & Theme Engine**: Native `SaveManager` (autoload configs, profile exports) and `ThemeManager` (live palette customization with built-in "Texas Chicken" preset).
- **Navigation**: Lucide icon dock supporting dual-column groupbox layouts.
- **Tabs**:
  - `Home`: Live player status, network telemetry (ping/FPS/uptime), and server utilities (rejoin, hop, reset).
  - `Combat`: Silent aim (Player & NPC), lead prediction, FOV circle customization, tracers, and skill blacklist.
  - `PvP`: Fast Attack (M1), Auto Buso Haki, Auto Race V3/V4 Awakening, Dragon Gun M1, Camlock, and Sanguine Boost.
  - `Mobility`: Glide flight, custom WalkSpeed, Super Jump, Infinite Jump, Noclip, and Water/Lava traversal.
  - `Soru`: Infinite Soru cooldown bypass, Soru aimbot, and instant combo skill automation.
  - `Visuals`: Player ESP (2D boxes, health bars, equipped tool, devil fruit, bounty, distance), Chams, and tracers.
  - `Macro`: 6-block autonomous combat combo engine with loop sequence and floating trigger widget.
  - `Settings`: Menu keybinds, FFlags FPS booster, animations stabilizer, theme studio, and config profiles.

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/texaspvp/main/main.lua"))()
```

## Structure

```text
TexasChicken/
├── assets/
│   └── backgrounds/
├── modules/
│   ├── combat/
│   ├── pvp/
│   ├── mobility/
│   ├── soru/
│   ├── esp/
│   ├── macro/
│   └── misc/
├── main.lua
└── README.md
```
