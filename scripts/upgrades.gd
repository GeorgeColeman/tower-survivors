# --------------------------------
# Manages upgrades for the player.
# --------------------------------

class_name Upgrades
extends RefCounted

signal upgrade_options_set(options: UpgradeOptions)
signal passive_rank_added(passive: PassiveUpgrade)

var passives_dict = {}					# <String, PassiveUpgrade>
var upgrades_listed: String

var _current_upgrade_options: UpgradeOptions
var _added_upgrades: Array[UpgradeOption]


func set_upgrade_options(options: UpgradeOptions):
	_current_upgrade_options = options

	upgrade_options_set.emit(options)


func add_upgrade(upgrade: UpgradeOption):
	upgrade.apply()

	_added_upgrades.append(upgrade)

	if _added_upgrades.size() == 1:
		upgrades_listed += upgrade.name

		if upgrade.rank:
			upgrades_listed += ", %s" % upgrade.rank
	else:
		upgrades_listed += str("\n%s" % upgrade.name)

		if upgrade.rank:
			upgrades_listed += ", %s" % upgrade.rank

	#print_debug(upgrades_listed)


func can_rank_up_passive(passive_key: String) -> bool:
	if !passives_dict.has(passive_key):
		return false

	var passive: PassiveUpgrade = passives_dict[passive_key]

	if passive.is_at_max_rank:
		return false

	return true


func add_passive(passive: PassiveUpgrade):
	if passives_dict.has(passive.name):
		push_warning("Passives dict already has key: %s. Aborting" % passive.name)

		return

	passives_dict[passive.name] = passive

	passive_rank_added.emit(passive)
	#print_debug("TODO: apply passive")


func rank_up_passive(passive_key: String):
	if !passives_dict.has(passive_key):
		push_warning("Passives dict doesn't have: %s. Aborting" % passive_key)

		return

	passives_dict[passive_key].rank_up()

	passive_rank_added.emit(passives_dict[passive_key])
