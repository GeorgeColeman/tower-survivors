class_name BuildButton
extends Button

@export var _main_texture: TextureRect
@export var _gold_label: Label
@export var _gold_cost_area: Control
@export var _rank_label: Label


func set_building_option(option: BuildingOption):
	_main_texture.texture = option.texture
	_gold_label.text = str(option.gold_cost)
	_rank_label.text = str(option.rank)

	if option.gold_cost == 0:
		_gold_cost_area.visible = false

	option.upgraded.connect(
		func(): _rank_label.text = str(option.rank)
	)
