class_name Game
extends RefCounted

signal speed_changed(speed: float)
signal game_over()

static var speed: float
static var speed_scaled_delta: float

var map: Map
var player: Player
var tower: Tower
var entities: Entities
var mob_spawner: MobSpawner
var game_data: GameData
var building_options: BuildingOptions
var upgrades_manager: UpgradeOptionsGenerator
var difficulty: Difficulty

var time: float
var is_paused: bool

var _speed: float
var _current_minute = 1 as int
var _resume_speed: float = _speed


func _init(p_map: Map, p_mob_spawner: MobSpawner, p_game_data: GameData):
	map = p_map
	entities = Entities.new(self)
	mob_spawner = p_mob_spawner
	game_data = p_game_data
	building_options = BuildingOptions.new()
	upgrades_manager = UpgradeOptionsGenerator.new()
	difficulty = Difficulty.new()

	set_speed(1)


func process(delta: float):
	# This is the only place we calculate delta based on game speed
	speed_scaled_delta = delta * _speed

	time += speed_scaled_delta

	difficulty.process(speed_scaled_delta)

	if time > _current_minute * 60:
		_current_minute += 1
		difficulty.increase_by(1)


func set_speed(p_speed: float):
	_speed = p_speed
	speed = p_speed

	speed_changed.emit(p_speed)


func toggle_pause() -> bool:
	if is_paused:
		resume_game()
	else:
		pause_game()

	return is_paused


func set_player(p_player: Player):
	player = p_player
	player.levelled_up.connect(
		func():
			pause_game()
			generate_new_upgrade_options_for_player()
	)

	player.upgrades.perk_added.connect(
		func(perk: Perk):
			entities.apply_perk_to_existing_towers(perk)
	)

	player.upgrades.passive_rank_added.connect(
		func(passive: PassivePerk):
			entities.apply_passive_rank_to_existing_towers(passive)
	)

	player.gold_changed.connect(
		func(_gold: int):
			building_options.update_build_options_can_build(player)
	)

	player.cores_changed.connect(
		func(_cores: int):
			building_options.update_build_options_can_build(player)
	)


func generate_new_upgrade_options_for_player():
	player.upgrades.set_upgrade_options(upgrades_manager.generate_upgrade_options(self, 3))


func pause_game():
	if !is_paused:
		_resume_speed = _speed

	is_paused = true
	set_speed(0)


func resume_game():
	is_paused = false
	set_speed(_resume_speed)


func set_main_tower(p_tower: Tower):
	tower = p_tower
	p_tower.was_killed.connect(_on_main_tower_was_killed)


func _on_main_tower_was_killed():
	game_over.emit()
