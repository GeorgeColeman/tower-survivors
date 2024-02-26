class_name PassiveUpgradeRankResource
extends Resource

@export var upgrades: Array[StatUpgradeResource]


func add_upgrades_to_passive_upgrade_rank(rank: PassiveUpgrade.PassiveUpgradeRank):
	for upgrade in upgrades:
		upgrade.add_to_passive_upgrade_rank(rank)
