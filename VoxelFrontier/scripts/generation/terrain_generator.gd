extends Node

## TerrainGenerator - Procedural terrain generation using layered noise
## Generates heightmaps, biomes, caves, ores, and vegetation

# Noise parameters
var _continent_noise = FastNoiseLite.new()
var _elevation_noise = FastNoiseLite.new()
var _detail_noise = FastNoiseLite.new()
var _cave_noise = FastNoiseLite.new()
var _temperature_noise = FastNoiseLite.new()
var _moisture_noise = FastNoiseLite.new()

# Biome definitions
var biome_definitions: Dictionary = {}

func _ready() -> void:
_setup_noise_generators()
_setup_biomes()

func _setup_noise_generators() -> void:
# Continent noise - large scale landmass shapes
_continent_noise.seed = 12345
_continent_noise.noise_type = FastNoiseLite.TYPE_PERLIN
_continent_noise.frequency = 0.008
_continent_noise.octaves = 3

# Elevation noise - base terrain height
_elevation_noise.seed = 23456
_elevation_noise.noise_type = FastNoiseLite.TYPE_PERLIN
_elevation_noise.frequency = 0.015
_elevation_noise.octaves = 4

# Detail noise - small variations
_detail_noise.seed = 34567
_detail_noise.noise_type = FastNoiseLite.TYPE_PERLIN
_detail_noise.frequency = 0.05
_detail_noise.octaves = 2

# Cave noise - 3D cave system
_cave_noise.seed = 45678
_cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
_cave_noise.frequency = 0.03
_cave_noise.octaves = 4

# Temperature noise - for biome selection
_temperature_noise.seed = 56789
_temperature_noise.noise_type = FastNoiseLite.TYPE_PERLIN
_temperature_noise.frequency = 0.01
_temperature_noise.octaves = 2

# Moisture noise - for biome selection
_moisture_noise.seed = 67890
_moisture_noise.noise_type = FastNoiseLite.TYPE_PERLIN
_moisture_noise.frequency = 0.01
_moisture_noise.octaves = 2

func _setup_biomes() -> void:
biome_definitions = {
"greenlands": {
"temp_range": Vector2(0.3, 0.6),
"moisture_range": Vector2(0.4, 0.7),
"surface_block": BlockRegistry.GRASS_BLOCK,
"subsurface_block": BlockRegistry.DIRT,
"base_height": 60,
"height_variation": 15
},
"pinewood": {
"temp_range": Vector2(0.2, 0.5),
"moisture_range": Vector2(0.5, 0.8),
"surface_block": BlockRegistry.GRASS_BLOCK,
"subsurface_block": BlockRegistry.DIRT,
"base_height": 70,
"height_variation": 20
},
"sunscar_desert": {
"temp_range": Vector2(0.6, 1.0),
"moisture_range": Vector2(0.0, 0.3),
"surface_block": BlockRegistry.SAND,
"subsurface_block": BlockRegistry.SANDSTONE if BlockRegistry.has_constant("SANDSTONE") else BlockRegistry.STONE,
"base_height": 55,
"height_variation": 8
},
"frostfields": {
"temp_range": Vector2(0.0, 0.25),
"moisture_range": Vector2(0.0, 1.0),
"surface_block": BlockRegistry.SNOW_BLOCK,
"subsurface_block": BlockRegistry.DIRT,
"base_height": 65,
"height_variation": 12
},
"highlands": {
"temp_range": Vector2(0.2, 0.7),
"moisture_range": Vector2(0.3, 0.6),
"surface_block": BlockRegistry.STONE,
"subsurface_block": BlockRegistry.STONE,
"base_height": 90,
"height_variation": 25
},
"stone_peaks": {
"temp_range": Vector2(0.0, 1.0),
"moisture_range": Vector2(0.0, 1.0),
"surface_block": BlockRegistry.STONE,
"subsurface_block": BlockRegistry.STONE,
"base_height": 110,
"height_variation": 15
},
"marshlands": {
"temp_range": Vector2(0.4, 0.8),
"moisture_range": Vector2(0.7, 1.0),
"surface_block": BlockRegistry.GRASS_BLOCK,
"subsurface_block": BlockRegistry.CLAY,
"base_height": 50,
"height_variation": 5
},
"coast": {
"temp_range": Vector2(0.0, 1.0),
"moisture_range": Vector2(0.0, 1.0),
"surface_block": BlockRegistry.SAND,
"subsurface_block": BlockRegistry.GRAVEL,
"base_height": 52,
"height_variation": 3
}
}

