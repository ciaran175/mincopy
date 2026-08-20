extends CharacterBody3D

## PlayerController - First-person player movement and camera control
## Handles WASD movement, jumping, sprinting, and mouse look

signal health_changed(new_health: float)
signal hunger_changed(new_hunger: float)
signal block_mined(position: Vector3i, block_id: int)
signal block_placed(position: Vector3i, block_id: int)

# Movement settings
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 6.0
@export var acceleration: float = 10.0
@export var friction: float = 8.0
@export var air_control: float = 0.3

# Camera settings
@export var mouse_sensitivity: float = 0.002
@export var min_pitch: float = -89.0
@export var max_pitch: float = 89.0

# Physics
@export var gravity: float = -20.0
@export var player_height: float = 1.8
@export var player_radius: float = 0.4

# Survival stats
var health: float = 100.0
var max_health: float = 100.0
var hunger: float = 100.0
var max_hunger: float = 100.0

# State
var is_sprinting: bool = false
var is_grounded: bool = false
var current_speed: float = 5.0

# Camera pivot
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera

# Raycast for block interaction
@onready var raycast: RayCast3D = $CameraPivot/Camera/BlockRaycast

# Reach distance
var reach_distance: float = 5.0

# Creative mode flight
var is_flying: bool = false
var fly_speed: float = 10.0

func _ready() -> void:
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
raycast.target_position = Vector3(0, 0, -reach_distance)
current_speed = walk_speed
print("[PlayerController] Initialized")

func _input(event: InputEvent) -> void:
if GameManager.instance.get_current_state() != GameManager.GameState.PLAYING:
return

# Mouse look
if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
var motion = event.relative
rotate_y(-motion.x * mouse_sensitivity)
camera_pivot.rotate_x(-motion.y * mouse_sensitivity)
camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

# Toggle mouse capture on pause
if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
else:
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
if GameManager.instance.get_current_state() != GameManager.GameState.PLAYING:
return

_handle_input(delta)
_apply_gravity(delta)
_apply_movement(delta)
move_and_slide()
is_grounded = is_on_floor()

# Update chunks through WorldManager
if WorldManager.instance:
WorldManager.instance.update_chunks_around_player(global_position.x, global_position.z)

func _handle_input(delta: float) -> void:
# Sprint
is_sprinting = Input.is_action_pressed("sprint") and not is_flying
current_speed = sprint_speed if is_sprinting else walk_speed

# Creative flight toggle (double-tap space would be better, but simple version here)
if Input.is_action_just_pressed("jump") and is_flying:
pass  # Could add flight toggle logic

# Jump
if Input.is_action_just_pressed("jump") and is_grounded and not is_flying:
velocity.y = jump_velocity

# Flight movement
if is_flying:
var fly_move = Vector3.ZERO
if Input.is_action_pressed("move_forward"):
fly_move -= transform.basis.z
if Input.is_action_pressed("move_backward"):
fly_move += transform.basis.z
if Input.is_action_pressed("move_left"):
fly_move -= transform.basis.x
if Input.is_action_pressed("move_right"):
fly_move += transform.basis.x

fly_move = fly_move.normalized()

var vertical = 0.0
if Input.is_action_pressed("jump"):
vertical = 1.0
if Input.is_action_pressed("sprint"):
vertical = -1.0

velocity.x = lerp(velocity.x, fly_move.x * fly_speed, acceleration * delta)
velocity.z = lerp(velocity.z, fly_move.z * fly_speed, acceleration * delta)
velocity.y = lerp(velocity.y, vertical * fly_speed, acceleration * delta)
return

func _apply_gravity(delta: float) -> void:
if not is_flying:
if not is_on_floor():
velocity.y += gravity * delta

func _apply_movement(delta: float) -> void:
if is_flying:
return

var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

if direction:
var target_speed = current_speed
var accel = acceleration

# Reduced air control
if not is_grounded:
accel *= air_control

velocity.x = lerp(velocity.x, direction.x * target_speed, accel * delta)
velocity.z = lerp(velocity.z, direction.z * target_speed, accel * delta)
else:
# Apply friction when no input
var friction_amount = friction if is_grounded else friction * 0.3
velocity.x = lerp(velocity.x, 0.0, friction_amount * delta)
velocity.z = lerp(velocity.z, 0.0, friction_amount * delta)

