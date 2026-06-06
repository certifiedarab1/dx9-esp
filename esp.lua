-- ============================================================
--  INIT GUARD
-- ============================================================
if not _G.aim_init then
    _G.aim_init      = true
    _G.aim_whitelist = {}

    local Lib = loadstring(dx9.Get("https://raw.githubusercontent.com/soupg/DXLibUI/main/main.lua"))()
    _G.aim_lib = Lib

    local Window = Lib:CreateWindow({
        Title         = "aimbot",
        Index         = "aim_win",
        Resizable     = false,
        ToggleKey     = "[F4]",
        StartLocation = {300, 200},
    })
    _G.aim_window = Window

    local Tab1 = Window:AddTab("aimbot")
    local Tab2 = Window:AddTab("target")
    local Tab3 = Window:AddTab("whitelist")

    if Lib.FirstRun then Tab1:Focus() end

    -- ========================
    --  TAB 1 - AIMBOT
    -- ========================
    local LeftA  = Tab1:AddLeftGroupbox("general")
    local RightA = Tab1:AddRightGroupbox("settings")

    LeftA:AddToggle({Index="aim_enabled",   Default=true,  Text="Enabled"})
    LeftA:AddToggle({Index="aim_showfov",   Default=true,  Text="Show FOV Circle"})
    LeftA:AddToggle({Index="aim_showline",  Default=false, Text="Show Target Line"})
    LeftA:AddToggle({Index="aim_showdot",   Default=true,  Text="Show Target Dot"})

    LeftA:AddBorder()
    LeftA:AddTitle("mode")

    LeftA:AddDropdown({
        Index   = "aim_mode",
        Text    = "Aim Mode",
        Default = 1,
        Values  = {"Third Person", "First Person"}
    })

    LeftA:AddBorder()
    LeftA:AddTitle("hold key")

    LeftA:AddDropdown({
        Index   = "aim_hotkey",
        Text    = "Hold Key",
        Default = 3,
        Values  = {
            "[RSHIFT]",
            "[LSHIFT]",
            "[INSERT]",
            "[CAPITAL]",
            "[LMENU]",
            "[RMENU]",
            "[LCONTROL]",
            "[RCONTROL]",
            "[MBUTTON]",
            "[XBUTTON1]",
            "[XBUTTON2]",
        }
    })

    RightA:AddSlider({
        Index    = "aim_fov",
        Default  = 150,
        Text     = "FOV Radius",
        Min      = 10,
        Max      = 500,
        Suffix   = "px",
        Rounding = 0
    })

    RightA:AddSlider({
        Index    = "aim_smooth",
        Default  = 12,
        Text     = "H Smoothness",
        Min      = 1,
        Max      = 30,
        Rounding = 0
    })

    RightA:AddSlider({
        Index    = "aim_vsmooth",
        Default  = 12,
        Text     = "V Smoothness",
        Min      = 1,
        Max      = 30,
        Rounding = 0
    })

    RightA:AddSlider({
        Index    = "aim_maxdist",
        Default  = 500,
        Text     = "Max Distance",
        Min      = 50,
        Max      = 2000,
        Suffix   = "st",
        Rounding = 0
    })

    RightA:AddBorder()
    RightA:AddTitle("legit settings")

    RightA:AddToggle({Index="aim_deadzone",  Default=true, Text="Deadzone (no jitter)"})

    RightA:AddSlider({
        Index    = "aim_deadzonesize",
        Default  = 5,
        Text     = "Deadzone Size",
        Min      = 1,
        Max      = 20,
        Suffix   = "px",
        Rounding = 0
    })

    -- ========================
    --  TAB 2 - TARGET
    -- ========================
    local LeftT  = Tab2:AddLeftGroupbox("bone")
    local RightT = Tab2:AddRightGroupbox("filters")

    LeftT:AddDropdown({
        Index   = "aim_bone",
        Text    = "Target Bone",
        Default = 1,
        Values  = {"Head", "HumanoidRootPart"}
    })

    LeftT:AddBorder()
    LeftT:AddTitle("priority")

    LeftT:AddDropdown({
        Index   = "aim_priority",
        Text    = "Lock Priority",
        Default = 1,
        Values  = {"Closest to crosshair", "Closest distance"}
    })

    RightT:AddToggle({Index="aim_skipteam",  Default=false, Text="Skip Same Team"})
    RightT:AddToggle({Index="aim_skipdead",  Default=true,  Text="Skip Dead Players"})
    RightT:AddToggle({Index="aim_vischeck",  Default=false, Text="Visible Only"})

    -- ========================
    --  TAB 3 - WHITELIST
    -- ========================
    _G.aim_wl_group = Tab3:AddLeftGroupbox("whitelisted players")
    _G.aim_wl_group:AddLabel("No players whitelisted.")

    _G.aim_add_group = Tab3:AddRightGroupbox("add from server")
    _G.aim_add_group:AddLabel("Loading players...")
