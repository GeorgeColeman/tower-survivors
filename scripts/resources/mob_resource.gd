class_name MobResource
extends Resource

@export var name: String
@export var mob_scene: PackedScene
@export var move_speed: float = 1
@export var damage = 1 as int
@export var hit_points = 10 as int
@export var gold_value = 1 as int
@export_flags("IN_SPAWN_POOL", "BOSS") var mob_flags = 0

enum MobFlag {
	IN_SPAWN_POOL = 1 << 0,
	BOSS = 1 << 1
}


func is_in_spawn_pool():
	return _has_flag(MobFlag.IN_SPAWN_POOL)


func is_boss():
	return _has_flag(1 << 1)


func _has_flag(mob_flag: MobFlag):
	return mob_flags & mob_flag != 0
