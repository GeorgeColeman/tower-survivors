class_name BuildButton
extends Button

@export var _main_texture: TextureRect
@export var gold_label: Label
@export var gold_cost_area: Control


func set_main_texture(texture: Texture2D):
	_main_texture.texture = texture


func set_gold_cost(cost: int):
	if cost == 0:
		gold_cost_area.visible = false

		return

	gold_label.text = str(cost)
