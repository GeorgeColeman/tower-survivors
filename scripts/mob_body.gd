class_name MobBody
extends Area2D

signal damaged(damage_info: DamageInfo)


func take_damage(damage_info: DamageInfo):
	damaged.emit(damage_info)
