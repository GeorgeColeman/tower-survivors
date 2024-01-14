class_name TowerResource
extends Resource

@export var name: String
@export var tower_scene: PackedScene
@export var weapons: Array[String]
@export var hit_points: int
@export var gold_cost: int
@export var core_cost: int
@export_flags("IS_MAIN_TOWER") var _flags
