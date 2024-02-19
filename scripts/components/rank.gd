class_name Rank
extends RefCounted

signal rank_added(current_rank: int)

var _rank: int = 0
var _next_rank_cost: int = 1


var display_rank:
	get:
		return _rank + 1


func set_rank(value: int):
	_rank = value


func set_min_rank(value: int):
	while _rank < value:
		add_rank(1)


func add_rank(amount: int):
	_rank += amount

	_next_rank_cost = _rank + 1				# TEMP

	rank_added.emit(_rank)

	#if GameRules.PASSIVE_LIMITED_TO_TOWER_RANK:
		#for passive in _passive_upgrade_dict.values():
			#passive.match_tower_rank_and_apply(self)
#
	#description_updated.emit(description)


func try_upgrade(player: Player):
	if !player:
		print_debug("TODO: proide player (or currency access)")

		return

	if player.cores < _next_rank_cost:
		print_debug("Cannot afford upgrade")

		return

	player.add_cores(-_next_rank_cost)

	add_rank(1)
