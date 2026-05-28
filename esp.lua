local DataModel = dx9.GetDatamodel()
local Workspace = dx9.FindFirstChild(DataModel, "Workspace")
local Chunks = dx9.FindFirstChild(Workspace, "Chunks")

-- ============================================================
--  CONFIG
-- ============================================================
local CONFIG = {
    maxDistance = 10000,
    boxColour   = {255, 255, 0},
    boxSize     = 14,
    textColour  = {255, 255, 0},
    distColour  = {255, 255, 255},
}

-- ============================================================
--  WHITELIST
-- ============================================================

-- Assault Rifles
local ASSAULT_RIFLES = {
    ["AKM"]    = true,
    ["AK-104"] = true,
    ["M4A1"]   = true,
    ["FAL"]    = true,
    ["Fedorov"]= true,
    ["RPK"]= true,
    ["AK-47"]= true,
    ["G36K"] = true,
}

-- Battle Rifles
local BATTLE_RIFLES = {
    ["M14"]    = true,
    ["HK-417"] = true,
    ["MK-17"]  = true,
    ["Enfield"] = true,
}

-- Light Machine Guns
local LMGS = {
    ["MK-48"] = true,
    ["M249"]  = true,
    ["RPK"]   = true,
    ["PKP"]   = true,

}

-- Submachine Guns
local SMGS = {
    ["CBJ-MS"] = true,
    ["TEC-9"]  = true,
    ["PPSH"]   = true,
    ["Patriot"]= true,
}

-- Pistols
local PISTOLS = {
    ["Makarov"]   = true,
    ["M93R"]      = true,
    ["G18"]       = true,
    ["Model 459"] = true,
    ["C275"]   = true,
}

-- Sniper Rifles
local SNIPERS = {
    ["Mosin Nagant"] = true,
    ["Stunna"]       = true,
}

-- Shotguns
local SHOTGUNS = {
    ["Auto-5"] = true,
}

-- Melee / Special
local SPECIAL = {
    ["Umbrella"] = true,
    ["Brown Military Backpack"] = true,
}

-- Ammo
local AMMO = {
    ["PPSHAmmo75"]    = true,
    ["M14Ammo50"]     = true,
    ["STANAGAmmo100"] = true,
    ["STANAGAmmo50"] = true,
    ["MK48Ammo100"]   = true,
    ["M249Ammo100"]   = true,
    ["PKPAmmo200"]   = true,
    ["AKAmmo45"]   = true,
    ["TEC9Ammo32"]   = true,
    ["TEC9Ammo50"] = true,
    ["AK47Ammo40"] = true,
    ["M9Ammo50"] = true,

}

-- ============================================================
--  MERGE ALL INTO ONE LOOKUP
-- ============================================================
local GUNS = {}
local function merge(t)
    for k, v in next, t do GUNS[k] = v end
end

merge(ASSAULT_RIFLES)
merge(BATTLE_RIFLES)
merge(LMGS)
merge(SMGS)
merge(PISTOLS)
merge(SNIPERS)
merge(SHOTGUNS)
merge(SPECIAL)
merge(AMMO)

-- ============================================================
--  SCREEN + LOCAL PLAYER
-- ============================================================
local screenW = dx9.size().width
local screenH = dx9.size().height

local lp  = dx9.get_localplayer()
local lpx = lp.Position.x
local lpy = lp.Position.y
local lpz = lp.Position.z

local maxDist   = CONFIG.maxDistance
local maxDistSq = maxDist * maxDist

-- ============================================================
--  MAIN LOOP
-- ============================================================
for _, chunk in next, dx9.GetChildren(Chunks) do
    for _, item in next, dx9.GetChildren(chunk) do
        local name = dx9.GetName(item)

        if GUNS[name] then
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
                local ddx = lpx - pos.x
                local ddy = lpy - pos.y
                local ddz = lpz - pos.z
                local distSq = ddx*ddx + ddy*ddy + ddz*ddz

                if distSq <= maxDistSq then
                    local dist = math.floor(math.sqrt(distSq))
                    local sp = dx9.WorldToScreen({pos.x, pos.y, pos.z})

                    if sp ~= nil
                    and sp.x ~= nil
                    and sp.x > 0 and sp.x < screenW
                    and sp.y > 0 and sp.y < screenH then

                        local bs = CONFIG.boxSize

                        -- Yellow box
                        dx9.DrawBox(
                            {sp.x - bs, sp.y - bs},
                            {sp.x + bs, sp.y + bs},
                            CONFIG.boxColour
                        )

                        -- Yellow gun name
                        dx9.DrawString(
                            {sp.x - 10, sp.y - bs - 14},
                            CONFIG.textColour,
                            name
                        )

                        -- White distance
                        dx9.DrawString(
                            {sp.x - 10, sp.y - bs - 4},
                            CONFIG.distColour,
                            dist .. "m"
                        )
                    end
                end
            end
        end
    end
end
