class_name MobBody
extends Area2D

signal damaged(damage_info: DamageInfo)

var _deferred_damages: Array[DamageInfo] = []


func _process(_delta):
	if _deferred_damages.size() > 0:
		for damage in _deferred_damages:
			damaged.emit(damage)

	_deferred_damages.clear()


#func take_damage(damage_info: DamageInfo):
	#damaged.emit(damage_info)


# Avoid adding new collision areas as a result collision triggers (on the same frame).
# Apply the damage on the frame after the collision occurs.
func take_damage_deferred(damage_info: DamageInfo):
	_deferred_damages.append(damage_info)
