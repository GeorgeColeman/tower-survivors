class_name StatusEffect
extends RefCounted

var name: String
var duration: float
var add: Callable
var remove: Callable

var is_expired: bool

var _elapsed: float


func process(delta: float):
	if is_expired:
		return

	_elapsed += delta

	if _elapsed >= duration:
		is_expired = true
