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


#func _process(_delta):
	#_get_keyboard_input()
#
#
#func _get_keyboard_input():
	#_keyboard_input = Input.get_vector("left", "right", "up", "down")


func _unhandled_key_input(event):
	#var x: float
	#var y: float
	#
	#if event.is_action("down"):
		#y += 1
	#if event.is_action("up"):
		#y -= 1
	#if event.is_action("left"):
		#x -= 1
	#if event.is_action("right"):
		#x += 1
	#
	#print_debug(y)
	#
	#_keyboard_input = Vector2(x, y)
	_keyboard_input = Input.get_vector("left", "right", "up", "down")
	
	#print_debug(_keyboard_input)
	#if event is InputEventKey:


func set_position_immediate(p_position: Vector2):
	position = p_position
	reset_smoothing()


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
