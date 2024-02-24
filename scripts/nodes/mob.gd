class_name Mob
extends Node2D

signal exited_cell(mob: Mob, cell: Cell)
signal entered_cell(mob: Mob, cell: Cell)
signal was_hit_not_killed(mob: Mob)
signal was_killed(mob: Mob)
signal path_to_centre_requested(mob: Mob)

@export var features: Array[MobFeature]
@export var hit_points_component: HitPointsComponent
@export var mob_body: MobBody
@export var _main_sprite: Node2D

var movement: Movement
var status_effects: StatusEffects
var attack_component: AttackComponent

var cell: Cell:
	get:
		return movement.cell

var nearest_cell: Cell:
	get:
		return movement.nearest_cell

var _mob_resource: MobResource
var _is_initialised: bool

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

	movement.entered_cell.connect(_on_entered_cell)

	movement.facing_direction_changed.connect(
		func(facing_direction: Movement.FacingDirection):
			match facing_direction:
				Movement.FacingDirection.LEFT:
					_main_sprite.scale.x = 1
				Movement.FacingDirection.RIGHT:
					_main_sprite.scale.x = -1
	)

	movement.path_completed.connect(_on_path_completed)

	status_effects = StatusEffects.new()

	for feature in features:
		feature.register_owner(self)

	mob_body.mob = self

	mob_body.damaged.connect(
		func(damage_info: DamageInfo):
			take_damage(damage_info)
	)

	if mob_resource.is_boss() || mob_resource.is_elite():			# TEMP: hardcoding
		core_value = 1

	attack_component = AttackComponent.new(mob_resource.damage, _attacks_per_second)

	attack_component.target_became_invalid.connect(
		func():
			path_to_centre_requested.emit(self)
	)

	_is_initialised = true


func set_tint_colour(colour: Color):
	_tint_colour = colour
	_main_sprite.modulate = _tint_colour


func take_damage(damage_info: DamageInfo):
	# Prevent the mob from exiting its node twice if it takes damage and is destroyed on the same frame
	if _is_destroyed:
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
		TweenEffects.flash_white(_main_sprite, _tint_colour)
		was_hit_not_killed.emit(self)

	VFXRequestFactory.request_damage_number(position, damage_info)


func _on_path_completed():
	var tower = GameUtilities.get_nearby_tower(cell)

	if tower:
		_start_attacking_tower(tower)
	else:
		print_debug("Path completed, but no nearby towers")


func _start_attacking_tower(tower: Tower):
	attack_component.start_attacking(tower)


func destroy():
	movement.destroy()
	_is_destroyed = true
	queue_free()


func animated_spawn():
	_main_sprite.modulate.a = 0
	var tween = get_tree().create_tween()
	tween.tween_property(_main_sprite, "modulate:a", 1, 0.5)


func _animated_destroy():
	movement.destroy()
	_is_destroyed = true
	var tween = get_tree().create_tween()
	tween.tween_property(_main_sprite, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.tween_callback(queue_free)
	was_killed.emit(self)


func _on_entered_cell(p_cell: Cell):
	entered_cell.emit(self, p_cell)

	if !_mob_resource.has_properties(MobResource.MobProperties.AGGRESSIVE):
		return

	var tower = GameUtilities.get_nearby_tower(p_cell)

	if tower:
		movement.cancel_path()
		_start_attacking_tower(tower)
		#print_debug("TODO: mob entered cell next to tower. Attack tower if agressive type")
