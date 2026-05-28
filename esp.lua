-- load ui library
loadstring(dx9.Get("https://raw.githubusercontent.com/x8n8x/srp/refs/heads/main/seraph9.lua"))()

-- ============================================================
--  GAME SETUP
-- ============================================================
local DataModel = dx9.GetDatamodel()
local Workspace = dx9.FindFirstChild(DataModel, "Workspace")
local Chunks    = dx9.FindFirstChild(Workspace, "Chunks")

-- ============================================================
--  WINDOW
-- ============================================================
local window   = library:Window({ name="esp", toggle_key="F2" })
local tab_loot = window:tab({ name="loot" })
local tab_cfg  = window:tab({ name="config" })

-- ============================================================
--  LOOT TAB — two columns
-- ============================================================
local col_left  = tab_loot:column()
local col_right = tab_loot:column()

-- LEFT: settings section
local s_set = col_left:section({ name="settings" })
s_set:toggle({ name="enabled",  flag="esp_enabled",  default=true })
s_set:toggle({ name="boxes",    flag="esp_boxes",    default=true })
s_set:toggle({ name="tracers",  flag="esp_tracers",  default=false })
s_set:toggle({ name="names",    flag="esp_names",    default=true })
s_set:toggle({ name="distance", flag="esp_dist",     default=true })
s_set:slider({ name="max dist", flag="esp_maxdist",  min=50, max=2000, default=500, interval=50, suffix=" st" })

-- LEFT: colours section
local s_col = col_left:section({ name="colours" })
s_col:dropdown({ name="box colour",  flag="esp_boxcol",  items={"yellow","red","green","white","cyan"} })
s_col:dropdown({ name="text colour", flag="esp_textcol", items={"yellow","red","green","white","cyan"} })

-- RIGHT: categories section
local s_cat = col_right:section({ name="categories" })
s_cat:toggle({ name="assault rifles", flag="cat_ar",      default=true })
s_cat:toggle({ name="battle rifles",  flag="cat_br",      default=true })
s_cat:toggle({ name="lmgs",           flag="cat_lmg",     default=true })
s_cat:toggle({ name="smgs",           flag="cat_smg",     default=true })
s_cat:toggle({ name="pistols",        flag="cat_pistol",  default=true })
s_cat:toggle({ name="snipers",        flag="cat_sniper",  default=true })
s_cat:toggle({ name="shotguns",       flag="cat_shotgun", default=true })
s_cat:toggle({ name="ammo",           flag="cat_ammo",    default=false })
s_cat:toggle({ name="special",        flag="cat_special", default=true })

-- ============================================================
--  CONFIG TAB
-- ============================================================
local col_cfg   = tab_cfg:column()
local s_info    = col_cfg:section({ name="info" })
s_info:button({ name="github: certifiedarab1", callback=function() end })

-- ============================================================
--  LOOT TABLES
-- ============================================================
local ASSAULT_RIFLES = {
    ["AKM"]    = true, ["AK-104"] = true, ["M4A1"]   = true,
    ["FAL"]    = true, ["Fedorov"]= true, ["AK-47"]  = true,
    ["G36K"]   = true,
}
local BATTLE_RIFLES = {
    ["M14"]     = true, ["HK-417"]  = true,
    ["MK-17"]   = true, ["Enfield"] = true,
}
local LMGS = {
    ["MK-48"] = true, ["M249"] = true,
    ["RPK"]   = true, ["PKP"]  = true,
}
local SMGS = {
    ["CBJ-MS"]  = true, ["TEC-9"]   = true,
    ["PPSH"]    = true, ["Patriot"] = true,
}
local PISTOLS = {
    ["Makarov"]   = true, ["M93R"]      = true,
    ["G18"]       = true, ["Model 459"] = true,
    ["C275"]      = true,
}
local SNIPERS = {
    ["Mosin Nagant"] = true, ["Stunna"] = true,
}
local SHOTGUNS = {
    ["Auto-5"] = true,
}
local SPECIAL = {
    ["Umbrella"]              = true,
    ["Brown Military Backpack"] = true,
    ["Sword"]                 = true,
}
local AMMO = {
    ["PPSHAmmo75"]    = true, ["M14Ammo50"]     = true,
    ["STANAGAmmo100"] = true, ["STANAGAmmo50"]  = true,
    ["MK48Ammo100"]   = true, ["M249Ammo100"]   = true,
    ["PKPAmmo200"]    = true, ["AKAmmo45"]      = true,
    ["TEC9Ammo32"]    = true, ["TEC9Ammo50"]    = true,
    ["AK47Ammo40"]    = true, ["M9Ammo50"]      = true,
    ["AK47Ammo30"]    = true, ["MK48Ammo100"]   = true,
    ["AR10Ammo30"]    = true, ["PP19Ammo64"]    = true,
    ["M1911Ammo7"]    = true, ["MavericAmmo6"]  = true,
    ["Ruger22Ammo10"] = true, ["M249Ammo100"]   = true,
    ["MK48Ammo100"]   = true, ["PKPAmmo200"]    = true,
    ["M3Ammo30"]      = true, ["MK48Ammo100"]   = true,
}

