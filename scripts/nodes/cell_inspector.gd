class_name CellInspector
extends Node2D

signal cell_inspected(cell: Cell)

@onready var cell_marker_sprite = %CellMarkerSprite

var current_cell: Cell


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

		cell_inspected.emit(current_cell)
		MapUtilities.mouse_clicked_cell.emit(current_cell)
#		print_debug("Mouse button released over cell: ", current_cell)


func _get_hovered_cell():
	if !GameUtilities.game_is_set:
		return

	var cell = GameUtilities.get_cell_at(get_global_mouse_position())

	if cell == null:
		current_cell = cell
		cell_marker_sprite.visible = false
		MapUtilities.mouse_hovered_outside_map.emit()

		return

	if cell != current_cell:
		current_cell = cell
		cell_marker_sprite.position = cell.scene_position
		cell_marker_sprite.visible = true
		MapUtilities.mouse_entered_cell.emit(cell)
