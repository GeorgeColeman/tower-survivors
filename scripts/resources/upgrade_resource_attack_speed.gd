class_name UpgradeResourceAttackSpeed
extends UpgradeResource

@export var attack_speed_amount: float


func add_to_tower(tower: Tower):
	tower.tower_stats.add_bonus_attack_speed(attack_speed_amount)
