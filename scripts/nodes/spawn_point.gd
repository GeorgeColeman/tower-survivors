class_name SpawnPoint
extends Node2D

#signal spawn_triggered(spawn_point: SpawnPoint)

@export var spawn_rate = 5.0
@export var spawn_rate_variance = 0.5

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
	_spawn_cooldown = spawn_rate + randf_range(-spawn_rate_variance, spawn_rate_variance)


func _process(_delta):
	if _spawn_delay > 0:
		_spawn_delay -= Game.speed_scaled_delta

		return

	_spawn_cooldown -= Game.speed_scaled_delta

	if _spawn_cooldown <= 0:
		_spawn_cooldown = spawn_rate + randf_range(-spawn_rate_variance, spawn_rate_variance)
		MobUtilities.spawn_mob_at(self)
		#spawn_triggered.emit(self)


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
