class_name StatUpgradeResourceMaxHP
extends StatUpgradeResource

@export var amount: float


func add_to_passive_upgrade_rank(rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\n+%s%% max hit points" % (amount * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			print_debug("TODO: apply max hp to tower")
	)
