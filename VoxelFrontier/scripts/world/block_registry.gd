extends Node

## BlockRegistry - Central registry for all block types
## Defines block properties and provides lookup functions

const AIR = 0
const GRASS_BLOCK = 1
const DIRT = 2
const STONE = 3
const SAND = 4
const GRAVEL = 5
const CLAY = 6
const SNOW_BLOCK = 7
const ICE = 8
const WATER = 9
const OAK_LOG = 10
const PINE_LOG = 11
const OAK_LEAVES = 12
const PINE_LEAVES = 13
const PLANKS = 14
const COBBLESTONE = 15
const COAL_ORE = 16
const COPPER_ORE = 17
const IRON_ORE = 18
const CRYSTAL_ORE = 19
const CRAFTING_TABLE = 20
const STORAGE_CRATE = 21
const FURNACE = 22
const TORCH = 23
const GLASS = 24
const BRICK = 25
const WOODEN_DOOR = 26
const WOODEN_FENCE = 27
const TALL_GRASS = 28
const FLOWER_YELLOW = 29
const FLOWER_RED = 30
const CACTUS = 31
const BEDROCK = 32

# Block properties stored in a dictionary
var block_definitions: Dictionary = {}

func _ready() -> void:
_register_default_blocks()

func _register_default_blocks() -> void:
# Air (special case)
register_block(AIR, {
"id": AIR,
"name": "Air",
"solid": false,
"transparent": true,
"breakable": false,
"hardness": 0.0,
"drop_item": null
})

# Grass Block
register_block(GRASS_BLOCK, {
"id": GRASS_BLOCK,
"name": "Grass Block",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.6,
"drop_item": DIRT,
"texture_top": "grass_top",
"texture_side": "grass_side",
"texture_bottom": "dirt"
})

# Dirt
register_block(DIRT, {
"id": DIRT,
"name": "Dirt",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.5,
"drop_item": DIRT,
"texture": "dirt"
})

# Stone
register_block(STONE, {
"id": STONE,
"name": "Stone",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 1.5,
"drop_item": COBBLESTONE,
"texture": "stone"
})

# Sand
register_block(SAND, {
"id": SAND,
"name": "Sand",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.5,
"drop_item": SAND,
"texture": "sand"
})

# Gravel
register_block(GRAVEL, {
"id": GRAVEL,
"name": "Gravel",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.6,
"drop_item": GRAVEL,
"texture": "gravel"
})

# Clay
register_block(CLAY, {
"id": CLAY,
"name": "Clay",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.6,
"drop_item": CLAY,
"texture": "clay"
})

# Snow Block
register_block(SNOW_BLOCK, {
"id": SNOW_BLOCK,
"name": "Snow Block",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.2,
"drop_item": SNOW_BLOCK,
"texture": "snow"
})

# Ice
register_block(ICE, {
"id": ICE,
"name": "Ice",
"solid": true,
"transparent": true,
"breakable": true,
"hardness": 0.5,
"drop_item": null,
"texture": "ice"
})

# Water
register_block(WATER, {
"id": WATER,
"name": "Water",
"solid": false,
"transparent": true,
"breakable": false,
"hardness": 0.0,
"liquid": true,
"drop_item": null,
"texture": "water"
})

# Oak Log
register_block(OAK_LOG, {
"id": OAK_LOG,
"name": "Oak Log",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.0,
"drop_item": OAK_LOG,
"texture_top": "log_oak_top",
"texture_side": "log_oak_side"
})

# Pine Log
register_block(PINE_LOG, {
"id": PINE_LOG,
"name": "Pine Log",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.0,
"drop_item": PINE_LOG,
"texture_top": "log_pine_top",
"texture_side": "log_pine_side"
})

# Oak Leaves
register_block(OAK_LEAVES, {
"id": OAK_LEAVES,
"name": "Oak Leaves",
"solid": true,
"transparent": true,
"breakable": true,
"hardness": 0.2,
"drop_item": null,
"texture": "leaves_oak"
})

# Pine Leaves
register_block(PINE_LEAVES, {
"id": PINE_LEAVES,
"name": "Pine Leaves",
"solid": true,
"transparent": true,
"breakable": true,
"hardness": 0.2,
"drop_item": null,
"texture": "leaves_pine"
})

# Planks
register_block(PLANKS, {
"id": PLANKS,
"name": "Planks",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.0,
"drop_item": PLANKS,
"texture": "planks"
})

# Cobblestone
register_block(COBBLESTONE, {
"id": COBBLESTONE,
"name": "Cobblestone",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.0,
"drop_item": COBBLESTONE,
"texture": "cobblestone"
})

# Coal Ore
register_block(COAL_ORE, {
"id": COAL_ORE,
"name": "Coal Ore",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 3.0,
"drop_item": COAL_ORE,
"texture": "ore_coal"
})

# Copper Ore
register_block(COPPER_ORE, {
"id": COPPER_ORE,
"name": "Copper Ore",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 3.0,
"drop_item": COPPER_ORE,
"texture": "ore_copper"
})

