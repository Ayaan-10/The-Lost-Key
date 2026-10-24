extends CharacterBody2D



const SPEED = 300.0
const  JUMP_VELOCITY = -400

var can_climb: bool = false
var is_climbing: bool = false
@export var climb_speed: float = 200.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var climbing_input := Input.get_axis("move_up", "move_down")
	# start climb when inside ladder
	if can_climb:
		if climbing_input != 0:
			is_climbing = true
	# attach to the ladder when entering it
	if  can_climb and not is_climbing:
		is_climbing = true
	# detach if we leave the ladder
	if not can_climb:
		is_climbing = false
	# Vertical movement
	if is_climbing and can_climb:
		velocity.y = climbing_input * climb_speed
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	#flip sprite
	if direction > 0:
		$Sprite2D.flip_h = false
	elif direction < 0:
		$Sprite2D.flip_h = true

		
	move_and_slide()

@onready var tripanim: AnimationPlayer = $tripanim
@onready var area_2d: Area2D = $"../Area2D"
@onready var dialouge_1: Label = $"../Dialouges/Dialouge1"
@onready var key: TextureRect = $"../Key"
@onready var keyfall: AnimationPlayer = $"../Key/Keyfall"
@onready var guide_1: Label = $"../Guide/Guide1"



func _on_area_2d_body_entered(body: Node2D) -> void:
	tripanim.play("trip")
	key.visible = true
	keyfall.play("keyfall")
	area_2d.queue_free()
	dialouge_1.visible = true
	guide_1.visible = true
