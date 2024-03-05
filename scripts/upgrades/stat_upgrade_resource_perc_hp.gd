class_name StatUpgradeResourceMaxHP
extends StatUpgradeResource

@export var amount: float


func add_to_passive_upgrade_rank(rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\n+%s%% max hit points" % (amount * 100)

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.hit_points_component.add_max_modifier(amount)
	)
