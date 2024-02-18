class_name BuildButton
extends Button

@export var _main_texture: TextureRect
@export var _gold_label: Label
@export var _gold_cost_area: Control
@export var _rank_label: Label
@export var _core_cost_label: Label
@export var _no_build_overlay_texture: TextureRect
@export var _rank_icons_container: HBoxContainer
@export var _star_texture: Texture2D


func set_building_option(option: BuildingOption):
	_main_texture.texture = option.tower_resource.texture
	_gold_label.text = str(option.tower_resource.gold_cost)
	_rank_label.text = str(option.display_rank)
	_core_cost_label.text = str(option.get_core_cost())
	_draw_rank_stars(option)

	if option.tower_resource.gold_cost == 0:
		_gold_cost_area.visible = false

	_no_build_overlay_texture.visible = !option.can_build


	option.upgraded.connect(
		func():
			_rank_label.text = str(option.display_rank)
			_draw_rank_stars(option)
	)

	option.can_build_updated.connect(
		func(can_build: bool):
			_no_build_overlay_texture.visible = !can_build
			_core_cost_label.text = str(option.get_core_cost())
	)


func _draw_rank_stars(option: BuildingOption):
	for child in _rank_icons_container.get_children():
		child.queue_free()

	for i in option.display_rank:
		var texture = TextureRect.new()
		texture.texture = _star_texture
		_rank_icons_container.add_child(texture)
