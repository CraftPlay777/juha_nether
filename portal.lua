-- juha_nether | Juha (CraftPlay777)
-- Detección, activación y teletransporte del portal

local OBSIDIAN_SET = {
    ["default:obsidian"]     = true,
    ["juha_nether:obsidian"] = true,
}

-- herramientas que pueden encender el portal
local LIGHTER_SET = {
    ["juha_nether:lighter"]  = true,
    ["default:flint_and_steel"] = true,
}

local PORTAL     = "juha_nether:portal"
local NETHER_MIN = -5100
local NETHER_Y   = -5090 -- destino en Y al entrar al nether

function juha_nether.is_obsidian(name)
    return OBSIDIAN_SET[name] == true
end

function juha_nether.is_lighter(name)
    return LIGHTER_SET[name] == true
end

local function adir(axis)
    return axis == "x" and {x=1,y=0,z=0} or {x=0,y=0,z=1}
end

local function get_frame(corner, axis)
    local d, f = adir(axis), {}
    for i = 0, 3 do
        table.insert(f, {x=corner.x+d.x*i, y=corner.y,   z=corner.z+d.z*i})
        table.insert(f, {x=corner.x+d.x*i, y=corner.y+4, z=corner.z+d.z*i})
    end
    for i = 1, 3 do
        table.insert(f, {x=corner.x,       y=corner.y+i, z=corner.z})
        table.insert(f, {x=corner.x+d.x*3, y=corner.y+i, z=corner.z+d.z*3})
    end
    return f
end

local function get_inner(corner, axis)
    local d, inner = adir(axis), {}
    for i = 1, 2 do
        for j = 1, 3 do
            table.insert(inner, {x=corner.x+d.x*i, y=corner.y+j, z=corner.z+d.z*i})
        end
    end
    return inner
end

function juha_nether.find_portal(pos)
    for _, axis in ipairs({"x", "z"}) do
        local d = adir(axis)
        for dw = -3, 0 do
            for dh = -4, 0 do
                local corner = {
                    x = pos.x + d.x * dw,
                    y = pos.y + dh,
                    z = pos.z + d.z * dw,
                }
                local frame = get_frame(corner, axis)
                local ok = true
                for _, fp in ipairs(frame) do
                    if not OBSIDIAN_SET[minetest.get_node(fp).name] then
                        ok = false; break
                    end
                end
                if ok then
                    local inner = get_inner(corner, axis)
                    local clear = true
                    for _, ip in ipairs(inner) do
                        local n = minetest.get_node(ip).name
                        if n ~= "air" and n ~= PORTAL then
                            clear = false; break
                        end
                    end
                    if clear then return corner, axis, inner end
                end
            end
        end
    end
    return nil
end

function juha_nether.activate_portal(inner, axis)
    local p2 = axis == "x" and 0 or 1
    for _, pos in ipairs(inner) do
        minetest.set_node(pos, {name = PORTAL, param2 = p2})
    end
end

function juha_nether.destroy_portal(origin)
    local queue, seen = {origin}, {}
    while #queue > 0 do
        local p = table.remove(queue)
        local k = minetest.pos_to_string(p)
        if not seen[k] then
            seen[k] = true
            if minetest.get_node(p).name == PORTAL then
                minetest.remove_node(p)
                for _, d in ipairs({
                    {1,0,0},{-1,0,0},{0,1,0},{0,-1,0},{0,0,1},{0,0,-1}
                }) do
                    table.insert(queue, {x=p.x+d[1], y=p.y+d[2], z=p.z+d[3]})
                end
            end
        end
    end
end

local function create_portal(corner, axis)
    for _, fp in ipairs(get_frame(corner, axis)) do
        minetest.set_node(fp, {name = "juha_nether:obsidian"})
    end
    juha_nether.activate_portal(get_inner(corner, axis), axis)
end

-- registro del uso del mechero de mt game sobre obsidiana
minetest.after(0, function()
    local def = minetest.registered_tools["default:flint_and_steel"]
    if not def then return end
    local old_on_use = def.on_use
    minetest.override_item("default:flint_and_steel", {
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing.type == "node" then
                local pos = pointed_thing.under
                if juha_nether.is_obsidian(minetest.get_node(pos).name) then
                    local corner, axis, inner = juha_nether.find_portal(pos)
                    if corner then
                        juha_nether.activate_portal(inner, axis)
                        minetest.sound_play("default_place_node", {pos = pos, max_hear_distance = 10})
                        return itemstack
                    end
                end
            end
            -- comportamiento original si no es obsidiana
            if old_on_use then
                return old_on_use(itemstack, user, pointed_thing)
            end
            return itemstack
        end,
    })
end)

local cooldown = {}

local function do_teleport(player, from_pos)
    local name = player:get_player_name()
    if cooldown[name] then return end
    cooldown[name] = true
    minetest.after(4, function() cooldown[name] = nil end)

    local in_nether = from_pos.y <= NETHER_MIN + 200
    local dest, emin, emax

    if in_nether then
        dest = {x = from_pos.x, y = 10,      z = from_pos.z}
        emin = {x = dest.x-16,  y = -5,       z = dest.z-16}
        emax = {x = dest.x+16,  y = 30,       z = dest.z+16}
    else
        dest = {x = from_pos.x, y = NETHER_Y, z = from_pos.z}
        emin = {x = dest.x-16,  y = NETHER_MIN,    z = dest.z-16}
        emax = {x = dest.x+16,  y = NETHER_MIN+120, z = dest.z+16}
    end

    minetest.emerge_area(emin, emax, function(_, _, calls_remaining)
        if calls_remaining ~= 0 then return end
        local near = minetest.find_node_near(dest, 12, {PORTAL})
        if near then
            player:set_pos({x = near.x, y = near.y + 1, z = near.z})
        else
            local corner = {x = dest.x, y = dest.y - 2, z = dest.z + 2}
            create_portal(corner, "x")
            player:set_pos({x = corner.x + 1, y = corner.y + 2, z = corner.z})
        end
    end)
end

minetest.register_abm({
    label     = "juha_nether:teleport",
    nodenames = {PORTAL},
    interval  = 0.5,
    chance    = 1,
    action    = function(pos)
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
            if obj:is_player() then
                do_teleport(obj, pos)
            end
        end
    end,
})