end

-- ============================================================
--  EVERY FRAME
-- ============================================================
local Lib    = _G.aim_lib
local Window = _G.aim_window
local Tools  = Window.Tools

Window:Render()

-- read all settings
local enabled    = Tools["aim_enabled"]      and Tools["aim_enabled"].Value      or false
local fov        = Tools["aim_fov"]          and Tools["aim_fov"].Value          or 150
local smooth     = Tools["aim_smooth"]       and Tools["aim_smooth"].Value       or 12
local vsmooth    = Tools["aim_vsmooth"]      and Tools["aim_vsmooth"].Value      or 12
local maxDist    = Tools["aim_maxdist"]      and Tools["aim_maxdist"].Value      or 500
local showfov    = Tools["aim_showfov"]      and Tools["aim_showfov"].Value      or false
local showline   = Tools["aim_showline"]     and Tools["aim_showline"].Value     or false
local showdot    = Tools["aim_showdot"]      and Tools["aim_showdot"].Value      or false
local modeVal    = Tools["aim_mode"]         and Tools["aim_mode"].Value         or "Third Person"
local hotkeyVal  = Tools["aim_hotkey"]       and Tools["aim_hotkey"].Value       or "[INSERT]"
local boneVal    = Tools["aim_bone"]         and Tools["aim_bone"].Value         or "Head"
local priorityV  = Tools["aim_priority"]     and Tools["aim_priority"].Value     or "Closest to crosshair"
local skipTeam   = Tools["aim_skipteam"]     and Tools["aim_skipteam"].Value     or false
local skipDead   = Tools["aim_skipdead"]     and Tools["aim_skipdead"].Value     or true
local deadzone   = Tools["aim_deadzone"]     and Tools["aim_deadzone"].Value     or true
local dzSize     = Tools["aim_deadzonesize"] and Tools["aim_deadzonesize"].Value or 5

-- ============================================================
--  HELD KEY CHECK
-- ============================================================
local function isHeld(k)
    local keys = dx9.GetKeys()
    for _, v in next, keys do
        if v == k then return true end
    end
    return false
end

local aiming = isHeld(hotkeyVal)

-- ============================================================
--  GAME DATA
-- ============================================================
local DataModel = dx9.GetDatamodel()
local Players   = dx9.FindFirstChild(DataModel, "Players")
local lp        = dx9.get_localplayer()
local lpName    = lp.Info.name
local screenW   = dx9.size().width
local screenH   = dx9.size().height
local mouse     = dx9.GetMouse()
local mx        = mouse.x
local my        = mouse.y
local maxDistSq = maxDist * maxDist

local GREEN  = {0,   255, 0}
local RED    = {255, 50,  50}
local GREY   = {80,  80,  80}
local YELLOW = {255, 255, 0}

-- status hint
dx9.DrawString(
    {10, screenH - 20},
    aiming and GREEN or GREY,
    "F4 = menu  |  hold " .. hotkeyVal .. "  |  " .. (aiming and "ACTIVE" or "idle")
)

