# Source: https://shaggydev.com/2024/01/09/dev-console/
class_name DevConsole
extends CanvasLayer


@export var _console: RichTextLabel
@export var _text_input: LineEdit

var _expression = Expression.new()

var _game: Game


func _ready():
	_text_input.text_submitted.connect(self._on_text_submitted)
	visible = false


func _process(delta):
	if Input.is_action_just_released("dev_console_input"):
		visible = true
		_text_input.grab_focus()


func set_game(game: Game):
	_game = game


func _on_text_submitted(command):
	var error = _expression.parse(command)
	if error != OK:
		push_warning(_expression.get_error_text())

		return

	var result = _expression.execute([], self)

	if not _expression.has_execute_failed():
		_console.text = str(result)
		#_console.text += str(result)
		#_console.text += "\n"


func add_upgrade(name: String) -> String:
	return _game.upgrades_manager.add_or_rank_up_passive_upgrade(name)

