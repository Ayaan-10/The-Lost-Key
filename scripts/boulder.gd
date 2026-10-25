
extends RigidBody2D

@export var cockroach: CharacterBody2D
@export var gate: StaticBody2D

var released = false

func release() -> void:
	if released:
		return

	released = true
	freeze = false
	sleeping = false




func _on_hitarea_body_entered(body: Node2D) -> void:
	if body == cockroach:
		cockroach.die()

		if is_instance_valid(gate):
			gate.queue_free()
