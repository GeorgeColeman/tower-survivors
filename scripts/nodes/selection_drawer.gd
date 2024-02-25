extends Node2D

@export var _sprite_2d: Sprite2D


func _ready():
	SelectionManager.entity_selected.connect(
		func(entity_info: EntityInfo):
			_sprite_2d.visible = true
			_sprite_2d.position = entity_info.position
	)

	SelectionManager.selection_cleared.connect(
		func():
			_sprite_2d.visible = false
	)

	SelectionManager.selected_entity_freed.connect(
		func():
			_sprite_2d.visible = false
	)
