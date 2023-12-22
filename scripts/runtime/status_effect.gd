class_name StatusEffect
extends RefCounted

var name: String
var duration: float
var properties = {}

var add: Callable = func(): pass
var remove: Callable = func(): pass
var update: Callable = func(delta: float): pass

var is_expired: bool

var _elapsed: float


func process(delta: float):
	if is_expired:
		return

	_elapsed += delta

	update.call(delta)

	if _elapsed >= duration:
		is_expired = true
