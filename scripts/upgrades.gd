# --------------------------------
# Manages upgrades for the player.
# --------------------------------

class_name Upgrades
extends RefCounted

signal upgrade_options_set(options: UpgradeOptions)
signal passive_rank_added(passive: PassiveUpgrade)

var passives_dict = {}					# <String, PassiveUpgrade>

var _current_upgrade_options: UpgradeOptions
#var _added_upgrades: Array[UpgradeOption]

var passive_upgrades_listed: String:
	get:
		var d = ""

		for upgrade in passives_dict.values():
			d += "\n%s: %s" % [upgrade.name, upgrade.display_rank]

		d = d.strip_edges()

		return d


func set_upgrade_options(options: UpgradeOptions):
	_current_upgrade_options = options

	upgrade_options_set.emit(options)


func add_upgrade(upgrade: UpgradeOption):
	upgrade.apply()

	#_added_upgrades.append(upgrade)


func can_rank_up_passive(passive_key: String) -> bool:
	if !passives_dict.has(passive_key):
		return false

	var passive: PassiveUpgrade = passives_dict[passive_key]

	if passive.is_at_max_rank:
		return false

	return true


func add_passive(passive: PassiveUpgrade):
	if passives_dict.has(passive.id):
		push_warning("Passives dict already has key: %s. Aborting" % passive.id)

		return

	passives_dict[passive.id] = passive

	passive_rank_added.emit(passive)


func rank_up_passive(passive_key: String):
	if !passives_dict.has(passive_key):
		push_warning("Passives dict doesn't have: %s. Aborting" % passive_key)

		return

	passives_dict[passive_key].rank_up()

	passive_rank_added.emit(passives_dict[passive_key])
