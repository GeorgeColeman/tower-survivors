extends Node2D

@export var cell_marker_sprite: Sprite2D

var _current_cell: Cell


func _ready():
	ControlMouseDetector.mouse_entered_control.connect(_on_mouse_entered_control)
	ControlMouseDetector.mouse_exited_control.connect(_on_mouse_exited_control)


func _on_mouse_entered_control():
	cell_marker_sprite.visible = false
	_current_cell = null
	MapUtilities.mouse_hovered_outside_map.emit()


func _on_mouse_exited_control():
	cell_marker_sprite.visible = true
	MapUtilities.mouse_hovered_inside_map.emit()
	_get_hovered_cell()


func _unhandled_input(event):
	if event is InputEventMouse:
		_get_hovered_cell()

	if event is InputEventMouseButton:
		if event.button_index != 1:
			return

		if event.pressed:
			return

		MapUtilities.mouse_clicked_cell.emit(_current_cell)


func _get_hovered_cell():
	if !GameUtilities.game_is_set:
		return

	var cell = MapUtilities.get_cell_at_scene_position(get_global_mouse_position())

	if cell == null:
		_current_cell = cell
		cell_marker_sprite.visible = false

		MapUtilities.mouse_hovered_outside_map.emit()

		return

	if cell != _current_cell:
		_current_cell = cell
		cell_marker_sprite.position = cell.scene_position
		cell_marker_sprite.visible = true

		MapUtilities.mouse_entered_cell.emit(cell)
