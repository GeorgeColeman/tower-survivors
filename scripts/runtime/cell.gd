class_name Cell
extends RefCounted

var i: int
var x: int
var y: int

var position: Vector2
var scene_position: Vector2


func _init(_i: int, _x: int, _y: int):
	i = _i
	x = _x
	y = _y
	position = Vector2(x, y)
	scene_position = position * GameConstants.PIXEL_SCALE
