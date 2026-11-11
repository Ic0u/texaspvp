--[[
    TEXAS CHICKEN™ | Next-Gen Combat & Utility Suite for Roblox
    Powered by Obsidian UI Library (deividcomsono/Obsidian)
    Rebranded & Refactored for TEXAS CHICKEN™
    Repository: https://github.com/Ic0u/texaspvp
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local lp = Players.LocalPlayer
while not lp do
    task.wait(0.1)
    lp = Players.LocalPlayer
end

-- ============================================================
-- GLOBAL COMPATIBILITY & CONFIGURATION BRIDGE
-- ============================================================
local APP_TITLE = "  TEXAS CHICKEN™ "
local APP_VERSION = "v1.0"
local APP_AUTHOR = "TEXAS CHICKEN™"
local APP_ACCENT = Color3.fromRGB(236, 179, 61) -- #ECB33D
pcall(function()
    if Color3.fromHex then APP_ACCENT = Color3.fromHex("#ECB33D") end
end)
local APP_ICON = 9712354122
local GITHUB_REPO_RAW = "https://raw.githubusercontent.com/Ic0u/texaspvp/main"

local SafeHttpGet = function(url)
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and res and #res > 0 then return res end
    return nil
end

local LoadedModules = {}

local exIsFile = isfile or is_file or (syn and syn.isfile)
local exReadFile = readfile or (syn and syn.readfile)
local exWriteFile = writefile or (syn and syn.writefile)
local exMakeFolder = makefolder or make_folder or (syn and syn.makefolder)
local exIsFolder = isfolder or is_folder or (syn and syn.isfolder)

local function RequireModule(relPath)
    if LoadedModules[relPath] then
        return LoadedModules[relPath]
    end

    -- 1. Check local file system first (enables offline & local dev testing)
    local candidatePaths = {
        relPath,
        "TexasChicken/" .. relPath,
        "Austina/" .. relPath,
        "DarlingX/" .. relPath,
        "assets/" .. relPath,
        "modules/" .. relPath:gsub("^modules/", ""),
    }

    if exIsFile and exReadFile then
        for _, path in ipairs(candidatePaths) do
            local okCheck, exists = pcall(exIsFile, path)
            if okCheck and exists then
                local okRead, content = pcall(exReadFile, path)
                if okRead and content and #content > 0 then
                    local okCompile, fn = pcall(loadstring, content)
                    if okCompile and fn then
                        local okRun, result = pcall(fn)
                        if okRun and result then
                            LoadedModules[relPath] = result
                            return result
                        end
                    end
                end
            end
        end
    end

    -- 2. Fresh remote fetch from GitHub
    local cacheBuster = tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    local remoteUrl = GITHUB_REPO_RAW .. "/" .. relPath .. "?t=" .. cacheBuster
    local body = SafeHttpGet(remoteUrl)
    if body and #body > 50 then
        local okCompile, fn = pcall(loadstring, body)
        if okCompile and fn then
            local okRun, result = pcall(fn)
            if okRun and result then
                LoadedModules[relPath] = result
                pcall(function()
                    if exIsFolder and exMakeFolder and not exIsFolder("TexasChicken") then exMakeFolder("TexasChicken") end
                    if exWriteFile then exWriteFile("TexasChicken/" .. relPath, body) end
                end)
                return result
            end
        end
    end

    return nil
end

-- TEXAS CHICKEN™ Core Hub Object
local TexasChicken = {
    Title = APP_TITLE,
    Version = APP_VERSION,
    Accent = APP_ACCENT,
    Icon = APP_ICON,
    Settings = {
        Aim = {
            Priority = "Nearest",
            Mode = "360",
            MaxRange = 1000,
            TargetPart = "HumanoidRootPart",
            Prediction = true,
            PredictionAmount = 0.12,
        },
        FOV = {
            Radius = 100,
            Mode = "Center",
            Color = APP_ACCENT,
            Thickness = 2,
        },
        Tracers = {
            Type = "Both",
            Origin = "Player",
            Color = APP_ACCENT,
            Thickness = 2,
        },
        Blacklist = {
            Melee = {},
            Sword = {},
            Fruit = {},
            Gun = {}
        }
    },
    Require = function(self, path)
        return RequireModule(path)
    end
}

-- Global environment bridging (TexasChicken native + backward compatibility with legacy modules)
_G.TexasChicken = TexasChicken
_G.TexasChickenHub = TexasChicken
_G.Austina = TexasChicken
_G.AustinaHub = TexasChicken
_G.DarlingX = TexasChicken
_G.DarlingHub = TexasChicken

if getgenv then
    pcall(function()
        local g = getgenv()
        g.TexasChicken = TexasChicken
        g.TexasChickenHub = TexasChicken
        g.Austina = TexasChicken
        g.AustinaHub = TexasChicken
        g.DarlingX = TexasChicken
        g.DarlingHub = TexasChicken
    end)
end

-- Cached Module Getters
local M = { cache = {} }
function M.get(path)
    if not M.cache[path] then M.cache[path] = RequireModule(path) end
    return M.cache[path]
end
function M.getFastAttack() return M.get("modules/pvp/fast_attack.lua") end
function M.getDragonGun() return M.get("modules/pvp/dragon_gun_m1.lua") end
function M.getSanguineBoost() return M.get("modules/pvp/sanguine_boost.lua") end
function M.getExtraWidgets() return M.get("modules/pvp/extra_widgets.lua") end
function M.getAutoCombat() return M.get("modules/pvp/auto_combat.lua") end
function M.getCamlock() return M.get("modules/pvp/camlock.lua") end
function M.getMoveMod() return M.get("modules/mobility/movement_engine.lua") end
function M.getClientTweaks() return M.get("modules/misc/client_tweaks.lua") end
function M.getSoruMod() return M.get("modules/soru/soru_controller.lua") end
function M.getEspMod() return M.get("modules/esp/esp_pvp.lua") end
function M.getMacroMod() return M.get("modules/macro/macro_engine.lua") end

-- Pre-warm modules in background
task.spawn(function()
    pcall(function()
        M.getFastAttack()
        M.getDragonGun()
        M.getSanguineBoost()
        M.getAutoCombat()
        M.getCamlock()
        M.getMoveMod()
        M.getClientTweaks()
        M.getSoruMod()
        M.getEspMod()
    end)
end)

-- ============================================================
-- COMBAT FILTER HELPERS (Blox Fruits PvP / SafeZone Detection)
-- ============================================================
local function isPlayerAlly(player)
    if not player or player == lp then return false end
    local ok, ally = pcall(function()
        local main = lp and lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
        local frame = main and main:FindFirstChild("Allies")
            and main.Allies:FindFirstChild("Container")
            and main.Allies.Container:FindFirstChild("Allies")
            and main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
            and main.Allies.Container.Allies.ScrollingFrame:FindFirstChild("Frame")
        if frame and frame:FindFirstChild(player.Name) then return true end

        local myTeam = lp and lp.Team
        local targetTeam = player.Team
        if myTeam and targetTeam and myTeam == targetTeam then return true end
        if myTeam and targetTeam and myTeam.Name == "Marines" and targetTeam.Name == "Marines" then return true end
        return false
    end)
    return ok and ally
end

local function isPlayerPvPEnabled(player)
    if not player or player == lp then return false end
    local ok, enabled = pcall(function()
        if player:GetAttribute("PvpDisabled") == true then return false end
        local char = player.Character
        if char then
            if char:FindFirstChildOfClass("ForceField") then return false end
            if char:GetAttribute("PvpDisabled") == true then return false end
        end
        return true
    end)
    return not ok or enabled
end

local function isPlayerInSafeZone(player)
    if not player or player == lp then return false end
    local ok, inZone = pcall(function()
        local char = player.Character
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit == true then return true end
        if char:FindFirstChildOfClass("ForceField") then return true end
        if char:GetAttribute("SafeZone") == true then return true end
        if player:GetAttribute("SafeZone") == true then return true end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local hrpPos = hrp.Position

        local function checkFolder(folder)
            if not folder then return false end
            for _, zone in ipairs(folder:GetChildren()) do
                if zone:IsA("BasePart") then
                    local mesh = zone:FindFirstChild("Mesh")
                    local radius = 0
                    if mesh and mesh:IsA("SpecialMesh") then
                        radius = (zone.Size.X * mesh.Scale.X) / 2
                    else
                        radius = math.min(zone.Size.X, zone.Size.Z) / 2
                    end
                    if radius > 500 then radius = 350 end
                    if radius <= 0 then radius = 350 end
                    if (zone.Position - hrpPos).Magnitude <= radius then return true end

                    local localPos = zone.CFrame:PointToObjectSpace(hrpPos)
                    local halfSize = zone.Size / 2
                    if math.abs(localPos.X) <= halfSize.X and math.abs(localPos.Y) <= halfSize.Y + 25 and math.abs(localPos.Z) <= halfSize.Z then
                        return true
                    end
                end
            end
            return false
        end

        local wo = Workspace:FindFirstChild("_WorldOrigin")
        if wo and checkFolder(wo:FindFirstChild("SafeZones")) then return true end
        if wo and checkFolder(wo:FindFirstChild("TempSafeZones")) then return true end
        if checkFolder(Workspace:FindFirstChild("SafeZones")) then return true end
        local map = Workspace:FindFirstChild("Map")
        if map and checkFolder(map:FindFirstChild("SafeZones")) then return true end
        return false
    end)
    return ok and inZone
end

local function hookAimbotTargetFilter()
    pcall(function()
        local core = RequireModule("modules/combat/aimbot_core.lua")
        if core and not core._TexasChickenFilterHooked then
            core._TexasChickenFilterHooked = true
            local origBlacklisted = core.isPlayerBlacklisted
            core.isPlayerBlacklisted = function(player)
                if not player then return false end
                if origBlacklisted and origBlacklisted(player) then return true end

                if _G.DarlingX_IgnoreAllies and isPlayerAlly(player) then
                    return true
                end
                if _G.DarlingX_IgnorePvPOff and not isPlayerPvPEnabled(player) then
                    return true
                end
                if _G.DarlingX_IgnoreSafeZone and isPlayerInSafeZone(player) then
                    return true
                end
                return false
            end
        end
    end)
end
task.spawn(hookAimbotTargetFilter)

-- ============================================================
-- SERVER & TELEMETRY UTILITIES
-- ============================================================
local function RejoinServer()
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
    if qot then
        pcall(function()
            qot([[loadstring(game:HttpGet("https://raw.githubusercontent.com/Ic0u/texaspvp/main/main.lua?t=" .. tostring(os.time())))()]])
        end)
    end
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
    end)
end

local function ServerHop()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/0?sortOrder=Desc&limit=100"
        local res = game:HttpGet(url)
        local data = HttpService:JSONDecode(res)
        if data and data.data then
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                    return
                end
            end
        end
    end)
