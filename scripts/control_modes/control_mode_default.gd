extends ControlMode


func _ready():
	MapUtilities.mouse_clicked_cell.connect(_on_mouse_clicked_cell)


func enter_mode():
	super()
	Messenger.clicked_on_empty.emit()


func _on_mouse_clicked_cell(cell: Cell):
	if !is_active:
		return

	if cell == null:
		Messenger.clicked_on_empty.emit()
		return

	var entites = GameUtilities.get_entity_info_at(cell)

	if entites.size() > 0:
		Messenger.clicked_on_entity.emit(entites[0])
		return

	Messenger.clicked_on_empty.emit()
