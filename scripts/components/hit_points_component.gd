class_name HitPointsComponent
extends Node

signal hit_points_changed(hit_points: HitPointsComponent)

@export var hit_points_bar: TextureProgressBar

var as_text: String:
	get:
		return "%s/%s" % [_current_hit_points, _modified_max_hit_points]

var bar_value: float:
	get:
		return _perc_hit_points * hit_points_bar.max_value

var is_at_zero: bool:
	get:
		return _current_hit_points <= 0

var _base_max_hit_points: int
var _current_hit_points: int

var _perc_hit_points:
	get:
		return _current_hit_points as float / _modified_max_hit_points

var _max_modifier: float = 1.0
var _modified_max_hit_points: int


func initialise(hit_points: int, is_visibile: bool = true):
	_base_max_hit_points = hit_points
	_current_hit_points = hit_points

	_modified_max_hit_points = floori(_base_max_hit_points * _max_modifier)

	hit_points_bar.visible = is_visibile

	_update_hit_points_bar()


func set_visibility(is_visible: bool):
	hit_points_bar.visible = is_visible


func change_current(amount: int):
	_current_hit_points = clampi(
		_current_hit_points + amount,
		0,
		_modified_max_hit_points
	)

	_update_hit_points_bar()

	hit_points_changed.emit(self)


func _update_hit_points_bar():
	hit_points_bar.value = bar_value


func add_max_modifier(amount: float):
	_max_modifier += amount
	_modified_max_hit_points = floori(_base_max_hit_points * _max_modifier)
	var recomp = floori(_base_max_hit_points * amount)
	change_current(recomp)
