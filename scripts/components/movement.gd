class_name Movement
extends RefCounted

signal exited_cell(cell: Cell)
signal entered_cell(cell: Cell)
signal path_interrupted()
signal path_completed()
signal facing_direction_changed(facing_direction: FacingDirection)

var cell: Cell

var speed: float:
	get:
		if !_is_mobile:
			return 0

		return _base_speed * _speed_modifier

var smooth_position: Vector2:
	get:
		return _path_follower.smooth_position

var is_near_target: bool:
	get:
		return MapUtilities.get_cell_neighbours(_target_cell).has(cell)

var _base_speed: float
var _speed_modifier: float = 1
var _is_mobile: bool = true
var _path_follower: PathFollower
var _target_cell: Cell
var _facing_direction = FacingDirection.LEFT


func _init(base_speed: float):
	_base_speed = base_speed

	_path_follower = PathFollower.new()
	_path_follower.set_move_speed(base_speed)

	_path_follower.exited_node.connect(_on_exited_node)
	_path_follower.entered_node.connect(_on_entered_node)
	_path_follower.enter_node_completed.connect(_update_facing_direction)
	_path_follower.path_interrupted.connect(_on_path_interrupted)
	_path_follower.path_completed.connect(_on_path_completed)


func _on_exited_node(node: Vector2i):
	var new_cell = MapUtilities.get_cell_at_scene_position(node)

	exited_cell.emit(new_cell)


func _on_entered_node(node: Vector2i):
	var new_cell = MapUtilities.get_cell_at_scene_position(node)

	cell = new_cell

	#_update_facing_direction()

	entered_cell.emit(new_cell)


func process(delta):
	_path_follower.process(delta)


func add_move_speed_modifier(amount: float):
	_speed_modifier += amount

	_path_follower.set_move_speed(speed)


func set_is_mobile(is_mobile: bool):
	_is_mobile = is_mobile

	_path_follower.set_move_speed(speed)


func set_path(path: PackedVector2Array, target_cell: Cell):
	_target_cell = target_cell

	_path_follower.set_path(path)

	#await get_tree().create_timer(0.5).timeout

	_path_follower.start_path()


func destroy():
	_path_follower.exit_current()


func _update_facing_direction():
	if !_path_follower.current_node || !_path_follower.next_node:
		print_debug("WARNING: current or next node is null")

		return

	var diff = _path_follower.current_node - _path_follower.next_node

	if diff.x > 0:
		_facing_direction = FacingDirection.RIGHT
	elif diff.x < 0:
		_facing_direction = FacingDirection.LEFT
	else:
		return

	facing_direction_changed.emit(_facing_direction)


func _on_path_interrupted():
	path_interrupted.emit()


func _on_path_completed():
	path_completed.emit()


enum FacingDirection {
	LEFT,
	RIGHT
}
