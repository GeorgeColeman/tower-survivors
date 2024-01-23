class_name UpgradeOptionFactory
extends RefCounted


static func new_passive(passive: PassiveUpgrade, player: Player) -> UpgradeOption:
	var cloned_passive = passive.clone()

	var option = UpgradeOption.new(
		cloned_passive.name,
		func():
			player.upgrades.add_passive(cloned_passive)
	)

	option.rank = 1
	option.flair = "New"
	option.stats = cloned_passive.get_next_rank_description()
	option.texture = passive.texture

	return option


static func rank_up_passive(passive_key: String, player: Player) -> UpgradeOption:
	var passive: PassiveUpgrade = player.upgrades.passives_dict[passive_key]

	var option = UpgradeOption.new(
		passive.name,
		func():
			player.upgrades.rank_up_passive(passive.name)
	)

	option.rank = passive.display_rank + 1
	option.stats = passive.get_next_rank_description()
	option.texture = passive.texture

	return option


#static func new_weapon(tower: Tower, weapon_data: TowerWeaponData) -> UpgradeOption:
	#var option = UpgradeOption.new(
		#weapon_data.name,
		#"New",
		#"CATEGORY UNUSED",
		#func():
			#tower.attach_weapon_from_weapon_data(weapon_data)
	#)
#
	#return option
#
#
#static func rank_up_weapon(weapon: TowerWeapon) -> UpgradeOption:
	#var option = UpgradeOption.new(
		#weapon.weapon_name,
		#"Rank %s" % (weapon.rank + 1),
		#"CATEGORY UNUSED",
		#"TODO: weapon rank up description",
		#func():
			#weapon.rank_up()
	#)
#
	#return option


static func rank_up_tower(existing: BuildingOption) -> UpgradeOption:
	var option = UpgradeOption.new(
		existing.tower_resource.name,
		func():
			existing.upgrade()
	)

	option.rank = existing.rank + 1
	option.texture = existing.tower_resource.texture

	return option


#static func rank_up_specific_tower(tower: Tower) -> UpgradeOption:
	#var option = UpgradeOption.new(
		#tower.tower_name,
		#func():
			#tower.add_rank(1)
	#)
#
	#option.rank = tower._rank + 1
	#option.texture = tower.tower_resource.texture
#
	#return option


static func new_tower(tower_resource: TowerResource, apply_callback: Callable) -> UpgradeOption:
	var option = UpgradeOption.new(
			tower_resource.name,
			apply_callback
	)

	option.rank = 1
	option.flair = "New"
	option.description = tower_resource.description
	option.stats = GameUtilities.get_tower_weapon_description(tower_resource)
	option.texture = tower_resource.texture

	return option


static func add_core(player: Player) -> UpgradeOption:
	var option = UpgradeOption.new(
		"+1 Core",
		func():
			player.add_cores(1)
	)

	option.texture = load("res://sprites/icons/core.tres")

	return option
