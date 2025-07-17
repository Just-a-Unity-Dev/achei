extends Node

func calculate_accuracy(target: Character, host: Character, gun_data: GunData) -> float:
	var accuracy = 0.5
	
	var distance = host.global_position.distance_to(target.global_position) / 32
	if distance < gun_data.minimum_range:
		return 0.0
	elif distance < gun_data.short_range:
		accuracy = 0.65
	elif distance < gun_data.medium_range:
		accuracy = 0.5
	elif distance < gun_data.long_range:
		accuracy = 0.4
	else:
		return 0.0
	
	# TODO: Proper skill modifiers
	accuracy += host.skills[gun_data.accuracy_skill].get_modifier()
	accuracy -= (0.3 * (1.0 - host.health.consciousness)) # Low consciousness penalty
	
	if host.velocity.length() > 0:
		accuracy -= 0.05 # Target movement penalty
	
	return max(accuracy, 0)

## Spawns a bullet visualizer and applies damage to the target.
func create_bullet(target: Character, host: Character, damage: int) -> void:
	var end_pos = target.global_position
	var direction = host.global_position.direction_to(target.global_position)
	var hit = damage > 0
	if not hit:
		end_pos = target.global_position + (direction * randf_range(64, 128))
	end_pos += Vector2.ONE * 32 * randf_range(-1, 1)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://textures/bullet.png")
	sprite.name = "VisBullet"
	sprite.global_position = host.global_position
	
	host.get_tree().current_scene.add_child(sprite)
	sprite.look_at(end_pos)
	
	var duration = (host.global_position.distance_to(end_pos) / 32) * 0.02
	var tween = host.create_tween().bind_node(sprite)
	tween.tween_property(sprite, "global_position", end_pos, duration)
	
	await tween.finished
	sprite.queue_free()
	
	if not hit: return
	target.health.take_damage(damage)
