extends CharacterBody2D



const SPEED = 300.0
const  JUMP_VELOCITY = -400

func _ready() -> void:
	print("hi")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true

		
	move_and_slide()


func _on_acid_body_entered(body: Node2D) -> void:
	body.hide()
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
	
	
