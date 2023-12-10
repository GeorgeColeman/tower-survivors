extends Node

signal mouse_entered_control()
signal mouse_exited_control()

var _was_input: bool
var _was_unhandled_input: bool
var _mouse_over_control: bool


func _process(_delta):
	if _was_input:
		if !_was_unhandled_input && !_mouse_over_control:
			_mouse_over_control = true
			mouse_entered_control.emit()
#			print_debug("Mouse entered control")

	_was_input = false
	_was_unhandled_input = false


func _input(event):
	if event is InputEventMouseMotion:
		_was_input = true


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if _mouse_over_control:
			mouse_exited_control.emit()
#			print_debug("Mouse exited control")

		_was_unhandled_input = true
		_mouse_over_control = false
