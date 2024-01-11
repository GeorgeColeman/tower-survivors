class_name PlayerCharacterDataResolver
extends RefCounted


static func get_player_characters(game_data: GameData) -> Array[PlayerCharacter]:
	var data: Array[PlayerCharacter] = []
	var config = ConfigFile.new()
	var err = config.load("res://config/player_characters.cfg")

	if err != OK:
		return []

	for section in config.get_sections():
		var name = config.get_value(section, "name")
		var main_tower_name = config.get_value(section, "main_tower")
		var starting_tower_names = config.get_value(section, "starting_towers")

		var player_character = PlayerCharacter.new()

		player_character.name = name

		var main_tower = game_data.try_get_tower_resource(main_tower_name)

		if main_tower:
			player_character.main_tower = main_tower

		for tower_name in starting_tower_names:
			var tower = game_data.try_get_tower_resource(tower_name)
			
			if tower:
				player_character.starting_towers.append(tower)

		data.append(player_character)

	return data
