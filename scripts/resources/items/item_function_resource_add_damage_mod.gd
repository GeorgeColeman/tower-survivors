class_name ItemFunctionResourceAddDamageMod
extends ItemFunctionResource

@export var _amount: float


func get_description() -> String:
	return "Increases damage modifier by %s%%." % (_amount * 100)
