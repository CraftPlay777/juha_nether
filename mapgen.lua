-- juha_nether | Juha (CraftPlay777)
-- Generación de terreno y biomas del nether

local NETHER_MIN = -5100
local NETHER_MAX = -5000

local c_sand, c_lava, c_air, c_stone, c_cursed_stone

minetest.register_on_mods_loaded(function()
    c_sand         = minetest.get_content_id("juha_nether:cursed_sand")
    c_lava         = minetest.get_content_id("default:lava_source")
    c_air          = minetest.get_content_id("air")
    c_stone        = minetest.get_content_id("default:stone")
    c_cursed_stone = minetest.get_content_id("juha_nether:cursed_stone")
end)

-- ruido 2D: altura del piso de arena
local np_floor = {
    offset = 0, scale = 4,
    spread = {x=60, y=60, z=60},
    seed = 4477, octaves = 3, persist = 0.5,
}

-- ruido 3D: volumen de piedra maldita y cuevas
local np_cave = {
    offset = 0, scale = 1,
    spread = {x=40, y=20, z=40},
    seed = 8812, octaves = 3, persist = 0.5,
}

-- bioma de bosque maldito normal
local np_biome = {
    offset = 0, scale = 1,
    spread = {x=350, y=350, z=350},
    seed = 3317, octaves = 2, persist = 0.4,
}

-- mega-bioma de bosque maldito (más raro, más denso)
local np_mega = {
    offset = 0, scale = 1,
    spread = {x=900, y=900, z=900},
    seed = 7741, octaves = 1, persist = 0.5,
}

-- bioma de bosque sin alma
local np_soul = {
    offset = 0, scale = 1,
    spread = {x=400, y=400, z=400},
    seed = 5532, octaves = 2, persist = 0.4,
}

-- hash determinístico para posición de árboles sin costuras entre chunks
local function grid_rand(gx, gz, salt)
    local h = math.abs(gx * 73856093 + gz * 19349663 + salt * 83492791)
    h = h % 2147483647
    h = (h * 1664525 + 1013904223) % 2147483647
    return h / 2147483647
end

