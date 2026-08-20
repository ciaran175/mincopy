extends Node

## InputManager - Handles input actions and events
## Centralizes input handling for the game

signal mine_pressed()
signal place_pressed()
signal hotbar_changed(slot: int)
signal inventory_requested()
signal pause_requested()
signal debug_toggle()

var current_hotbar_slot: int = 0
var mouse_sensitivity: float = 1.0

func _ready() -> void:
print("[InputManager] Initialized")

func _input(event: InputEvent) -> void:
# Hotbar number keys
if event is InputEventKey and event.pressed:
match event.keycode:
KEY_1: _set_hotbar_slot(0)
KEY_2: _set_hotbar_slot(1)
KEY_3: _set_hotbar_slot(2)
KEY_4: _set_hotbar_slot(3)
KEY_5: _set_hotbar_slot(4)
KEY_6: _set_hotbar_slot(5)
KEY_7: _set_hotbar_slot(6)
KEY_8: _set_hotbar_slot(7)
KEY_9: _set_hotbar_slot(8)
KEY_E:
if GameManager.instance.get_current_state() == GameManager.GameState.PLAYING:
inventory_requested.emit()
KEY_ESCAPE:
pause_requested.emit()
KEY_F3:
debug_toggle.emit()

# Mouse wheel for hotbar
if event is InputEventMouseButton and event.pressed:
if event.button_index == MOUSE_BUTTON_WHEEL_UP:
_set_hotbar_slot((current_hotbar_slot - 1) % 9)
elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
_set_hotbar_slot((current_hotbar_slot + 1) % 9)

# Mine action
if Input.is_action_just_pressed("mine"):
mine_pressed.emit()

# Place action
if Input.is_action_just_pressed("place"):
place_pressed.emit()

func _set_hotbar_slot(slot: int) -> void:
current_hotbar_slot = slot
hotbar_changed.emit(slot)

func get_current_hotbar_slot() -> int:
return current_hotbar_slot

func set_mouse_sensitivity(sensitivity: float) -> void:
mouse_sensitivity = sensitivity
# Apply to player if exists
var player = get_tree().get_first_node_in_group("player")
if player and player.has_script():
player.mouse_sensitivity = mouse_sensitivity * 0.002

func get_mouse_sensitivity() -> float:
return mouse_sensitivity
