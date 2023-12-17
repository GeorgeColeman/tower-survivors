class_name MobSpawner
extends Node2D

@export var spawn_point_scene: PackedScene
@export var starting_spawn_points = 3 as int

@export_group("SFX")
@export var mob_killed_sfx: AudioStream
@export var mob_hit_sfx: AudioStream

var _game: Game
var _map: Map

var _valid_spawn_point_cells: Array[Cell] = []

var _cell_mob_dict = {}
var _cell_spawn_point_dict = {}

var _current_minute: int

var _mob_spawner_utilities: MobSpawnerUtilities


func _ready():
	_mob_spawner_utilities = MobSpawnerUtilities.new(self)


func _process(delta):
	if !_game:
		return

	if _game.time > _current_minute * 60:
		_current_minute += 1

		# Spawning a boss every 2 minutes
		if _current_minute % 2 == 0:
			return

		spawn_random_boss()
		for spawn_point in _cell_spawn_point_dict.values():
			spawn_point.set_spawn_delay(15)


#func _draw():
	#for point in _valid_spawn_point_cells:
		#draw_circle(point.scene_position, 8, Color.ORANGE)


func get_spawn_points_at(cell: Cell) -> Array:
	if !_cell_spawn_point_dict.has(cell):
		return []

	return [_cell_spawn_point_dict[cell]]


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

	_current_minute = 1

	for cell in _map.cells:
		_cell_mob_dict[cell] = []

	_get_valid_spawn_points()

	for spawn_point in starting_spawn_points:
		_spawn_new_spawn_point()


func _get_valid_spawn_points():
	var poisson_points = PoissonDiscSampling.generate_points_for_polygon(
		PackedVector2Array([Vector2(0, 0), Vector2(0, 32), Vector2(32, 32), Vector2(32, 0)]),
		4,
		30
	)

	var min_dist_from_tower_sqr = 10 * 10

	for point in poisson_points:
		var cell = MapUtilities.get_cell_at_map_position(point)

		if cell:
			var dist_from_tower = cell.position.distance_squared_to(_game.tower.cell.position)

			if dist_from_tower > min_dist_from_tower_sqr:
				_valid_spawn_point_cells.append(cell)

	#queue_redraw()


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

	var cells = Array(_valid_spawn_point_cells)
	#var cells = Array(_map.border_cells)
	cells.shuffle()

	for cell in cells:
		if _cell_spawn_point_dict.has(cell):
			print_debug("Spawn point already exists at: ", cell)
			continue

		var chosen_cell = cell
		new_spawn_point.cell = chosen_cell
		new_spawn_point.position = chosen_cell.scene_position
		_cell_spawn_point_dict[chosen_cell] = new_spawn_point

		break


func _on_spawn_triggered(spawn_point: SpawnPoint):
	_spawn_random_mob(spawn_point)


func _on_difficulty_changed(_difficulty: float):
	_spawn_new_spawn_point()


func _spawn_random_mob(spawn_point: SpawnPoint):
	var mob_resource = _game.game_data.get_random_mob_resource()

	spawn_mob(mob_resource, spawn_point.cell)


func spawn_random_boss():
	#print_debug("Spawning random boss")
	spawn_mob(
		_game.game_data.bosses.pick_random(),
		_cell_spawn_point_dict.values().pick_random().cell
	)


func spawn_mob(mob_resource: MobResource, cell: Cell):
	var new_mob: Mob = mob_resource.mob_scene.instantiate()
	var position = cell.scene_position

	add_child(new_mob)

	new_mob.position = position

	new_mob.entered_node.connect(_on_mob_entered_node)
	new_mob.exited_node.connect(_on_mob_exited_node)
	new_mob.attacked_tower.connect(_on_mob_attacked_tower)
	new_mob.was_hit_not_killed.connect(func(mob: Mob):
		Audio.play_sfx(mob_hit_sfx)
	)
	new_mob.was_killed.connect(func(mob: Mob):
		Audio.play_sfx(mob_killed_sfx)
	)

	new_mob.set_resource(mob_resource)

	new_mob._path_follower.path_interrupted.connect(func():
		var path = GameUtilities.get_path_from_cell_to_cell(new_mob.cell, _map.center_cell)
		new_mob.set_path(path, _map.center_cell)
	)

	#await get_tree().create_timer(0.5).timeout

	var path = GameUtilities.get_path_from_cell_to_cell(cell, _map.center_cell)
	new_mob.set_path(path, _map.center_cell)

	new_mob.animated_spawn()


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
