class_name TowerResource
extends Resource

@export var name: String
@export var tower_scene: PackedScene
@export var weapons: Array[String]
@export var hit_points: int
@export var gold_cost: int
@export var core_cost: int
@export_flags("IS_MAIN_TOWER") var _flags


var can_be_offered_as_new_tower: bool:
	get:
		return !has_flag(TowerFlags.IS_MAIN_TOWER)


func has_flag(flag: TowerFlags):
	return _flags & flag != 0


enum TowerFlags {
	IS_MAIN_TOWER = 1 << 0
}
