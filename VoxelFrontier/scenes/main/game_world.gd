extends Node3D

## GameWorld - Main game scene handler
## Manages the player, world, UI, and game loop during gameplay

@onready var player: CharacterBody3D = $Player
@onready var world_manager: Node = $WorldManager
@onready var ui_layer: CanvasLayer = $UILayer
@onready var pause_menu: Control = $UILayer/PauseMenu
@onready var hud: Control = $UILayer/HUD
@onready var inventory_screen: Control = $UILayer/InventoryScreen
@onready var debug_overlay: Label = $UILayer/DebugOverlay

var is_paused: bool = false
var _autosave_timer: float = 0.0
var _debug_visible: bool = false

func _ready() -> void:
print("[GameWorld] Initializing game world")

# Connect signals
InputManager.instance.mine_pressed.connect(_on_mine_pressed)
InputManager.instance.place_pressed.connect(_on_place_pressed)
InputManager.instance.inventory_requested.connect(_on_inventory_requested)
InputManager.instance.pause_requested.connect(_on_pause_requested)
InputManager.instance.debug_toggle.connect(_toggle_debug)

# Initialize WorldManager with current world data
var world_data = GameManager.current_world_data
if world_data.is_empty():
push_error("[GameWorld] No world data loaded!")
return

world_manager.initialize_world(
world_data.get("seed", "default"),
world_data.get("name", "unknown"),
world_data.get("game_mode", Version.GameMode.SURVIVAL),
world_data.get("difficulty", Difficulty.NORMAL)
)

# Setup player
var spawn_pos = world_manager.get_spawn_position()
player.global_position = spawn_pos
player.set_game_mode(world_data.get("game_mode", Version.GameMode.SURVIVAL))

# Hide pause menu initially
pause_menu.visible = false

# Apply settings
var sensitivity = GameManager.instance.get_setting("controls", "mouse_sensitivity", 1.0)
InputManager.instance.set_mouse_sensitivity(sensitivity)

print("[GameWorld] Game world ready - spawned at ", spawn_pos)

func _process(delta: float) -> void:
if is_paused:
return

# Update day/night cycle
if world_manager:
world_manager.advance_day_time(delta)

# Autosave timer
_autosave_timer += delta
var autosave_interval = GameManager.instance.get_setting("gameplay", "autosave_interval", 60.0)
if _autosave_timer >= autosave_interval:
_autosave_timer = 0.0
_autosave()

# Update debug overlay
if _debug_visible:
_update_debug_overlay()

func _input(event: InputEvent) -> void:
if event is InputEventKey and event.pressed:
if event.keycode == KEY_ESCAPE:
_toggle_pause()
elif event.keycode == KEY_F5:
_quick_save()

func _on_mine_pressed() -> void:
if is_paused or not player:
return
player.mine_block()

func _on_place_pressed() -> void:
if is_paused or not player:
return
# Get selected block from inventory (placeholder - will use actual inventory later)
var selected_slot = InputManager.instance.get_current_hotbar_slot()
var block_to_place = BlockRegistry.DIRT  # Placeholder
player.place_block(block_to_place)

func _on_inventory_requested() -> void:
if is_paused:
return
inventory_screen.visible = not inventory_screen.visible
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if inventory_screen.visible else Input.MOUSE_MODE_CAPTURED

func _on_pause_requested() -> void:
_toggle_pause()

func _toggle_pause() -> void:
is_paused = not is_paused
pause_menu.visible = is_paused
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if is_paused else Input.MOUSE_MODE_CAPTURED
get_tree().paused = is_paused

func _toggle_debug() -> void:
_debug_visible = not _debug_visible
debug_overlay.visible = _debug_visible

func _update_debug_overlay() -> void:
if not player or not world_manager:
return

var fps = Performance.get_monitor(Performance.TIME_FPS)
var pos = player.global_position
var chunk_x = floori(pos.x / Version.CHUNK_SIZE)
var chunk_z = floori(pos.z / Version.CHUNK_SIZE)
var biome = TerrainGenerator.get_biome_name(floori(pos.x), floori(pos.z))

debug_overlay.text = """VOXEL FRONTIER %s
FPS: %d
Position: %.1f, %.1f, %.1f
Chunk: %d, %d
Loaded Chunks: %d
Biome: %s
Day Time: %.2f
Seed: %s""" % [
Version.GAME_VERSION_STRING,
fps,
pos.x, pos.y, pos.z,
chunk_x, chunk_z,
world_manager.get_loaded_chunk_count(),
biome,
world_manager.get_day_time(),
world_manager.world_seed
]

func _autosave() -> void:
print("[GameWorld] Autosaving...")
GameManager.instance.save_current_world()

func _quick_save() -> void:
print("[GameWorld] Quick saving...")
GameManager.instance.save_current_world()

func _on_resume_button_pressed() -> void:
_toggle_pause()

func _on_save_world_button_pressed() -> void:
GameManager.instance.save_current_world()

func _on_settings_menu_button_pressed() -> void:
# Open settings UI (to be implemented)
pass

func _on_main_menu_button_pressed() -> void:
GameManager.instance.unload_world()

func _on_quit_to_desktop_button_pressed() -> void:
GameManager.instance.quit_game()
