# ------------------------------------------------------------------
# Contains information about a building (tower) the player can build
# ------------------------------------------------------------------

class_name BuildingOption
extends RefCounted

signal upgraded()
signal can_build_updated(can_build: bool)

var name: String
var scene: PackedScene
var texture: Texture2D
var gold_cost: int
var rank: int = 1
var on_build_confirmed: Callable = func(_cell: Cell): pass
var can_build: bool


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


func confirm_build(cell: Cell):
	on_build_confirmed.call(cell)
