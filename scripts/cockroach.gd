
extends CharacterBody2D

var dead = false

func die() -> void:
	if dead:
		return

	dead = true
	queue_free()
