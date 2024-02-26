class_name TowerAbilityResourceGenerateExperience
extends TowerAbilityResource

@export var amount: int = 1
@export var frequency: float = 5.0


func get_tower_ability() -> TowerAbilityGenerateExperience:
	return TowerAbilityGenerateExperience.new(self)
