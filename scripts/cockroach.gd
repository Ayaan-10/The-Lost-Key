
extends CharacterBody2D

var dead = false







func _on_killarea_body_entered(body: Node2D) -> void:
	if dead:
		return

	if body.name == "Player2":
		get_tree().reload_current_scene()
		
		
func die():
	if dead:
		return

	dead = true
	GameState.unlock_wing()

	$AnimationPlayer.stop()
	queue_free()