end

-- ============================================================
-- OBSIDIAN UI INITIALIZATION
-- ============================================================
local obsidianRepo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(SafeHttpGet(obsidianRepo .. "Library.lua"))()
local ThemeManager = loadstring(SafeHttpGet(obsidianRepo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(SafeHttpGet(obsidianRepo .. "addons/SaveManager.lua"))()

-- Configure Primary Accent (#ECB33D) in Library Scheme
Library.Scheme.AccentColor = APP_ACCENT
pcall(function() Library:UpdateColorsUsingRegistry() end)

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = APP_TITLE,
    Footer = "TEXAS CHICKEN™ | v1.0",
    Icon = APP_ICON,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local function Notify(title, desc, duration)
    pcall(function()
        if type(title) == "table" then
            Library:Notify(title)
        elseif desc then
            Library:Notify({
                Title = tostring(title),
                Description = tostring(desc),
                Time = duration or 3,
            })
        else
            Library:Notify({
                Title = "TEXAS CHICKEN™",
                Description = tostring(title),
                Time = duration or 3,
            })
        end
    end)
end

-- Navigation Tabs
local Tabs = {
    Home = Window:AddTab("Home", "home"),
    Combat = Window:AddTab("Combat", "crosshair"),
    PvP = Window:AddTab("PvP", "swords"),
    Mobility = Window:AddTab("Mobility", "wind"),
    Soru = Window:AddTab("Soru", "zap"),
    Visuals = Window:AddTab("Visuals", "eye"),
    Macro = Window:AddTab("Macro", "bot"),
    Settings = Window:AddTab("Settings", "settings"),
}

-- ============================================================
-- 1. HOME TAB (PLAYER PROFILE & QUICK ACTIONS)
-- ============================================================
do
    local LeftGroup = Tabs.Home:AddLeftGroupbox("Player Profile")
    local RightGroup = Tabs.Home:AddRightGroupbox("Quick Actions & Server")

    -- Profile Info Labels
    local nameLabel = LeftGroup:AddLabel("Player: " .. (lp.DisplayName or lp.Name) .. " (@" .. lp.Name .. ")")
    local uidLabel = LeftGroup:AddLabel("User ID: " .. tostring(lp.UserId))
    local ageLabel = LeftGroup:AddLabel("Account Age: " .. tostring(lp.AccountAge) .. " days")
    local teamLabel = LeftGroup:AddLabel("Faction: " .. (lp.Team and lp.Team.Name or "Neutral"))

    LeftGroup:AddDivider()

    local lvlLabel = LeftGroup:AddLabel("Level: --")
    local bountyLabel = LeftGroup:AddLabel("Bounty / Honor: --")
    local beliLabel = LeftGroup:AddLabel("Beli: --")
    local fruitLabel = LeftGroup:AddLabel("Devil Fruit: --")

    LeftGroup:AddDivider()

    local pingLabel = LeftGroup:AddLabel("Network Ping: 0 ms")
    local fpsLabel = LeftGroup:AddLabel("Client FPS: 60 FPS")
    local uptimeLabel = LeftGroup:AddLabel("Server Uptime: 0m 0s")

    -- Telemetry Updater Loop
    task.spawn(function()
        local startTime = os.clock()
        local frameCount = 0
        local lastFpsCheck = os.clock()
        local currentFps = 60

        local renderConn = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if os.clock() - lastFpsCheck >= 1 then
                currentFps = frameCount
                frameCount = 0
                lastFpsCheck = os.clock()
            end
        end)

        while not Library.Unloaded do
            pcall(function()
                -- Live stats
                local data = lp:FindFirstChild("Data") or lp:FindFirstChild("leaderstats")
                if data then
                    local lvl = data:FindFirstChild("Level")
                    if lvl then lvlLabel:SetText("Level: " .. tostring(lvl.Value)) end

                    local bnty = data:FindFirstChild("Bounty") or data:FindFirstChild("Bounty/Honor")
                    if bnty then bountyLabel:SetText("Bounty / Honor: " .. tostring(bnty.Value)) end

                    local beli = data:FindFirstChild("Beli")
                    if beli then beliLabel:SetText("Beli: $" .. tostring(beli.Value)) end

                    local df = data:FindFirstChild("DevilFruit")
                    if df then fruitLabel:SetText("Devil Fruit: " .. tostring(df.Value):gsub("-%w+", "")) end
                end

                if lp.Team then
                    teamLabel:SetText("Faction: " .. tostring(lp.Team.Name))
                end

                -- Ping
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                if ping == 0 then
                    pcall(function() ping = math.floor(lp:GetNetworkPing() * 1000) end)
                end
                pingLabel:SetText("Network Ping: " .. tostring(ping) .. " ms")
                fpsLabel:SetText("Client FPS: " .. tostring(currentFps) .. " FPS")

                local elapsed = math.floor(os.clock() - startTime)
                uptimeLabel:SetText("Server Uptime: " .. math.floor(elapsed / 60) .. "m " .. (elapsed % 60) .. "s")
            end)
            task.wait(1.5)
        end

        if renderConn then pcall(function() renderConn:Disconnect() end) end
    end)

    -- Quick Utilities
    RightGroup:AddButton({
        Text = "Rejoin Current Server",
        Func = function()
            Notify("Server", "Rejoining current server...", 2)
            RejoinServer()
        end
    })

    RightGroup:AddButton({
        Text = "Server Hop (Next Server)",
        Func = function()
            Notify("Server", "Looking for next open server...", 2)
            ServerHop()
        end
    })

    RightGroup:AddButton({
        Text = "Reset Character",
        Func = function()
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    })

    RightGroup:AddButton({
        Text = "Copy Server JobId",
        Func = function()
            pcall(function()
                local setFn = setclipboard or toclipboard
                if setFn then
                    setFn(tostring(game.JobId))
                    Notify("Server", "JobId copied to clipboard!", 2)
                end
            end)
        end
    })

    RightGroup:AddDivider()

    RightGroup:AddButton({
        Text = "Copy Discord Invite Link",
        Func = function()
            pcall(function()
                local setFn = setclipboard or toclipboard
                if setFn then
                    setFn("https://discord.gg/DyG2BSMfVg")
                    Notify("Discord", "Discord link copied to clipboard!", 3)
                end
            end)
        end
    })

    RightGroup:AddLabel("TEXAS CHICKEN™ • Obsidian Edition", true)
    RightGroup:AddLabel("High-performance modular PvP suite", true)
end

-- ============================================================
-- 2. COMBAT TAB (SILENT AIM, FOV CIRCLE, TRACERS & BLACKLIST)
-- ============================================================
do
    local LeftGroup = Tabs.Combat:AddLeftGroupbox("Silent Aim Settings")
    local RightGroup = Tabs.Combat:AddRightGroupbox("FOV Circle & Tracers")

    -- Silent Aim Controls
    LeftGroup:AddToggle("PlayerSilentAim", {
        Text = "Player Silent Aim",
        Default = false,
        Tooltip = "Direct combat skills towards enemy players",
        Callback = function(val)
            local mod = RequireModule("modules/combat/player_aimbot.lua")
            if mod then if val then mod.enable() else mod.disable() end end
            Notify("Combat", "Player Silent Aim: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("NPCSilentAim", {
        Text = "NPC Silent Aim",
        Default = false,
        Tooltip = "Direct combat skills towards mobs and bosses",
        Callback = function(val)
            local mod = RequireModule("modules/combat/npc_aimbot.lua")
            if mod then if val then mod.enable() else mod.disable() end end
            Notify("Combat", "NPC Silent Aim: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("ShowFOVCircle", {
        Text = "Show FOV Circle",
        Default = false,
        Tooltip = "Displays targeting boundary on screen",
        Callback = function(val)
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod then if val then fovMod.enable() else fovMod.disable() end end
        end
    }):AddColorPicker("FOVColorPicker", {
        Default = APP_ACCENT,
        Title = "FOV Circle Color",
        Callback = function(color)
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod and fovMod.setColor then fovMod.setColor(color) end
        end
    })

    LeftGroup:AddToggle("IgnoreAllies", {
        Text = "Ignore Allies",
        Default = false,
        Tooltip = "Do not target crew or team members",
        Callback = function(val)
            _G.DarlingX_IgnoreAllies = val
            hookAimbotTargetFilter()
        end
    })

    LeftGroup:AddToggle("IgnorePvPOff", {
        Text = "Ignore PvP Disabled",
        Default = false,
        Tooltip = "Do not target players with passive shield / PvP off",
        Callback = function(val)
            _G.DarlingX_IgnorePvPOff = val
            hookAimbotTargetFilter()
        end
    })

    LeftGroup:AddToggle("IgnoreSafeZone", {
        Text = "Ignore Safe Zone",
        Default = false,
        Tooltip = "Do not target players inside safe zones",
        Callback = function(val)
            _G.DarlingX_IgnoreSafeZone = val
            hookAimbotTargetFilter()
        end
    })

    LeftGroup:AddDropdown("TargetPriority", {
        Text = "Target Priority",
        Values = { "Nearest", "Low HP", "Looking At Me" },
        Default = 1,
        Callback = function(val)
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then core.TargetPriority = val end
            TexasChicken.Settings.Aim.Priority = val
        end
    })

    LeftGroup:AddDropdown("AimMode", {
        Text = "Aiming Mode",
        Values = { "360", "FOV", "180" },
        Default = 1,
        Callback = function(val)
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then core.AimMode = val end
            TexasChicken.Settings.Aim.Mode = val
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod and fovMod.setAimMode then fovMod.setAimMode(val) end
        end
    })

    LeftGroup:AddDropdown("TargetHitbox", {
        Text = "Target Hitbox",
        Values = { "HumanoidRootPart", "Head", "UpperTorso" },
        Default = 1,
        Callback = function(val)
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then
                core.TargetHitbox = val
                core.TargetPart = val
            end
            TexasChicken.Settings.Aim.TargetPart = val
        end
    })

    LeftGroup:AddSlider("MaxAimRange", {
        Text = "Max Aim Range",
        Default = 1000,
        Min = 100,
        Max = 3000,
        Rounding = 0,
        Callback = function(val)
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then core.MaxRange = val end
            TexasChicken.Settings.Aim.MaxRange = val
        end
    })

    LeftGroup:AddToggle("PredictionEnabled", {
        Text = "Lead Prediction",
        Default = true,
        Tooltip = "Predicts enemy movement based on velocity and latency",
        Callback = function(val)
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then core.PredictionEnabled = val end
            TexasChicken.Settings.Aim.Prediction = val
        end
    })

    LeftGroup:AddSlider("PredictionAmount", {
        Text = "Prediction Factor",
        Default = 12,
        Min = 5,
        Max = 30,
        Rounding = 0,
        Callback = function(val)
            local factor = val / 100
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core then core.PredictionAmount = factor end
            TexasChicken.Settings.Aim.PredictionAmount = factor
        end
    })

    -- Right Group: FOV Circle & Tracers
    RightGroup:AddSlider("FOVRadius", {
        Text = "FOV Radius",
        Default = 100,
        Min = 20,
        Max = 600,
        Rounding = 0,
        Callback = function(val)
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod and fovMod.setRadius then fovMod.setRadius(val) end
            local core = RequireModule("modules/combat/aimbot_core.lua")
            if core and core.setFOVRadius then core.setFOVRadius(val) end
            TexasChicken.Settings.FOV.Radius = val
        end
    })

    RightGroup:AddDropdown("FOVPosition", {
        Text = "FOV Center Position",
        Values = { "Center", "Mouse" },
        Default = 1,
        Callback = function(val)
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod and fovMod.setMode then fovMod.setMode(val) end
            TexasChicken.Settings.FOV.Mode = val
        end
    })

    RightGroup:AddSlider("FOVThickness", {
        Text = "FOV Line Thickness",
        Default = 2,
        Min = 1,
        Max = 8,
        Rounding = 0,
        Callback = function(val)
            local fovMod = RequireModule("modules/combat/fov.lua")
            if fovMod and fovMod.setThickness then fovMod.setThickness(val) end
        end
    })

    RightGroup:AddDivider()

    RightGroup:AddToggle("ShowTracers", {
        Text = "Render Target Tracers",
        Default = false,
        Tooltip = "Renders lines/beams connecting to active target",
        Callback = function(val)
            local mod = RequireModule("modules/combat/tracers.lua")
            if mod then if val then mod.enable() else mod.disable() end end
        end
    }):AddColorPicker("TracerColorPicker", {
        Default = APP_ACCENT,
        Title = "Tracer Color",
        Callback = function(color)
            local mod = RequireModule("modules/combat/tracers.lua")
            if mod and mod.setColor then mod.setColor(color) end
        end
    })

    RightGroup:AddDropdown("TracerMode", {
        Text = "Tracer Render Mode",
        Values = { "Both", "3D Beam", "2D Line" },
        Default = 1,
        Callback = function(val)
            local mod = RequireModule("modules/combat/tracers.lua")
            if mod and mod.setType then mod.setType(val) end
            TexasChicken.Settings.Tracers.Type = val
        end
    })

    RightGroup:AddDropdown("TracerOrigin", {
        Text = "Tracer Origin",
        Values = { "Player", "Bottom", "Center", "Mouse" },
        Default = 1,
        Callback = function(val)
            local mod = RequireModule("modules/combat/tracers.lua")
            if mod and mod.setOrigin then mod.setOrigin(val) end
            TexasChicken.Settings.Tracers.Origin = val
        end
    })

    RightGroup:AddSlider("TracerThickness", {
        Text = "Tracer Line Thickness",
        Default = 2,
        Min = 1,
        Max = 6,
        Rounding = 0,
        Callback = function(val)
            local mod = RequireModule("modules/combat/tracers.lua")
            if mod and mod.setThickness then mod.setThickness(val) end
        end
    })

    RightGroup:AddDivider()

    -- Skill Exclusion Multi-Dropdown
    local skillOptions = {
        "Melee Z", "Melee X", "Melee C",
        "Sword Z", "Sword X",
        "Fruit Z", "Fruit X", "Fruit C", "Fruit V", "Fruit F", "Fruit TAP",
        "Gun Z", "Gun X"
    }

    RightGroup:AddDropdown("SkillBlacklist", {
        Text = "Skill Exclusion List",
        Values = skillOptions,
        Multi = true,
        Tooltip = "Excluded skills will not trigger auto target redirection",
        Callback = function(values)
            local blMod = RequireModule("modules/combat/blacklist.lua")
            for _, sName in ipairs(skillOptions) do
                local cat, key = sName:match("^(%w+)%s+(%w+)$")
                if cat and key then
                    local isExcluded = (values[sName] == true)
                    if blMod then
                        if isExcluded then blMod.add(cat, key) else blMod.remove(cat, key) end
                    end
                end
            end
        end
    })
end

-- ============================================================
-- 3. PVP COMBAT TAB (PASSIVES, FAST ATTACK & COMBAT TECH)
-- ============================================================
do
    local LeftGroup = Tabs.PvP:AddLeftGroupbox("Auto Combat Passives")
    local RightGroup = Tabs.PvP:AddRightGroupbox("Combat Tech & Lock")

    -- Passives
    LeftGroup:AddToggle("FastAttack", {
        Text = "Fast Attack (M1 Spam)",
        Default = false,
        Tooltip = "Executes rapid melee and sword attack packets",
        Callback = function(val)
            _G.DarlingX_FastAttack = val
            local fa = M.getFastAttack()
            if fa then if val then fa.enable() else fa.disable() end end
            Notify("PvP", "Fast Attack: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("AutoBuso", {
        Text = "Auto Buso Haki (Armament)",
        Default = false,
        Tooltip = "Maintains Armament Haki permanently active",
        Callback = function(val)
            local ac = M.getAutoCombat()
            if ac then ac.SetAutoBuso(val) end
            Notify("PvP", "Auto Buso: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("AutoRaceV3", {
        Text = "Auto Race V3",
        Default = false,
        Tooltip = "Triggers Race V3 ability in combat",
        Callback = function(val)
            local ac = M.getAutoCombat()
            if ac then ac.SetAutoV3(val) end
            Notify("PvP", "Auto Race V3: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("AutoRaceV4", {
        Text = "Auto Race V4 Awakening",
        Default = false,
        Tooltip = "Automatically awakens Race V4 when full",
        Callback = function(val)
            local ac = M.getAutoCombat()
            if ac then ac.SetAutoV4(val) end
            Notify("PvP", "Auto Race V4: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("DragonGunM1", {
        Text = "Dragon Gun M1",
        Default = false,
        Tooltip = "Rapid fire M1 gun shots",
        Callback = function(val)
            _G.DarlingX_DragonM1Enabled = val
            local dg = M.getDragonGun()
            if dg then dg.SetEnabled(val) end
            local ew = M.getExtraWidgets()
            if ew then
                ew.SetDragonM1WidgetVisible(val)
                ew.UpdateDragonM1Visual(val)
            end
            Notify("PvP", "Dragon Gun M1: " .. (val and "Enabled" or "Disabled"))
        end
    })

    -- Combat Tech
    RightGroup:AddToggle("CamlockToggle", {
        Text = "Camlock onto Target",
        Default = false,
        Tooltip = "Locks camera directly to enemy target",
        Callback = function(val)
            local cl = M.getCamlock()
            if cl then cl.SetEnabled(val) end
        end
    }):AddKeyPicker("CamlockKey", {
        Default = "C",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Camlock Target"
    })

    RightGroup:AddSlider("CamlockFOV", {
        Text = "Camlock FOV Zoom",
        Default = 70,
        Min = 70,
        Max = 120,
        Rounding = 0,
        Callback = function(val)
            local cl = M.getCamlock()
            if cl then cl.SetCameraFOV(val) end
        end
    })

    RightGroup:AddDivider()

    RightGroup:AddToggle("SanguineBoost", {
        Text = "Sanguine Boost (Lunge)",
        Default = false,
        Tooltip = "High velocity forward burst",
        Callback = function(val)
            _G.DarlingX_SanguineBoost = val
            local sb = M.getSanguineBoost()
            if sb then sb.SetEnabled(val) end
            local ew = M.getExtraWidgets()
            if ew then ew.SetSanguineWidgetVisible(val) end
            Notify("PvP", "Sanguine Boost: " .. (val and "Ready" or "Inactive"))
        end
    }):AddKeyPicker("SanguineKey", {
        Default = "Z",
        Mode = "Press",
        Text = "Trigger Sanguine Boost",
        Callback = function()
            local sb = M.getSanguineBoost()
            if sb then sb.Trigger() end
        end
    })
end

-- ============================================================
-- 4. MOBILITY TAB (FLIGHT, SPEED, NOCLIP & WATER WALKING)
-- ============================================================
do
    local LeftGroup = Tabs.Mobility:AddLeftGroupbox("Flight & Speed")
    local RightGroup = Tabs.Mobility:AddRightGroupbox("Physics & Environment")

    -- Flight & Speed
    LeftGroup:AddToggle("FlyToggle", {
        Text = "Glide Flight",
        Default = false,
        Tooltip = "Free glide movement through air",
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetFly(val) end
            Notify("Mobility", "Flight: " .. (val and "Active" or "Disabled"))
        end
    }):AddKeyPicker("FlyKey", {
        Default = "X",
        SyncToggleState = true,
        Mode = "Toggle",
        Text = "Flight Toggle"
    })

    LeftGroup:AddSlider("FlySpeed", {
        Text = "Flight Speed",
        Default = 70,
        Min = 20,
        Max = 500,
        Rounding = 0,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetFlySpeed(val) end
        end
    })

    LeftGroup:AddDivider()

    LeftGroup:AddToggle("CustomWalkSpeed", {
        Text = "Custom WalkSpeed",
        Default = false,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetWalkSpeed(val) end
            Notify("Mobility", "WalkSpeed: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddSlider("WalkSpeedVal", {
        Text = "WalkSpeed Value",
        Default = 150,
        Min = 16,
        Max = 500,
        Rounding = 0,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetWalkSpeedValue(val) end
        end
    })

    LeftGroup:AddDivider()

    LeftGroup:AddToggle("InfiniteJump", {
        Text = "Infinite Air Jump",
        Default = false,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetInfiniteJump(val) end
        end
    })

    LeftGroup:AddToggle("SuperJump", {
        Text = "Super Jump Leap",
        Default = false,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetSuperJump(val) end
        end
    })

    LeftGroup:AddSlider("SuperJumpPower", {
        Text = "Super Jump Force",
        Default = 216,
        Min = 50,
        Max = 350,
        Rounding = 0,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetSuperJumpPower(val) end
        end
    })

    -- Physics & Environment
    RightGroup:AddToggle("NoclipToggle", {
        Text = "Noclip (Wallpass)",
        Default = false,
        Tooltip = "Disables character collision with solid objects",
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetNoclip(val) end
            Notify("Mobility", "Noclip: " .. (val and "Enabled" or "Disabled"))
        end
    })

    RightGroup:AddToggle("DashLengthToggle", {
        Text = "Custom Dash Length",
        Default = false,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetDashLength(val) end
        end
    })

    RightGroup:AddSlider("DashDistance", {
        Text = "Dash Distance",
        Default = 30,
        Min = 15,
        Max = 150,
        Rounding = 0,
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetDashDistance(val) end
        end
    })

    RightGroup:AddDivider()

    RightGroup:AddToggle("WalkOnWater", {
        Text = "Walk on Water",
        Default = false,
        Tooltip = "Prevents sinking in open ocean water",
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetWalkOnWater(val) end
        end
    })

    RightGroup:AddToggle("AntiLava", {
        Text = "Anti-Lava Damage",
        Default = false,
        Tooltip = "Immunity to molten lava damage",
        Callback = function(val)
            local mm = M.getMoveMod()
            if mm then mm.SetAntiLava(val) end
        end
    })
end

-- ============================================================
-- 5. SORU TAB (FLASHSTEP COOLDOWN BYPASS & COMBO INTEGRATION)
-- ============================================================
do
    local LeftGroup = Tabs.Soru:AddLeftGroupbox("Flashstep Engine")
    local RightGroup = Tabs.Soru:AddRightGroupbox("Soru Skill Combo")

    LeftGroup:AddToggle("InfiniteSoru", {
        Text = "Infinite Soru (No Cooldown)",
        Default = false,
        Tooltip = "Bypasses flashstep cooldown timer",
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm and sm.setInfinite then sm.setInfinite(val) end
            Notify("Soru", "Infinite Soru: " .. (val and "Enabled" or "Disabled"))
        end
    })

    LeftGroup:AddToggle("SoruAimbot", {
        Text = "Soru Aimbot (Auto Teleport)",
        Default = false,
        Tooltip = "Flashsteps directly onto enemy target",
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm and sm.setAimbot then sm.setAimbot(val) end
        end
    })

    LeftGroup:AddDropdown("SoruTargetMode", {
        Text = "Soru Target Mode",
        Values = { "Nearest Player", "Selected Player" },
        Default = 1,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.TargetMode = val end
        end
    })

    LeftGroup:AddDropdown("SoruSelectedPlayer", {
        Text = "Target Player",
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.SelectedPlayer = val end
        end
    })

    LeftGroup:AddSlider("MaxSoruRange", {
        Text = "Max Soru Range",
        Default = 2000,
        Min = 200,
        Max = 3000,
        Rounding = 0,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.MaxDistance = val end
        end
    })

    -- Soru Skill Combo
    RightGroup:AddToggle("AutoSkillOnSoru", {
        Text = "Auto Skill On Soru",
        Default = false,
        Tooltip = "Instantly fires attack skill upon landing",
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm and sm.setSkillCombo then sm.setSkillCombo(val) end
        end
    })

    RightGroup:AddDropdown("SoruWeapon", {
        Text = "Combo Weapon",
        Values = { "Fruit", "Melee", "Sword", "Gun" },
        Default = 1,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.SkillWeapon = val end
        end
    })

    RightGroup:AddDropdown("SoruKey", {
        Text = "Combo Skill Key",
        Values = { "Z", "X", "C", "V", "F" },
        Default = 1,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.SkillKey = val end
        end
    })

    RightGroup:AddSlider("SoruDelay", {
        Text = "Execution Delay (ms)",
        Default = 300,
        Min = 50,
        Max = 800,
        Rounding = 0,
        Callback = function(val)
            local sm = M.getSoruMod()
            if sm then sm.SkillDelay = val / 1000 end
        end
    })
end

-- ============================================================
-- 6. VISUALS / ESP TAB (PVP RADAR, CHAMS & SCREEN TRACERS)
-- ============================================================
do
    local LeftGroup = Tabs.Visuals:AddLeftGroupbox("Player ESP Elements")
    local RightGroup = Tabs.Visuals:AddRightGroupbox("Chams & Tracers")

    LeftGroup:AddToggle("MasterESP", {
        Text = "Master Player ESP",
        Default = false,
        Tooltip = "Master switch for player visuals",
        Callback = function(val)
            local em = M.getEspMod()
            if em and em.toggle then em.toggle(val) end
            Notify("ESP", "ESP: " .. (val and "Active" or "Disabled"))
        end
    })

    LeftGroup:AddDropdown("ESPStyle", {
        Text = "Radar Display Style",
        Values = { "2D Boxes", "Overhead Billboard" },
        Default = 1,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Style = val end
        end
    })

    LeftGroup:AddToggle("ESPBoxes", {
        Text = "Player Bounding Boxes",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Boxes = val end
        end
    })

    LeftGroup:AddToggle("ESPNames", {
        Text = "Player Usernames",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Names = val end
        end
    })

    LeftGroup:AddToggle("ESPHealth", {
        Text = "Health Bars & HP %",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Health = val end
        end
    })

    LeftGroup:AddToggle("ESPDistance", {
        Text = "Distance Indicator (studs)",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Distance = val end
        end
    })

    LeftGroup:AddToggle("ESPTool", {
        Text = "Equipped Weapon / Tool",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Tool = val end
        end
    })

    LeftGroup:AddToggle("ESPFruit", {
        Text = "Devil Fruit Tracker",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Fruit = val end
        end
    })

    LeftGroup:AddToggle("ESPBounty", {
        Text = "Player Bounty Value",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Bounty = val end
        end
    })

    LeftGroup:AddToggle("ESPLevel", {
        Text = "Player Level Display",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Level = val end
        end
    })

    LeftGroup:AddToggle("ESPPvPStatus", {
        Text = "Combat / Safe Zone Status",
        Default = true,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.PvPStatus = val end
        end
    })

    -- Right Group: Chams & Tracers
    RightGroup:AddToggle("ESPChams", {
        Text = "Player Chams (Wall Highlight)",
        Default = false,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Chams = val end
        end
    }):AddColorPicker("ChamsColorPicker", {
        Default = APP_ACCENT,
        Title = "Chams Color",
        Callback = function(color)
            local em = M.getEspMod()
            if em then em.ChamsColor = color end
        end
    })

    RightGroup:AddToggle("ESPTracers", {
        Text = "Player Screen Tracers",
        Default = false,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.Tracers = val end
        end
    }):AddColorPicker("PlayerTracerColorPicker", {
        Default = APP_ACCENT,
        Title = "Player Tracer Color",
        Callback = function(color)
            local em = M.getEspMod()
            if em then em.TracerColor = color end
        end
    })

    RightGroup:AddSlider("ESPFontSize", {
        Text = "ESP Text Font Size",
        Default = 13,
        Min = 10,
        Max = 22,
        Rounding = 0,
        Callback = function(val)
            local em = M.getEspMod()
            if em then em.TextSize = val end
        end
    })

    RightGroup:AddDivider()

    RightGroup:AddButton({
        Text = "Enable All Visuals",
        Func = function()
            Toggles.MasterESP:SetValue(true)
            Toggles.ESPBoxes:SetValue(true)
            Toggles.ESPNames:SetValue(true)
            Toggles.ESPHealth:SetValue(true)
            Toggles.ESPDistance:SetValue(true)
            Toggles.ESPTool:SetValue(true)
            Toggles.ESPFruit:SetValue(true)
            Toggles.ESPBounty:SetValue(true)
            Toggles.ESPLevel:SetValue(true)
            Toggles.ESPPvPStatus:SetValue(true)
            Toggles.ESPChams:SetValue(true)
            Toggles.ESPTracers:SetValue(true)
            Notify("ESP", "All ESP visuals enabled", 2)
        end
    })

    RightGroup:AddButton({
        Text = "Disable All Visuals",
        Func = function()
            Toggles.MasterESP:SetValue(false)
            Toggles.ESPChams:SetValue(false)
            Toggles.ESPTracers:SetValue(false)
            Notify("ESP", "All ESP visuals disabled", 2)
        end
    })
end

-- ============================================================
-- 7. MACRO TAB (AUTONOMOUS COMBO ENGINE)
-- ============================================================
do
    local LeftGroup = Tabs.Macro:AddLeftGroupbox("Macro Controller")
    local RightGroup = Tabs.Macro:AddRightGroupbox("Combo Blocks (1-6)")

    local macroMod = M.getMacroMod()

    LeftGroup:AddToggle("MacroEnabled", {
        Text = "Macro Active",
        Default = false,
        Callback = function(val)
            if macroMod then macroMod.toggle(val) end
            Notify("Macro", "Macro: " .. (val and "Active" or "Disabled"))
        end
    })

    LeftGroup:AddDropdown("MacroSlot", {
        Text = "Active Macro Slot",
        Values = { "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5" },
        Default = 1,
        Callback = function(val)
            local num = tonumber(tostring(val):match("%d+")) or 1
            if macroMod then macroMod.ActiveSlot = num end
        end
    })

    LeftGroup:AddToggle("MacroLoop", {
        Text = "Loop Combo Sequence",
        Default = false,
        Callback = function(val)
            if macroMod then
                macroMod.Loop = val
                macroMod.LoopMode = val
            end
        end
    })

    LeftGroup:AddToggle("MacroWidget", {
        Text = "On-Screen Floating Trigger",
        Default = false,
        Callback = function(val)
            if macroMod and macroMod.ensureMobileButton then
                macroMod.ensureMobileButton(val)
            end
        end
    })

    LeftGroup:AddDropdown("MacroTriggerKey", {
        Text = "Trigger Key (Keyboard)",
        Values = { "F", "Q", "E", "R", "T", "C", "V", "B", "None" },
        Default = 1,
        Callback = function(k)
            if macroMod then
                if k == "None" then
                    macroMod.TriggerKey = Enum.KeyCode.Unknown
                elseif Enum.KeyCode[k] then
                    macroMod.TriggerKey = Enum.KeyCode[k]
                end
            end
        end
    })

    LeftGroup:AddDivider()

    LeftGroup:AddButton({
        Text = "Start Combo Sequence",
        Func = function()
            if macroMod then
                macroMod.Enabled = true
                macroMod.startMacro()
            end
        end
    })

    LeftGroup:AddButton({
        Text = "Stop Combo Sequence",
        Func = function()
            if macroMod then macroMod.stopMacro() end
        end
    })

    -- 6 Combo Blocks
    local weaponOpts = { "Melee", "Sword", "Fruit", "Gun" }
    local skillKeyOpts = { "Z", "X", "C", "V", "F" }
    local modeOpts = { "Tap", "Hold" }

    for b = 1, 6 do
        local defEnabled = (b <= 3)
        local defWeapon = (b <= 2 and "Melee" or "Sword")
        local defKey = ({ "Z", "X", "C", "Z", "X", "C" })[b]

        RightGroup:AddToggle("MacroBlock_" .. b, {
            Text = "Block " .. b .. " Enabled",
            Default = defEnabled,
            Callback = function(val)
                if macroMod then macroMod.setSlot(b, nil, nil, val) end
            end
        })

        RightGroup:AddDropdown("MacroWeapon_" .. b, {
            Text = "Block " .. b .. " Weapon",
            Values = weaponOpts,
            Default = defWeapon,
            Callback = function(val)
                if macroMod then macroMod.setSlot(b, val, nil, nil) end
            end
        })

        RightGroup:AddDropdown("MacroKey_" .. b, {
            Text = "Block " .. b .. " Key",
            Values = skillKeyOpts,
            Default = defKey,
            Callback = function(val)
                if macroMod then macroMod.setSlot(b, nil, val, nil) end
            end
        })

        RightGroup:AddDropdown("MacroMode_" .. b, {
            Text = "Block " .. b .. " Mode",
            Values = modeOpts,
            Default = 1,
            Callback = function(val)
                if macroMod then macroMod.setSlot(b, nil, nil, nil, val) end
            end
        })

        if b < 6 then RightGroup:AddDivider() end
    end
end

-- ============================================================
-- 8. SETTINGS & CONFIG TAB (THEMEMANAGER & SAVEMANAGER)
-- ============================================================
do
    local LeftGroup = Tabs.Settings:AddLeftGroupbox("Menu & Engine Tweaks")
    local ct = M.getClientTweaks()

    LeftGroup:AddToggle("FFlagsFPS", {
        Text = "FFlags FPS Booster (120 FPS)",
        Default = false,
        Tooltip = "Smooth plastic textures, debris cleanup, 120 FPS target",
        Callback = function(val)
            if ct and ct.SetFFlags1 then ct.SetFFlags1(val) end
        end
    })

    LeftGroup:AddToggle("NoAnimations", {
        Text = "Disable Extraneous Animations",
        Default = false,
        Tooltip = "Suppresses non-attack animations to prevent player sideways freeze",
        Callback = function(val)
            if ct and ct.SetNoAnimations then ct.SetNoAnimations(val) end
        end
    })

    LeftGroup:AddButton({
        Text = "Apply Fast FFlags Immediately",
        Func = function()
            if ct and ct.ApplyFastFFlags then
                ct.ApplyFastFFlags()
                Notify("Engine", "Fast FFlags applied", 2)
            end
        end
    })

    LeftGroup:AddDivider()

    LeftGroup:AddToggle("KeybindMenuOpen", {
        Text = "Show Keybind Overlay",
        Default = Library.KeybindFrame.Visible,
        Callback = function(val)
            Library.KeybindFrame.Visible = val
        end
    })

    LeftGroup:AddToggle("CustomCursor", {
        Text = "Custom Mouse Cursor",
        Default = false,
        Callback = function(val)
            Library.ShowCustomCursor = val
        end
    })

    LeftGroup:AddToggle("AlwaysOnTop", {
        Text = "Always On Top",
        Default = true,
        Callback = function(val)
            Window:SetAlwaysOnTop(val)
        end
    })

    LeftGroup:AddDropdown("NotificationSide", {
        Text = "Notification Position",
        Values = { "Right", "Left" },
        Default = "Right",
        Callback = function(val)
            Library:SetNotifySide(val)
        end
    })

    LeftGroup:AddDropdown("DPIScale", {
        Text = "UI DPI Scale",
        Values = { "75%", "100%", "125%", "150%" },
        Default = "100%",
        Callback = function(val)
            local num = tonumber(val:gsub("%%", ""))
            if num then Library:SetDPIScale(num) end
        end
    })

    LeftGroup:AddSlider("UICornerRadius", {
        Text = "Window Corner Radius",
        Default = 8,
        Min = 0,
        Max = 16,
        Rounding = 0,
        Callback = function(val)
            Window:SetCornerRadius(val)
        end
    })

    LeftGroup:AddDivider()

    LeftGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift",
        NoUI = true,
        Text = "Menu Keybind"
    })

    LeftGroup:AddButton({
        Text = "Unload TEXAS CHICKEN™",
        Func = function()
            Library:Unload()
        end
    })

    Library.ToggleKeybind = Options.MenuKeybind

    -- Set up ThemeManager & SaveManager
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

    ThemeManager:SetFolder("TexasChicken")
    SaveManager:SetFolder("TexasChicken/configs")

    -- Register Texas Chicken Built-in Theme with #ECB33D Accent
    ThemeManager.BuiltInThemes["Texas Chicken"] = {
        1,
        {
            FontColor = "ffffff",
            MainColor = "191919",
            AccentColor = "ecb33d",
            BackgroundColor = "0f0f0f",
            OutlineColor = "282828",
            BackgroundImage = ""
        }
    }

    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:ApplyToTab(Tabs.Settings)

    pcall(function()
        ThemeManager:ApplyTheme("Texas Chicken")
        SaveManager:LoadAutoloadConfig()
    end)
end

-- ============================================================
-- COMPLETION NOTIFICATION
-- ============================================================
Notify({
    Title = "  TEXAS CHICKEN™ ",
    Description = "TEXAS CHICKEN™ loaded successfully with Obsidian UI!",
    Time = 4,
})
