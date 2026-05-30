-- ============================================================
--  LOOT ESP
-- ============================================================
local Lib = loadstring(dx9.Get("https://raw.githubusercontent.com/soupg/DXLibUI/main/main.lua"))()

local DataModel = dx9.GetDatamodel()
local Workspace = dx9.FindFirstChild(DataModel, "Workspace")
local Chunks    = dx9.FindFirstChild(Workspace, "Chunks")

-- ============================================================
--  TOGGLE STORAGE
-- ============================================================
local T = {}

-- ============================================================
--  WINDOW + TABS (first run only)
-- ============================================================
if Lib.FirstRun then
    local Window = Lib:CreateWindow({
        Title         = "loot esp",
        Index         = "loot_esp_win",
        Resizable     = true,
        ToggleKey     = "[F2]",
        StartLocation = {300, 200},
        FooterToggle  = true,
    })

    local TabVisuals = Window:AddTab("Visuals")
    local TabLoot    = Window:AddTab("Loot")
    local TabAmmo    = Window:AddTab("Ammo")
    TabVisuals:Focus()

    local GbEsp   = TabVisuals:AddLeftGroupbox("ESP")
    local GbStyle = TabVisuals:AddRightGroupbox("Style")

    T.esp_enabled = GbEsp:AddToggle({ Index="esp_enabled", Default=true,  Text="Enable ESP" })
    T.esp_boxes   = GbEsp:AddToggle({ Index="esp_boxes",   Default=true,  Text="Show Boxes" })
    T.esp_tracers = GbEsp:AddToggle({ Index="esp_tracers", Default=false, Text="Show Tracers" })
    T.esp_names   = GbEsp:AddToggle({ Index="esp_names",   Default=true,  Text="Show Names" })
    T.esp_dist    = GbEsp:AddToggle({ Index="esp_dist",    Default=true,  Text="Show Distance" })

    T.esp_maxdist = GbStyle:AddSlider({ Index="esp_maxdist", Default=500, Text="Max Distance", Min=50, Max=2000, Suffix=" st", Rounding=0 })
    T.esp_boxcol  = GbStyle:AddColorPicker({ Index="esp_boxcol",  Default={255,255,0}, Text="Box Colour" })
    T.esp_textcol = GbStyle:AddColorPicker({ Index="esp_textcol", Default={255,255,0}, Text="Text Colour" })

    local GbWeapons    = TabLoot:AddLeftGroupbox("Weapons")
    local GbMisc       = TabLoot:AddLeftGroupbox("Misc")
    local GbHealth     = TabLoot:AddRightGroupbox("Health")
    local GbContainers = TabLoot:AddRightGroupbox("Containers")

    T.cat_ar      = GbWeapons:AddToggle({ Index="cat_ar",      Default=true, Text="Assault Rifles" })
    T.cat_br      = GbWeapons:AddToggle({ Index="cat_br",      Default=true, Text="Battle Rifles" })
    T.cat_lmg     = GbWeapons:AddToggle({ Index="cat_lmg",     Default=true, Text="LMGs" })
    T.cat_smg     = GbWeapons:AddToggle({ Index="cat_smg",     Default=true, Text="SMGs" })
    T.cat_pistol  = GbWeapons:AddToggle({ Index="cat_pistol",  Default=true, Text="Pistols" })
    T.cat_sniper  = GbWeapons:AddToggle({ Index="cat_sniper",  Default=true, Text="Snipers" })
    T.cat_shotgun = GbWeapons:AddToggle({ Index="cat_shotgun", Default=true, Text="Shotguns" })

    T.cat_special = GbMisc:AddToggle({ Index="cat_special", Default=true, Text="Special" })
    T.cat_c4      = GbMisc:AddToggle({ Index="cat_c4",      Default=true, Text="C4" })
    T.cat_c4det   = GbMisc:AddToggle({ Index="cat_c4det",   Default=true, Text="C4 Detonator" })

    T.health_bloodbag    = GbHealth:AddToggle({ Index="health_bloodbag",    Default=true, Text="Blood Bag" })
    T.health_painkickers = GbHealth:AddToggle({ Index="health_painkickers", Default=true, Text="Painkickers" })

    T.cat_daypacks = GbContainers:AddToggle({ Index="cat_daypacks", Default=true, Text="Daypacks" })
    T.cat_milpacks = GbContainers:AddToggle({ Index="cat_milpacks", Default=true, Text="Military Backpacks" })

    local GbRifleAmmo  = TabAmmo:AddLeftGroupbox("Rifle Ammo")
    local GbLMGAmmo    = TabAmmo:AddLeftGroupbox("LMG Ammo")
    local GbPistolAmmo = TabAmmo:AddRightGroupbox("Pistol / SMG Ammo")

    T.ammo_ak47_30    = GbRifleAmmo:AddToggle({ Index="ammo_ak47_30",    Default=false, Text="AK47 Ammo 30" })
    T.ammo_ak47_40    = GbRifleAmmo:AddToggle({ Index="ammo_ak47_40",    Default=false, Text="AK47 Ammo 40" })
    T.ammo_ak_45      = GbRifleAmmo:AddToggle({ Index="ammo_ak_45",      Default=false, Text="AK Ammo 45" })
    T.ammo_ak_75      = GbRifleAmmo:AddToggle({ Index="ammo_ak_75",      Default=false, Text="AK Ammo 75" })
    T.ammo_stanag_50  = GbRifleAmmo:AddToggle({ Index="ammo_stanag_50",  Default=false, Text="STANAG Ammo 50" })
    T.ammo_stanag_100 = GbRifleAmmo:AddToggle({ Index="ammo_stanag_100", Default=false, Text="STANAG Ammo 100" })
    T.ammo_m14_50     = GbRifleAmmo:AddToggle({ Index="ammo_m14_50",     Default=false, Text="M14 Ammo 50" })
    T.ammo_m14_30     = GbRifleAmmo:AddToggle({ Index="ammo_m14_30",     Default=false, Text="M14 Ammo 30" })
    T.ammo_m14_20     = GbRifleAmmo:AddToggle({ Index="ammo_m14_20",     Default=false, Text="M14 Ammo 20" })

    T.ammo_mk48_100 = GbLMGAmmo:AddToggle({ Index="ammo_mk48_100", Default=false, Text="MK48 Ammo 100" })
    T.ammo_m249_100 = GbLMGAmmo:AddToggle({ Index="ammo_m249_100", Default=false, Text="M249 Ammo 100" })
    T.ammo_pkp_200  = GbLMGAmmo:AddToggle({ Index="ammo_pkp_200",  Default=false, Text="PKP Ammo 200" })

    T.ammo_tec9_32 = GbPistolAmmo:AddToggle({ Index="ammo_tec9_32", Default=false, Text="TEC9 Ammo 32" })
    T.ammo_tec9_50 = GbPistolAmmo:AddToggle({ Index="ammo_tec9_50", Default=false, Text="TEC9 Ammo 50" })
    T.ammo_m9_50   = GbPistolAmmo:AddToggle({ Index="ammo_m9_50",   Default=false, Text="M9 Ammo 50" })
    T.ammo_m9_32   = GbPistolAmmo:AddToggle({ Index="ammo_m9_32",   Default=false, Text="M9 Ammo 32" })
    T.ammo_ppsh_75 = GbPistolAmmo:AddToggle({ Index="ammo_ppsh_75", Default=false, Text="PPSH Ammo 75" })
