
extends Area2D

@export var boulder: RigidBody2D

var player_nearby = false
var activated = false

func _process(_delta: float) -> void:
	if player_nearby and not activated:
		if Input.is_key_pressed(KEY_E):
			activated = true
			boulder.release()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2":
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player2":
		player_nearby = false
