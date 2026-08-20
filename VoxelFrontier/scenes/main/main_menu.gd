extends Control

## MainMenu - Main menu UI handler
## Handles world creation, loading, settings, and quitting

@onready var version_label: Label = $MarginContainer/VBoxContainer/VersionLabel
@onready var new_world_panel: Panel = $NewWorldPanel
@onready var load_world_panel: Panel = $LoadWorldPanel
@onready var settings_panel: Panel = $SettingsPanel

@onready var world_name_input: LineEdit = $NewWorldPanel/MarginContainer/VBoxContainer/WorldNameInput
@onready var seed_input: LineEdit = $NewWorldPanel/MarginContainer/VBoxContainer/SeedInput
@onready var game_mode_select: OptionButton = $NewWorldPanel/MarginContainer/VBoxContainer/GameModeSelect
@onready var difficulty_select: OptionButton = $NewWorldPanel/MarginContainer/VBoxContainer/DifficultySelect

@onready var world_list: ItemList = $LoadWorldPanel/MarginContainer/VBoxContainer/WorldList

var worlds_dir: String = "user://worlds/"

func _ready() -> void:
version_label.text = Version.GAME_VERSION_STRING
_refresh_world_list()
print("[MainMenu] Ready")

func _on_new_world_button_pressed() -> void:
new_world_panel.visible = true
load_world_panel.visible = false
settings_panel.visible = false

func _on_load_world_button_pressed() -> void:
new_world_panel.visible = false
load_world_panel.visible = true
settings_panel.visible = false
_refresh_world_list()

func _on_settings_button_pressed() -> void:
new_world_panel.visible = false
load_world_panel.visible = false
settings_panel.visible = true

func _on_quit_button_pressed() -> void:
GameManager.instance.quit_game()

func _on_create_world_button_pressed() -> void:
var world_name = world_name_input.text.strip_edges()
if world_name.is_empty():
world_name = "World %d" % int(Time.get_unix_time_from_system())

var seed = seed_input.text.strip_edges()
var game_mode = game_mode_select.selected
var difficulty = difficulty_select.selected

var world_config = {
"name": world_name,
"seed": seed,
"game_mode": game_mode,
"difficulty": difficulty
}

GameManager.instance.create_new_world(world_config)
_transition_to_game()

func _on_cancel_new_world_button_pressed() -> void:
new_world_panel.visible = false

func _on_play_selected_button_pressed() -> void:
var selected = world_list.get_selected_items()
if selected.size() > 0:
var world_name = world_list.get_item_text(selected[0])
var error = GameManager.instance.load_world(world_name)
if error == OK:
_transition_to_game()

func _on_cancel_load_button_pressed() -> void:
load_world_panel.visible = false

func _on_cancel_settings_button_pressed() -> void:
settings_panel.visible = false

func _refresh_world_list() -> void:
world_list.clear()

if not DirAccess.dir_exists_absolute(worlds_dir):
return

var dir = DirAccess.open(worlds_dir)
if dir:
dir.list_dir_begin()
var file_name = dir.get_next()
while file_name != "":
if dir.current_is_dir() and not file_name.begins_with("."):
world_list.add_item(file_name)
file_name = dir.get_next()
dir.list_dir_end()

func _transition_to_game() -> void:
# Hide all panels
new_world_panel.visible = false
load_world_panel.visible = false
settings_panel.visible = false
visible = false

# Load game scene
var game_scene = load("res://scenes/main/game_world.tscn")
if game_scene:
get_tree().change_scene_to_packed(game_scene)
