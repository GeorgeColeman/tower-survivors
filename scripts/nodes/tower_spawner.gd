class_name TowerSpawner
extends Node2D

@export var main_tower_scene: PackedScene

var _main_tower: Tower


func instantiate_tower(cell: Cell) -> Tower:
	# Delete existing tower
	if _main_tower:
		_main_tower.uninstantiate()

	var tower = main_tower_scene.instantiate() as Tower
	add_child(tower)
	tower.position = Utilities.get_world_position(cell)
	tower.set_cell_and_init(cell)
	_main_tower = tower

	return tower


func get_towers_at(cell: Cell) -> Array:
	if _main_tower != null:
		if cell == _main_tower.cell:
			return [_main_tower]

	return []
