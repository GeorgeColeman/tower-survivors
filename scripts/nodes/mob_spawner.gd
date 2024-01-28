class_name MobSpawner
extends Node2D

@export_group("SFX")
@export var mob_killed_sfx: AudioStream
@export var mob_hit_sfx: AudioStream

var _game: Game
var _map: Map

var _cell_mob_dict = {}


func get_mob_targets(cells: Array[Cell]) -> Array[Mob]:
	var mob_targets: Array[Mob] = []

	for cell in cells:
		for mob in _cell_mob_dict[cell]:
			if !mob:
				print_debug("Null mob")
				_cell_mob_dict.erase(mob)
				continue

			mob_targets.append(mob)

	return mob_targets


func start_game(game: Game):
	_erase_existing()

	_game = game

	_game.difficulty.spawn_boss_triggered.connect(spawn_random_boss)
	_game.difficulty.spawn_elite_triggered.connect(_spawn_random_elite)

	_map = game.map

	for cell in _map.cells:
		_cell_mob_dict[cell] = []


func _erase_existing():
	for mobs in _cell_mob_dict.values():
		for mob in mobs:
			mob.destroy()

	_cell_mob_dict.clear()


func spawn_mob_at(spawn_point: SpawnPoint):
	var mob_resource = _game.game_data.get_random_mob_resource()

	spawn_mob(mob_resource, spawn_point.cell)


func spawn_random_boss():
	spawn_mob(
		_game.game_data.bosses.pick_random(),
		MobUtilities.get_random_spawn_point().cell
	)


func _spawn_random_elite():
	spawn_mob(
		_game.game_data.elites.pick_random(),
		MobUtilities.get_random_spawn_point().cell
	)


func spawn_mob(mob_resource: MobResource, cell: Cell) -> Mob:
	var new_mob: Mob = mob_resource.mob_scene.instantiate()

	add_child(new_mob)

	new_mob.position = cell.scene_position
	new_mob.exited_cell.connect(_on_mob_exited_cell)
	new_mob.entered_cell.connect(_on_mob_entered_cell)
	new_mob.was_hit_not_killed.connect(
		func(_mob: Mob):
			Audio.play_sfx(mob_hit_sfx)
	)
	new_mob.was_killed.connect(
		func(_mob: Mob):
			Audio.play_sfx(mob_killed_sfx)
	)
	new_mob.path_to_centre_requested.connect(
		func(mob: Mob):
			var new_path = PathUtilities.get_path_from_cell_to_cell(mob.cell, _map.center_cell)
			mob.movement.set_path(new_path, _map.center_cell)
	)

	new_mob.set_resource(mob_resource)

	new_mob.movement.path_interrupted.connect(func():
		var new_path = PathUtilities.get_path_from_cell_to_cell(new_mob.cell, _map.center_cell)
		new_mob.movement.set_path(new_path, _map.center_cell)
	)

	#await get_tree().create_timer(0.5).timeout

	var path = PathUtilities.get_path_from_cell_to_cell(cell, _map.center_cell)
	new_mob.movement.set_path(path, _map.center_cell)

	new_mob.animated_spawn()

	return new_mob


func _on_mob_entered_cell(mob: Mob, cell: Cell):
	_cell_mob_dict[cell].append(mob)


func _on_mob_exited_cell(mob: Mob, cell: Cell):
	if !_cell_mob_dict[cell].has(mob):
		print_debug("WARNING: cell mob dict doesn't contain the mob ", mob)
		return

	_cell_mob_dict[cell].erase(mob)
