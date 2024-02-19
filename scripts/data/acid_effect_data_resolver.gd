class_name AcidEffectDataResolver


static func _resolve_acid_effect(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank):
	rank.description += "\nSpawn a lingering area of damaging acid after attacking"

	var acid_effect = WeaponEffectAcid.new()

	rank.description += "\n%s" % acid_effect.info

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			tower.tower_stats.add_weapon_effect(effect_id, WeaponEffectAcid.new())
	)


static func _resolve_acid_duration(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s acid duration" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var acid_effect: WeaponEffectAcid = tower.tower_stats.try_get_weapon_effect(effect_id)

			acid_effect.add_duration(variant)
	)


static func _resolve_acid_damage(effect_id: String, rank: PassiveUpgrade.PassiveUpgradeRank, variant):
	rank.description += "\n+%s acid damage" % variant

	rank.apply_to_tower_callbacks.append(
		func(tower: Tower):
			var acid_effect: WeaponEffectAcid = tower.tower_stats.try_get_weapon_effect(effect_id)

			acid_effect.add_damage(variant)
	)
