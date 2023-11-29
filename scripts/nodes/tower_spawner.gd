class_name TowerSpawner
extends Node2D

var tower_scene: PackedScene = preload("res://Scenes/tower.tscn")

var _main_tower: Tower


func instantiate_tower(cell: Cell) -> Tower:
	# Delete existing tower
	if _main_tower:
		_main_tower.uninstantiate()

	var tower = tower_scene.instantiate() as Tower
	add_child(tower)
	tower.position = Utilities.get_world_position(cell)
	tower.set_cell(cell)
	_main_tower = tower

	return tower


func get_towers_at(cell: Cell) -> Array:
	if _main_tower != null:
		if cell == _main_tower.cell:
#			Messenger.clicked_on_tower.emit(_main_tower)
			return [_main_tower]

	return []
