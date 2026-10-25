extends CharacterBody2D



const SPEED = 300.0
const  JUMP_VELOCITY = -400

@export var wing_scene: PackedScene

var weapon_enabled = false
var active_wing: Node2D
var facing = 1.0
var dead = false

var can_climb: bool = false
var is_climbing: bool = false
@export var climb_speed: float = 200.0

func _ready() -> void:
	set_weapon_enabled(GameState.has_wing)
	GameState.wing_unlocked.connect(_on_wing_unlocked)
	

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_axis("move_left", "move_right")
	var climbing_input := Input.get_axis("move_up", "move_down")
	
	if not is_on_floor():
		velocity += get_gravity() * delta


	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	# start climb when inside ladder
	if can_climb:
		if climbing_input != 0:
			is_climbing = true
	# attach to the ladder when entering it
	if  can_climb and not is_climbing:
		is_climbing = true
	if is_climbing and can_climb:
		velocity.y = climbing_input * climb_speed
	else:
		if not is_on_floor():
			velocity += get_gravity() * delta
	



	if direction > 0:
		facing = 1.0
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		facing = -1.0
		$AnimatedSprite2D.flip_h = true

		
	move_and_slide()


func _on_acid_body_entered(body: Node2D) -> void:
	body.hide()
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()
	
	


func _on_ladder_body_entered(body: Node2D) -> void:
		body.set("can_climb", true)


func _on_ladder_body_exited(body: Node2D) -> void:
	body.set("can_climb", false)
	body.set("is_climbing", false)

func _on_wing_unlocked():
	set_weapon_enabled(true)


func set_weapon_enabled(enabled: bool):
	weapon_enabled = enabled

	if not enabled and is_instance_valid(active_wing):
		active_wing.queue_free()


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		throw_wing()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			throw_wing()


func throw_wing():
	if dead or not weapon_enabled:
		return

	if wing_scene == null or is_instance_valid(active_wing):
		return

	active_wing = wing_scene.instantiate()
	active_wing.player = self
	active_wing.direction = facing

	get_parent().add_child(active_wing)

	active_wing.global_position = (
		global_position + Vector2(25 * facing, -50)
	)
	
