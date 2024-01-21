# --------------------------
# Tower weapon runtime data.
# --------------------------
class_name TowerWeaponData
extends RefCounted

var id: String
var name: String
var targeting_type: Enums.TargetingType
var damage: int
var attack_speed: float
var attack_range: int
var projectile_speed: int
var weapon_effects: Array[WeaponEffect] = []
var proj_scene: PackedScene
var sfx: AudioStream


func _init(
	p_id: String,
	p_name: String,
	p_targeting_type: Enums.TargetingType,
	p_damage: int,
	p_attack_speed: float,
	p_range: int,
	p_projectile_speed: int,
	p_weapon_effects: Array[WeaponEffect],
	p_proj_scene: PackedScene,
	p_sfx: AudioStream
):
	id = p_id
	name = p_name
	targeting_type = p_targeting_type
	damage = p_damage
	attack_speed = p_attack_speed
	attack_range = p_range
	projectile_speed = p_projectile_speed
	weapon_effects = p_weapon_effects
	proj_scene = p_proj_scene
	sfx = p_sfx


func get_description() -> String:
	var description: String

	description = "Damage: %s" % damage
	description += "\nRange: %s" % attack_range
	description += "\nAttack Speed: %s" % attack_speed

	return description
