# --------------------------
# Tower weapon runtime data.
# --------------------------
class_name TowerWeaponData
extends RefCounted

var id: String
var damage: int
var attack_speed: float
var attack_range: int
var weapon_effects: Array[WeaponEffect] = []
var proj_scene: PackedScene
var sfx: AudioStream


func _init(
	p_id: String,
	p_damage: int,
	p_attack_speed: float,
	p_range: int,
	p_weapon_effects: Array[WeaponEffect],
	p_proj_scene: PackedScene,
	p_sfx: AudioStream
):
	id = p_id
	damage = p_damage
	attack_speed = p_attack_speed
	attack_range = p_range
	weapon_effects = p_weapon_effects
	proj_scene = p_proj_scene
	sfx = p_sfx
