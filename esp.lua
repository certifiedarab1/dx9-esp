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
local tab_ammo = window:tab({ name="ammo" })

-- ============================================================
--  LOOT TAB
-- ============================================================
local col_left  = tab_loot:column()
local col_right = tab_loot:column()

local s_set = col_left:section({ name="settings" })
s_set:toggle({ name="enabled",  flag="esp_enabled",  default=true })
s_set:toggle({ name="boxes",    flag="esp_boxes",    default=true })
s_set:toggle({ name="tracers",  flag="esp_tracers",  default=false })
s_set:toggle({ name="names",    flag="esp_names",    default=true })
s_set:toggle({ name="distance", flag="esp_dist",     default=true })
s_set:slider({ name="max dist", flag="esp_maxdist",  min=50, max=2000, default=500, interval=50, suffix=" st" })

local s_col = col_left:section({ name="colours" })
s_col:dropdown({ name="box colour",  flag="esp_boxcol",  items={"yellow","red","green","white","cyan"} })
s_col:dropdown({ name="text colour", flag="esp_textcol", items={"yellow","red","green","white","cyan"} })

local s_cat = col_right:section({ name="categories" })
s_cat:toggle({ name="assault rifles", flag="cat_ar",      default=true })
s_cat:toggle({ name="battle rifles",  flag="cat_br",      default=true })
s_cat:toggle({ name="lmgs",           flag="cat_lmg",     default=true })
s_cat:toggle({ name="smgs",           flag="cat_smg",     default=true })
s_cat:toggle({ name="pistols",        flag="cat_pistol",  default=true })
s_cat:toggle({ name="snipers",        flag="cat_sniper",  default=true })
s_cat:toggle({ name="shotguns",       flag="cat_shotgun", default=true })
s_cat:toggle({ name="special",        flag="cat_special", default=true })

local s_health = col_right:section({ name="health" })
s_health:toggle({ name="blood bag",   flag="health_bloodbag",    default=true })
s_health:toggle({ name="painkickers", flag="health_painkickers", default=true })

-- ============================================================
--  AMMO TAB
-- ============================================================
local col_ammo_left  = tab_ammo:column()
local col_ammo_right = tab_ammo:column()

local s_ammo_rifle = col_ammo_left:section({ name="rifle ammo" })
s_ammo_rifle:toggle({ name="AK47 Ammo 30",    flag="ammo_ak47_30",    default=false })
s_ammo_rifle:toggle({ name="AK47 Ammo 40",    flag="ammo_ak47_40",    default=false })
s_ammo_rifle:toggle({ name="AK Ammo 45",      flag="ammo_ak_45",      default=false })
s_ammo_rifle:toggle({ name="STANAG Ammo 50",  flag="ammo_stanag_50",  default=false })
s_ammo_rifle:toggle({ name="STANAG Ammo 100", flag="ammo_stanag_100", default=false })
s_ammo_rifle:toggle({ name="M14 Ammo 50",     flag="ammo_m14_50",     default=false })
s_ammo_rifle:toggle({ name="AR10 Ammo 30",    flag="ammo_ar10_30",    default=false })
s_ammo_rifle:toggle({ name="M3 Ammo 30",      flag="ammo_m3_30",      default=false })

local s_ammo_lmg = col_ammo_left:section({ name="lmg ammo" })
s_ammo_lmg:toggle({ name="MK48 Ammo 100", flag="ammo_mk48_100", default=false })
s_ammo_lmg:toggle({ name="M249 Ammo 100", flag="ammo_m249_100", default=false })
s_ammo_lmg:toggle({ name="PKP Ammo 200",  flag="ammo_pkp_200",  default=false })

local s_ammo_pistol = col_ammo_right:section({ name="pistol / smg ammo" })
s_ammo_pistol:toggle({ name="TEC9 Ammo 32",    flag="ammo_tec9_32",  default=false })
s_ammo_pistol:toggle({ name="TEC9 Ammo 50",    flag="ammo_tec9_50",  default=false })
s_ammo_pistol:toggle({ name="M9 Ammo 50",      flag="ammo_m9_50",    default=false })
s_ammo_pistol:toggle({ name="PP19 Ammo 64",    flag="ammo_pp19_64",  default=false })
s_ammo_pistol:toggle({ name="PPSH Ammo 75",    flag="ammo_ppsh_75",  default=false })
s_ammo_pistol:toggle({ name="M1911 Ammo 7",    flag="ammo_m1911_7",  default=false })
s_ammo_pistol:toggle({ name="Maverick Ammo 6", flag="ammo_mav_6",    default=false })
s_ammo_pistol:toggle({ name="Ruger22 Ammo 10", flag="ammo_ruger_10", default=false })

