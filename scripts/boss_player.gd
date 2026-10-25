extends CharacterBody2D

signal died

@export var speed = 305.0
@export var jump_speed = -760.0
@export var weapon_enabled = true
@export var wing_scene: PackedScene

var health = 6
var facing = 1.0
var dead = false
var locked = false

var invincible_time = 0.0
var stun_time = 0.0
var throw_time = 0.0
var pose_time = 0.0
var pose = ""

var active_wing: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta):
	invincible_time = maxf(0, invincible_time - delta)
	stun_time = maxf(0, stun_time - delta)
	throw_time = maxf(0, throw_time - delta)
	pose_time = maxf(0, pose_time - delta)
	
	velocity.y += 1750.0 * delta
	
	if dead or locked:
		velocity.x = 0
	elif stun_time > 0:
		velocity.x = move_toward(velocity.x, 0, 450 * delta)
	else:
		var direction = Input.get_axis("move_left", "move_right")
		velocity.x = direction * speed

		if direction != 0:
			facing = direction

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_speed
			pose = "jump_start"
			pose_time = 0.08

	var was_on_floor = is_on_floor()
	move_and_slide()

	if not was_on_floor and is_on_floor():
		pose = "land"
		pose_time = 0.10

	sprite.flip_h = facing < 0
	sprite.modulate.a = 1.0

	if invincible_time > 0:
		sprite.modulate.a = (
			0.45 if int(invincible_time * 12) % 2 == 0 else 1.0
		)

	if dead:
		sprite.play("death")
	elif stun_time > 0:
		sprite.play("hurt")
	elif throw_time > 0:
		sprite.play("throw")
	elif pose_time > 0:
		sprite.play(pose)
	elif not is_on_floor():
		sprite.play("jump" if velocity.y < 0 else "fall")
	elif absf(velocity.x) > 5:
		sprite.play("run")
	else:
		sprite.play("idle")
		
	var art_scale = 0.13

	if sprite.animation == "run":
		art_scale = 0.085
	elif sprite.animation in ["throw", "hurt", "death"]:
		art_scale = 0.34

	sprite.scale = Vector2.ONE * art_scale
	sprite.position = Vector2(0, -688.0 * art_scale)


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		throw_wing()
		print("Thrwoing")


func throw_wing():
	if dead or locked or stun_time > 0 or not weapon_enabled:
		return

	if wing_scene == null or is_instance_valid(active_wing):
		return

	active_wing = wing_scene.instantiate()
	active_wing.player = self
	active_wing.direction = facing
	get_parent().add_child(active_wing)
	active_wing.global_position = global_position + Vector2(
		25 * facing, -50
	)

	throw_time = 0.25


func set_weapon_enabled(enabled: bool):
	weapon_enabled = enabled

	if not enabled and is_instance_valid(active_wing):
		active_wing.queue_free()


func hurt(from_x: float):
	if dead or invincible_time > 0:
		return

	health -= 1
	invincible_time = 1.2
	stun_time = 0.3

	var push = -360.0 if global_position.x < from_x else 360.0
	velocity = Vector2(push, -300)

	if health <= 0:
		dead = true
		died.emit()


func knock_back():
	stun_time = 0.65
	invincible_time = 1.4
	velocity = Vector2(-620, -430)
