class_name Mob
extends Node2D

signal exited_node(mob: Mob, node: Vector2i)
signal entered_node(mob: Mob, node: Vector2i)
signal attacked_tower(mob: Mob)
signal was_hit_not_killed(mob: Mob)
signal was_killed(mob: Mob)

@onready var sprite: Sprite2D = $Sprite2D

var status_effects: StatusEffects

var cell: Cell:
	get:
		return GameUtilities.get_cell_at_vector2i(_path_follower.current_node)

var _mob_resource: MobResource
var _is_initialised: bool
var _path_follower: PathFollower
var _target_cell: Cell
var _hit_points: int
var _is_destroyed = false
var _tint_colour = Color.WHITE

var _base_move_speed: float:
	get:
		return _mob_resource.move_speed

var _move_speed_modifier: float = 1

var damage: int:
	get:
		return _mob_resource.damage

var gold_value: int:
	get:
		return _mob_resource.gold_value


func _process(_delta):
	if _is_destroyed:
		return

	if !_is_initialised:
		return

	_path_follower.process(Game.speed_scaled_delta)
	position = _path_follower.smooth_position

	status_effects.process(Game.speed_scaled_delta)


func set_resource(mob_resource: MobResource):
	_mob_resource = mob_resource
	_hit_points = mob_resource.hit_points

	_path_follower = PathFollower.new()
	_path_follower.set_move_speed(_base_move_speed)

	_path_follower.exited_node.connect(func(node): exited_node.emit(self, node))
	_path_follower.entered_node.connect(func(node): entered_node.emit(self, node))
	_path_follower.path_completed.connect(_on_path_completed)

	status_effects = StatusEffects.new()

	_is_initialised = true


func set_tint_colour(colour: Color):
	_tint_colour = colour
	sprite.modulate = _tint_colour


func add_move_speed_modifier(amount: float):
	_move_speed_modifier += amount

	# Update path follower
	_path_follower.set_move_speed(_base_move_speed * _move_speed_modifier)


func set_path(path: PackedVector2Array, target_cell: Cell):
	_path_follower.set_path(path)
	_target_cell = target_cell


func _on_path_completed():
	var is_at_target_position = GameUtilities.get_cell_at(position) == _target_cell

	if is_at_target_position:
		_attack_tower()
	else:
		print_debug(
			"WARNING: Mob reached the end of the path, but is not at the target position")


func take_damage(damage_amount: int):
	# Prevent the mob from exiting its node twice if it takes damage and is destroyed on the same frame
	if _is_destroyed:
		return

	_hit_points -= damage_amount

	if _hit_points <= 0:
		Messenger.mob_killed.emit(self)
		# Ensure the mob exits its current node so mob spawner is made aware
		_path_follower.exit_current()
#		destroy()
		_animated_destroy()
	else:
		TweenEffects.flash_white(sprite, _tint_colour)
		was_hit_not_killed.emit(self)

	Messenger.floating_text_requested.emit(str(damage_amount), position, EffectType.DAMAGE_NUMBER)


func _attack_tower():
	attacked_tower.emit(self)
	destroy()


func destroy():
	_is_destroyed = true
	queue_free()


func _animated_destroy():
	_is_destroyed = true
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(0, 0, 0, 0), 0.5)
	tween.tween_callback(queue_free)
	was_killed.emit(self)
