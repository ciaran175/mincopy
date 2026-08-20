class_name ChunkData
extends RefCounted

## ChunkData - Stores voxel data for a single chunk
## Uses compact byte arrays for efficient memory usage

var chunk_x: int = 0
var chunk_z: int = 0
var size_x: int = 16
var size_y: int = 128
var size_z: int = 16

# Block data stored as PackedByteArray (one byte per block)
var blocks: PackedByteArray = PackedByteArray()

# Track which blocks have been modified from generation
var modified_blocks: Dictionary = {}  # key: "x,y,z", value: block_id

# Mesh state
var mesh_dirty: bool = true
var mesh_instance: MeshInstance3D = null
var collision_shape: CollisionShape3D = null

func _init(p_size_x: int = 16, p_size_y: int = 128, p_size_z: int = 16) -> void:
size_x = p_size_x
size_y = p_size_y
size_z = p_size_z

# Initialize all blocks to air (0)
blocks.resize(size_x * size_y * size_z)
for i in range(blocks.size()):
blocks[i] = 0

func get_index(local_x: int, y: int, local_z: int) -> int:
return local_x + (y * size_x * size_z) + (local_z * size_x)

func get_block(local_x: int, y: int, local_z: int) -> int:
if local_x < 0 or local_x >= size_x:
return BlockRegistry.AIR
if y < 0 or y >= size_y:
return BlockRegistry.AIR
if local_z < 0 or local_z >= size_z:
return BlockRegistry.AIR

var index = get_index(local_x, y, local_z)
return blocks[index]

func set_block(local_x: int, y: int, local_z: int, block_id: int) -> void:
if local_x < 0 or local_x >= size_x:
return
if y < 0 or y >= size_y:
return
if local_z < 0 or local_z >= size_z:
return

var index = get_index(local_x, y, local_z)
blocks[index] = block_id

# Track modification
var key = "%d,%d,%d" % [local_x, y, local_z]
modified_blocks[key] = block_id

mesh_dirty = true

func is_block_solid(local_x: int, y: int, local_z: int) -> bool:
var block_id = get_block(local_x, y, local_z)
return BlockRegistry.is_block_solid(block_id)

func is_block_transparent(local_x: int, y: int, local_z: int) -> bool:
var block_id = get_block(local_x, y, local_z)
return BlockRegistry.is_block_transparent(block_id)

func should_render_face(local_x: int, y: int, local_z: int, direction: Vector3i) -> bool:
var neighbor_x = local_x + direction.x
var neighbor_y = y + direction.y
var neighbor_z = local_z + direction.z

# Out of bounds - check neighboring chunk
if neighbor_x < 0 or neighbor_x >= size_x or \
   neighbor_z < 0 or neighbor_z >= size_z:
return true  # Render face at chunk boundary

if neighbor_y < 0 or neighbor_y >= size_y:
return true  # Render face at world boundary

# Don't render if neighbor is solid and not transparent
var neighbor_id = get_block(neighbor_x, neighbor_y, neighbor_z)
if BlockRegistry.is_block_solid(neighbor_id):
if not BlockRegistry.is_block_transparent(neighbor_id):
return false

return true

func get_world_position() -> Vector3:
return Vector3(chunk_x * size_x, 0, chunk_z * size_z)

func clear_modified() -> void:
modified_blocks.clear()

func get_modified_blocks_data() -> Dictionary:
return modified_blocks.duplicate()

func apply_modified_blocks(modified: Dictionary) -> void:
for key in modified.keys():
var parts = key.split(",")
var x = int(parts[0])
var y = int(parts[1])
var z = int(parts[2])
var block_id = int(modified[key])
set_block(x, y, z, block_id)
