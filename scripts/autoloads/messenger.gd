extends Node

signal game_event_occured(game_event: GameEvent)
signal mob_killed(mob: Mob)
signal clicked_on_actor(actor)
signal clicked_on_empty()

signal start_game_requested()
signal floating_text_requested(message: String, position: Vector2, effect_type: int)


func request_floating_text(message: String):
	var game_event = GameEvent.new(message)
	game_event_occured.emit(game_event)
