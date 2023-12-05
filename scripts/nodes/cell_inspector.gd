extends Node2D

@onready var cell_marker_sprite = %CellMarkerSprite

var _current_cell: Cell


func _ready():
	ControlMouseDetector.mouse_entered_control.connect(_on_mouse_entered_control)
	ControlMouseDetector.mouse_exited_control.connect(_on_mouse_exited_control)


func _on_mouse_entered_control():
	cell_marker_sprite.visible = false
	MapUtilities.mouse_hovered_outside_map.emit()


func _on_mouse_exited_control():
	cell_marker_sprite.visible = true
	MapUtilities.mouse_hovered_inside_map.emit()


func _unhandled_input(event):
	if event is InputEventMouse:
		_get_hovered_cell()

	# By doing this check we get type completion within the block. Handy!
	if event is InputEventMouseButton:
		if event.button_index != 1:
			return

		if event.pressed:
			return

		MapUtilities.mouse_clicked_cell.emit(_current_cell)
#		print_debug("Mouse button released over cell: ", _current_cell)


func _get_hovered_cell():
	if !GameUtilities.game_is_set:
		return

	var cell = GameUtilities.get_cell_at(get_global_mouse_position())

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
