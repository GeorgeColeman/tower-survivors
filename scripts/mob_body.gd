class_name MobBody
extends Area2D

signal damaged(damage_info: DamageInfo)

var mob: Mob
var is_immune = false

var _immune_time = 0.0


func _process(_delta):
	if _immune_time > 0:
		_immune_time -= Game.speed_scaled_delta

		if _immune_time <= 0:
			is_immune = false


func set_invulnerable_time(time: float):
	_immune_time = time

	if time > 0:
		is_immune = true


func take_damage(damage_info: DamageInfo):
	if is_immune:
		print_debug("Mob body is invulnerable")

		return

	damaged.emit(damage_info)
