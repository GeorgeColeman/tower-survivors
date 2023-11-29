class_name UpgradeResourceDamage
extends UpgradeResource

@export var damage_amount: int


func add_to_tower(tower: Tower):
	tower.tower_stats.add_bonus_damage(damage_amount)
