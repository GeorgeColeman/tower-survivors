class_name UpgradeOption
extends RefCounted

# TODO: 'NEW' is the 'flair', not the rank

var name: String
var rank: String
var category: String
var description: String
var texture: Texture2D

var _apply_callback: = func(): pass


func _init(
	p_name: String,
	p_rank: String,
	p_category: String,
	p_description: String,
	apply_callback: Callable
):
	name = p_name
	rank = p_rank
	category = p_category
	description = p_description
	_apply_callback = apply_callback


func apply():
	_apply_callback.call()
