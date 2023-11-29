class_name UpgradeOptionButton
extends Button

@export var _description_label: Label

var _on_pressed: Callable = func(): print("Pressed")


func set_description(description: String):
	_description_label.text = description


func _pressed():
	_on_pressed.call()


func set_on_pressed(callable: Callable):
	_on_pressed = callable


# Example of a workaround if we want to clone an existing node. Source: https://github.com/godotengine/godot/issues/78060#issuecomment-1722527964
func clone() -> UpgradeOptionButton:
	var packed_clone = PackedScene.new()
	packed_clone.pack(self)
	return packed_clone.instantiate() as UpgradeOptionButton
