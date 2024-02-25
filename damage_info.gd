# ------------------------------------------------
# Contains information about an instance of damage
# ------------------------------------------------

class_name DamageInfo
extends RefCounted

var damage_amount: int
var damage_type: DamageType
var is_crit: bool

enum DamageType {
	NONE,
	FIRE
}
