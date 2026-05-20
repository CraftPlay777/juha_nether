-- juha_nether | Juha (CraftPlay777)
-- Registro de nodos, herramientas y recetas

local S = juha_nether.S

-- obsidiana
minetest.register_node("juha_nether:obsidian", {
    description = S("Obsidian"),
    tiles = {"juha_nether_obsidian.png"},
    is_ground_content = false,
    groups = {cracky = 1, level = 2},
    sounds = default.node_sound_stone_defaults(),
    light_source = 10,
})

minetest.register_craft({
    output = "juha_nether:obsidian",
    recipe = {
        {"default:sand",        "default:stone",       "default:sand"},
        {"default:stone",       "default:steel_ingot", "default:stone"},
        {"default:sand",        "default:stone",       "default:sand"},
    },
})

-- arena maldita
minetest.register_node("juha_nether:cursed_sand", {
    description = S("Cursed Sand"),
    tiles = {"juha_nether_cursed_sand.png"},
    groups = {crumbly = 3, falling_node = 1},
    sounds = default.node_sound_sand_defaults(),
    light_source = 10,
})

-- portal
minetest.register_node("juha_nether:portal", {
    description = S("Nether Portal"),
    drawtype = "nodebox",
    tiles = {{
        name = "juha_nether_portal.png",
        animation = {
            type     = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length   = 1.5,
        },
    }},
    node_box = {
        type  = "fixed",
        fixed = {-0.5, -0.5, -0.05, 0.5, 0.5, 0.05},
    },
    paramtype         = "light",
    paramtype2        = "facedir",
    walkable          = false,
    light_source      = 11,
    use_texture_alpha = "blend",
    groups = {not_in_creative_inventory = 1},
    on_destruct = function(pos)
        juha_nether.destroy_portal(pos)
    end,
})

-- encendedor
minetest.register_tool("juha_nether:lighter", {
    description = S("Lighter"),
    inventory_image = "juha_nether_lighter.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return itemstack end
        local pos = pointed_thing.under
        if not juha_nether.is_obsidian(minetest.get_node(pos).name) then
            return itemstack
        end
        local corner, axis, inner = juha_nether.find_portal(pos)
        if corner then
            juha_nether.activate_portal(inner, axis)
            minetest.sound_play("default_place_node", {pos = pos, max_hear_distance = 10})
        end
        return itemstack
    end,
})

minetest.register_craft({
    output = "juha_nether:lighter",
    recipe = {{"default:steel_ingot", "default:coal_lump"}},
})

-- ── madera maldita ────────────────────────────────────────────────────────────

