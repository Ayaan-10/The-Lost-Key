extends Node2D

@onready var player = $Player
@onready var rat = $RatBoss
@onready var key = $Key
@onready var message: Label = $UI/Message


func _ready():
	rat.warning_changed.connect(_on_warning_changed)
	player.died.connect(_on_player_died)

	message.text = "Approach the rat's key. Click it or press E."


func _unhandled_input(event):
	if event.is_action_pressed("retry"):
		get_tree().reload_current_scene()
		return

	if player.dead or rat.awake:
		return

	if event.is_action_pressed("interact"):
		try_take_key()

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_position = get_global_mouse_position()

			if mouse_position.distance_to(key.global_position) < 55:
				try_take_key()


func try_take_key():
	var distance = player.global_position.distance_to(
		key.global_position
	)

	if distance > 200:
		message.text = "Move closer to the key first."
		return

	rat.wake_up(player)


func _on_warning_changed(text: String):
	message.text = text


func _on_player_died():
	rat.stop()
	message.text = "You fell! Press R to try again."