end

-- ============================================================
--  LOOT TABLES
-- ============================================================
local ASSAULT_RIFLES = { ["AKM"]=true,["AK-104"]=true,["M4A1"]=true,["Fedorov"]=true,["AK-47"]=true,["G36K"]=true,["AK-12"]=true }
local BATTLE_RIFLES  = { ["M14"]=true,["HK-417"]=true,["MK-17"]=true,["Enfield"]=true,["FAL"]=true }
local LMGS           = { ["MK-48"]=true,["M249"]=true,["RPK"]=true,["PKP"]=true }
local SMGS           = { ["CBJ-MS"]=true,["TEC-9"]=true,["PPSH"]=true,["Patriot"]=true }
local PISTOLS        = { ["Makarov"]=true,["M93R"]=true,["G18"]=true,["Model 459"]=true,["C275"]=true }
local SNIPERS        = { ["Mosin Nagant"]=true }
local SHOTGUNS       = { ["Auto-5"]=true }
local SPECIAL        = { ["Umbrella"]=true,["Sword"]=true,["ToolBox"]=true }
local C4             = { ["C4"]=true }
local C4DET          = { ["C4 Detonator"]=true }
local DAYPACKS       = { ["Red Daypack"]=true,["Black Daypack"]=true,["Yellow Daypack"]=true,["Gray Daypack"]=true,["Blue Daypack"]=true }
local MILPACKS       = { ["White Military Backpack"]=true,["Brown Military Backpack"]=true,["Blue Military Backpack"]=true,["Green Military Backpack"]=true }

local CAT_FLAGS = {
    { flag="cat_ar",       items=ASSAULT_RIFLES },
    { flag="cat_br",       items=BATTLE_RIFLES  },
    { flag="cat_lmg",      items=LMGS           },
    { flag="cat_smg",      items=SMGS           },
    { flag="cat_pistol",   items=PISTOLS        },
    { flag="cat_sniper",   items=SNIPERS        },
    { flag="cat_shotgun",  items=SHOTGUNS       },
    { flag="cat_special",  items=SPECIAL        },
    { flag="cat_c4",       items=C4             },
    { flag="cat_c4det",    items=C4DET          },
    { flag="cat_daypacks", items=DAYPACKS       },
    { flag="cat_milpacks", items=MILPACKS       },
}