minetest.register_on_generated(function(minp, maxp, seed)
    if maxp.y < NETHER_MIN or minp.y > NETHER_MAX then return end

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
    local data = vm:get_data()

    local sx = maxp.x - minp.x + 1
    local sy = maxp.y - minp.y + 1
    local sz = maxp.z - minp.z + 1 -- luacheck: ignore

    local nobj_floor = minetest.get_perlin_map(np_floor, {x=sx, y=sz})
    local nval_floor = nobj_floor:get2dMap_flat({x=minp.x, y=minp.z})

    local nobj_cave = minetest.get_perlin_map(np_cave, {x=sx, y=sy, z=sz})
    local nval_cave = nobj_cave:get3dMap_flat(minp)

    -- mapa de piso por columna (para pasada 2 y árboles)
    local floor_map = {}
    local ni2 = 1
    for z = minp.z, maxp.z do
        floor_map[z] = {}
        for x = minp.x, maxp.x do
            floor_map[z][x] = NETHER_MIN + 3 + math.floor(nval_floor[ni2])
            ni2 = ni2 + 1
        end
    end

    -- pasada 1: piedra maldita, lava y aire (sin arena todavía)
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local ylo = math.max(minp.y, NETHER_MIN)
            local yhi = math.min(maxp.y, NETHER_MAX)
            for y = ylo, yhi do
                local vi   = area:index(x, y, z)
                local ni3  = (z-minp.z)*sx*sy + (y-minp.y)*sx + (x-minp.x) + 1
                local cave = nval_cave[ni3]

                if y <= NETHER_MIN + 1 then
                    data[vi] = c_lava         -- lago de lava
                elseif y >= NETHER_MAX - 2 then
                    data[vi] = c_stone        -- techo sólido
                elseif cave > 0.10 then
                    data[vi] = c_cursed_stone -- volumen sólido
                else
                    data[vi] = c_air          -- cueva
                end
            end
        end
    end

    -- pasada 2: arena solo encima de piedra maldita (nunca sobre lava)
    local surf = {}
    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local floor_h  = floor_map[z][x]
            local scan_top = math.min(floor_h + 4, maxp.y)
            local scan_bot = math.max(NETHER_MIN + 2, minp.y)
            local real_surf = nil

            for y = scan_top, scan_bot, -1 do
                local vi = area:index(x, y, z)
                if data[vi] == c_cursed_stone then
                    for s = 1, 2 do
                        local sy2 = y + s
                        if sy2 <= maxp.y then
                            local svi = area:index(x, sy2, z)
                            if data[svi] == c_air then
                                data[svi] = c_sand
                                real_surf = sy2
                            end
                        end
                    end
                    if real_surf == nil then real_surf = y end
                    break
                elseif data[vi] == c_lava then
                    break -- no colocar arena sobre lava
                end
            end

            if not surf[x] then surf[x] = {} end
            surf[x][z] = real_surf or floor_h
        end
    end

    -- bioma de bosque maldito
    local pn_b = minetest.get_perlin(np_biome)
    local pn_m = minetest.get_perlin(np_mega)

    local GRID = 4
    local gx0  = math.floor(minp.x / GRID) * GRID
    local gz0  = math.floor(minp.z / GRID) * GRID

    for gz = gz0, maxp.z + GRID, GRID do
        for gx = gx0, maxp.x + GRID, GRID do
            local bval    = pn_b:get2d({x=gx, y=gz})
            local mval    = pn_m:get2d({x=gx, y=gz})
            local in_mega  = mval > 0.42
            local in_biome = bval > 0.25
            if not (in_mega or in_biome) then goto continue end

            local jx = math.floor(grid_rand(gx, gz, 1) * 3) - 1
            local jz = math.floor(grid_rand(gx, gz, 2) * 3) - 1
            local tx, tz = gx+jx, gz+jz

            if tx < minp.x or tx > maxp.x
            or tz < minp.z or tz > maxp.z then goto continue end

            local sy_val = surf[tx] and surf[tx][tz]
            if not sy_val then goto continue end
            local ty = sy_val + 1
            if ty < minp.y or ty > maxp.y then goto continue end

            if data[area:index(tx, ty, tz)] ~= c_air then goto continue end

            if grid_rand(gx, gz, 3) < (in_mega and 0.04 or 0.20) then goto continue end

            juha_nether.grow_tree({x=tx, y=ty, z=tz}, data, area, emin, emax)

            -- árbol extra en mega-bioma
            if in_mega then
                local hx = gx + math.floor(GRID/2) + math.floor(grid_rand(gx, gz, 4) * 3) - 1
                local hz = gz + math.floor(GRID/2) + math.floor(grid_rand(gx, gz, 5) * 3) - 1
                if hx >= minp.x and hx <= maxp.x and hz >= minp.z and hz <= maxp.z then
                    local sy2 = surf[hx] and surf[hx][hz]
                    if sy2 then
                        local ty2 = sy2 + 1
                        if ty2 >= minp.y and ty2 <= maxp.y then
                            if data[area:index(hx, ty2, hz)] == c_air then
                                juha_nether.grow_tree({x=hx, y=ty2, z=hz}, data, area, emin, emax)
                            end
                        end
                    end
                end
            end

            ::continue::
        end
    end

    -- bioma de bosque sin alma
    local pn_soul = minetest.get_perlin(np_soul)

    local GRID_S = 5
    local gx0s   = math.floor(minp.x / GRID_S) * GRID_S
    local gz0s   = math.floor(minp.z / GRID_S) * GRID_S

    for gz = gz0s, maxp.z + GRID_S, GRID_S do
        for gx = gx0s, maxp.x + GRID_S, GRID_S do
            if pn_soul:get2d({x=gx, y=gz}) <= 0.30 then goto continue_soul end

            local jx = math.floor(grid_rand(gx, gz, 6) * 3) - 1
            local jz = math.floor(grid_rand(gx, gz, 7) * 3) - 1
            local tx, tz = gx+jx, gz+jz

            if tx < minp.x or tx > maxp.x
            or tz < minp.z or tz > maxp.z then goto continue_soul end

            local sy_val = surf[tx] and surf[tx][tz]
            if not sy_val then goto continue_soul end
            local ty = sy_val + 1
            if ty < minp.y or ty > maxp.y then goto continue_soul end

            if data[area:index(tx, ty, tz)] ~= c_air then goto continue_soul end

            if grid_rand(gx, gz, 8) < 0.20 then goto continue_soul end

            juha_nether.grow_soul_tree({x=tx, y=ty, z=tz}, data, area, emin, emax)

            ::continue_soul::
        end
    end

    vm:set_data(data)
    vm:write_to_map()
    vm:update_liquids()
end)
