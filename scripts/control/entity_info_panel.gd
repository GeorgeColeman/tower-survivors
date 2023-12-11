class_name EntityInfoPanel
extends Panel

@export var entity_name_label: Label
@export var button_container: VBoxContainer

var _buttons: Array[Button]


func set_entity(entity):
	for button in _buttons:
		button.queue_free()

	_buttons.clear()

	entity_name_label.text = entity.name

	if entity is Tower:
		var button = Button.new()
		button.text = "Destroy"
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(
			func():
				entity.take_damage(999)
		)
		button_container.add_child(button)
		_buttons.append(button)
