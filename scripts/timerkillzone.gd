extends Timer

@onready var timer = $Timer 

func _on_body_entered(body):
	print("you died!")
	timer.start() 

func _on_time_timeout():
	get_tree().reload_current_scene()
