class_name Projectile
extends Node2D

var _speed: float
var _does_pass: bool


func set_target(_target_mob: Mob):
	pass


func add_on_hit_callback(_on_hit_callback: Callable):
	pass


func set_damage(_value: int):
	pass


func set_range(_value: int):
	pass


func set_speed(speed: float):
	_speed = speed


func set_pass(does_pass: bool):
	_does_pass = does_pass
