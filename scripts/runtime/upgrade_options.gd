class_name UpgradeOptions
extends RefCounted

var options: Array
var option_is_chosen: bool

# https://docs.godotengine.org/en/stable/classes/class_string.html
var options_listed: String:
	get:
		var s = ""

		for option in options:
			s += option.name + ", "

		return s.substr(0, s.length() - 2)


func _init(options: Array):
	self.options = options
