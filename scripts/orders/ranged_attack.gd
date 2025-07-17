extends BaseOrder

var target: Character
var time_since_last_hit: float = 0.0
var progress: float = 1.0

var weapon_data: GunData
var end_when_target_dies: bool = true

func setup(new_host: Character, new_parameters: Dictionary) -> void:
	super(new_host, new_parameters)
	target = new_parameters["target"]
	weapon_data = new_host.current_weapon
	time_since_last_hit = weapon_data.base_reload
	end_when_target_dies = not target.health.is_dead

func start() -> void:
	set_status("Attacking other pawn with ranged")
	super()

var bullets: Array[Sprite2D] = []

func end(succeed: bool) -> void:
	for bullet in bullets:
		bullet.queue_free()
	super(succeed)

var cached_accuracy: float = -1
func do(delta: float) -> void:
	if target.health.is_dead and end_when_target_dies:
		end(true) # End this order when the target is dead
	time_since_last_hit += delta
	 
	if cached_accuracy == -1: # Refresh the cached accuracy
		cached_accuracy = BulletManager.calculate_accuracy(target, host, weapon_data)
	
	progress = time_since_last_hit / (weapon_data.base_reload + weapon_data.base_cooldown)
	if cached_accuracy <= 0.0:
		progress = 0.0
		set_status("Attack: Refusing to fire: 0% chance of hit")
		return # Do not waste ammo
	if time_since_last_hit < (weapon_data.base_reload):
		set_status("Attack: Reloading weapon (%.2f%% chance to hit)" % (cached_accuracy * 100))
		return # Can't fire if we are reloading
	if time_since_last_hit < (weapon_data.base_reload + weapon_data.base_cooldown):
		set_status("Attack: Aiming weapon (%.2f%% chance to hit)"  % (cached_accuracy * 100))
		return # Can't fire if we are on cooldown
	
	for i in range(weapon_data.shots_fired):
		var accuracy = BulletManager.calculate_accuracy(target, host, weapon_data)
		if randf() < accuracy:
			# Hit!
			var damage = randi_range(weapon_data.damage_min, weapon_data.damage_max)
			BulletManager.create_bullet(target, host, damage)
		else:
			# Miss
			BulletManager.create_bullet(target, host, 0)
		await target.get_tree().create_timer(weapon_data.time_between_shots)
	cached_accuracy = -1
	time_since_last_hit = 0.0
