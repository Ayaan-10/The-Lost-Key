extends Area2D

var player: CharacterBody2D
var direction = 1.0

var age = 0.0
var returning = false
var hit_targets: Array = []


func _physics_process(delta):
	if not is_instance_valid(player):
		queue_free()
		return

	if player.dead or not player.weapon_enabled:
		queue_free()
		return

	age += delta
	$Sprite2D.rotation += 17.0 * delta

	if age >= 0.6:
		returning = true

	if returning:
		var catch_position = (
			player.global_position + Vector2(0, -50)
		)

		global_position = global_position.move_toward(
			catch_position,
			850.0 * delta
		)

		if global_position.distance_to(catch_position) < 25:
			queue_free()
			return
	else:
		global_position.x += direction * 700.0 * delta

	for area in get_overlapping_areas():
		var target = area.get_parent()

		if target.has_method("take_damage"):
			if target not in hit_targets:
				hit_targets.append(target)
				target.take_damage(1)

	if age > 4.0:
		queue_free()
