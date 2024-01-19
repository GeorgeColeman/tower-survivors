extends Node2D

@export var _marker: Sprite2D


func _ready():
	SelectionManager.entity_selected.connect(
		func(entity_info: EntityInfo):
			_marker.visible = true
			_marker.position = entity_info.position
	)

	SelectionManager.selection_cleared.connect(
		func():
			_marker.visible = false
	)

	SelectionManager.selected_entity_freed.connect(
		func():
			_marker.visible = false
	)