-- FOV circle
if showfov then
    local col = aiming and GREEN or GREY
    dx9.DrawCircle({mx, my}, col, fov)
    dx9.DrawLine({mx-5, my}, {mx+5, my}, col)
    dx9.DrawLine({mx, my-5}, {mx, my+5}, col)
end

-- ============================================================
--  AIMBOT LOGIC
-- ============================================================
if not enabled then return end
if not aiming  then return end

local bestDist  = (priorityV == "Closest to crosshair") and fov or math.huge
local bestSP    = nil
local bestWorld = nil

for _, p in next, dx9.GetChildren(Players) do
    local name = dx9.GetName(p)

    if name ~= lpName and not _G.aim_whitelist[name] then

        -- team check
        local skipThis = false
        if skipTeam then
            local myTeam     = dx9.GetTeam(
                (function()
                    for _, pl in next, dx9.GetChildren(Players) do
                        if dx9.GetName(pl) == lpName then return pl end
                    end
                end)()
            )
            local theirTeam = dx9.GetTeam(p)
            if myTeam ~= nil and theirTeam ~= nil and myTeam == theirTeam then
                skipThis = true
            end
        end

        if not skipThis then
            local char = dx9.GetCharacter(p)
            if char ~= nil then
                local hum = dx9.FindFirstChildOfClass(char, "Humanoid")
                if hum ~= nil then
                    local hp = dx9.GetHealth(hum)

                    local alive = (hp ~= nil and hp > 0)
                    if skipDead and not alive then alive = false end

                    if alive then
                        local bone = dx9.FindFirstChild(char, boneVal)
                        if bone ~= nil then
                            local pos = dx9.GetPosition(bone)
                            if pos ~= nil then

                                -- distance from local player
                                local lpx = lp.Position.x
                                local lpy = lp.Position.y
                                local lpz = lp.Position.z
                                local wx  = lpx - pos.x
                                local wy  = lpy - pos.y
                                local wz  = lpz - pos.z
                                local wDistSq = wx*wx + wy*wy + wz*wz

                                if wDistSq <= maxDistSq then
                                    local sp = dx9.WorldToScreen({pos.x, pos.y, pos.z})
                                    if sp ~= nil and sp.x ~= nil
                                    and sp.x > 0 and sp.x < screenW
                                    and sp.y > 0 and sp.y < screenH then

                                        if priorityV == "Closest to crosshair" then
                                            local ddx  = sp.x - mx
                                            local ddy  = sp.y - my
                                            local dist = math.sqrt(ddx*ddx + ddy*ddy)
                                            if dist < bestDist then
                                                bestDist  = dist
                                                bestSP    = sp
                                            end
                                        else
                                            -- closest world distance
                                            if wDistSq < bestDist then
                                                local ddx = sp.x - mx
                                                local ddy = sp.y - my
                                                local scr = math.sqrt(ddx*ddx + ddy*ddy)
                                                if scr <= fov then
                                                    bestDist = wDistSq
                                                    bestSP   = sp
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

if bestSP ~= nil then

    -- deadzone check — dont move if already very close
    local dx2  = bestSP.x - mx
    local dy2  = bestSP.y - my
    local near = math.sqrt(dx2*dx2 + dy2*dy2)

    if not deadzone or near > dzSize then
        if modeVal == "Third Person" then
            dx9.ThirdPersonAim(
                {bestSP.x, bestSP.y},
                smooth,
                vsmooth
            )
        else
            dx9.FirstPersonAim(
                {bestSP.x, bestSP.y},
                smooth,
                10
            )
        end
    end

    if showline then
        dx9.DrawLine({mx, my}, {bestSP.x, bestSP.y}, RED)
    end

    if showdot then
        dx9.DrawFilledBox(
            {bestSP.x-3, bestSP.y-3},
            {bestSP.x+3, bestSP.y+3},
            RED
        )
    end
end
