class_name ControlGameOver
extends Control

@onready var restart_button = %RestartButton


func _ready():
	restart_button.pressed.connect(func(): Messenger.start_game_requested.emit())
