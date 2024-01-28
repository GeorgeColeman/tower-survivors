# ---------------------------------------------------
# Source: https://www.youtube.com/watch?v=Sw9Iiejkae4
# ---------------------------------------------------
extends Node2D

@export var _sprite: Sprite2D


var _inset: float = 15.0

func _physics_process(_delta):
	var canvas = get_canvas_transform()
	var top_left = -canvas.origin / canvas.get_scale()
	var size = get_viewport_rect().size / canvas.get_scale()

	set_marker_position(Rect2(top_left, size))


func set_marker_position(bounds: Rect2):
	_sprite.global_position.x = clamp(
		global_position.x,
		bounds.position.x + _inset,
		bounds.end.x - _inset
	)
	_sprite.global_position.y = clamp(
		global_position.y,
		bounds.position.y + _inset,
		bounds.end.y - _inset
	)

	if bounds.has_point(global_position):
		hide()
	else:
		show()
