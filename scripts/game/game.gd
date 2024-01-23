class_name Game
extends RefCounted

signal speed_changed(speed: float)
signal game_over()
signal run_state_changed(run_state: RunState)

static var speed: float
static var speed_scaled_delta: float

var map: Map
var player: Player
var tower: Tower
var entities: Entities
var mob_spawner: MobSpawner
var game_data: GameData
var building_options: BuildingOptions
var difficulty: Difficulty
var upgrades_manager: UpgradesManager

var time: float

var _run_state: RunState
var _speed: float
var _resume_speed: float = _speed


func _init(p_map: Map, p_mob_spawner: MobSpawner, p_game_data: GameData):
	map = p_map
	entities = Entities.new(self)
	mob_spawner = p_mob_spawner
	game_data = p_game_data
	building_options = BuildingOptions.new()
	difficulty = Difficulty.new()

	set_speed(1)


func process(delta: float):
	# This is the only place we calculate delta based on game speed
	speed_scaled_delta = delta * _speed

	time += speed_scaled_delta

	difficulty.process(speed_scaled_delta)


func set_speed(p_speed: float):
	_speed = p_speed
	speed = p_speed

	speed_changed.emit(p_speed)


func toggle_pause():
	match _run_state:
		RunState.RUNNING:
			_pause_game()
		RunState.PAUSED:
			_resume_game()


func set_player(p_player: Player):
	player = p_player
	player.levelled_up.connect(
		func():
			_pause_game_await_input()
	)

	upgrades_manager = UpgradesManager.new(
		building_options,
		player.upgrades,
		entities
	)

	upgrades_manager.game_data = game_data
	upgrades_manager.set_player(player)


func accept_input_and_resume():
	_set_run_state(RunState.RUNNING)
	set_speed(_resume_speed)


func _pause_game():
	if _run_state == RunState.RUNNING:
		_resume_speed = _speed

	_set_run_state(RunState.PAUSED)
	set_speed(0)


func _resume_game():
	if _run_state == RunState.PAUSED_AWATING_INPUT:
		print_debug("Run state is awaiting input. Cannot resume normally")

		return

	_set_run_state(RunState.RUNNING)
	set_speed(_resume_speed)


func _pause_game_await_input():
	if _run_state == RunState.RUNNING:
		_resume_speed = _speed

	_set_run_state(RunState.PAUSED_AWATING_INPUT)

	set_speed(0)


func init_player_character(player_character_name: String):
	var player_character: PlayerCharacter = game_data.player_character_dict[player_character_name]

	var params = SpawnEntityParams.new()
	params.entity_scene = player_character.main_tower.tower_scene
	params.cell = map.center_cell

	entities.spawn_tower(player_character.main_tower, params)
	set_main_tower(params.spawned_entity)

	building_options.add_building_option(player_character.main_tower, player)

	for tower in player_character.starting_towers:
		building_options.add_building_option(tower, player)


func set_main_tower(p_tower: Tower):
	tower = p_tower
	p_tower.was_killed.connect(_on_main_tower_was_killed)


func _on_main_tower_was_killed():
	game_over.emit()


func _set_run_state(run_state: RunState):
	_run_state = run_state

	run_state_changed.emit(run_state)


enum RunState {
	RUNNING,
	PAUSED,
	PAUSED_AWATING_INPUT			# GPT suggested 'DECISION TIME'
}
