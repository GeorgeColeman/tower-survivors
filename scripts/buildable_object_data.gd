class_name BuildableObjectData
extends RefCounted

var scene: PackedScene
var gold_cost: int
var on_build_confirmed: Callable = func(_cell: Cell): pass


func _init(p_scene: PackedScene, p_gold_cost: int):
	scene = p_scene
	gold_cost = p_gold_cost


func confirm_build(cell: Cell):
	on_build_confirmed.call(cell)
