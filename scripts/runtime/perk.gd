class_name Perk
extends RefCounted

# TEMP
var upgrade_resource: UpgradeResource


func apply_to_tower(tower: Tower):
	if upgrade_resource:
		upgrade_resource.add_to_tower(tower)
