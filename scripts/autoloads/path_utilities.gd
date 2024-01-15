extends Node

signal updated_cell_is_solid(cell: Cell, is_solid: bool)

var _pathfinding_manager: PathfindingManager


func get_path_from_cell_to_cell(start_cell: Cell, end_cell: Cell) -> PackedVector2Array:
	return _pathfinding_manager.get_path_from_cell_to_cell(start_cell, end_cell)


func set_pathfinding_manager(pathfinding_manager: PathfindingManager):
	_pathfinding_manager = pathfinding_manager


func get_is_next_node_walkable(next: Vector2i) -> bool:
	return _pathfinding_manager.is_point_walkable(next)


func update_cell_is_solid(cell: Cell, is_solid: bool):
	updated_cell_is_solid.emit(cell, is_solid)


func get_is_cell_walkable(cell: Cell) -> bool:
	return _pathfinding_manager.is_cell_walkable(cell)
