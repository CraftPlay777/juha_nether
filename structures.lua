-- juha_nether | Juha (CraftPlay777)
-- Torres de madera maldita generadas en el nether

local S = juha_nether.S

local NETHER_MIN = -5100

local S_PLANKS = "juha_nether:cursed_planks"
local S_LOG    = "juha_nether:cursed_log"
local S_BLOCK  = "juha_nether:cursed_block"
local S_CHEST  = "juha_nether:cursed_chest"
local AIR      = "air"

local function grid_rand(gx, gz, salt)
    local h = math.abs(gx * 73856093 + gz * 19349663 + salt * 83492791)
    h = h % 2147483647
    h = (h * 1664525 + 1013904223) % 2147483647
    return h / 2147483647
end

-- loot raro (30% de probabilidad)
local loot_rare = {
    {"default:diamond",         2, 5},
    {"default:gold_ingot",      8, 16},
    {"default:goldblock",       1, 3},
    {"default:obsidian",        4, 10},
    {"default:mese_crystal",    3, 8},
    {"default:obsidian_shard",  4, 12},
    {"juha_nether:lighter",     1, 1},
    {"default:sword_diamond",   1, 1},
    {"default:pick_diamond",    1, 1},
    {"default:axe_diamond",     1, 1},
    {"juha_nether:cursed_log",  5, 12},
    {"juha_nether:soul_log",    3, 8},
}

-- loot común (70% de probabilidad)
local loot_common = {
    {"default:gold_ingot",        2, 6},
    {"default:steel_ingot",       3, 8},
    {"default:copper_ingot",      2, 6},
    {"default:bronze_ingot",      2, 5},
    {"juha_nether:cursed_log",    4, 10},
    {"juha_nether:soul_log",      2, 6},
    {"default:sword_steel",       1, 1},
    {"default:pick_steel",        1, 1},
    {"default:axe_steel",         1, 1},
    {"juha_nether:cursed_planks", 8, 16},
    {"juha_nether:soul_planks",   4, 10},
    {"farming:bread",             2, 5},
    {"default:apple",             3, 8},
}

-- rellena el cofre de la cima con loot aleatorio
local function fill_chest(pos)
    local meta = minetest.get_meta(pos)
    local inv  = meta:get_inventory()
    inv:set_size("main", 32)
    meta:set_string("infotext", S("Cursed Wood Chest"))
    meta:set_string("formspec",
        "size[8,9]" ..
        "list[context;main;0,0.3;8,4;]" ..
        "list[current_player;main;0,4.85;8,1;]" ..
        "list[current_player;main;0,6.08;8,3;8]" ..
        "listring[context;main]" ..
        "listring[current_player;main]"
    )
    local pool   = math.random() < 0.30 and loot_rare or loot_common
    local chance = pool == loot_rare and 0.75 or 0.65
    for _, item in ipairs(pool) do
        if math.random() < chance then
            inv:add_item("main", item[1] .. " " .. math.random(item[2], item[3]))
        end
    end
end

-- escalera en espiral interior 5×5
-- piso 0 = entrada | piso 9 = rellano | piso 17 = cima
local SPIRAL = {
    {-1,1,-1}, {0,2,-1}, {1,3,-1}, -- sur → este
    {1,4,0},   {1,5,1},             -- este → norte
    {0,6,1},   {-1,7,1},            -- norte → oeste
    {-1,8,0},  {0,8,0}, {1,8,0},   -- rellano
}

