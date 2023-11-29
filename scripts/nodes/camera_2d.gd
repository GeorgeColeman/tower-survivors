extends Camera2D

@export var speed: int = 10

var _keyboard_input = Vector2()


func _physics_process(delta):
	_move_camera(delta)


func _process(delta):
	_get_keyboard_input()


func _get_keyboard_input():
	_keyboard_input = Input.get_vector("left", "right", "up", "down")


func _move_camera(delta):
	position += _keyboard_input * delta * speed
