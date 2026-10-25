extends Area2D

@export_file("*.tscn") var next_scene: String

var changing_scene = false



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player2" and not changing_scene:
		changing_scene = true
		
		await get_tree().create_timer(0.5).timeout
		
		
		get_tree().change_scene_to_file.call_deferred(next_scene)
