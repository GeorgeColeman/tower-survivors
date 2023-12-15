extends ControlMode

@export var preview_container: Node2D

var _building_option: BuildingOption
var _current_preview: Node


func _ready():
	MapUtilities.mouse_entered_cell.connect(_on_mouse_entered_cell)
	MapUtilities.mouse_clicked_cell.connect(_on_mouse_clicked_cell)
	MapUtilities.mouse_hovered_outside_map.connect(_on_mouse_hovered_outside_map)


func _on_mouse_hovered_outside_map():
	preview_container.visible = false


func set_building_option(option: BuildingOption):
	_cleanup_existing_preview()

	_building_option = option

	_current_preview = option.scene.instantiate()
	preview_container.add_child(_current_preview)


func exit_mode():
	super()
	_cleanup_existing_preview()


func _cleanup_existing_preview():
	if _current_preview:
		_current_preview.queue_free()

		_current_preview = null


func _on_mouse_entered_cell(cell: Cell):
	if !is_active:
		return

	preview_container.visible = true

	preview_container.position = cell.scene_position


func _on_mouse_clicked_cell(cell: Cell):
	if !is_active:
		return

	_building_option.confirm_build(cell)
