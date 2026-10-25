extends Node2D
@onready var scene_transitions: Node = $SceneTransitions


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transitions.fade_in()
	
	await scene_transitions.fade_complete



func _on_teleporter_button_pressed() -> void:
	scene_transitions.fade_out()
	
	await scene_transitions.fade_complete
	
	get_tree().change_scene_to_file("res://scenes/sewer.tscn")
	
	
	await scene_transitions.fade_complete
