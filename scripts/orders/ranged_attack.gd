extends BaseAttackOrder

var progress: float = 1.0

var weapon_data: GunData
var end_when_target_is_not_state: int = -1

var target_host: Character

func setup(new_subject: Character, new_target: Noun = null, new_with: Noun = null, new_parameters: Dictionary = {}) -> void:
	super(new_subject, new_target, new_with, new_parameters)
	if target == null:
		return end(false) # cant attack if we don't have a character
	if subject.current_weapon == null:
		return end(false) # ... how can we ranged attack if we don't have a ranged weapon?
	if target.host is not Character:
		return end(false)
	
	target_host = new_target.host
	weapon_data = subject.current_weapon
	time_since_last_hit = weapon_data.base_reload
	end_when_target_is_not_state = target_host.health.current_state

func start() -> void:
	set_status("Attacking other pawn with ranged")
	super()

var cached_accuracy: float = -1
func do(delta: float) -> void:
	if target_host.health.current_state != end_when_target_is_not_state:
		end(true) # End this order when the target is dead
	time_since_last_hit += delta
	 
	if cached_accuracy == -1: # Refresh the cached accuracy
		cached_accuracy = BulletManager.calculate_accuracy(target_host, subject, weapon_data)
	
	progress = time_since_last_hit / (weapon_data.base_reload + weapon_data.base_cooldown)
	if cached_accuracy <= 0.0:
		progress = 0.0
		set_status("Attack: Refusing to fire: 0% chance of hit")
		if time_since_last_hit > .5:
			time_since_last_hit = 0.0
			cached_accuracy = -1
		return # Do not waste ammo
	if time_since_last_hit < (weapon_data.base_reload):
		set_status("Attack: Reloading weapon (%.2f%% chance to hit)" % (cached_accuracy * 100))
		return # Can't fire if we are reloading
	if time_since_last_hit < (weapon_data.base_reload + weapon_data.base_cooldown):
		set_status("Attack: Aiming weapon (%.2f%% chance to hit)"  % (cached_accuracy * 100))
		return # Can't fire if we are on cooldown
	
	var accuracy = BulletManager.calculate_accuracy(target_host, subject, weapon_data)
	if accuracy <= 0.0:
		cached_accuracy = accuracy
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
	cached_accuracy = -1
	time_since_last_hit = 0.0
