extends Node

signal game_event_occured(game_event: GameEvent)
signal mob_killed(mob: Mob)
signal clicked_on_entity(entity_info: EntityInfo)
signal clicked_on_empty()
signal draw_tower_attack_range_requested(tower: Tower)
signal draw_cell_area_requested(cell_area: Array[Cell])
signal alerted(message: String)
signal start_game_requested()
signal game_started(game: Game)


func log_game_event(message: String):
	var game_event = GameEvent.new(message)

	game_event_occured.emit(game_event)


func create_alert(message: String):
	alerted.emit(message)


func start_game(game: Game):
	game_started.emit(game)
