extends BaseOrder

var target: Character
var time_since_last_hit: float = 3.0

var weapon_data: GunData

func setup(new_host: Character, new_parameters: Dictionary) -> void:
	super(new_host, new_parameters)
	target = new_parameters["target"]
	weapon_data = new_host.current_weapon

func start() -> void:
	set_status("Attacking other pawn with ranged")
	super()

func do(delta: float) -> void:
	if target.health.hp <= 0:
		end(true) # End this order when the target is dead
	time_since_last_hit += delta
	if time_since_last_hit < (weapon_data.base_reload):
		set_status("Attack: Reloading weapon")
		return # Can't fire if we are reloading
	if time_since_last_hit < (weapon_data.base_reload + weapon_data.base_cooldown):
		set_status("Attack: Aiming weapon")
		return # Can't fire if we are on cooldown
	
	for i in range(weapon_data.shots_fired):
		var base_accuracy = 0.5
		if randf() < base_accuracy:
			# Hit!
			target.health.hp -= randi_range(weapon_data.damage_min, weapon_data.damage_max)
		else:
			# Miss
			pass
	time_since_last_hit = 0.0
