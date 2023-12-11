extends MobFeature

@export var mob_to_spawn: MobResource
@export var number: int


func register_owner(p_mob: Mob):
	p_mob.was_killed.connect(
		func(mob: Mob):
			MobSpawnerUtilities.spawn_mobs_in_random_neighbouring_tiles(
				mob_to_spawn,
				number,
				mob.cell
			)
	)
