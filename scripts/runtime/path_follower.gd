class_name PathFollower
extends RefCounted

signal exited_node(node: Vector2i)
signal entered_node(node: Vector2i)
signal path_interrupted()
signal path_completed()

var smooth_position: Vector2:
	get:
		return (current_node as Vector2).lerp(next_node, _progress_to_next)

var path: PackedVector2Array

var _move_speed: float

var _node_index: int
var _dist_to_next: float
var _progress_to_next: float

var current_node: Vector2i
var next_node: Vector2i

var _has_active_path: bool


func set_move_speed(move_speed: float):
	_move_speed = move_speed


func process(delta):
	if !_has_active_path:
		return

	_process_move(delta)


func set_path(new_path: PackedVector2Array):
	if new_path.size() == 0:
		push_warning("WARNING: path length is 0")

	path = new_path

	current_node = new_path[0]
	next_node = new_path[0]

	_node_index = 0
	_dist_to_next = 1
	_progress_to_next = 1
	#_has_active_path = true

	entered_node.emit(new_path[0])


func start_path():
	_has_active_path = true



func exit_current():
	exited_node.emit(path[_node_index])


func _process_move(delta):
	_progress_to_next += _move_speed / _dist_to_next * delta

	if _progress_to_next >= 1:
		_enter_next()


func _enter_next():
	exited_node.emit(path[_node_index])

	_node_index += 1

	if _node_index >= path.size():
		_complete_path()
		return

	entered_node.emit(path[_node_index])

	current_node = next_node
	next_node = path[_node_index]

	if !PathUtilities.get_is_next_node_walkable(next_node):
		exit_current()
		_interrupt_path()
		return

	# Allows for correct speed when moving along diagonals
	_dist_to_next = GameUtilities.get_distance_between_nodes(current_node, next_node)
	_progress_to_next = 0


func _complete_path():
	_has_active_path = false

	path_completed.emit()


func _interrupt_path():
	print_debug("Path was interrupted")
	_has_active_path = false

	path_interrupted.emit()
