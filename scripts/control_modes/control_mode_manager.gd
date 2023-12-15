extends Node

var current_control_mode: ControlMode

@export var control_mode_default: ControlMode
@export var control_mode_build: ControlMode


func _ready():
	_set_current_control_mode(control_mode_default)

	GameUtilities.control_mode_build_requested.connect(_on_control_mode_build_requested)


func _on_control_mode_build_requested(option: BuildingOption):
	_set_current_control_mode(control_mode_build)
	control_mode_build.set_building_option(option)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index != 2 || event.pressed:
			return

		_set_current_control_mode(control_mode_default)


func _set_current_control_mode(control_mode: ControlMode):
	if current_control_mode:
		current_control_mode.exit_mode()

	current_control_mode = control_mode
	control_mode.enter_mode()
