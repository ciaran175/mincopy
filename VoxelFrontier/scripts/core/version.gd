extends Node

## Voxel Frontier - Version Information
## Central version tracking for the game

const VERSION_MAJOR: int = 0
const VERSION_MINOR: int = 1
const VERSION_PATCH: int = 0
const VERSION_STATUS: String = "Alpha"

const GAME_TITLE: String = "Voxel Frontier"
const GAME_VERSION_STRING: String = "v0.1.0 Alpha"

# Build information
const BUILD_DATE: String = __DATE__
const BUILD_TIME: String = __TIME__

# Configuration constants
const TICKS_PER_SECOND: int = 20
const DAY_LENGTH_SECONDS: float = 1200.0  # 20 minutes per full day
const CHUNK_SIZE: int = 16
const CHUNK_HEIGHT: int = 128
const RENDER_DISTANCE_DEFAULT: int = 6
const MAX_RENDER_DISTANCE: int = 16
const MIN_RENDER_DISTANCE: int = 2

# Game modes
enum GameMode {
	SURVIVAL,
	CREATIVE
}

# Difficulty levels
enum Difficulty {
	PEACEFUL,
	EASY,
	NORMAL,
	HARD
}

static func get_full_version_string() -> String:
	return "%s %s %d.%d.%d" % [GAME_TITLE, VERSION_STATUS, VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH]

static func get_version_number() -> String:
	return "%d.%d.%d" % [VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH]

static func is_development_build() -> bool:
	return VERSION_MAJOR == 0
