# -------------------------------------------------------
# Contains information about a tower the player can build
# -------------------------------------------------------

class_name BuildingOption
extends RefCounted

signal upgraded()
signal can_build_updated(can_build: bool)

var display_rank:
	get:
		return _rank + 1

var tower_resource: TowerResource
var _rank: int = 0
var try_build_callback: Callable = func(_cell: Cell): pass
var is_buildable: bool
var can_build: bool

var _build_count: int


func upgrade():
	_rank += 1

	upgraded.emit()


func update_can_build(player: Player):
	can_build = player.can_afford_building_option(self)

	can_build_updated.emit(can_build)


func get_core_cost() -> int:
	var tax = _build_count if GameRules.MULTIPLE_TOWER_TAX else 0

	return tower_resource.core_cost + tax


func try_build(cell: Cell):
	try_build_callback.call(cell)


func confirm_build():
	_build_count += 1

	can_build_updated.emit(can_build)