local function place_tower(cx, cy, cz)
    -- base sólida
    for dz = -2, 2 do
        for dx = -2, 2 do
            minetest.set_node({x=cx+dx, y=cy-1, z=cz+dz}, {name=S_BLOCK})
        end
    end

    -- cuerpo: 18 bloques de alto, 5×5 de planta
    for dy = 0, 17 do
        for dz = -2, 2 do
            for dx = -2, 2 do
                local pos      = {x=cx+dx, y=cy+dy, z=cz+dz}
                local is_corner= math.abs(dx)==2 and math.abs(dz)==2
                local is_wall  = math.abs(dx)==2 or math.abs(dz)==2
                local is_floor = dy==0 or dy==9 or dy==17

                if is_corner then
                    minetest.set_node(pos, {name=S_LOG})
                elseif is_wall or is_floor then
                    minetest.set_node(pos, {name=S_PLANKS})
                else
                    minetest.set_node(pos, {name=AIR})
                end
            end
        end
    end

    -- ventanas (1 por pared)
    minetest.set_node({x=cx,   y=cy+4, z=cz+2}, {name=AIR}) -- sur
    minetest.set_node({x=cx,   y=cy+4, z=cz-2}, {name=AIR}) -- norte
    minetest.set_node({x=cx+2, y=cy+4, z=cz},   {name=AIR}) -- este
    minetest.set_node({x=cx-2, y=cy+4, z=cz},   {name=AIR}) -- oeste

    -- entrada (arco de 2 bloques)
    minetest.set_node({x=cx, y=cy,   z=cz+2}, {name=AIR})
    minetest.set_node({x=cx, y=cy+1, z=cz+2}, {name=AIR})

    -- escalera piso 1 → rellano
    for _, s in ipairs(SPIRAL) do
        minetest.set_node({x=cx+s[1], y=cy+s[2],   z=cz+s[3]}, {name=S_BLOCK})
    end
    -- escalera rellano → cima
    for _, s in ipairs(SPIRAL) do
        minetest.set_node({x=cx+s[1], y=cy+s[2]+9, z=cz+s[3]}, {name=S_BLOCK})
    end

    -- cofre en la cima
    local chest_pos = {x=cx, y=cy+16, z=cz}
    minetest.set_node(chest_pos, {name=S_CHEST, param2=0})
    minetest.after(0.2, function() fill_chest(chest_pos) end)
end

-- una torre cada ~80 bloques con presencia determinística (~40% de celdas)
local TOWER_GRID = 80
local np_tower = {
    offset=0, scale=1,
    spread={x=160, y=160, z=160},
    seed=6631, octaves=1, persist=0.5,
}

local placed_towers = {} -- evita duplicados entre chunks solapados

minetest.register_on_generated(function(minp, maxp, seed)
    if maxp.y < NETHER_MIN or minp.y > NETHER_MIN + 60 then return end

    local pn  = minetest.get_perlin(np_tower)
    local gx0 = math.floor(minp.x / TOWER_GRID) * TOWER_GRID
    local gz0 = math.floor(minp.z / TOWER_GRID) * TOWER_GRID

    for gz = gz0, maxp.z + TOWER_GRID, TOWER_GRID do
        for gx = gx0, maxp.x + TOWER_GRID, TOWER_GRID do
            if pn:get2d({x=gx, y=gz}) < 0.10 then goto skip end

            local jx = math.floor(grid_rand(gx, gz, 20) * (TOWER_GRID-16)) - (TOWER_GRID/2-8)
            local jz = math.floor(grid_rand(gx, gz, 21) * (TOWER_GRID-16)) - (TOWER_GRID/2-8)
            local tx = gx + jx
            local tz = gz + jz

            if tx < minp.x or tx > maxp.x
            or tz < minp.z or tz > maxp.z then goto skip end

            local key = gx .. ":" .. gz
            if placed_towers[key] then goto skip end
            placed_towers[key] = true

            local emin = {x=tx-3, y=NETHER_MIN-2, z=tz-3}
            local emax = {x=tx+3, y=NETHER_MIN+60, z=tz+3}
            minetest.emerge_area(emin, emax, function(_, _, remaining)
                if remaining ~= 0 then return end
                local surface_y = NETHER_MIN + 5
                for y = NETHER_MIN+40, NETHER_MIN, -1 do
                    local n = minetest.get_node({x=tx, y=y, z=tz}).name
                    if n ~= AIR and n ~= "default:lava_source" then
                        surface_y = y + 1
                        break
                    end
                end
                place_tower(tx, surface_y, tz)
            end)

            ::skip::
        end
    end
end)