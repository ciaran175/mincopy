extends Node

## WorldManager - Manages the voxel world, chunks, and terrain generation
## Handles chunk loading/unloading, block access, and world persistence

signal chunk_loaded(chunk_x: int, chunk_z: int)
signal chunk_unloaded(chunk_x: int, chunk_z: int)
signal block_changed(x: int, y: int, z: int, block_id: int)

const CHUNK_SIZE = Version.CHUNK_SIZE
const CHUNK_HEIGHT = Version.CHUNK_HEIGHT

var chunks: Dictionary = {}  # key: "x,z", value: ChunkData
var loaded_chunk_keys: Array = []
var world_seed: String = ""
var current_difficulty: int = Difficulty.NORMAL
var game_mode: int = Version.GameMode.SURVIVAL
var day_time: float = 0.0  # 0.0 to 1.0 (full day cycle)
var world_name: String = ""

var render_distance: int = Version.RENDER_DISTANCE_DEFAULT
var player_chunk_x: int = 0
var player_chunk_z: int = 0

var _chunk_update_queue: Array = []
var _mesh_update_queue: Array = []

func _ready() -> void:
print("[WorldManager] Initialized")

func initialize_world(seed: String, name: String, mode: int, difficulty: int) -> void:
world_seed = seed
world_name = name
game_mode = mode
current_difficulty = difficulty
day_time = 0.0

# Clear existing chunks
unload_all_chunks()

print("[WorldManager] World initialized: ", name, " (seed: ", seed, ")")

func get_block(world_x: int, world_y: int, world_z: int) -> int:
if world_y < 0 or world_y >= CHUNK_HEIGHT:
return BlockRegistry.AIR

var chunk_x = floori(float(world_x) / CHUNK_SIZE)
var chunk_z = floori(float(world_z) / CHUNK_SIZE)

var local_x = wrapi(world_x, CHUNK_SIZE)
var local_z = wrapi(world_z, CHUNK_SIZE)

var chunk_key = "%d,%d" % [chunk_x, chunk_z]
if chunks.has(chunk_key):
var chunk = chunks[chunk_key]
return chunk.get_block(local_x, world_y, local_z)

return BlockRegistry.AIR

func set_block(world_x: int, world_y: int, world_z: int, block_id: int) -> bool:
if world_y < 0 or world_y >= CHUNK_HEIGHT:
return false

var chunk_x = floori(float(world_x) / CHUNK_SIZE)
var chunk_z = floori(float(world_z) / CHUNK_SIZE)

var local_x = wrapi(world_x, CHUNK_SIZE)
var local_z = wrapi(world_z, CHUNK_SIZE)

var chunk_key = "%d,%d" % [chunk_x, chunk_z]
if chunks.has(chunk_key):
var chunk = chunks[chunk_key]
chunk.set_block(local_x, world_y, local_z, block_id)
request_mesh_update(chunk_x, chunk_z)

# Update neighboring chunks if on boundary
if local_x == 0:
request_mesh_update(chunk_x - 1, chunk_z)
elif local_x == CHUNK_SIZE - 1:
request_mesh_update(chunk_x + 1, chunk_z)

if local_z == 0:
request_mesh_update(chunk_x, chunk_z - 1)
elif local_z == CHUNK_SIZE - 1:
request_mesh_update(chunk_x, chunk_z + 1)

block_changed.emit(world_x, world_y, world_z, block_id)
return true

return false

func request_mesh_update(chunk_x: int, chunk_z: int) -> void:
var key = "%d,%d" % [chunk_x, chunk_z]
if not _mesh_update_queue.has(key):
_mesh_update_queue.append(key)

func update_chunks_around_player(player_world_x: int, player_world_z: int) -> void:
var new_chunk_x = floori(float(player_world_x) / CHUNK_SIZE)
var new_chunk_z = floori(float(player_world_z) / CHUNK_SIZE)

if new_chunk_x == player_chunk_x and new_chunk_z == player_chunk_z:
return

player_chunk_x = new_chunk_x
player_chunk_z = new_chunk_z

# Load chunks within render distance
for dx in range(-render_distance, render_distance + 1):
for dz in range(-render_distance, render_distance + 1):
var cx = player_chunk_x + dx
var cz = player_chunk_z + dz
var dist = sqrt(dx * dx + dz * dz)

if dist <= render_distance:
load_chunk(cx, cz)

# Unload distant chunks
var keys_to_remove: Array = []
for key in chunks.keys():
var parts = key.split(",")
var cx = int(parts[0])
var cz = int(parts[1])

var dist_x = abs(cx - player_chunk_x)
var dist_z = abs(cz - player_chunk_z)

