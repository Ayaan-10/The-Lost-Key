extends Node2D

signal warning_changed(text: String)
signal defeated

@export var shockwave_scene: PackedScene
@export var acid_scene: PackedScene

var health = 12
var dead = false
var player: CharacterBody2D
var rolling = false
var attack_number = 0
var awake = false
var stopped = false
var breathing_time = 0.0

var home = Vector2.ZERO
var motion: Tween
var key_hidden = false

var wake_protection_until = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	home = position
	show_pose("sleep")


func _process(delta):
	if not awake:
		breathing_time += delta

		var breath = sin(breathing_time * 2.5) * 0.01

		sprite.scale = Vector2(
			0.5 + breath,
			0.5 - breath
		)

	if rolling and can_attack():
		var close_enough = absf(
			player.global_position.x - global_position.x
		) < 90.0

		var player_is_too_low = (
			player.global_position.y > global_position.y - 140.0
		)

		if close_enough and player_is_too_low:
			player.hurt(global_position.x)


func show_pose(animation_name: String):
	key_hidden = animation_name in ["jump", "roll", "death"]
	
	sprite.position = Vector2.ZERO
	sprite.rotation = 0
	sprite.scale = Vector2.ONE * 0.5

	$Hurtbox.position = Vector2(0, -135)
	$Hurtbox.scale = Vector2.ONE

	match animation_name:
		"sleep":
			sprite.offset = Vector2(32, -279)

		"angry":
			sprite.offset = Vector2(41.5, -286)

		"jump":
			sprite.offset = Vector2(-20, -215)

		"acid":
			sprite.offset = Vector2(42, -195)

		"death":
			sprite.offset = Vector2(-2.5, -121)

		"roll":
			sprite.offset = Vector2(54, -29)
			sprite.position = Vector2(0, -67)
			sprite.scale = Vector2.ONE * 0.28

			$Hurtbox.position = Vector2(0, -67)
			$Hurtbox.scale = Vector2.ONE * 0.5

	sprite.play(animation_name)


func wake_up(target: CharacterBody2D):
	if awake:
		return

	player = target
	awake = true
	wake_protection_until = Time.get_ticks_msec() + 200
	
	show_pose("angry")
	player.knock_back()
	warning_changed.emit("The rat woke up!")

	await get_tree().create_timer(1.2).timeout

	if can_attack():
		attack_loop()


func can_attack() -> bool:
	if stopped or dead or not is_instance_valid(player):
		return false

	return not player.dead

func take_damage(amount: int):
	if not awake or dead or stopped:
		return

	if Time.get_ticks_msec() < wake_protection_until:
		return

	health = maxi(0, health - amount)

	if health == 0:
		die()
	else:
		sprite.modulate = Color("#ffbaba")

		var flash = create_tween()
		flash.tween_property(
			sprite,
			"modulate",
			Color.WHITE,
			0.15
		)


func die():
	if dead:
		return

	dead = true
	stop()

	position = home
	sprite.modulate = Color.WHITE
	show_pose("death")

	defeated.emit()

func attack_loop():
	while can_attack():
		show_pose("angry")
		warning_changed.emit("Watch the rat...")

		await get_tree().create_timer(1.5).timeout

		if not can_attack():
			return

		match attack_number % 3:
			0:
				await slam_attack()
			1:
				await roll_attack()
			2:
				await acid_attack()

		attack_number += 1


func slam_attack():
	if shockwave_scene == null:
		warning_changed.emit("Assign Shockwave Scene on RatBoss.")
		stopped = true
		return

	show_pose("angry")
	warning_changed.emit("Ground slam! Get ready to jump.")

	await get_tree().create_timer(0.9).timeout

	if not can_attack():
		return

	show_pose("jump")

	motion = create_tween()

	motion.tween_property(
		self,
		"position:y",
		home.y - 160.0,
		0.35
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	motion.tween_property(
		self,
		"position:y",
		home.y,
		0.25
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await motion.finished

	if not can_attack():
		return

	show_pose("angry")
	warning_changed.emit("Jump over each approaching ring!")

	for i in range(3):
		if not can_attack():
			return

		spawn_shockwave()
		await get_tree().create_timer(0.95).timeout

	await get_tree().create_timer(1.0).timeout

func roll_attack():
	show_pose("angry")
	warning_changed.emit("Roll attack! Get ready to jump.")

	await get_tree().create_timer(1.0).timeout

	if not can_attack():
		return

	show_pose("roll")
	rolling = true

	motion = create_tween().set_parallel(true)

	motion.tween_property(
		self,
		"position:x",
		90.0,
		1.45
	)

	motion.tween_property(
		sprite,
		"rotation",
		-TAU * 2.0,
		1.45
	)

	await motion.finished

	if not can_attack():
		return

	warning_changed.emit("It is coming back! Jump again.")

	await get_tree().create_timer(0.7).timeout

	if not can_attack():
		return

	motion = create_tween().set_parallel(true)

	motion.tween_property(
		self,
		"position:x",
		home.x,
		1.8
	)

	motion.tween_property(
		sprite,
		"rotation",
		0.0,
		1.8
	)

	await motion.finished

	rolling = false

	if can_attack():
		show_pose("angry")
		await get_tree().create_timer(0.5).timeout

func acid_attack():
	if acid_scene == null:
		warning_changed.emit("Assign Acid Scene on RatBoss.")
		stopped = true
		return

	show_pose("angry")
	warning_changed.emit("Acid! Move away from the green marks.")

	await get_tree().create_timer(1.0).timeout

	if not can_attack():
		return

	show_pose("acid")

	for i in range(5):
		if not can_attack():
			return

		var drop = acid_scene.instantiate()
		drop.player = player
		get_parent().add_child(drop)

		var start = (
			global_position + Vector2(-80, -140)
		)

		var destination = Vector2(
			clampf(player.global_position.x, 50.0, 1230.0),
			global_position.y
		)

		drop.setup(start, destination)

		await get_tree().create_timer(0.6).timeout

	await get_tree().create_timer(1.0).timeout
	
func spawn_shockwave():
	var wave = shockwave_scene.instantiate()
	wave.player = player

	get_parent().add_child(wave)
	wave.global_position = global_position

func stop():
	stopped = true
	rolling = false

	if motion != null and motion.is_valid():
		motion.kill()

	for hazard in get_tree().get_nodes_in_group("boss_hazards"):
		hazard.queue_free()
		
		
