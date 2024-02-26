class_name PlayerUtilities

static var _player: Player


static func set_player(player: Player):
	_player = player


static func add_experience(amount: int):
	_player.experience_component.add_experience(amount)
