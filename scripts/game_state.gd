extends Node

signal wing_unlocked

var has_wing = false


func unlock_wing():
	if has_wing:
		return

	has_wing = true
	wing_unlocked.emit()


func reset_run():
	has_wing = false
