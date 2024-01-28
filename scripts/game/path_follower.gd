class_name PathFollower
extends RefCounted

signal exited_node(node: Vector2i)
signal entered_node(node: Vector2i)
signal enter_node_completed()
signal path_interrupted()
signal path_completed()

var smooth_position: Vector2:
	get:
		return (current_node as Vector2).lerp(next_node, _progress_to_next)

var path: PackedVector2Array

var _move_speed: float
var _next_node_index: int

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
	path = new_path

	if new_path.size() == 0:
		push_warning("Path size is 0")

		return

	current_node = new_path[0]

	if new_path.size() <= 1:
		push_warning("Path size is less than or equal to 1")

		return

	next_node = new_path[1]

	entered_node.emit(current_node)

	_next_node_index = 1

	_dist_to_next = GameUtilities.get_distance_between_nodes(current_node, next_node)
	_progress_to_next = 0

	enter_node_completed.emit()


func start_path():
	if path.size() == 0:
		push_warning("Path size is 0")

		return

	_has_active_path = true


func cancel_path():
	_has_active_path = false


func exit_current():
	exited_node.emit(current_node)

	#if _node_index >= path.size():
		#print_debug(_node_index, " :: ", path.size())
#
	#exited_node.emit(path[_node_index])


func _process_move(delta):
	_progress_to_next += _move_speed / _dist_to_next * delta

	if _progress_to_next >= 1:
		_enter_next()


func _enter_next():
	exited_node.emit(path[_next_node_index - 1])
	entered_node.emit(path[_next_node_index])

	_next_node_index += 1

	current_node = next_node

	if _next_node_index >= path.size():
		_complete_path()

		return
	else:
		next_node = path[_next_node_index]

	if !PathUtilities.get_is_next_node_walkable(next_node):
		#exit_current()
		_interrupt_path()

		return

	# Allows for correct speed when moving along diagonals
	_dist_to_next = GameUtilities.get_distance_between_nodes(current_node, next_node)
	_progress_to_next = 0

	enter_node_completed.emit()


func _complete_path():
	_has_active_path = false
	current_node = next_node
	path_completed.emit()


func _interrupt_path():
	print_debug("Path was interrupted")
	_has_active_path = false

	path_interrupted.emit()
