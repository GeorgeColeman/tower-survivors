class_name AttackComponent
extends RefCounted

var _damage: int
var _attacks_per_second: float
var _enabled: bool

var _target_tower: Tower
var _attack_cooldown: float


func _init(p_damage: int, p_attacks_per_second: float):
	_damage = p_damage
	_attacks_per_second = p_attacks_per_second


func process(delta: float):
	if !_enabled:
		return

	_attack_cooldown -= delta

	if _attack_cooldown <= 0:
		_attack()


func start_attacking(tower: Tower):
	_enabled = true
	_target_tower = tower
	_attack_cooldown = 1 / _attacks_per_second


func _attack():
	#print_debug("Attacking")
	
	_attack_cooldown = 1 / _attacks_per_second

	if _target_tower:
		_target_tower.take_damage(_damage)
