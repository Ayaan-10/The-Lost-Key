extends Node2D

var key_dropped = false
var key_available = false
var won = false

@onready var player = $Player
@onready var rat = $RatBoss
@onready var key = $Key

@onready var message: Label = $UI/Message
@onready var player_health: Label = $UI/PlayerHealth
@onready var boss_health: ProgressBar = $UI/BossHealth


func _ready():
	rat.warning_changed.connect(_on_warning_changed)
	rat.defeated.connect(_on_rat_defeated)
	player.died.connect(_on_player_died)

	boss_health.max_value = rat.health
	message.text = "Approach the rat's key. Click it or press E."


func _process(_delta):
	player_health.text = "Health: %d / 6" % player.health
	boss_health.value = rat.health

	if won:
		key.hide()
	elif not key_dropped:
		key.visible = not rat.key_hidden
		key.global_position = (
			rat.global_position + Vector2(70, -110)
		)


func _unhandled_input(event):
	if event.is_action_pressed("retry"):
		if won:
			GameState.reset_run()
			get_tree().change_scene_to_file(
				"res://scenes/scene_1.tscn"
			)
		else:
			get_tree().reload_current_scene()
		return

	if player.dead or won:
		return

	if event.is_action_pressed("interact"):
		try_take_key()

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var clicked_key = (
				key.visible
				and get_global_mouse_position().distance_to(
					key.global_position
				) < 55.0
			)

			if clicked_key:
				try_take_key()
			elif rat.awake and not rat.dead:
				player.throw_wing()


func try_take_key():
	if rat.awake and not rat.dead:
		message.text = "Defeat the rat to get the key!"
		return

	if rat.dead and not key_available:
		return

	var distance = player.global_position.distance_to(
		key.global_position
	)

	if distance > 200.0:
		message.text = "Move closer to the key first."
		return

	if key_available:
		collect_key()
	elif not rat.awake:
		rat.wake_up(player)


func collect_key():
	won = true
	key.hide()

	player.locked = true
	player.set_weapon_enabled(false)

	message.text = "Key recovered! You won! Press R to play again."


func _on_warning_changed(text: String):
	if not won and not player.dead and not rat.dead:
		message.text = text


func _on_rat_defeated():
	key_dropped = true
	key_available = false

	key.show()
	key.global_position = Vector2(850, 460)

	message.text = "Rat defeated!"

	var drop = create_tween()
	drop.tween_property(
		key,
		"global_position",
		Vector2(850, 570),
		0.5
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await drop.finished

	key_available = true
	message.text = "Walk to the dropped key. Click it or press E."


func _on_player_died():
	rat.stop()
	message.text = "You fell! Press R to try again."
