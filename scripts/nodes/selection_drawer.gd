extends Node2D

@export var _marker: Sprite2D

var _selected_entity
var _entity_is_selected: bool


func _ready():
	Messenger.clicked_on_entity.connect(_on_clicked_on_entity)
	Messenger.clicked_on_empty.connect(_on_clicked_on_empty)


func _process(_delta):
	# The selected entity has become null, most likely because it's been freed
	if _entity_is_selected && _selected_entity.entity == null:
		_entity_is_selected = false


func _on_clicked_on_entity(entity_info: EntityInfo):
	_selected_entity = entity_info
	_entity_is_selected = true

	_marker.visible = true
	_marker.position = entity_info.position


func _on_clicked_on_empty():
	_selected_entity = null
	_entity_is_selected = false

	_marker.visible = false
