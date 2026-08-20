extends Node

## EventManager - Central event bus for game events
## Decouples systems by providing publish/subscribe functionality

signal block_changed(position: Vector3i, old_id: int, new_id: int)
signal item_picked_up(item_id: int, amount: int)
signal player_died()
signal player_respawned()
signal day_time_changed(time: float)
signal weather_changed(weather_type: String)

# Event subscribers
var _subscribers: Dictionary = {}

func _ready() -> void:
print("[EventManager] Initialized")

func subscribe(event_name: String, callback: Callable) -> void:
if not _subscribers.has(event_name):
_subscribers[event_name] = []
_subscribers[event_name].append(callback)

func unsubscribe(event_name: String, callback: Callable) -> void:
if _subscribers.has(event_name):
_subscribers[event_name].erase(callback)

func emit_event(event_name: String, data: Variant = null) -> void:
if _subscribers.has(event_name):
for callback in _subscribers[event_name]:
if data != null:
callback.call(data)
else:
callback.call()

func clear_subscribers() -> void:
_subscribers.clear()
