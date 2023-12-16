# ------------------------------------------------------------------
# Contains information about a building (tower) the player can build
# ------------------------------------------------------------------

class_name BuildingOption
extends RefCounted

signal upgraded()

var id: int
var scene: PackedScene
var texture: Texture2D
var gold_cost: int
var rank: int = 1
var on_build_confirmed: Callable = func(_cell: Cell): pass


func _init(p_id: int, p_scene: PackedScene, p_texture: Texture2D, p_gold_cost: int):
	id = p_id
	scene = p_scene
	texture = p_texture
	gold_cost = p_gold_cost


func upgrade():
	rank += 1

	upgraded.emit()


func confirm_build(cell: Cell):
	on_build_confirmed.call(cell)
