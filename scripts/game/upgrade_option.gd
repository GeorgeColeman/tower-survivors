class_name UpgradeOption
extends RefCounted

# TODO: 'NEW' is the 'flair', not the rank

var name: String
var rank: int
var flair: String
#var category: String
var description: String
var stats: String
var texture: Texture2D

var _apply_callback: = func(): pass


func _init(p_name: String, apply_callback: Callable):
	name = p_name
	_apply_callback = apply_callback


func apply():
	_apply_callback.call()
