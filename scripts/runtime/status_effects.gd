class_name StatusEffects
extends RefCounted
# A component that manages status effects applied to an entity.
# For example, a slow effect on a mob.

var _status_effects_dict = {}


func process(delta):
	for status_effect in _status_effects_dict.values():
		status_effect.process(delta)

		if status_effect.is_expired:
			status_effect.remove.call()
			# Since we're iterating over the dictionary's
			# keys we can safely modify the dictionary
			_status_effects_dict.erase(status_effect.name)


func add_status_effect(status_effect: StatusEffect):
	if _status_effects_dict.has(status_effect.name):
		return

	_status_effects_dict[status_effect.name] = status_effect
	status_effect.add.call()
