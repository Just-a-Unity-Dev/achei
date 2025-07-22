extends BaseOrder

var HEALING_TIME = 4.0
var MAX_HEAL_AMOUNT = 0.0
var time_since_last_heal = 0.0
var target_host: Character

func setup(new_subject: Character, new_target: Noun = null, new_with: Noun = null, new_parameters: Dictionary = {}) -> void:
	super(new_subject, new_target, new_with, new_parameters)
	if target == null:
		return end(false) # cant heal if we don't have a character
	if target.host is not Character:
		return end(false)
	target_host = new_target.host
	if target_host.health.current_state == HealthStatsComponent.State.DEAD:
		return end(false)
	
	# Recalculate healing time
	HEALING_TIME += new_subject.skills.get_modifier(new_subject.skills.doctor)
	HEALING_TIME /= new_subject.health._actual_finesse
	HEALING_TIME *= 1.5 if new_subject == target_host else 1.0
	
	# 0: 65% of HP, 3: 85% of HP, 6+: 100% of HP
	MAX_HEAL_AMOUNT = min(0.85 + new_subject.skills.get_modifier(new_subject.skills.doctor), 1)

func start() -> void:
	set_status("Moving to heal target")
	super()

func try_heal_target():
	if target_host.health.bleeding_severity > 0:
		target_host.health.bleeding_severity = max(target_host.health.bleeding_severity - 1, 0)
		PopupManager.popup("bleed -1", target_host.global_position, PopupManager.SEVERITY_GOOD)
	else:
		# Iterate from most important to least important
		var skipped_limbs = 0
		var successful_limbs = 0
		for limb in target_host.health.limbs:
			if limb.mangled:
				skipped_limbs += 1
				continue
			var effective_max_hp = limb.max_hp * MAX_HEAL_AMOUNT
			if limb.hp < effective_max_hp:
				var heal_amount = randi_range(25, 45)
				var prev_hp = limb.hp
				limb.hp = min(limb.hp + heal_amount, effective_max_hp)
				PopupManager.popup("+%d hp" % [limb.hp - prev_hp], target_host.global_position, PopupManager.SEVERITY_GOOD)
				if limb.hp >= effective_max_hp: successful_limbs += 1
				break
			skipped_limbs += 1
		if (skipped_limbs + successful_limbs) >= target_host.health.limbs.size():
			PopupManager.popup("treatment finished", target_host.global_position, PopupManager.SEVERITY_GREAT)
			end(true) # No more bleed, no more damage, end treatment
	target_host.health.health_delta() # Trigger health deltas

func do(delta: float) -> void:
	if target_host.health.current_state == HealthStatsComponent.State.DEAD:
		return end(false)
	
	var distance = subject.global_position.distance_to(target_host.global_position)
	if distance < 48:
		subject.velocity = Vector2.ZERO
		time_since_last_heal += delta
		set_status("Healing target (%.2fs)" % [HEALING_TIME - time_since_last_heal])
		progress = time_since_last_heal / HEALING_TIME
		if time_since_last_heal < HEALING_TIME:
			return # Not yet time
		try_heal_target()
		time_since_last_heal = 0.0
	else:
		var direction = subject.global_position.direction_to(target_host.global_position)
		subject.velocity = direction * delta * subject.cache_speed
		set_status("Moving to heal target")
		time_since_last_heal = 0.0
