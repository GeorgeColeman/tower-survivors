class_name Difficulty
extends RefCounted

signal changed(difficulty: float)
signal spawn_boss_triggered()
signal spawn_elite_triggered()

var _time: float
var _current_second: int = 1
var _current_minute: int = 1
var _difficulty: float = 1

var _chance_to_spawn_elite: float = -1.0


func process(delta: float):
	_time += delta

	if _time > _current_minute * 60:
		_current_minute += 1
		
		if (_current_minute - 1) % 2 == 0:
			_increase_by(1)

	while _time >= _current_second:
		_current_second += 1

		_chance_to_spawn_elite += 0.025

		# Spawn elite is rolled every 4 seconds
		if _current_second % 4 == 0:
			if _chance_to_spawn_elite >= randf():
				_spawn_elite()

		#print_debug("Second passed")


func _increase_by(amount: float):
	_difficulty += amount
	changed.emit(_difficulty)

	Messenger.log_game_event("Game difficulty increased. Current difficulty: %s." % str(_difficulty))


func _spawn_boss():
	spawn_boss_triggered.emit()


func _spawn_elite():
	#print_debug("Spawning elite. Chance: %s%%" % (_chance_to_spawn_elite * 100))

	_chance_to_spawn_elite = -1.0
	
	spawn_elite_triggered.emit()
