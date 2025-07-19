extends BaseAttackOrder

var weapon_data: GunData
var end_when_target_is_not_state: int = -1

var cache_reload_time := 0.0
var cache_aiming_time := 0.0
var cache_accuracy := -1.0
var cache_recalculate := true

var attack_progress = 0.0

var target_host: Character

func setup(new_subject: Character, new_target: Noun = null, new_with: Noun = null, new_parameters: Dictionary = {}) -> void:
	super(new_subject, new_target, new_with, new_parameters)
	if target == null:
		return end(false) # cant attack if we don't have a character
	if target.host == new_subject:
		return end(false) # ... please don't do that
	if subject.current_weapon == null:
		return end(false) # ... how can we ranged attack if we don't have a ranged weapon?
	if target.host is not Character:
		return end(false)
	
	target_host = new_target.host
	weapon_data = subject.current_weapon
	time_since_last_hit = 0.0 # Can be abused to kite weapons - should add a "loaded" state to weapons if we want this
	end_when_target_is_not_state = target_host.health.current_state

func recalculate_cache():
	cache_reload_time = (weapon_data.base_reload - subject.skills.get_modifier(subject.skills[weapon_data.accuracy_skill])) / subject.health._actual_finesse
	cache_aiming_time = (weapon_data.base_cooldown - subject.skills.get_modifier(subject.skills[weapon_data.accuracy_skill])) / subject.health._actual_sight
	cache_accuracy = BulletManager.calculate_accuracy(target_host, subject, weapon_data)

func start() -> void:
	set_status("Attacking other pawn with ranged")
	subject.current_gun_node.show()
	super()

func end(succeed: bool):
	subject.current_gun_node.hide()
	subject.current_gun_node.rotation = 0.0
	super(succeed)

func do(delta: float) -> void:
	if target_host.health.current_state != end_when_target_is_not_state:
		end(true) # End this order when the target is dead
	time_since_last_hit += delta
	
	var cg = subject.current_gun_node
	cg.look_at(target_host.global_position)
	subject.current_gun_sprite.flip_v = (cg.rotation_degrees > 90 and cg.rotation_degrees < 180) or (cg.rotation_degrees < -90 and cg.rotation_degrees > -180)
	
	if cache_recalculate: # Refresh the cached accuracy
		recalculate_cache()
		cache_recalculate = false
	
	var reload_time = cache_reload_time
	var aim_time = cache_aiming_time
	
	progress = 0 # time_since_last_hit / (reload_time + aim_time)
	attack_progress = (reload_time + aim_time) - time_since_last_hit
	if cache_accuracy <= 0.0:
		progress = -1
		set_status("Attack: Refusing to fire: 0% chance of hit")
		if time_since_last_hit > .5:
			time_since_last_hit = 0.0
			cache_recalculate = true
		return # Do not waste ammo
	if time_since_last_hit < reload_time:
		set_status("Attack: Reloading weapon (%.2f%% chance to hit)" % (cache_accuracy * 100))
		return # Can't fire if we are reloading
	if time_since_last_hit < (reload_time + aim_time):
		set_status("Attack: Aiming weapon (%.2f%% chance to hit)"  % (cache_accuracy * 100))
		return # Can't fire if we are on cooldown
	
	var accuracy = BulletManager.calculate_accuracy(target_host, subject, weapon_data)
	if accuracy <= 0.0:
		cache_accuracy = accuracy
		return # Do not waste ammo
	
	for i in range(weapon_data.shots_fired):
		if randf() < accuracy:
			# Hit!
			var damage = randi_range(weapon_data.damage_min, weapon_data.damage_max)
			BulletManager.create_bullet(target_host, subject, damage)
		else:
			# Miss
			BulletManager.create_bullet(target_host, subject, 0)
		await subject.get_tree().create_timer(weapon_data.time_between_shots)
	
	cache_recalculate = true
	time_since_last_hit = 0.0
