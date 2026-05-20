-- juha_nether | Juha (CraftPlay777)
-- Generación de árboles malditos y sin alma

local c_log, c_leaves, c_air
local c_soul_log, c_soul_leaves

minetest.register_on_mods_loaded(function()
    c_log        = minetest.get_content_id("juha_nether:cursed_log")
    c_leaves     = minetest.get_content_id("juha_nether:cursed_leaves")
    c_air        = minetest.get_content_id("air")
    c_soul_log   = minetest.get_content_id("juha_nether:soul_log")
    c_soul_leaves= minetest.get_content_id("juha_nether:soul_leaves")
end)

-- árbol maldito (altura 4-6, copa circular)
function juha_nether.grow_tree(pos, data, area, emin, emax)
    local height = math.random(4, 6)

    for i = 0, height do
        local ty = pos.y + i
        if ty <= emax.y then
            data[area:index(pos.x, ty, pos.z)] = c_log
        end
    end

    local top = pos.y + height
    local radios = {[0]=2, [1]=2, [2]=1, [3]=1}
    for dy, r in pairs(radios) do
        local ly = top + dy - 1
        if ly > emax.y then break end
        for dz = -r, r do
            for dx = -r, r do
                if dx*dx + dz*dz <= r*r + 1 then
                    local lx, lz = pos.x+dx, pos.z+dz
                    if lx >= emin.x and lx <= emax.x and
                       lz >= emin.z and lz <= emax.z and
                       ly >= emin.y and ly <= emax.y then
                        local vi = area:index(lx, ly, lz)
                        if data[vi] == c_air then
                            data[vi] = c_leaves
                        end
                    end
                end
            end
        end
    end
end

-- árbol sin alma (altura 5-7, copa más grande)
function juha_nether.grow_soul_tree(pos, data, area, emin, emax)
    local height = math.random(5, 7)

    for i = 0, height do
        local ty = pos.y + i
        if ty <= emax.y then
            data[area:index(pos.x, ty, pos.z)] = c_soul_log
        end
    end

    local top = pos.y + height
    local radios = {[0]=2, [1]=2, [2]=2, [3]=1, [4]=1}
    for dy, r in pairs(radios) do
        local ly = top + dy - 1
        if ly > emax.y then break end
        for dz = -r, r do
            for dx = -r, r do
                if dx*dx + dz*dz <= r*r + 1 then
                    local lx, lz = pos.x+dx, pos.z+dz
                    if lx >= emin.x and lx <= emax.x and
                       lz >= emin.z and lz <= emax.z and
                       ly >= emin.y and ly <= emax.y then
                        local vi = area:index(lx, ly, lz)
                        if data[vi] == c_air then
                            data[vi] = c_soul_leaves
                        end
                    end
                end
            end
        end
    end
end
