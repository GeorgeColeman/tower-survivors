class_name UpgradeOption
extends RefCounted

var name: String

var _apply_callback: = func(): pass


func _init(p_name: String, apply_callback: Callable):
	name = p_name
	_apply_callback = apply_callback


func apply():
	_apply_callback.call()
