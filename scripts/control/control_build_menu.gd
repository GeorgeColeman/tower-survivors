class_name ControlBuildMenu
extends Control

@export var button_containter: Container
@export var build_button_scene: PackedScene


func set_game(game: Game):
	game.building_options.option_added.connect(add_build_option)


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
