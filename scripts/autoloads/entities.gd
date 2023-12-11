extends Node

signal spawn_entity_requested(params: SpawnEntityParams)


func spawn_entity(params: SpawnEntityParams):
	spawn_entity_requested.emit(params)
