# 'Fracture'?

extends MobFeature

@export var mob_to_spawn: MobResource
@export var number: int


func register_owner(p_mob: Mob):
	p_mob.was_killed.connect(
		func(mob: Mob):
			var new_mobs: Array[Mob] = MobUtilities.spawn_mobs_in_random_neighbouring_tiles(
				mob_to_spawn,
				number,
				mob.cell
			)

			for new_mob in new_mobs:
				new_mob.set_invulnerable_time(0.5)
	)
