class_name StatUpgradeResourceThorns
extends StatUpgradeResource

@export var damage: int


func add_to_passive_upgrade_rank(rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\n+%s thorns" % damage

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			print_debug("TODO: apply thorns to tower")
	)
