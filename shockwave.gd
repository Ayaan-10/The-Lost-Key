extends Node2D

var player: CharacterBody2D

var radius = 20.0
var expansion_speed = 430.0
var already_hit = false


func _ready():
	add_to_group("boss_hazards")
	$Sprite2D.hide()


func _physics_process(delta):
	if not is_instance_valid(player):
		queue_free()
		return

	if player.dead:
		queue_free()
		return

	var previous_radius = radius
	radius += expansion_speed * delta
	queue_redraw()

	var distance_from_center = absf(
		player.global_position.x - global_position.x
	)

	var touching_edge = (
		distance_from_center >= previous_radius - 28.0
		and distance_from_center <= radius + 28.0
	)

	var player_is_too_low = (
		player.global_position.y > global_position.y - 45.0
	)

	if touching_edge and player_is_too_low and not already_hit:
		already_hit = true
		player.hurt(global_position.x)

	if radius > 1400.0:
		queue_free()


func _draw():
	var points = PackedVector2Array()
	var depth = minf(radius * 0.08, 35.0)
	
	for i in range(97):
		var angle = TAU * float(i) / 96.0

		points.append(Vector2(
			cos(angle) * radius,
			sin(angle) * radius * 0.25
		))

	var opacity = 1.0 - clampf(
		(radius - 1050.0) / 350.0,
		0.0,
		1.0
	)

	draw_polyline(
		points,
		Color(0.72, 0.48, 0.95, opacity),
		5.0,
		true
	)

	draw_polyline(
		points,
		Color(0.91, 0.79, 1.0, opacity),
		1.5,
		true
	)
