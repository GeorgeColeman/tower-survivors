class_name VFXRequestFactory

static func request_damage_number(position: Vector2, damage_info: DamageInfo):
	var message = str(damage_info.damage_amount)
	var colour = Color.WHITE if !damage_info.is_crit else Color.RED

	VFXDrawer2D.request_vfx(VFXDrawer2D.EffectType.DAMAGE_NUMBER, position, message, colour)


static func request_fire_burst(position: Vector2):
	VFXDrawer2D.request_vfx(VFXDrawer2D.EffectType.FIRE_BURST, position)
