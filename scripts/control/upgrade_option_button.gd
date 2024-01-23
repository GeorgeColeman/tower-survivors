class_name UpgradeOptionButton
extends Button

@export var _name_label: Label
@export var _rank_label: Label
@export var _flair_label: Label
@export var _description_label: Label
@export var _stats_label: Label
@export var _main_texure: TextureRect


func set_upgrade_option(option: UpgradeOption):
	_name_label.text = option.name
	_rank_label.text = "Rank %s" % option.rank
	_flair_label.text = option.flair
	_description_label.text = option.description
	_stats_label.text = option.stats

	if option.texture:
		_main_texure.texture = option.texture


# Example of a workaround if we want to clone an existing node.
# Source: https://github.com/godotengine/godot/issues/78060#issuecomment-1722527964
#func clone() -> UpgradeOptionButton:
	#var packed_clone = PackedScene.new()
	#packed_clone.pack(self)
	#return packed_clone.instantiate() as UpgradeOptionButton
