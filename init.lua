-- juha_nether | Juha (CraftPlay777)
-- Entrada principal del mod

juha_nether = {}
juha_nether.S = minetest.get_translator("juha_nether")

local mp = minetest.get_modpath("juha_nether")
dofile(mp .. "/nodes.lua")
dofile(mp .. "/portal.lua")
dofile(mp .. "/trees.lua")
dofile(mp .. "/mapgen.lua")
dofile(mp .. "/structures.lua")