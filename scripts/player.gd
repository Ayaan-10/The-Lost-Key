extends CharacterBody2D



const SPEED = 300.0
const  JUMP_VELOCITY = -400



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

@onready var tripanim: AnimationPlayer = $tripanim
@onready var area_2d: Area2D = $"../Background/Area2D"
@onready var dialouge_1: Label = $"../Background/Dialouge1"
@onready var key: TextureRect = $"../Background/Key"
@onready var guide_1: Label = $"../Background/Guide1"


func _on_area_2d_body_entered(body: Node2D) -> void:
	tripanim.play("trip")
	key.visible = true
	area_2d.queue_free()
	dialouge_1.visible = true
	guide_1.visible = true
