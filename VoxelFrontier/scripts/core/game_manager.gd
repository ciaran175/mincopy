extends Node

## GameManager - Core game state and lifecycle management
## Handles game initialization, state transitions, and global systems

signal game_state_changed(old_state: int, new_state: int)
signal world_loaded(world_name: String)
signal world_unloaded()

enum GameState {
NONE,
MAIN_MENU,
CREATING_WORLD,
LOADING_WORLD,
PLAYING,
PAUSED,
SAVING
}

var current_state: GameState = GameState.NONE
var current_world_data: Dictionary = {}
var player_data: Dictionary = {}
var settings: Dictionary = {}
var is_quitting: bool = false

# Singleton reference
static var instance: GameManager

func _ready() -> void:
instance = self
_initialize_settings()
_change_state(GameState.MAIN_MENU)
print("[GameManager] Initialized - Voxel Frontier ", Version.get_version_number())

func _initialize_settings() -> void:
settings = {
"video": {
"render_distance": Version.RENDER_DISTANCE_DEFAULT,
"fov": 75.0,
"fullscreen": false,
"vsync": true,
"graphics_quality": "medium"
},
"audio": {
"master_volume": 1.0,
"music_volume": 0.7,
"sfx_volume": 1.0
},
"controls": {
"mouse_sensitivity": 1.0,
"invert_y": false
},
"gameplay": {
"autosave_interval": 60.0,
"view_bobbing": true,
"difficulty": Difficulty.NORMAL
}
}
_load_settings()

func _load_settings() -> void:
var save_path = "user://settings/settings.json"
if FileAccess.file_exists(save_path):
var file = FileAccess.open(save_path, FileAccess.READ)
if file:
var json_string = file.get_as_text()
var json = JSON.new()
var error = json.parse(json_string)
if error == OK:
settings = json.data
print("[GameManager] Settings loaded from ", save_path)
else:
push_warning("[GameManager] Failed to parse settings: ", json.get_error_message())
else:
_save_settings()

func _save_settings() -> void:
var save_path = "user://settings/settings.json"
DirAccess.make_dir_recursive_absolute("user://settings")
var file = FileAccess.open(save_path, FileAccess.WRITE)
if file:
file.store_string(JSON.stringify(settings, "\t"))
print("[GameManager] Settings saved to ", save_path)

func _change_state(new_state: GameState) -> void:
var old_state = current_state
current_state = new_state
game_state_changed.emit(old_state, new_state)

match new_state:
GameState.MAIN_MENU:
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
GameState.PLAYING:
Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
GameState.PAUSED:
Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func start_main_menu() -> void:
_change_state(GameState.MAIN_MENU)
var main_menu_scene = load("res://scenes/main/main_menu.tscn")
if main_menu_scene:
get_tree().change_scene_to_packed(main_menu_scene)

func create_new_world(world_config: Dictionary) -> Error:
_change_state(GameState.CREATING_WORLD)
current_world_data = world_config

# Generate seed if not provided
if not world_config.has("seed") or world_config["seed"] == "":
world_config["seed"] = str(randi())

# Set defaults
world_config["created_at"] = Time.get_datetime_string_from_system()
world_config["game_mode"] = world_config.get("game_mode", Version.GameMode.SURVIVAL)
world_config["difficulty"] = world_config.get("difficulty", Difficulty.NORMAL)
world_config["play_time"] = 0.0

print("[GameManager] Creating new world: ", world_config["name"], " (seed: ", world_config["seed"], ")")

# Transition to loading
_change_state(GameState.LOADING_WORLD)
return OK

func load_world(world_name: String) -> Error:
_change_state(GameState.LOADING_WORLD)

var world_path = "user://worlds/%s/" % world_name
if not DirAccess.dir_exists_absolute(world_path):
push_error("[GameManager] World not found: ", world_name)
_change_state(GameState.MAIN_MENU)
return ERR_FILE_NOT_FOUND

# Load world metadata
var metadata_path = world_path + "metadata.json"
if FileAccess.file_exists(metadata_path):
var file = FileAccess.open(metadata_path, FileAccess.READ)
var json = JSON.new()
var error = json.parse(file.get_as_text())
if error == OK:
current_world_data = json.data
print("[GameManager] Loaded world: ", world_name)
world_loaded.emit(world_name)
_change_state(GameState.PLAYING)
return OK
else:
push_error("[GameManager] Failed to parse world metadata: ", json.get_error_message())

push_error("[GameManager] Failed to load world: ", world_name)
_change_state(GameState.MAIN_MENU)
return ERR_FILE_CORRUPT

func save_current_world() -> Error:
if current_world_data.is_empty():
return ERR_DOES_NOT_EXIST

_change_state(GameState.SAVING)

var world_name = current_world_data.get("name", "unknown")
var world_path = "user://worlds/%s/" % world_name
DirAccess.make_dir_recursive_absolute(world_path)

# Update play time
if has_node("/root/WorldManager"):
current_world_data["last_played"] = Time.get_datetime_string_from_system()

# Save metadata
var metadata_path = world_path + "metadata.json"
var temp_path = world_path + "metadata.json.tmp"
var file = FileAccess.open(temp_path, FileAccess.WRITE)
if file:
file.store_string(JSON.stringify(current_world_data, "\t"))
file.close()

# Atomic replace
DirAccess.remove_absolute(metadata_path)
DirAccess.rename_absolute(temp_path, metadata_path)

print("[GameManager] World saved: ", world_name)
_change_state(GameState.PLAYING)
return OK

push_error("[GameManager] Failed to save world: ", world_name)
_change_state(GameState.PLAYING)
return ERR_CANT_CREATE

func unload_world() -> void:
if not current_world_data.is_empty():
save_current_world()
current_world_data.clear()
player_data.clear()
world_unloaded.emit()
print("[GameManager] World unloaded")
_change_state(GameState.MAIN_MENU)

func quit_game() -> void:
is_quitting = true
if not current_world_data.is_empty():
save_current_world()
get_tree().quit()

func get_setting(category: String, key: String, default = null):
if settings.has(category) and settings[category].has(key):
return settings[category][key]
return default

func set_setting(category: String, key: String, value) -> void:
if not settings.has(category):
settings[category] = {}
settings[category][key] = value
_save_settings()

func get_player_data() -> Dictionary:
return player_data.duplicate(true)

func set_player_data(data: Dictionary) -> void:
player_data = data.duplicate(true)

func get_current_state() -> GameState:
return current_state

func is_world_loaded() -> bool:
return not current_world_data.is_empty()
