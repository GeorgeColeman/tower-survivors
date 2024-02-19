class_name MobCampResource
extends Resource

@export var name: String
@export var main_texture: Texture2D
@export var spawn_rate: float = 5.0
@export var spawn_rate_variance: float = 0.5

@export var spawns_all: bool = true
@export var accepted_mob_tags: Array[Tag]


func can_spawn_mob(mob_resource: MobResource) -> bool:
	for mob_tag in mob_resource.tags:
		for camp_tag in accepted_mob_tags:
			if mob_tag == camp_tag:
				return true

	return false
