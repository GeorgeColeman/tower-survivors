class_name ItemResource
extends Resource

@export var id: String
@export var name: String
@export var main_texture: Texture2D
@export var functions: Array[ItemFunctionResource]


func get_item():
	pass


func get_description() -> String:
	var description: String = ""

	for function in functions:
		description += "\n%s" % function.get_description()

	description.strip_edges()

	return description