-- category flag map
local CAT_FLAGS = {
    { flag="cat_ar",      items=ASSAULT_RIFLES },
    { flag="cat_br",      items=BATTLE_RIFLES  },
    { flag="cat_lmg",     items=LMGS           },
    { flag="cat_smg",     items=SMGS           },
    { flag="cat_pistol",  items=PISTOLS        },
    { flag="cat_sniper",  items=SNIPERS        },
    { flag="cat_shotgun", items=SHOTGUNS       },
    { flag="cat_special", items=SPECIAL        },
    { flag="cat_ammo",    items=AMMO           },
}

-- colour lookup
local COLOURS = {
    ["yellow"] = {255, 255, 0},
    ["red"]    = {255, 0,   0},
    ["green"]  = {0,   255, 0},
    ["white"]  = {255, 255, 255},
    ["cyan"]   = {0,   255, 255},
}

-- ============================================================
--  RENDER
-- ============================================================
window:Render()

-- ============================================================
--  ESP LOGIC (runs every frame)
-- ============================================================
if not library.flags.esp_enabled then return end

-- build active loot table from enabled categories
local ACTIVE = {}
for _, cat in next, CAT_FLAGS do
    if library.flags[cat.flag] then
        for k, v in next, cat.items do
            ACTIVE[k] = v
        end
    end
end

local screenW   = dx9.size().width
local screenH   = dx9.size().height
local cx        = screenW / 2
local lp        = dx9.get_localplayer()
local lpx       = lp.Position.x
local lpy       = lp.Position.y
local lpz       = lp.Position.z
local maxDist   = library.flags.esp_maxdist or 500
local maxDistSq = maxDist * maxDist
local boxCol    = COLOURS[library.flags.esp_boxcol  or "yellow"]
local textCol   = COLOURS[library.flags.esp_textcol or "yellow"]
local distCol   = {255, 255, 255}

for _, chunk in next, dx9.GetChildren(Chunks) do
    for _, item in next, dx9.GetChildren(chunk) do
        local name = dx9.GetName(item)

        if ACTIVE[name] then
            local part = nil
            for _, child in next, dx9.GetChildren(item) do
                local t = dx9.GetType(child)
                if t == "Part" or t == "MeshPart" or t == "UnionOperation" then
                    part = child
                    break
                end
            end

            if part == nil then part = item end

            local pos = dx9.GetPosition(part)

            if pos ~= nil then
                local ddx   = lpx - pos.x
                local ddy   = lpy - pos.y
                local ddz   = lpz - pos.z
                local distSq = ddx*ddx + ddy*ddy + ddz*ddz

                if distSq <= maxDistSq then
                    local dist = math.floor(math.sqrt(distSq))
                    local sp   = dx9.WorldToScreen({pos.x, pos.y, pos.z})

                    if sp ~= nil
                    and sp.x ~= nil
                    and sp.x > 0 and sp.x < screenW
                    and sp.y > 0 and sp.y < screenH then

                        local bs = 14

                        -- box
                        if library.flags.esp_boxes then
                            dx9.DrawBox(
                                {sp.x - bs, sp.y - bs},
                                {sp.x + bs, sp.y + bs},
                                boxCol
                            )
                        end

                        -- tracer
                        if library.flags.esp_tracers then
                            dx9.DrawLine(
                                {cx, screenH},
                                {sp.x, sp.y},
                                boxCol
                            )
                        end

                        -- name
                        if library.flags.esp_names then
                            dx9.DrawString(
                                {sp.x - 10, sp.y - bs - 14},
                                textCol,
                                name
                            )
                        end

                        -- distance
                        if library.flags.esp_dist then
                            dx9.DrawString(
                                {sp.x - 10, sp.y - bs - 4},
                                distCol,
                                dist .. "m"
                            )
                        end

                    end
                end
            end
        end
    end
end
