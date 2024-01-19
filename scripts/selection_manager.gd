extends Node

signal entity_selected(entity_info: EntityInfo)
signal selection_cleared()
signal selected_entity_freed()

var _selected_entity
var _entity_is_selected: bool


func _init():
	Messenger.clicked_on_entity.connect(_on_clicked_on_entity)
	Messenger.clicked_on_empty.connect(_on_clicked_on_empty)


func _process(_delta):
	# The selected entity has become null, most likely because it's been freed
	if _entity_is_selected && _selected_entity.entity == null:
		_entity_is_selected = false

		selected_entity_freed.emit()


func _on_clicked_on_entity(entity_info: EntityInfo):
	_selected_entity = entity_info
	_entity_is_selected = true

	entity_selected.emit(entity_info)


func _on_clicked_on_empty():
	_selected_entity = null
	_entity_is_selected = false

	selection_cleared.emit()
