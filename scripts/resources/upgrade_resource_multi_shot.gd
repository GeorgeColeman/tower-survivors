class_name UpgradeResourceMultiShot
extends UpgradeResource

@export var extra_shots: int


func add_to_tower(tower: Tower):
	tower.tower_stats.add_multi_shot(extra_shots)


func get_description():
	return "Multi shot +{extra_shots}".format(
		{
		"extra_shots": str(extra_shots)
		}
	)
