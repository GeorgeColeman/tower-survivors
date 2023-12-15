class_name Game
extends RefCounted

signal difficulty_changed(difficulty: float)
signal game_over()

static var speed: float = 1
static var speed_scaled_delta: float

var map: Map
var player: Player
var tower: Tower
var mob_spawner: MobSpawner
var game_data: GameData
var building_options: BuildingOptions

var time: float
var is_paused: bool

var _current_minute = 1 as int
var _difficulty: float = 1
var _resume_speed: float = speed


func _init(p_map: Map, p_mob_spawner: MobSpawner, p_game_data: GameData):
	map = p_map
	mob_spawner = p_mob_spawner
	game_data = p_game_data
	building_options = BuildingOptions.new()

	building_options.option_upgraded.connect(func(option: BuildingOption): print_debug("option added. TODO: rank up existing towers"))


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
		speed = _resume_speed
	else:
		is_paused = true
		_resume_speed = speed
		speed = 0

	return is_paused


func set_player(p_player: Player):
	player = p_player
	player.levelled_up.connect(
		func():
			#print_debug(GameUtilities.generate_upgrade_options(3).str)
			pause_game()
	)


func pause_game():
	if !is_paused:
		_resume_speed = speed

	is_paused = true
	speed = 0


func resume_game():
	is_paused = false
	speed = _resume_speed


func set_tower(tower: Tower):
	self.tower = tower
	tower.was_killed.connect(_on_tower_was_killed)


func add_difficulty(amount: float):
	_difficulty += amount
	difficulty_changed.emit(_difficulty)

	Messenger.request_floating_text("Game difficulty increased. Current difficulty: %s." % str(_difficulty))


func _on_tower_was_killed():
	game_over.emit()
