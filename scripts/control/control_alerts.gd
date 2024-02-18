class_name ControlAlerts
extends Control

@export var _container: PanelContainer
@export var _alert_text: RichTextLabel
@export var _alert_timer: Timer


func _ready():
	_container.visible = false
	_alert_timer.timeout.connect(_on_timeout)
	Messenger.alerted.connect(_on_alerted)

	var tween = get_tree().create_tween()
	tween.tween_property(_alert_text, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property(_alert_text, "modulate", Color.WHITE, 0.5)
	tween.set_loops()


#func _process(delta):
	#if Input.is_key_pressed(KEY_L):
		#_on_alerted("text alert")


#func _unhandled_key_input(event):
	#if event.keycode == KEY_L:
		#_on_alerted("test alert")


func _on_timeout():
	_container.visible = false


func _on_alerted(message: String):
	_container.visible = true
	_alert_text.text = message
	_alert_timer.start()