if dist_x > render_distance + 1 or dist_z > render_distance + 1:
keys_to_remove.append(key)

for key in keys_to_remove:
unload_chunk_by_key(key)

# Process mesh updates
_process_mesh_updates()

func load_chunk(chunk_x: int, chunk_z: int) -> void:
var key = "%d,%d" % [chunk_x, chunk_z]
if chunks.has(key):
return

var chunk = ChunkData.new(CHUNK_SIZE, CHUNK_HEIGHT)
chunk.chunk_x = chunk_x
chunk.chunk_z = chunk_z

# Generate terrain for this chunk
TerrainGenerator.generate_chunk(chunk, world_seed)

chunks[key] = chunk
loaded_chunk_keys.append(key)

# Create mesh for chunk
_create_chunk_mesh(chunk)

chunk_loaded.emit(chunk_x, chunk_z)

func unload_chunk(chunk_x: int, chunk_z: int) -> void:
var key = "%d,%d" % [chunk_x, chunk_z]
unload_chunk_by_key(key)

func unload_chunk_by_key(key: String) -> void:
if not chunks.has(key):
return

var chunk = chunks[key]

# Remove chunk mesh
_remove_chunk_mesh(chunk)

chunks.erase(key)
loaded_chunk_keys.erase(key)

chunk_unloaded.emit(chunk.chunk_x, chunk.chunk_z)

func unload_all_chunks() -> void:
var keys: Array = chunks.keys().duplicate()
for key in keys:
unload_chunk_by_key(key)

func _create_chunk_mesh(chunk: ChunkData) -> void:
# This will be implemented with actual mesh generation
# For now, just mark that the chunk needs a mesh
chunk.mesh_dirty = true

func _remove_chunk_mesh(chunk: ChunkData) -> void:
# Clean up mesh resources
pass

func _process_mesh_updates() -> void:
for key in _mesh_update_queue.duplicate():
if chunks.has(key):
var chunk = chunks[key]
if chunk.mesh_dirty:
_generate_chunk_mesh(chunk)
chunk.mesh_dirty = false
_mesh_update_queue.erase(key)

func _generate_chunk_mesh(chunk: ChunkData) -> void:
# Generate actual mesh data - to be implemented
pass

func get_spawn_position() -> Vector3:
# Find a safe spawn position near world origin
var spawn_x = 0
var spawn_z = 0

# Get height at spawn position
var spawn_y = TerrainGenerator.get_height_at(spawn_x, spawn_z, world_seed)

# Move up until we find air
while spawn_y < CHUNK_HEIGHT - 5:
spawn_y += 1
if get_block(spawn_x, spawn_y, spawn_z) == BlockRegistry.AIR:
if get_block(spawn_x, spawn_y - 1, spawn_z) != BlockRegistry.AIR:
break

return Vector3(spawn_x + 0.5, spawn_y + 1, spawn_z + 0.5)

func save_world_data() -> Dictionary:
var data = {
"seed": world_seed,
"name": world_name,
"game_mode": game_mode,
"difficulty": current_difficulty,
"day_time": day_time,
"modified_blocks": {}
}

# Save only modified blocks
for key in chunks.keys():
var chunk = chunks[key]
if chunk.modified_blocks.size() > 0:
data["modified_blocks"][key] = chunk.modified_blocks

return data

func load_world_data(data: Dictionary) -> void:
if data.has("seed"):
world_seed = data["seed"]
if data.has("name"):
world_name = data["name"]
if data.has("game_mode"):
game_mode = data["game_mode"]
if data.has("difficulty"):
current_difficulty = data["difficulty"]
if data.has("day_time"):
day_time = data["day_time"]

# Apply modified blocks
if data.has("modified_blocks"):
for chunk_key in data["modified_blocks"].keys():
var blocks_data = data["modified_blocks"][chunk_key]
# Apply blocks to chunk when it loads
print("[WorldManager] Loaded ", blocks_data.size(), " modified blocks for chunk ", chunk_key)

func get_day_time() -> float:
return day_time

func set_day_time(time: float) -> void:
day_time = fposmod(time, 1.0)

func advance_day_time(delta: float) -> void:
day_time = fposmod(day_time + delta / Version.DAY_LENGTH_SECONDS, 1.0)

func get_sun_angle() -> float:
return day_time * TAU - PI / 2.0

func get_loaded_chunk_count() -> int:
return chunks.size()

func get_chunk_at(chunk_x: int, chunk_z: int) -> ChunkData:
var key = "%d,%d" % [chunk_x, chunk_z]
return chunks.get(key, null)
