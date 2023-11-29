class_name Game
extends RefCounted

signal difficulty_changed(difficulty: float)
signal game_over()

static var speed: float = 1
static var speed_scaled_delta: float

var map: Map
var tower: Tower
var mob_spawner: MobSpawner
var game_data: GameData

var time: float
var is_paused: bool

var _current_minute = 1 as int
var _difficulty: float = 1
var _unpause_speed: float = speed


func _init(map: Map, mob_spawner: MobSpawner, game_data: GameData):
	self.map = map
	self.mob_spawner = mob_spawner
	self.game_data = game_data


func process(delta: float):
	# This is the only place we calculate delta based on game speed
	speed_scaled_delta = delta * speed

	time += speed_scaled_delta

	if time > _current_minute * 60:
		_current_minute += 1
		add_difficulty(1)


func toggle_pause() -> bool:
	if is_paused:
		is_paused = false
		speed = _unpause_speed
	else:
		is_paused = true
		_unpause_speed = speed
		speed = 0

	return is_paused


func set_tower(tower: Tower):
	self.tower = tower
	tower.was_killed.connect(_on_tower_was_killed)


func add_difficulty(amount: float):
	_difficulty += amount
	difficulty_changed.emit(_difficulty)

	Messenger.request_floating_text("Game difficulty increased. Current difficulty: %s." % str(_difficulty))


func _on_tower_was_killed():
	game_over.emit()
