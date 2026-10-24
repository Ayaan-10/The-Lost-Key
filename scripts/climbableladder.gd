extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set("can_climb", true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set("can_climb", false)
		body.set("is_climbing", false)
