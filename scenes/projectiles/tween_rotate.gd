extends Node2D

var _tween: Tween


func _ready():
	_tween = get_tree().create_tween().set_loops()
	# FIX: https://www.reddit.com/r/godot/comments/x2d7lh/having_a_problem_tweening_a_rotation_with_the_new/
	_tween.tween_property(self, "rotation", TAU, 1).as_relative()


func _exit_tree():
	if !_tween:
		return

	_tween.kill()
