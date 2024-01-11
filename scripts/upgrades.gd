# --------------------------------
# Manages upgrades for the player.
# --------------------------------

class_name Upgrades
extends RefCounted

signal upgrade_options_set(options: UpgradeOptions)
#signal perk_added(perk: Perk)
signal passive_rank_added(passive: PassivePerk)

#var perks: Array[Perk] = []
var passives_dict = {}					# <String, PassivePerk>

var _current_upgrade_options: UpgradeOptions


func set_upgrade_options(options: UpgradeOptions):
	_current_upgrade_options = options

	upgrade_options_set.emit(options)


func can_rank_up_passive(passive_key: String) -> bool:
	if !passives_dict.has(passive_key):
		return false

	var passive: PassivePerk = passives_dict[passive_key]

	if passive.is_at_max_rank:
		return false

	return true


func add_passive(passive: PassivePerk):
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