# Iron Ore
register_block(IRON_ORE, {
"id": IRON_ORE,
"name": "Iron Ore",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 4.0,
"drop_item": IRON_ORE,
"texture": "ore_iron"
})

# Crystal Ore (rare)
register_block(CRYSTAL_ORE, {
"id": CRYSTAL_ORE,
"name": "Moon Crystal Ore",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 6.0,
"drop_item": CRYSTAL_ORE,
"texture": "ore_crystal"
})

# Crafting Table
register_block(CRAFTING_TABLE, {
"id": CRAFTING_TABLE,
"name": "Crafting Table",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.5,
"drop_item": CRAFTING_TABLE,
"texture_top": "crafting_table_top",
"texture_side": "crafting_table_side",
"texture_front": "crafting_table_front"
})

# Storage Crate
register_block(STORAGE_CRATE, {
"id": STORAGE_CRATE,
"name": "Storage Crate",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.5,
"drop_item": STORAGE_CRATE,
"texture": "storage_crate"
})

# Furnace
register_block(FURNACE, {
"id": FURNACE,
"name": "Furnace",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 3.5,
"drop_item": FURNACE,
"texture_top": "furnace_top",
"texture_side": "furnace_side",
"texture_front": "furnace_front"
})

# Torch
register_block(TORCH, {
"id": TORCH,
"name": "Torch",
"solid": false,
"transparent": true,
"breakable": true,
"hardness": 0.0,
"drop_item": TORCH,
"light_emission": 14,
"texture": "torch"
})

# Glass
register_block(GLASS, {
"id": GLASS,
"name": "Glass",
"solid": true,
"transparent": true,
"breakable": true,
"hardness": 0.3,
"drop_item": null,
"texture": "glass"
})

# Brick
register_block(BRICK, {
"id": BRICK,
"name": "Brick",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 2.0,
"drop_item": BRICK,
"texture": "brick"
})

# Wooden Door
register_block(WOODEN_DOOR, {
"id": WOODEN_DOOR,
"name": "Wooden Door",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 3.0,
"drop_item": WOODEN_DOOR,
"texture": "door_wood"
})

# Wooden Fence
register_block(WOODEN_FENCE, {
"id": WOODEN_FENCE,
"name": "Wooden Fence",
"solid": true,
"transparent": true,
"breakable": true,
"hardness": 2.0,
"drop_item": WOODEN_FENCE,
"texture": "fence_wood"
})

# Tall Grass
register_block(TALL_GRASS, {
"id": TALL_GRASS,
"name": "Tall Grass",
"solid": false,
"transparent": true,
"breakable": true,
"hardness": 0.0,
"drop_item": null,
"texture": "tall_grass"
})

# Yellow Flower
register_block(FLOWER_YELLOW, {
"id": FLOWER_YELLOW,
"name": "Sunflower",
"solid": false,
"transparent": true,
"breakable": true,
"hardness": 0.0,
"drop_item": FLOWER_YELLOW,
"texture": "flower_yellow"
})

# Red Flower
register_block(FLOWER_RED, {
"id": FLOWER_RED,
"name": "Poppy",
"solid": false,
"transparent": true,
"breakable": true,
"hardness": 0.0,
"drop_item": FLOWER_RED,
"texture": "flower_red"
})

# Cactus
register_block(CACTUS, {
"id": CACTUS,
"name": "Barrel Cactus",
"solid": true,
"transparent": false,
"breakable": true,
"hardness": 0.4,
"drop_item": CACTUS,
"texture": "cactus"
})

# Bedrock (unbreakable)
register_block(BEDROCK, {
"id": BEDROCK,
"name": "Bedrock",
"solid": true,
"transparent": false,
"breakable": false,
"hardness": -1.0,
"drop_item": null,
"texture": "bedrock"
})

func register_block(block_id: int, definition: Dictionary) -> void:
block_definitions[block_id] = definition

func get_block_definition(block_id: int) -> Dictionary:
if block_definitions.has(block_id):
return block_definitions[block_id]
return {}

func get_block_name(block_id: int) -> String:
var def = get_block_definition(block_id)
return def.get("name", "Unknown Block")

func is_block_solid(block_id: int) -> bool:
var def = get_block_definition(block_id)
return def.get("solid", false)

func is_block_transparent(block_id: int) -> bool:
var def = get_block_definition(block_id)
return def.get("transparent", false)

func is_block_breakable(block_id: int) -> bool:
var def = get_block_definition(block_id)
return def.get("breakable", true)

func get_block_hardness(block_id: int) -> float:
var def = get_block_definition(block_id)
return def.get("hardness", 1.0)

func get_block_drop(block_id: int) -> int:
var def = get_block_definition(block_id)
var drop = def.get("drop_item")
if drop != null:
return drop
return block_id

func is_block_liquid(block_id: int) -> bool:
var def = get_block_definition(block_id)
return def.get("liquid", false)

func get_light_emission(block_id: int) -> int:
var def = get_block_definition(block_id)
return def.get("light_emission", 0)

func get_all_block_ids() -> Array:
var ids: Array = []
for id in block_definitions.keys():
if id != AIR:
ids.append(id)
return ids
