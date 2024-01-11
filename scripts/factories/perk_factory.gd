class_name PerkFactory
extends RefCounted


static func new_passive(passive: PassivePerk, player: Player) -> UpgradeOption:
	var cloned_passive = passive.clone()

	var option = UpgradeOption.new(
		cloned_passive.name,
		"New",
		#str(cloned_passive.display_rank),
		"NEW PASSIVE",
		cloned_passive.get_current_rank_description(),
		func():
			player.upgrades.add_passive(cloned_passive)
	)

	option.texture = passive.texture

	return option


static func rank_up_passive(passive_key: String, player: Player) -> UpgradeOption:
	var passive: PassivePerk = player.upgrades.passives_dict[passive_key]

	var option = UpgradeOption.new(
		passive.name,
		str(passive.display_rank + 1),
		"RANK UP PASSIVE",
		passive.get_next_rank_description(),
		func():
			player.upgrades.rank_up_passive(passive.name)
	)

	option.texture = passive.texture

	return option


static func new_weapon(tower: Tower, weapon_data: TowerWeaponData) -> UpgradeOption:
	var option = UpgradeOption.new(
		weapon_data.name,
		"New",
		"CATEGORY UNUSED",
		"TODO: weapon data description",
		func():
			tower.attach_weapon_from_weapon_data(weapon_data)
	)

	return option


static func rank_up_weapon(weapon: TowerWeapon) -> UpgradeOption:
	var option = UpgradeOption.new(
		weapon.weapon_name,
		"Rank %s" % (weapon.rank + 1),
		"CATEGORY UNUSED",
		"TODO: weapon rank up description",
		func():
			weapon.rank_up()
	)

	return option


static func rank_up_tower(tower: Tower, existing: BuildingOption) -> UpgradeOption:
	var option = UpgradeOption.new(
		tower.tower_name,
		"Rank %s" % (existing.rank + 1),
		"Rank Up Tower",
		"TODO: tower rank up description",
		func():
			existing.upgrade()
	)

	option.texture = tower.main_sprite_2d.texture

	return option


static func rank_up_specific_tower(tower: Tower) -> UpgradeOption:
	var option = UpgradeOption.new(
		tower.tower_name,
		"Rank %s" % (tower._rank + 1),
		"Rank Up Tower",
		"TODO: tower rank up description",
		func():
			tower.add_rank(1)
	)

	option.texture = tower.main_sprite_2d.texture

	return option


static func new_tower(tower: Tower, apply_callback: Callable) -> UpgradeOption:
	var option = UpgradeOption.new(
			tower.tower_name,
			"New",
			"New Tower",
			tower.weapons_description,
			apply_callback
	)

	option.texture = tower.main_sprite_2d.texture

	return option
