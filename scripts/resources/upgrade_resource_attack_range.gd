class_name UpgradeResourceAttackRange
extends UpgradeResource

@export var attack_range_amount: int


func add_to_tower(tower: Tower):
	tower.tower_stats.add_bonus_attack_range(attack_range_amount)


func get_description():
	return "Attack range +{attack_range}".format(
		{
		"attack_range": str(attack_range_amount)
		}
	)
