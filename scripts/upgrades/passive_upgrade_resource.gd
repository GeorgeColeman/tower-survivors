class_name PassiveUpgradeResource
extends Resource

@export var id: String
@export var name: String
@export var main_texture: Texture2D
@export var ranks: Array[PassiveUpgradeRankResource]


func get_passive_upgrade() -> PassiveUpgrade:
	var passive_upgrade = PassiveUpgrade.new()

	passive_upgrade.id = id
	passive_upgrade.name = name
	passive_upgrade.texture = main_texture
	passive_upgrade.ranks = _get_ranks()

	return passive_upgrade


func _get_ranks() -> Array[PassiveUpgrade.PassiveUpgradeRank]:
	var initialised_ranks: Array[PassiveUpgrade.PassiveUpgradeRank] = []
	var i: int = 0

	for rank_resource in ranks:
		var rank = PassiveUpgrade.PassiveUpgradeRank.new()

		rank.number = i
		i += 1

		rank_resource.add_upgrades_to_passive_upgrade_rank(rank)

		# Remove the leading new line from rank description
		if rank.description.length() > 1:
			rank.description = rank.description.substr(1, rank.description.length())

		initialised_ranks.append(rank)

	return initialised_ranks
