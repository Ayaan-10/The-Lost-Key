extends Node2D

var player: CharacterBody2D

var velocity = Vector2.ZERO
var landing_position = Vector2.ZERO
var floor_y = 600.0


func _ready():
	add_to_group("boss_hazards")


func setup(start: Vector2, destination: Vector2):
	global_position = start
	landing_position = destination
	floor_y = destination.y

	var flight_time = 1.0
	var gravity = 900.0

	velocity.x = (
		destination.x - start.x
	) / flight_time

	velocity.y = (
		destination.y - start.y
		- 0.5 * gravity * flight_time * flight_time
	) / flight_time


func _physics_process(delta):
	if not is_instance_valid(player):
		queue_free()
		return

	if player.dead:
		queue_free()
		return

	velocity.y += 900.0 * delta
	global_position += velocity * delta
	queue_redraw()

	var player_center = (
		player.global_position + Vector2(0, -40)
	)

	if global_position.distance_to(player_center) < 30.0:
		player.hurt(global_position.x)
		queue_free()
		return

	if global_position.y >= floor_y:
		queue_free()


func _draw():
	var marker = to_local(landing_position)

	draw_line(
		marker + Vector2(-20, 0),
		marker + Vector2(20, 0),
		Color("#b7cf83"),
		4.0,
		true
	)
