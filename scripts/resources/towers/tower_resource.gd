class_name TowerResource
extends Resource

@export var name: String
@export_multiline var description: String
@export var texture: Texture2D
@export var base_area: Vector2i = Vector2i(1, 1)
@export var tower_scene: PackedScene
@export var weapons: Array[String]
@export var hit_points: int
@export var gold_cost: int
@export var core_cost: int
@export_flags("IS_MAIN_TOWER") var _flags = 0
@export var tower_abilities: Array[TowerAbilityResource]


var is_main_tower: bool:
	get:
		return has_flag(TowerFlags.IS_MAIN_TOWER)


func has_flag(flag: TowerFlags):
	return _flags & flag != 0


enum TowerFlags {
	IS_MAIN_TOWER = 1 << 0
}
