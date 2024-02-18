# -------------------------------------
# Displays information about an entity.
# -------------------------------------

class_name EntityInfoPanel
extends Panel

@export var _entity_name_label: Label
@export var _button_container: VBoxContainer
@export var _description_label: Label

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
		entity_info.entity.description_updated.connect(_on_description_updated)

		var take_damage = func():
			entity_info.entity.take_damage(999)

		_add_button("Destroy", take_damage)

		var rank_up = func():
			entity_info.entity.add_rank(1)

		_add_button("Rank Up", rank_up)


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
	print_debug("Description updated")
	_description_label.text = description


func _add_button(text: String, pressed_callback: Callable):
		var button = Button.new()
		button.text = text
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(pressed_callback)
		_button_container.add_child(button)