-- ============================================================
--  LOOT TABLES
-- ============================================================
local ASSAULT_RIFLES = {
    ["AKM"]=true,["AK-104"]=true,["M4A1"]=true,
    ["Fedorov"]=true,["AK-47"]=true,["G36K"]=true,
    ["AK-12"]=true,
}
local BATTLE_RIFLES = {
    ["M14"]=true,["HK-417"]=true,["MK-17"]=true,["Enfield"]=true,
    ["FAL"]=true,
}
local LMGS = {
    ["MK-48"]=true,["M249"]=true,["RPK"]=true,["PKP"]=true,
}
local SMGS = {
    ["CBJ-MS"]=true,["TEC-9"]=true,["PPSH"]=true,["Patriot"]=true,
}
local PISTOLS = {
    ["Makarov"]=true,["M93R"]=true,["G18"]=true,
    ["Model 459"]=true,["C275"]=true,
}
local SNIPERS  = { ["Mosin Nagant"]=true }
local SHOTGUNS = { ["Auto-5"]=true }
local SPECIAL  = {
    ["Umbrella"]=true,["Brown Military Backpack"]=true,
    ["Green Military Backpack"]=true,["Sword"]=true,
}

local CAT_FLAGS = {
    { flag="cat_ar",      items=ASSAULT_RIFLES },
    { flag="cat_br",      items=BATTLE_RIFLES  },
    { flag="cat_lmg",     items=LMGS           },
    { flag="cat_smg",     items=SMGS           },
    { flag="cat_pistol",  items=PISTOLS        },
    { flag="cat_sniper",  items=SNIPERS        },
    { flag="cat_shotgun", items=SHOTGUNS       },
    { flag="cat_special", items=SPECIAL        },
}

local AMMO_FLAGS = {
    { flag="ammo_ak47_30",    name="AK47Ammo30"    },
    { flag="ammo_ak47_40",    name="AK47Ammo40"    },
    { flag="ammo_ak_45",      name="AKAmmo45"      },
    { flag="ammo_stanag_50",  name="STANAGAmmo50"  },
    { flag="ammo_stanag_100", name="STANAGAmmo100" },
    { flag="ammo_m14_50",     name="M14Ammo50"     },
    { flag="ammo_m14_20",     name="M14Ammo20"     },
    { flag="ammo_ar10_30",    name="AR10Ammo30"    },
    { flag="ammo_m3_30",      name="M3Ammo30"      },
    { flag="ammo_mk48_100",   name="MK48Ammo100"   },
    { flag="ammo_m249_100",   name="M249Ammo100"   },
    { flag="ammo_pkp_200",    name="PKPAmmo200"    },
    { flag="ammo_tec9_32",    name="TEC9Ammo32"    },
    { flag="ammo_tec9_50",    name="TEC9Ammo50"    },
    { flag="ammo_m9_50",      name="M9Ammo50"      },
    { flag="ammo_pp19_64",    name="PP19Ammo64"    },
    { flag="ammo_ppsh_75",    name="PPSHAmmo75"    },
    { flag="ammo_m1911_7",    name="M1911Ammo7"    },
    { flag="ammo_mav_6",      name="MavericAmmo6"  },
    { flag="ammo_ruger_10",   name="Ruger22Ammo10" },
}

local HEALTH_FLAGS = {
    { flag="health_bloodbag",    name="Blood Bag"   },
    { flag="health_painkickers", name="Painkickers" },
}

local COLOURS = {
    ["yellow"]={255,255,0},["red"]={255,0,0},
    ["green"]={0,255,0},["white"]={255,255,255},["cyan"]={0,255,255},
}

-- ============================================================
--  RENDER
-- ============================================================
window:Render()

-- ============================================================
--  ESP LOGIC
-- ============================================================
if not library.flags.esp_enabled then return end

local ACTIVE = {}
for _, cat in next, CAT_FLAGS do
    if library.flags[cat.flag] then
        for k, v in next, cat.items do ACTIVE[k] = v end
    end
end
for _, ammo in next, AMMO_FLAGS do
    if library.flags[ammo.flag] then ACTIVE[ammo.name] = true end
end
for _, h in next, HEALTH_FLAGS do
    if library.flags[h.flag] then ACTIVE[h.name] = true end
end

local screenW   = dx9.size().width
local screenH   = dx9.size().height
local cx        = screenW / 2
local lp        = dx9.get_localplayer()
if lp == nil then return end
local lpx       = lp.Position.x
local lpy       = lp.Position.y
local lpz       = lp.Position.z
local maxDist   = library.flags.esp_maxdist or 500
local maxDistSq = maxDist * maxDist
local boxCol    = COLOURS[library.flags.esp_boxcol  or "yellow"]
local textCol   = COLOURS[library.flags.esp_textcol or "yellow"]
local distCol   = {255,255,255}

for _, chunk in next, dx9.GetChildren(Chunks) do
    for _, item in next, dx9.GetChildren(chunk) do
        local name = dx9.GetName(item)
        if ACTIVE[name] then
            local part = nil
            for _, child in next, dx9.GetChildren(item) do
                local t = dx9.GetType(child)
                if t=="Part" or t=="MeshPart" or t=="UnionOperation" then
                    part = child
                    break
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
                        if library.flags.esp_boxes then
                            dx9.DrawBox({sp.x-bs,sp.y-bs},{sp.x+bs,sp.y+bs},boxCol)
                        end
                        if library.flags.esp_tracers then
                            dx9.DrawLine({cx,screenH},{sp.x,sp.y},boxCol)
                        end
                        if library.flags.esp_names then
                            dx9.DrawString({sp.x-10,sp.y-bs-14},textCol,name)
                        end
                        if library.flags.esp_dist then
                            dx9.DrawString({sp.x-10,sp.y-bs-4},distCol,dist.."m")
                        end
                    end
                end
            end
        end
    end
end