func get_target_block() -> Dictionary:
raycast.force_raycast_update()

if raycast.is_colliding():
var collision_point = raycast.get_collision_point()
var normal = raycast.get_collision_normal()

# Get block position (the block being looked at)
var block_pos = Vector3i(floor(collision_point.x), floor(collision_point.y), floor(collision_point.z))

# Get placement position (adjacent block)
var place_pos = Vector3i(
floor(collision_point.x + normal.x * 0.5),
floor(collision_point.y + normal.y * 0.5),
floor(collision_point.z + normal.z * 0.5)
)

return {
"hit": true,
"block_pos": block_pos,
"place_pos": place_pos,
"normal": normal,
"distance": global_position.distance_to(collision_point)
}

return {"hit": false}

func mine_block() -> bool:
var target = get_target_block()
if not target.has("hit") or not target["hit"]:
return false

var block_pos = target["block_pos"]
var block_id = WorldManager.instance.get_block(block_pos.x, block_pos.y, block_pos.z)

if BlockRegistry.is_block_breakable(block_id):
# Check game mode
if GameManager.current_world_data.get("game_mode", Version.GameMode.SURVIVAL) == Version.GameMode.CREATIVE:
WorldManager.instance.set_block(block_pos.x, block_pos.y, block_pos.z, BlockRegistry.AIR)
block_mined.emit(block_pos, block_id)
return true

# TODO: Add mining progress based on tool and hardness
WorldManager.instance.set_block(block_pos.x, block_pos.y, block_pos.z, BlockRegistry.AIR)
block_mined.emit(block_pos, block_id)
return true

return false

func place_block(block_id: int) -> bool:
var target = get_target_block()
if not target.has("hit") or not target["hit"]:
return false

var place_pos = target["place_pos"]

# Don't place block inside player
var player_box = AABB(global_position - Vector3(player_radius, 0, player_radius), 
Vector3(player_radius * 2, player_height, player_radius * 2))

var block_box = AABB(Vector3(place_pos), Vector3.ONE)
if player_box.intersects(block_box):
return false

# Check if there's already a solid block there
var existing_block = WorldManager.instance.get_block(place_pos.x, place_pos.y, place_pos.z)
if BlockRegistry.is_block_solid(existing_block):
return false

if GameManager.current_world_data.get("game_mode", Version.GameMode.SURVIVAL) == Version.GameMode.CREATIVE:
WorldManager.instance.set_block(place_pos.x, place_pos.y, place_pos.z, block_id)
block_placed.emit(place_pos, block_id)
return true

# TODO: Check if player has the block in inventory
WorldManager.instance.set_block(place_pos.x, place_pos.y, place_pos.z, block_id)
block_placed.emit(place_pos, block_id)
return true

func take_damage(amount: float) -> void:
if GameManager.current_world_data.get("game_mode", Version.GameMode.SURVIVAL) == Version.GameMode.CREATIVE:
return

health = max(0.0, health - amount)
health_changed.emit(health)

if health <= 0.0:
die()

func heal(amount: float) -> void:
health = min(max_health, health + amount)
health_changed.emit(health)

func die() -> void:
print("[PlayerController] Player died!")
# TODO: Implement death screen and respawn
health = max_health
hunger = max_hunger

func consume_hunger(amount: float) -> void:
if GameManager.current_world_data.get("game_mode", Version.GameMode.SURVIVAL) == Version.GameMode.CREATIVE:
return

hunger = max(0.0, hunger - amount)
hunger_changed.emit(hunger)

func eat(food_value: float) -> void:
hunger = min(max_hunger, hunger + food_value)
hunger_changed.emit(hunger)

func set_game_mode(mode: int) -> void:
if mode == Version.GameMode.CREATIVE:
is_flying = true
health = max_health
else:
is_flying = false
current_speed = walk_speed

func get_eye_position() -> Vector3:
return global_position + Vector3(0, player_height - 0.2, 0)

func get_eye_direction() -> Vector3:
return -global_transform.basis.z
