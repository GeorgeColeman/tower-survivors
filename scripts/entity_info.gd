# -------------------------------------
# Contains information about an entity.
# -------------------------------------

class_name EntityInfo
extends RefCounted

var entity
var name: String
var description: String
var position: Vector2

func _init(p_entity, p_name: String, p_description: String, p_position: Vector2):
	entity = p_entity
	name = p_name
	description = p_description
	position = p_position
