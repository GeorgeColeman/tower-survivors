class_name Camera2DController
extends Camera2D

@export var speed: int = 10

var _keyboard_input = Vector2()
var _limit_right: float
var _limit_bottom: float


func set_limits(p_limit_right: float, p_limit_bottom: float):
	_limit_right = p_limit_right
	_limit_bottom = p_limit_bottom


func _physics_process(delta):
	_move_camera(delta)


func _process(_delta):
	_get_keyboard_input()


func _get_keyboard_input():
	_keyboard_input = Input.get_vector("left", "right", "up", "down")


func _move_camera(delta):
	position += _keyboard_input * delta * speed

	if position.y < 0:
		position.y = 0
	elif position.y > _limit_bottom:
		position.y = _limit_bottom

	if position.x < 0:
		position.x = 0
	elif position.x > _limit_right:
		position.x = _limit_right
