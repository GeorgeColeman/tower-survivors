extends Node

signal game_event_occured(game_event: GameEvent)
signal mob_killed(mob: Mob)
signal clicked_on_entity(actor)
signal clicked_on_empty()

signal start_game_requested()


func log_game_event(message: String):
	var game_event = GameEvent.new(message)

	game_event_occured.emit(game_event)
