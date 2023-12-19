class_name UpgradeOption
extends RefCounted

var name: String
var category: String
var description: String

var _apply_callback: = func(): pass


func _init(
	p_name: String,
	p_category: String,
	p_description: String,
	apply_callback: Callable
):
	name = p_name
	category = p_category
	description = p_description
	_apply_callback = apply_callback


func apply():
	_apply_callback.call()
