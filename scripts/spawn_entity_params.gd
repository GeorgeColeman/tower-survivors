class_name SpawnEntityParams
extends RefCounted

signal entity_instantiated(entity)

var entity_scene: PackedScene
var cell: Cell
var base_area: Vector2i
var spawned_entity
var entity_destroyed: Signal
