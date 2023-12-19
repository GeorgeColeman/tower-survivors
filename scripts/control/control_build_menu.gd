# Displays buttons corresponding to the towers the player can build
class_name ControlBuildMenu
extends Control

@export var button_containter: Container
@export var build_button_scene: PackedScene

# <BuildingOption, BuildButton>
var _option_button_dict = {}


func set_game(game: Game):
	game.building_options.option_added.connect(add_build_option)


func add_build_option(option: BuildingOption):
	#var blueprint = option.scene.instantiate() as Tower
	var button = _instantiate_build_button(
		func():
			GameUtilities.try_enter_build_mode(option)
	)

	button.set_building_option(option)

	_option_button_dict[option] = button


func _instantiate_build_button(on_pressed: Callable) -> BuildButton:
	var build_button: BuildButton = build_button_scene.instantiate()
	button_containter.add_child(build_button)
	build_button.pressed.connect(on_pressed)

	return build_button
