# -------------------------------------
# Displays information about an entity.
# -------------------------------------

class_name EntityInfoPanel
extends Panel

@export var _entity_name_label: Label
@export var _button_container: VBoxContainer
@export var _description_label: Label

@export var _container_hit_points: Container
@export var _label_hit_points: RichTextLabel
@export var _bar_hit_points: TextureProgressBar

var _entity_info: EntityInfo


func open():
	visible = true


func close():
	visible = false


func set_entity(entity_info: EntityInfo):
	clear_entity()

	_entity_info = entity_info

	for child in _button_container.get_children():
		child.queue_free()

	_entity_name_label.text = entity_info.name
	_description_label.text = entity_info.description

	if entity_info.entity is Tower:
		var tower: Tower = entity_info.entity

		tower.description_updated.connect(_on_description_updated)
		tower.hit_points_component.hit_points_changed.connect(_on_hit_points_changed)

		_set_hit_points_elements(tower.hit_points_component)

		# TODO: make get these callables from entity.
		var take_damage = func():
			tower.take_damage(999)

		_add_button("Destroy", take_damage)

		var take_damage_small = func():
			tower.take_damage(5)

		_add_button("Take Damage", take_damage_small)

		var upgrade = func():
			tower.rank.try_upgrade(null)

		_add_button("Upgrade", upgrade)

		var rank_up = func():
			tower.rank.add_rank(1)

		_add_button("DEBUG: Rank Up", rank_up)

		_container_hit_points.visible = true
	else:
		_container_hit_points.visible = false


func clear_entity():
	if !_entity_info:
		return

	# Occurs when an entity is destroyed
	if !_entity_info.entity:
		_entity_info = null

		return

	if _entity_info.entity is Tower:
		_entity_info.entity.description_updated.disconnect(_on_description_updated)

	_entity_info = null


func _on_description_updated(description: String):
	#print_debug("Description updated")
	_description_label.text = description


func _on_hit_points_changed(hit_points: HitPointsComponent):
	_set_hit_points_elements(hit_points)


func _set_hit_points_elements(hit_points: HitPointsComponent):
	_label_hit_points.text = "[center]%s" % hit_points.as_text
	_bar_hit_points.value = hit_points.bar_value


func _add_button(text: String, pressed_callback: Callable):
		var button = Button.new()
		button.text = text
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(pressed_callback)
		_button_container.add_child(button)
