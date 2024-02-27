class_name TowerAbilityResourceWeaponFourDirection
extends TowerAbilityResource

@export var damage: int
@export var attack_speed: float
@export var range: int
@export var projectile_speed: int
@export var projectile_scene: PackedScene


func get_tower_ability() -> TowerAbilityWeaponFourDirection:
	return TowerAbilityWeaponFourDirection.new(self)
