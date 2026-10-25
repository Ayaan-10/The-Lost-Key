extends Node2D

signal warning_changed(text: String)

@export var shockwave_scene: PackedScene

var player: CharacterBody2D

var awake = false
var stopped = false
var breathing_time = 0.0

var home = Vector2.ZERO
var motion: Tween

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


func show_pose(animation_name: String):
	sprite.position = Vector2.ZERO
	sprite.rotation = 0
	sprite.scale = Vector2.ONE * 0.5

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
			sprite.offset = Vector2(54, -269)

	sprite.play(animation_name)


func wake_up(target: CharacterBody2D):
	if awake:
		return

	player = target
	awake = true

	show_pose("angry")
	player.knock_back()
	warning_changed.emit("The rat woke up!")

	await get_tree().create_timer(1.2).timeout

	if can_attack():
		attack_loop()


func can_attack() -> bool:
	if stopped or not is_instance_valid(player):
		return false

	return not player.dead


func attack_loop():
	while can_attack():
		show_pose("angry")
		warning_changed.emit("Watch the rat...")
		await get_tree().create_timer(1.5).timeout

		if not can_attack():
			return

		await slam_attack()


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


func spawn_shockwave():
	var wave = shockwave_scene.instantiate()
	wave.player = player

	get_parent().add_child(wave)
	wave.global_position = global_position


func stop():
	stopped = true

	if motion != null and motion.is_valid():
		motion.kill()

	for hazard in get_tree().get_nodes_in_group("boss_hazards"):
		hazard.queue_free()
