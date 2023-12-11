class_name UpgradeOptionButton
extends Button

@export var _description_label: Label


func set_description(description: String):
	_description_label.text = description


# Example of a workaround if we want to clone an existing node. Source: https://github.com/godotengine/godot/issues/78060#issuecomment-1722527964
#func clone() -> UpgradeOptionButton:
	#var packed_clone = PackedScene.new()
	#packed_clone.pack(self)
	#return packed_clone.instantiate() as UpgradeOptionButton
