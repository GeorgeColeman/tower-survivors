class_name SpawnPoint
extends Node2D
# A very simple object that probably doesn't have to be a node (TODO)

signal spawn_triggered(spawn_point: SpawnPoint)

@export var spawn_rate = 5.0
@export var spawn_rate_variance = 0.5

var cell: Cell

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
		spawn_triggered.emit(self)


func set_spawn_delay(delay: float):
	_spawn_delay = delay
