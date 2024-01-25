class_name PassiveUpgradeTowerAttached
extends RefCounted

var name: String
var display_rank: int:
	get:
		return _highest_rank

var _passive_upgrade: PassiveUpgrade
var _highest_rank: int					# The greatest passive upgrade rank that has been applied to the tower so far


func _init(passive_upgrade: PassiveUpgrade):
	_passive_upgrade = passive_upgrade
	
	name = passive_upgrade.name


func match_tower_rank_and_apply(tower: Tower):
	for i in tower._rank + 1:
		if i < _highest_rank:
			continue

		if _highest_rank > _passive_upgrade._current_rank_index:
			continue

		_passive_upgrade.apply_rank_to_tower(i, tower)

		_highest_rank += 1


func ignore_tower_rank_and_apply_max(tower: Tower):
	for i in _passive_upgrade._current_rank_index + 1:
		if i < _highest_rank:
			continue
			
		_passive_upgrade.apply_rank_to_tower(i, tower)
		
		_highest_rank += 1
