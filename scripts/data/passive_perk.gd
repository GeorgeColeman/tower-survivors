class_name PassivePerk

var name: String
var texture: Texture2D
var ranks: Array[Rank] = []

var is_at_max_rank: bool:
	get:
		return _current_rank_index >= ranks.size() - 1

var display_rank:
	get:
		return _current_rank_index + 1

var _current_rank_index: int = -1


func clone() -> PassivePerk:
	var passive = PassivePerk.new()

	passive.name = name
	passive.texture = texture
	passive.ranks = ranks
	passive._current_rank_index = 0

	#for rank in ranks:
		#print_debug(rank.number)

	return passive


func get_current_rank_description() -> String:
	if _current_rank_index >= ranks.size():
		push_warning(
			"Current rank index %s is out of range of the number of ranks %s" %
			[_current_rank_index, ranks.size()]
		)

		return "NO DESCRIPTION"

	return ranks[_current_rank_index].description


func get_next_rank_description() -> String:
	var next_rank_index = _current_rank_index + 1

	if next_rank_index >= ranks.size():
		push_warning(
			"Next rank index %s is out of range of the number of ranks %s" %
			[next_rank_index, ranks.size()]
		)

		return "NO DESCRIPTION"

	return ranks[next_rank_index].description


func rank_up():
	_current_rank_index += 1


func apply_all_ranks_to_tower(tower: Tower):
	for i in _current_rank_index + 1:
		ranks[i].apply_to_tower(tower)


func apply_current_rank_to_tower(tower: Tower):
	if _current_rank_index >= ranks.size():
		push_warning(
			"Current rank index %s is out of range of the number of ranks %s" %
			[_current_rank_index, ranks.size()]
		)

		return

	ranks[_current_rank_index].apply_to_tower(tower)


class Rank:

	var number: int
	var description: String
	var apply_to_tower_callbacks: Array[Callable]


	func apply_to_tower(tower: Tower):
		for callback in apply_to_tower_callbacks:
			callback.call(tower)
