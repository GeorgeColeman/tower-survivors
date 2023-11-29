class_name MobSpawner
extends Node

@export var spawn_point_scene: PackedScene
@export var starting_spawn_points = 3 as int
@export var mob_killed_sfx: AudioStream
@export var mob_hit_sfx: AudioStream

var _game: Game
var _map: Map
var _cell_mob_dict = {}
var _cell_spawn_point_dict = {}


func get_mob_targets(cells: Array[Cell]) -> Array[Mob]:
	var mob_targets: Array[Mob] = []

	for cell in cells:
		for mob in _cell_mob_dict[cell]:
			mob_targets.append(mob)

	return mob_targets


func start_game(game: Game):
	_erase_existing()

	_game = game
	_game.difficulty_changed.connect(_on_difficulty_changed)
	_map = game.map

	for cell in _map.cells:
		_cell_mob_dict[cell] = []

	for spawn_point in starting_spawn_points:
		_spawn_new_spawn_point()


func _erase_existing():
	for mobs in _cell_mob_dict.values():
		for mob in mobs:
			mob.destroy()

	_cell_mob_dict.clear()

	for spawn_point in _cell_spawn_point_dict.values():
		spawn_point.queue_free()

	_cell_spawn_point_dict.clear()


func _spawn_new_spawn_point():
	var new_spawn_point = spawn_point_scene.instantiate() as SpawnPoint
	new_spawn_point.spawn_triggered.connect(_on_spawn_triggered)
	add_child(new_spawn_point)

	var cells = Array(_map.border_cells)
	cells.shuffle()

	for cell in cells:
		if _cell_spawn_point_dict.has(cell):
			continue

		var chosen_cell = cell
		new_spawn_point.cell = chosen_cell
		new_spawn_point.position = Utilities.get_world_position(chosen_cell)
		_cell_spawn_point_dict[chosen_cell] = new_spawn_point

		break


func _on_spawn_triggered(spawn_point: SpawnPoint):
	_spawn_random_mob(spawn_point)


func _on_difficulty_changed(_difficulty: float):
	_spawn_new_spawn_point()


func _spawn_random_mob(spawn_point: SpawnPoint):
	var mob_data = _game.game_data.get_random_mob_resource()
	var new_mob: Mob = mob_data.mob_scene.instantiate()
	var position = spawn_point.position

	add_child(new_mob)

	new_mob.position = position

	new_mob.entered_node.connect(_on_mob_entered_node)
	new_mob.exited_node.connect(_on_mob_exited_node)
	new_mob.attacked_tower.connect(_on_mob_attacked_tower)
	new_mob.was_hit_not_killed.connect(
		func(mob: Mob): Audio.play_sfx(mob_hit_sfx))
	new_mob.was_killed.connect(
		func(mob: Mob): Audio.play_sfx(mob_killed_sfx))

	new_mob.set_resource(mob_data)
#	new_mob.set_path(_map.spawn_point_path_dict[spawn_point], _map.center_cell)
	var path = GameUtilities.get_point_path(spawn_point.cell.position, _map.center)
	new_mob.set_path(path, _map.center_cell)


func _on_mob_entered_node(mob: Mob, node: Vector2i):
	var cell = _map.get_cell_at_world(node.x, node.y)
	_cell_mob_dict[cell].append(mob)


func _on_mob_exited_node(mob: Mob, node: Vector2i):
	var cell = _map.get_cell_at_world(node.x, node.y)

	if !_cell_mob_dict[cell].has(mob):
		print_debug("WARNING: cell mob dict doesn't contain the mob ", mob)
		return

	_cell_mob_dict[cell].erase(mob)


func _on_mob_attacked_tower(mob: Mob):
	_game.tower.take_damage(mob.damage)