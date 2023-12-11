class_name ControlBuildMenu
extends Control

@export var button_containter: Container
@export var build_button_scene: PackedScene

#func _ready():
	## NOTE: we are instantiating the scene to access certain members.
	## We only want to do this once, so here may not be the most approprite
	## place to do it.
	#var _proto_candlestick_scene = candlestick_scene.instantiate() as Tower
#
	#var build_rock_button = _instantiate_build_button(
		#func():
			#GameUtilities.try_enter_build_mode(
				#BuildableObjectData.new(rock_scene, 0)
			#)
			##control_manager.enter_build_mode(rock_scene)
	#)
#
	#build_rock_button.main_texture.texture = rock_texture
	#build_rock_button.set_gold_cost(0)
#
	#var build_candlestick_button = _instantiate_build_button(
		#func():
			#GameUtilities.try_enter_build_mode(
				#BuildableObjectData.new(candlestick_scene, _proto_candlestick_scene.gold_cost)
			#)
			##control_manager.enter_build_mode(candlestick_scene)
	#)
#
	#build_candlestick_button.main_texture.texture = _proto_candlestick_scene.main_sprite_2d.texture
	#build_candlestick_button.set_gold_cost(_proto_candlestick_scene.gold_cost)


func add_build_option(scene: PackedScene):
	var blueprint = scene.instantiate() as Tower
	var button = _instantiate_build_button(
		func():
			GameUtilities.try_enter_build_mode(
				BuildableObjectData.new(scene, blueprint.gold_cost)
			)
	)

	button.set_main_texture(blueprint.main_sprite_2d.texture)
	button.set_gold_cost(blueprint.gold_cost)


func _instantiate_build_button(on_pressed: Callable) -> BuildButton:
	var build_button: BuildButton = build_button_scene.instantiate()
	button_containter.add_child(build_button)
	build_button.pressed.connect(on_pressed)

	return build_button
