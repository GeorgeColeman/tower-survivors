# -------------------------------------
# Displays information about an entity.
# -------------------------------------

class_name EntityInfoPanel
extends Panel

@export var entity_name_label: Label
@export var button_container: VBoxContainer
@export var _description_label: Label

var _buttons: Array[Button]


func set_entity(entity_info: EntityInfo):
	for button in _buttons:
		button.queue_free()

	_buttons.clear()

	entity_name_label.text = entity_info.name
	_description_label.text = entity_info.description

	if entity_info.entity is Tower:
		var button = Button.new()
		button.text = "Destroy"
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(
			func():
				entity_info.entity.take_damage(999)
		)
		button_container.add_child(button)
		_buttons.append(button)