func generate_chunk(chunk: ChunkData, seed: String) -> void:
# Seed the noise generators based on world seed
var seed_hash = hash(seed)
_setup_noise_for_seed(seed_hash)

var chunk_world_x = chunk.chunk_x * chunk.size_x
var chunk_world_z = chunk.chunk_z * chunk.size_z

# Generate blocks for this chunk
for local_x in range(chunk.size_x):
for local_z in range(chunk.size_z):
var world_x = chunk_world_x + local_x
var world_z = chunk_world_z + local_z

# Get terrain height at this position
var height = get_height_at(world_x, world_z, seed)

# Get biome information
var biome = get_biome_at(world_x, world_z)
var surface_block = biome.get("surface_block", BlockRegistry.GRASS_BLOCK)
var subsurface_block = biome.get("subsurface_block", BlockRegistry.DIRT)

# Fill column
for y in range(chunk.size_y):
var block_id = BlockRegistry.AIR

if y == 0:
block_id = BlockRegistry.BEDROCK
elif y < height - 4:
# Deep underground - stone with possible caves
if _is_cave_at(world_x, y, world_z, seed):
block_id = BlockRegistry.AIR
else:
# Check for ores
block_id = _generate_ore_at(world_x, y, world_z, seed)
if block_id == BlockRegistry.AIR:
block_id = BlockRegistry.STONE
elif y < height - 1:
# Subsurface layer
block_id = subsurface_block
elif y == height - 1:
# Surface block
block_id = surface_block
elif y == height and surface_block == BlockRegistry.GRASS_BLOCK:
# Vegetation layer
_generate_vegetation_at(chunk, local_x, height + 1, local_z, world_x, world_z, seed)

if block_id != BlockRegistry.AIR:
chunk.set_block(local_x, y, local_z, block_id)

# Generate trees
_generate_trees_in_chunk(chunk, seed)

func _setup_noise_for_seed(seed_hash: int) -> void:
_continent_noise.seed = seed_hash
_elevation_noise.seed = seed_hash + 1
_detail_noise.seed = seed_hash + 2
_cave_noise.seed = seed_hash + 3
_temperature_noise.seed = seed_hash + 4
_moisture_noise.seed = seed_hash + 5

func get_height_at(world_x: int, world_z: int, seed: String) -> int:
var seed_hash = hash(seed)

# Get continent factor (0-1)
var continent = (_continent_noise.get_noise_2d(world_x, world_z) + 1.0) * 0.5

# Get base elevation
var elevation = _elevation_noise.get_noise_2d(world_x, world_z)

# Add detail
var detail = _detail_noise.get_noise_2d(world_x, world_z) * 0.3

# Combine noises
var combined = (elevation + detail) * 20.0

# Apply continent factor to reduce height near ocean edges
var height = 50 + combined + (continent - 0.5) * 20.0

return int(clamp(height, 5, 110))

func get_biome_at(world_x: int, world_z: int) -> Dictionary:
# Get temperature and moisture at this position
var temp = (_temperature_noise.get_noise_2d(world_x, world_z) + 1.0) * 0.5
var moisture = (_moisture_noise.get_noise_2d(world_x, world_z) + 1.0) * 0.5

# Find matching biome
var best_biome = biome_definitions["greenlands"]
var best_match = 0.0

for biome_name in biome_definitions.keys():
var biome = biome_definitions[biome_name]
var temp_match = 1.0 - abs(temp - (biome.temp_range.x + biome.temp_range.y) * 0.5)
var moisture_match = 1.0 - abs(moisture - (biome.moisture_range.x + biome.moisture_range.y) * 0.5)
var total_match = temp_match + moisture_match

if total_match > best_match:
best_match = total_match
best_biome = biome

return best_biome

func _is_cave_at(x: int, y: int, z: int, seed: String) -> bool:
var seed_hash = hash(seed)
_cave_noise.seed = seed_hash + 3

# Get 3D noise value
var noise_val = _cave_noise.get_noise_3d(x, y, z)

# Cave threshold - higher values = more caves
var threshold = 0.55

# More caves deeper underground
var depth_factor = float(y) / 60.0
threshold -= depth_factor * 0.1

return noise_val > threshold

func _generate_ore_at(x: int, y: int, z: int, seed: String) -> int:
var seed_hash = hash(seed)

# Use ore-specific noise
var ore_noise = FastNoiseLite.new()
ore_noise.seed = seed_hash + 100
ore_noise.frequency = 0.08
ore_noise.octaves = 2

