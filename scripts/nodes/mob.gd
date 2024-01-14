class_name Mob
extends Node2D

signal exited_cell(mob: Mob, cell: Cell)
signal entered_cell(mob: Mob, cell: Cell)
signal attacked_tower(mob: Mob)
signal was_hit_not_killed(mob: Mob)
signal was_killed(mob: Mob)

@export var features: Array[MobFeature]
@export var sprite_2d: Sprite2D
@export var hit_points_component: HitPointsComponent
@export var mob_body: MobBody

var movement: Movement
var status_effects: StatusEffects
var attack_component: AttackComponent

var cell: Cell:
	get:
		return movement.cell

var _visuals_container: Node2D = self

var _mob_resource: MobResource
var _is_initialised: bool

var _invulnerable_time = 0.0
var _is_invulnerable = false

var _is_destroyed = false
var _tint_colour = Color.WHITE

var damage: int:
	get:
		return _mob_resource.damage

var gold_value: int:
	get:
		return _mob_resource.gold_value

var experience_value: int:
	get:
		return _mob_resource.experience_value

var core_value: int

var _attacks_per_second: float = 1.0


func _process(_delta):
	if _is_destroyed:
		return

	if !_is_initialised:
		return

	if _invulnerable_time > 0:
		_invulnerable_time -= Game.speed_scaled_delta

		if _invulnerable_time <= 0:
			_is_invulnerable = false

	movement.process(Game.speed_scaled_delta)
	position = movement.smooth_position

	status_effects.process(Game.speed_scaled_delta)
	attack_component.process(Game.speed_scaled_delta)


func set_resource(mob_resource: MobResource):
	_mob_resource = mob_resource

	var show_hit_points_bar = mob_resource.is_boss() || mob_resource.is_elite()
	hit_points_component.initialise(mob_resource.hit_points, show_hit_points_bar)

	movement = Movement.new(mob_resource.move_speed)

	movement.exited_cell.connect(
		func(new_cell: Cell):
			exited_cell.emit(self, new_cell)
	)

	movement.entered_cell.connect(
		func(new_cell: Cell):
			entered_cell.emit(self, new_cell)
	)

	movement.facing_direction_changed.connect(
		func(facing_direction: Movement.FacingDirection):
			match facing_direction:
				Movement.FacingDirection.LEFT:
					sprite_2d.flip_h = false
				Movement.FacingDirection.RIGHT:
					sprite_2d.flip_h = true
	)

	movement.path_completed.connect(_on_path_completed)

	status_effects = StatusEffects.new()

	for feature in features:
		feature.register_owner(self)

	mob_body.damaged.connect(
		func(damage_info: DamageInfo):
			take_damage(damage_info)
	)

	if mob_resource.is_boss() || mob_resource.is_elite():			# TEMP: hardcoding
		core_value = 1

	attack_component = AttackComponent.new(mob_resource.damage, _attacks_per_second)

	_is_initialised = true


func set_tint_colour(colour: Color):
	_tint_colour = colour
	_visuals_container.modulate = _tint_colour


func set_invulnerable_time(time: float):
	_invulnerable_time = time

	if time > 0:
		_is_invulnerable = true


func take_damage(damage_info: DamageInfo):
	# Prevent the mob from exiting its node twice if it takes damage and is destroyed on the same frame
	if _is_destroyed:
		return

	if _is_invulnerable:
		return

	hit_points_component.change_current(-damage_info.damage_amount)

	match damage_info.damage_type:
		DamageInfo.DamageType.FIRE:
			VFXRequestFactory.request_fire_burst(position)

	if hit_points_component.is_at_zero:
		Messenger.mob_killed.emit(self)			# TODO: not sure if I like this
		# Ensure the mob exits its current node so mob spawner is made aware
#		destroy()
		_animated_destroy()
	else:
		TweenEffects.flash_white(_visuals_container, _tint_colour)
		was_hit_not_killed.emit(self)

	VFXRequestFactory.request_damage_number(position, str(damage_info.damage_amount))


func _on_path_completed():
	if movement.is_near_target:
		_attack_tower()
	else:
		print_debug("WARNING: path complete, but not near target")


func _attack_tower():
	attacked_tower.emit(self)
	#destroy()


func destroy():
	movement.destroy()
	_is_destroyed = true
	queue_free()


func animated_spawn():
	_visuals_container.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(_visuals_container, "modulate:a", 1, 0.5)


func _animated_destroy():
	movement.destroy()
	_is_destroyed = true
	var tween = get_tree().create_tween()
	tween.tween_property(_visuals_container, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.tween_callback(queue_free)
	was_killed.emit(self)
