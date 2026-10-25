extends Area2D

@export var boulder: RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var player_nearby = false
var activated = false


func _input(event):
	if not player_nearby or activated:
		return

	if event.is_echo():
		return

	if event.is_action_pressed("interact"):
		activate()
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var clicked_lever = sprite.get_rect().has_point(
				sprite.get_local_mouse_position()
			)

			if clicked_lever:
				activate()
				get_viewport().set_input_as_handled()


func activate():
	if activated or not is_instance_valid(boulder):
		return

	activated = true
	animation_player.play("flip")
	boulder.release()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2":
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player2":
		player_nearby = false
