class_name PlayerCharacterResource
extends Resource

@export var name: String
@export var main_tower: TowerResource
@export var starting_towers: Array[TowerResource]


func get_player_character() -> PlayerCharacter:
	return PlayerCharacter.new(self)
