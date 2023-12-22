class_name VFXRequestFactory

static func request_damage_number(position: Vector2, message: String):
	VFXDrawer2D.request_vfx(VFXDrawer2D.EffectType.DAMAGE_NUMBER, position, message)


static func request_fire_burst(position: Vector2):
	VFXDrawer2D.request_vfx(VFXDrawer2D.EffectType.FIRE_BURST, position)