var noise_val = ore_noise.get_noise_3d(x, y, z)

# Coal - common, all depths
if y < 80 and noise_val > 0.6:
return BlockRegistry.COAL_ORE

# Copper - medium depth
if y >= 30 and y < 70 and noise_val > 0.7:
return BlockRegistry.COPPER_ORE

# Iron - deeper
if y >= 20 and y < 60 and noise_val > 0.75:
return BlockRegistry.IRON_ORE

# Crystal - rare, deep
if y >= 5 and y < 30 and noise_val > 0.85:
return BlockRegistry.CRYSTAL_ORE

return BlockRegistry.AIR

func _generate_vegetation_at(chunk: ChunkData, local_x: int, y: int, local_z: int, world_x: int, world_z: int, seed: String) -> void:
var seed_hash = hash(seed)
var veg_noise = FastNoiseLite.new()
veg_noise.seed = seed_hash + 200
veg_noise.frequency = 0.2

var noise_val = veg_noise.get_noise_2d(world_x, world_z)

if noise_val > 0.3:
# Place tall grass or flowers
if noise_val > 0.7:
chunk.set_block(local_x, y, local_z, BlockRegistry.FLOWER_YELLOW)
elif noise_val > 0.5:
chunk.set_block(local_x, y, local_z, BlockRegistry.FLOWER_RED)
else:
chunk.set_block(local_x, y, local_z, BlockRegistry.TALL_GRASS)

func _generate_trees_in_chunk(chunk: ChunkData, seed: String) -> void:
var seed_hash = hash(seed)
var tree_noise = FastNoiseLite.new()
tree_noise.seed = seed_hash + 300
tree_noise.frequency = 0.05

var chunk_world_x = chunk.chunk_x * chunk.size_x
var chunk_world_z = chunk.chunk_z * chunk.size_z

for local_x in range(chunk.size_x):
for local_z in range(chunk.size_z):
var world_x = chunk_world_x + local_x
var world_z = chunk_world_z + local_z

var noise_val = tree_noise.get_noise_2d(world_x, world_z)

if noise_val > 0.6:
# Find surface height
var height = get_height_at(world_x, world_z, seed)

# Check if we can place a tree here
if height > 55 and height < 100:
var biome = get_biome_at(world_x, world_z)
var is_cold = biome.get("temp_range", Vector2(0, 1)).y < 0.4

# Place tree
if is_cold:
_place_pine_tree(chunk, local_x, height + 1, local_z)
else:
_place_oak_tree(chunk, local_x, height + 1, local_z)

func _place_oak_tree(chunk: ChunkData, center_x: int, base_y: int, center_z: int) -> void:
var trunk_height = 4 + randi() % 3

# Trunk
for y in range(trunk_height):
if base_y + y < chunk.size_y:
chunk.set_block(center_x, base_y + y, center_z, BlockRegistry.OAK_LOG)

# Leaves
for dx in range(-2, 3):
for dy in range(0, 3):
for dz in range(-2, 3):
var lx = center_x + dx
var ly = base_y + trunk_height - 1 + dy
var lz = center_z + dz

if lx >= 0 and lx < chunk.size_x and lz >= 0 and lz < chunk.size_z:
if abs(dx) + abs(dz) <= 3:
if not chunk.is_block_solid(lx, ly, lz):
chunk.set_block(lx, ly, lz, BlockRegistry.OAK_LEAVES)

func _place_pine_tree(chunk: ChunkData, center_x: int, base_y: int, center_z: int) -> void:
var trunk_height = 5 + randi() % 3

# Trunk
for y in range(trunk_height):
if base_y + y < chunk.size_y:
chunk.set_block(center_x, base_y + y, center_z, BlockRegistry.PINE_LOG)

# Leaves (cone shape)
for dy in range(0, 4):
var radius = 2 - dy / 2
for dx in range(-2, 3):
for dz in range(-2, 3):
var lx = center_x + dx
var ly = base_y + trunk_height - 2 + dy
var lz = center_z + dz

if lx >= 0 and lx < chunk.size_x and lz >= 0 and lz < chunk.size_z:
if abs(dx) + abs(dz) <= radius + 1:
if not chunk.is_block_solid(lx, ly, lz):
chunk.set_block(lx, ly, lz, BlockRegistry.PINE_LEAVES)

func get_biome_name(world_x: int, world_z: int) -> String:
var biome = get_biome_at(world_x, world_z)

for name in biome_definitions.keys():
if biome_definitions[name] == biome:
return name

return "unknown"