-- tronco
minetest.register_node("juha_nether:cursed_log", {
    description = S("Cursed Wood Log"),
    tiles = {
        "juha_nether_cursed_log_top.png",
        "juha_nether_cursed_log_top.png",
        "juha_nether_cursed_log.png",
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    on_place = minetest.rotate_node,
    light_source = 10,
})

minetest.register_craft({
    type   = "shapeless",
    output = "juha_nether:cursed_planks 4",
    recipe = {"juha_nether:cursed_log"},
})

-- tablones
minetest.register_node("juha_nether:cursed_planks", {
    description = S("Cursed Planks"),
    tiles = {"juha_nether_cursed_planks.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 10,
})

-- hojas
minetest.register_node("juha_nether:cursed_leaves", {
    description = S("Cursed Leaves"),
    drawtype = "allfaces_optional",
    tiles = {"juha_nether_cursed_leaves.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, leaves = 1},
    sounds = default.node_sound_leaves_defaults(),
    light_source = 10,
    drop = {
        max_items = 1,
        items = {
            {items = {"juha_nether:cursed_log"}, rarity = 20},
            {items = {"juha_nether:cursed_leaves"}},
        },
    },
})

-- bloque comprimido
minetest.register_node("juha_nether:cursed_block", {
    description = S("Cursed Wood Block"),
    tiles = {"juha_nether_cursed_block.png"},
    is_ground_content = false,
    groups = {choppy = 1, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 10,
})

minetest.register_craft({
    output = "juha_nether:cursed_block",
    recipe = {
        {"juha_nether:cursed_planks", "juha_nether:cursed_planks", "juha_nether:cursed_planks"},
        {"juha_nether:cursed_planks", "juha_nether:cursed_planks", "juha_nether:cursed_planks"},
        {"juha_nether:cursed_planks", "juha_nether:cursed_planks", "juha_nether:cursed_planks"},
    },
})

minetest.register_craft({
    output = "juha_nether:cursed_planks 9",
    recipe = {{"juha_nether:cursed_block"}},
})

-- ── madera sin alma ───────────────────────────────────────────────────────────

-- tronco
minetest.register_node("juha_nether:soul_log", {
    description = S("Soulless Wood Log"),
    tiles = {
        "juha_nether_soul_log_top.png",
        "juha_nether_soul_log_top.png",
        "juha_nether_soul_log.png",
    },
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    on_place = minetest.rotate_node,
    light_source = 10,
})

-- tablones
minetest.register_node("juha_nether:soul_planks", {
    description = S("Soulless Planks"),
    tiles = {"juha_nether_soul_planks.png"},
    groups = {choppy = 2, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 10,
})

-- bloque comprimido
minetest.register_node("juha_nether:soul_block", {
    description = S("Soulless Wood Block"),
    tiles = {"juha_nether_soul_block.png"},
    is_ground_content = false,
    groups = {choppy = 1, oddly_breakable_by_hand = 1},
    sounds = default.node_sound_wood_defaults(),
    light_source = 10,
})

-- hojas
minetest.register_node("juha_nether:soul_leaves", {
    description = S("Soulless Leaves"),
    drawtype = "allfaces_optional",
    tiles = {"juha_nether_soul_leaves.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, leaves = 1},
    sounds = default.node_sound_leaves_defaults(),
    light_source = 10,
    drop = {
        max_items = 1,
        items = {
            {items = {"juha_nether:soul_log"}, rarity = 20},
            {items = {"juha_nether:soul_leaves"}},
        },
    },
})

minetest.register_craft({
    type   = "shapeless",
    output = "juha_nether:soul_planks 4",
    recipe = {"juha_nether:soul_log"},
})

minetest.register_craft({
    output = "juha_nether:soul_block",
    recipe = {
        {"juha_nether:soul_planks", "juha_nether:soul_planks", "juha_nether:soul_planks"},
        {"juha_nether:soul_planks", "juha_nether:soul_planks", "juha_nether:soul_planks"},
        {"juha_nether:soul_planks", "juha_nether:soul_planks", "juha_nether:soul_planks"},
    },
})

minetest.register_craft({
    output = "juha_nether:soul_planks 9",
    recipe = {{"juha_nether:soul_block"}},
})

-- ── cofres ────────────────────────────────────────────────────────────────────

local function chest_formspec()
    return "size[8,9]" ..
        "list[context;main;0,0.3;8,4;]" ..
        "list[current_player;main;0,4.85;8,1;]" ..
        "list[current_player;main;0,6.08;8,3;8]" ..
        "listring[context;main]" ..
        "listring[current_player;main]"
end

local function register_chest(name, desc, tiles)
    minetest.register_node("juha_nether:" .. name, {
        description = desc,
        tiles = tiles,
        paramtype2 = "facedir",
        groups = {choppy = 2, oddly_breakable_by_hand = 1},
        sounds = default.node_sound_wood_defaults(),
        light_source = 10,
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_string("formspec", chest_formspec())
            meta:set_string("infotext", desc)
            local inv = meta:get_inventory()
            inv:set_size("main", 8 * 4)
        end,
        can_dig = function(pos)
            return minetest.get_meta(pos):get_inventory():is_empty("main")
        end,
        on_rightclick = function(pos, node, clicker)
            minetest.show_formspec(
                clicker:get_player_name(),
                "juha_nether:" .. name,
                chest_formspec()
            )
        end,
        on_receive_fields = function() end,
        allow_metadata_inventory_move = function(_, _, _, _, _, count) return count end,
        allow_metadata_inventory_put  = function(_, _, _, stack) return stack:get_count() end,
        allow_metadata_inventory_take = function(_, _, _, stack) return stack:get_count() end,
    })
end

-- cofre maldito
register_chest("cursed_chest", S("Cursed Wood Chest"), {
    "juha_nether_cursed_chest_top.png",
    "juha_nether_cursed_chest_top.png",
    "juha_nether_cursed_chest_side.png",
    "juha_nether_cursed_chest_side.png",
    "juha_nether_cursed_chest_side.png",
    "juha_nether_cursed_chest_front.png",
})

minetest.register_craft({
    output = "juha_nether:cursed_chest",
    recipe = {
        {"juha_nether:cursed_planks", "juha_nether:cursed_planks", "juha_nether:cursed_planks"},
        {"juha_nether:cursed_planks", "",                           "juha_nether:cursed_planks"},
        {"juha_nether:cursed_planks", "juha_nether:cursed_planks", "juha_nether:cursed_planks"},
    },
})

-- cofre sin alma
register_chest("soul_chest", S("Soulless Wood Chest"), {
    "juha_nether_soul_chest_top.png",
    "juha_nether_soul_chest_top.png",
    "juha_nether_soul_chest_side.png",
    "juha_nether_soul_chest_side.png",
    "juha_nether_soul_chest_side.png",
    "juha_nether_soul_chest_front.png",
})

minetest.register_craft({
    output = "juha_nether:soul_chest",
    recipe = {
        {"juha_nether:soul_planks", "juha_nether:soul_planks", "juha_nether:soul_planks"},
        {"juha_nether:soul_planks", "",                         "juha_nether:soul_planks"},
        {"juha_nether:soul_planks", "juha_nether:soul_planks", "juha_nether:soul_planks"},
    },
})

-- piedra maldita
minetest.register_node("juha_nether:cursed_stone", {
    description = S("Cursed Stone"),
    tiles = {"juha_nether_cursed_stone.png"},
    groups = {cracky = 3, oddly_breakable_by_hand = 3},
    sounds = default.node_sound_stone_defaults(),
    light_source = 10,
})