local AMMO_FLAGS = {
    { flag="ammo_ak47_30",    name="AK47Ammo30"    },
    { flag="ammo_ak47_40",    name="AK47Ammo40"    },
    { flag="ammo_ak_45",      name="AKAmmo45"      },
    { flag="ammo_ak_75",      name="AKAmmo75"      },
    { flag="ammo_stanag_50",  name="STANAGAmmo50"  },
    { flag="ammo_stanag_100", name="STANAGAmmo100" },
    { flag="ammo_m14_50",     name="M14Ammo50"     },
    { flag="ammo_m14_30",     name="M14Ammo30"     },
    { flag="ammo_m14_20",     name="M14Ammo20"     },
    { flag="ammo_mk48_100",   name="MK48Ammo100"   },
    { flag="ammo_m249_100",   name="M249Ammo100"   },
    { flag="ammo_pkp_200",    name="PKPAmmo200"     },
    { flag="ammo_tec9_32",    name="TEC9Ammo32"    },
    { flag="ammo_tec9_50",    name="TEC9Ammo50"    },
    { flag="ammo_m9_50",      name="M9Ammo50"      },
    { flag="ammo_m9_32",      name="M9Ammo32"      },
    { flag="ammo_ppsh_75",    name="PPSHAmmo75"    },
}

local HEALTH_FLAGS = {
    { flag="health_bloodbag",    name="Blood Bag"   },
    { flag="health_painkickers", name="Painkickers" },
}

-- ============================================================
--  PER FRAME
-- ============================================================
local screenW = dx9.size().width
local screenH = dx9.size().height

dx9.DrawString({screenW-110, screenH-26}, {255,255,255}, "ping: "..dx9.GetPing().."ms")

if not T.esp_enabled or not T.esp_enabled.Value then return end
if not Chunks then return end

local lp = dx9.get_localplayer()
if lp == nil then return end

local ACTIVE = {}
for _, cat in next, CAT_FLAGS do
    if T[cat.flag] and T[cat.flag].Value then
        for k in next, cat.items do ACTIVE[k] = true end
    end
end
for _, ammo in next, AMMO_FLAGS do
    if T[ammo.flag] and T[ammo.flag].Value then ACTIVE[ammo.name] = true end
end
for _, h in next, HEALTH_FLAGS do
    if T[h.flag] and T[h.flag].Value then ACTIVE[h.name] = true end
end

local lpx       = lp.Position.x
local lpy       = lp.Position.y
local lpz       = lp.Position.z
local maxDist   = (T.esp_maxdist and T.esp_maxdist.Value) or 500
local maxDistSq = maxDist * maxDist
local boxCol    = (T.esp_boxcol  and T.esp_boxcol.Value)  or {255,255,0}
local textCol   = (T.esp_textcol and T.esp_textcol.Value) or {255,255,0}
local cx        = screenW / 2

for _, chunk in next, dx9.GetChildren(Chunks) do
    for _, item in next, dx9.GetChildren(chunk) do
        local name = dx9.GetName(item)
        if ACTIVE[name] then
            local part = nil
            for _, child in next, dx9.GetChildren(item) do
                local t = dx9.GetType(child)
                if t=="Part" or t=="MeshPart" or t=="UnionOperation" then
                    part = child; break
                end
            end
            if part == nil then part = item end
            local pos = dx9.GetPosition(part)
            if pos ~= nil then
                local ddx    = lpx - pos.x
                local ddy    = lpy - pos.y
                local ddz    = lpz - pos.z
                local distSq = ddx*ddx + ddy*ddy + ddz*ddz
                if distSq <= maxDistSq then
                    local dist = math.floor(math.sqrt(distSq))
                    local sp   = dx9.WorldToScreen({pos.x, pos.y, pos.z})
                    if sp ~= nil and sp.x ~= nil
                    and sp.x > 0 and sp.x < screenW
                    and sp.y > 0 and sp.y < screenH then
                        local bs = 14
                        if T.esp_boxes   and T.esp_boxes.Value   then dx9.DrawBox({sp.x-bs,sp.y-bs},{sp.x+bs,sp.y+bs},boxCol) end
                        if T.esp_tracers and T.esp_tracers.Value then dx9.DrawLine({cx,screenH},{sp.x,sp.y},boxCol) end
                        if T.esp_names   and T.esp_names.Value   then dx9.DrawString({sp.x-10,sp.y-bs-14},textCol,name) end
                        if T.esp_dist    and T.esp_dist.Value    then dx9.DrawString({sp.x-10,sp.y-bs-4},{255,255,255},dist.."m") end
                    end
                end
            end
        end
    end
end
