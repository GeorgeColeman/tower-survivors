class_name TowerAbilityGenerateExperience
extends TowerAbility

var _tower_ability_resource: TowerAbilityResourceGenerateExperience

var _amount: int
var _frequency: float

var _proc_timer: float


func _init(tower_ability_resource: TowerAbilityResourceGenerateExperience):
	_tower_ability_resource = tower_ability_resource

	_amount = tower_ability_resource.amount
	_frequency = tower_ability_resource.frequency


func process(delta: float):
	_proc_timer += delta

	if _proc_timer >= _frequency:
		_proc_timer = _proc_timer - _frequency

		_generate_experience()


func _generate_experience():
	PlayerUtilities.add_experience(_amount)

	_tower_graphics.play_animation_once("flash_twice")
