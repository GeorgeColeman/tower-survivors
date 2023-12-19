class_name ExperienceComponent

signal experience_added()
signal levelled_up()

var experience: int
var level: int = 1
var exp_to_next_level: int = 10
var perc_to_next_level: float:
	get:
		return (experience as float / exp_to_next_level) * 100


func DEBUG_manual_level_up():
	add_experience(exp_to_next_level)


func add_experience(amount: int):
	experience += amount

	# Check if the tower has leveled up
	if experience >= exp_to_next_level:
		_level_up()

	experience_added.emit()


func _level_up():
	experience -= exp_to_next_level
	var additional_exp = floori(exp_to_next_level * 0.1) + 5
	exp_to_next_level += additional_exp
	#print_debug("FIXME: arbitrary additional exp formula. Exp to next: ", exp_to_next_level)
	level += 1
	Messenger.request_floating_text("Level up. Current level: %s" % str(level))

	levelled_up.emit()
