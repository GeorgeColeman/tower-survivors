class_name PlayerCharacter

var name: String
var main_tower: TowerResource
var starting_towers: Array[TowerResource] = []


func _init(player_character_resource: PlayerCharacterResource):
	name = player_character_resource.name
	main_tower = player_character_resource.main_tower
	starting_towers = player_character_resource.starting_towers
