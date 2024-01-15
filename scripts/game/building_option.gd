# -------------------------------------------------------
# Contains information about a tower the player can build
# -------------------------------------------------------

class_name BuildingOption
extends RefCounted

signal upgraded()
signal can_build_updated(can_build: bool)

var tower_resource: TowerResource
var tower_proto: Tower

var name: String
var scene: PackedScene
var texture: Texture2D
var gold_cost: int
var rank: int = 1
var try_build_callback: Callable = func(_cell: Cell): pass
var can_build: bool

var _build_count: int


func _init(p_name: String, p_scene: PackedScene, p_texture: Texture2D, p_gold_cost: int):
	name = p_name
	scene = p_scene
	texture = p_texture
	gold_cost = p_gold_cost


func upgrade():
	rank += 1

	upgraded.emit()


func update_can_build(player: Player):
	can_build = player.can_afford_building_option(self)

	can_build_updated.emit(can_build)


func get_core_cost() -> int:
	var tax = _build_count				# TODO

	return tower_resource.core_cost + tax


func try_build(cell: Cell):
	try_build_callback.call(cell)


func confirm_build(tower: Tower):
	tower.set_rank(rank)

	_build_count += 1

	can_build_updated.emit(can_build)

	#print_debug("%s has been built %s time(s)" % [tower_resource.name, _build_count])
