class_name SpawnPoint
extends Node2D


@export var _sprite: Sprite2D

var _spawn_rate: float
var _spawn_rate_variance: float


var description: String:
	get:
		var d = "Rank %s" % display_rank

		d = d.strip_edges()

		return d

var cell: Cell

var display_rank:
	get:
		return _rank + 1

var _rank: int = 0

var _spawn_cooldown: float
var _spawn_delay: float


func _ready():
	_spawn_cooldown = _spawn_rate + randf_range(-_spawn_rate_variance, _spawn_rate_variance)


func _process(_delta):
	if _spawn_delay > 0:
		_spawn_delay -= Game.speed_scaled_delta

		return

	_spawn_cooldown -= Game.speed_scaled_delta

	if _spawn_cooldown <= 0:
		_spawn_cooldown = _spawn_rate + randf_range(-_spawn_rate_variance, _spawn_rate_variance)
		MobUtilities.spawn_mob_at(self)
		#spawn_triggered.emit(self)


func set_resource(mob_camp_resource: MobCampResource):
	#print_debug(mob_camp_resource.name)
	_sprite.texture = mob_camp_resource.main_texture
	_spawn_rate = mob_camp_resource.spawn_rate
	_spawn_rate_variance = mob_camp_resource.spawn_rate_variance


func get_entity_info() -> EntityInfo:
	return EntityInfo.new(
		self,
		 "Spawn Point",
		 description,
		 position
	)


func set_spawn_delay(delay: float):
	_spawn_delay = delay


func add_rank(amount: int):
	print_debug("TODO: adding rank to spawn point")

	_rank += amount
