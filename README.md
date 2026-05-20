# juha_nether
A nether dimension mod for Minetest Game. Travel through an obsidian portal to a dark underground world filled with cursed stone, two types of cursed wood, lava lakes, and handcrafted towers with loot.

## Portal
Build a 4-wide × 5-tall frame of obsidian (your own or `default:obsidian`) and light it with the lighter. The portal will teleport you to the nether at around Y −5090 and back.

- visual ejem
OOOO
O......O
O......O      x5 obsidian
O......O
OOOO
x4 obsidian

-- Github ruined my awesome chart, but it's basically 4 wide and 5 tall in total. 

## Nether
The nether is generated between Y −5100 and Y −5000.

### Terrain
- **Cursed Stone** — main rock, fills most of the volume with natural cave openings
- **Cursed Sand** — thin floor layer, always placed on top of cursed stone
- **Lava** — lakes at the very bottom
- **Stone ceiling** — solid top layer

### Biomes
| Biome | Size | Trees |
|---|---|---|
| Cursed Forest | ~15–18 chunks | Cursed Wood trees (purple leaves) |
| Cursed Mega-Forest | ~40–55 chunks | Dense cursed trees |
| Soulless Forest | ~25 chunks | Soulless Wood trees (blue leaves) |

### Towers
Cursed wood towers (~18 blocks tall) generate across the nether floor, roughly one per 80×80 block area. Each tower has:
- A spiral staircase of cursed wood blocks
- Windows on each wall
- A chest at the top with random loot

**Rare loot (30%):** diamonds, gold blocks, mese crystals, diamond tools, obsidian shards, the Lighter

**Common loot (70%):** steel/copper/bronze ingots, gold ingots, steel tools, planks, bread, apples


## Nodes

### Cursed Wood (purple)
| Node | Description |
|---|---|
| Cursed Wood Log | Rotatable log, fire-immune |
| Cursed Planks | Standard planks |
| Cursed Wood Block | Compressed 9-plank block, harder |
| Cursed Leaves | Drops log rarely |
| Cursed Wood Chest | 32-slot chest |

### Soulless Wood (dark blue)
| Node | Description |
|---|---|
| Soulless Wood Log | Rotatable log, fire-immune |
| Soulless Planks | Standard planks |
| Soulless Wood Block | Compressed 9-plank block, harder |
| Soulless Leaves | Drops log rarely |
| Soulless Wood Chest | 32-slot chest |

All nether wood is **fire and lava immune** (no `flammable` group).  
All nether blocks emit **light level 10** for natural ambient lighting.

## Dependencies
- `default` (Minetest Game)
- `farming` (Minetest Game, for chest loot)


**Author:** Juha (CraftPlay777)  
**License:** MIT
# juha_nether
