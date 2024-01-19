class_name MobSpawner
extends Node2D

@export var spawn_point_scene: PackedScene
@export var starting_spawn_points = 3 as int
@export var spawn_point_here_texture: Texture2D

@export_group("SFX")
@export var mob_killed_sfx: AudioStream
@export var mob_hit_sfx: AudioStream

var _game: Game
var _map: Map

var _valid_spawn_point_cells: Array[Cell] = []
var _next_spawn_point_dict = {}						# <Cell, Sprite2D>

var _cell_mob_dict = {}
var _cell_spawn_point_dict = {}

var _current_minute: int

var _mob_spawner_utilities: MobSpawnerUtilities


func _ready():
	_mob_spawner_utilities = MobSpawnerUtilities.new(self)


func _process(_delta):
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

	_game.difficulty.changed.connect(_on_difficulty_changed)
	_game.difficulty.spawn_elite_triggered.connect(spawn_random_elite)

	_map = game.map

	_current_minute = 1

	for cell in _map.cells:
		_cell_mob_dict[cell] = []

	# HACK: because path noded don't seem to be properly updated yet
	await get_tree().create_timer(0.1).timeout

	_get_valid_spawn_points(_map.width, _map.height)

	for spawn_point in starting_spawn_points:
		_spawn_new_spawn_point()


func _get_valid_spawn_points(width: int, height: int):
	var poisson_points = PoissonDiscSampling.generate_points_for_polygon(
		PackedVector2Array(
			[Vector2(0, 0),
			Vector2(0, height),
			Vector2(width, height),
			Vector2(width, 0)]
		),
		3,
		30
	)

	var min_dist_from_tower_sqr = 10 * 10

	for point in poisson_points:
		var cell = MapUtilities.get_cell_at_map_position(point)

		if !PathUtilities.get_is_cell_walkable(cell):
			#print_debug("Cell is unwalkable. Cannot be used as spawn point")

			continue

		if cell:
			var dist_from_tower = cell.position.distance_squared_to(_game.tower.cell.position)

			if dist_from_tower > min_dist_from_tower_sqr:
				_valid_spawn_point_cells.append(cell)

	#print_debug("Found %s valid spawn points" % _valid_spawn_point_cells.size())

	#queue_redraw()


func _erase_existing():
	for mobs in _cell_mob_dict.values():
		for mob in mobs:
			mob.destroy()

	_cell_mob_dict.clear()

	for spawn_point in _cell_spawn_point_dict.values():
		spawn_point.queue_free()

	_cell_spawn_point_dict.clear()


func spawn_new_spawn_point():
	_spawn_new_spawn_point()


func _spawn_new_spawn_point():
	var next: Cell

	if _next_spawn_point_dict.size() == 0:
		next = _get_valid_spawn_point_cell()
	else:
		next = _next_spawn_point_dict.keys().pick_random()
		_next_spawn_point_dict[next].queue_free()
		_next_spawn_point_dict.erase(next)

	var new_spawn_point = spawn_point_scene.instantiate() as SpawnPoint
	new_spawn_point.spawn_triggered.connect(_on_spawn_triggered)
	add_child(new_spawn_point)

	new_spawn_point.cell = next
	new_spawn_point.position = next.scene_position
	_cell_spawn_point_dict[next] = new_spawn_point

	_set_next_spawn_point()


func _set_next_spawn_point():
	var next_cell = _get_valid_spawn_point_cell()
	var next_marker = Sprite2D.new()

	_next_spawn_point_dict[next_cell] = next_marker

	add_child(next_marker)

	next_marker.texture = spawn_point_here_texture
	next_marker.position = next_cell.scene_position
	next_marker.z_index = 1


func _get_valid_spawn_point_cell() -> Cell:
	var cells = Array(_valid_spawn_point_cells)
	cells.shuffle()

	for cell in cells:
		if _cell_spawn_point_dict.has(cell):
			print_debug("Spawn point already exists at: ", cell)
			continue

		return cell

	print_debug("WARNING: unable to find valid spawn point cell. Returning null")

	return null


func _on_spawn_triggered(spawn_point: SpawnPoint):
	_spawn_random_mob(spawn_point)


func _on_difficulty_changed(_difficulty: float):
	_spawn_new_spawn_point()


func _spawn_random_mob(spawn_point: SpawnPoint):
	var mob_resource = _game.game_data.get_random_mob_resource()

	spawn_mob(mob_resource, spawn_point.cell)


func spawn_random_boss():
	spawn_mob(
		_game.game_data.bosses.pick_random(),
		_cell_spawn_point_dict.values().pick_random().cell
	)


func spawn_random_elite():
	#print_debug("Spawning random elite")

	spawn_mob(
		_game.game_data.elites.pick_random(),
		_cell_spawn_point_dict.values().pick_random().cell
	)


func spawn_mob(mob_resource: MobResource, cell: Cell) -> Mob:
	var new_mob: Mob = mob_resource.mob_scene.instantiate()

	add_child(new_mob)

	new_mob.position = cell.scene_position
	new_mob.exited_cell.connect(_on_mob_exited_cell)
	new_mob.entered_cell.connect(_on_mob_entered_cell)
	new_mob.attacked_tower.connect(_on_mob_attacked_tower)
	new_mob.was_hit_not_killed.connect(
		func(_mob: Mob):
			Audio.play_sfx(mob_hit_sfx)
	)
	new_mob.was_killed.connect(
		func(_mob: Mob):
			Audio.play_sfx(mob_killed_sfx)
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


func _on_mob_attacked_tower(mob: Mob):
	if !_game.tower:
		print_debug("No tower to attack")

		return

	mob.attack_component.start_attacking(_game.tower)

	#_game.tower.take_damage(mob.damage)
