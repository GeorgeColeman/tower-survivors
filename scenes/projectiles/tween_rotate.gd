extends Node2D

var _tween: Tween


func _ready():
	_tween = get_tree().create_tween().set_loops()
	_tween.tween_property(self, "rotation", 360, 1)


func _exit_tree():
	if !_tween:
		return

	_tween.kill()
