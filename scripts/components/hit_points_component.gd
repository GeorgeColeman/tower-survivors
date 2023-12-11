class_name HitPointsComponent
extends Node

#signal hit_points_changed()

@export var hit_points_bar: TextureProgressBar

var is_at_zero: bool:
	get:
		return _current_hit_points <= 0

var _max_hit_points: int
var _current_hit_points: int

var _perc_hit_points:
	get:
		return _current_hit_points as float / _max_hit_points


func initialise(hit_points: int, show_health_bar: bool):
	_max_hit_points = hit_points
	_current_hit_points = hit_points

	hit_points_bar.visible = show_health_bar

	_update_hit_points_bar()


func change_current(amount: int):
	_current_hit_points = clampi(_current_hit_points + amount, 0, _max_hit_points)

	_update_hit_points_bar()


func _update_hit_points_bar():
	hit_points_bar.value = _perc_hit_points * hit_points_bar.max_value
