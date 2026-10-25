extends Node2D

var player: CharacterBody2D

var radius = 20.0
var expansion_speed = 430.0
var already_hit = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	add_to_group("boss_hazards")
	update_size()


func _physics_process(delta):
	if not is_instance_valid(player):
		queue_free()
		return

	if player.dead:
		queue_free()
		return

	var previous_radius = radius
	radius += expansion_speed * delta

	update_size()

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


func update_size():
	var image_scale = radius / 78.0

	sprite.scale = Vector2(
		image_scale,
		image_scale * 0.18
	)
