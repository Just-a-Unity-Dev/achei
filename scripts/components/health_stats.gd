extends Node
class_name HealthStatsComponent

@export var host: Character

@export_category("Wounds")
#@export var wounds: Array[Wound]
@export var starting_limbs: Array[LimbData]
var limbs: Array[LimbComponent]
@export var torso: HealthComponent = HealthComponent.make(320, 320)

@export_category("Immediate health")
@export var blood: HealthComponent = HealthComponent.make(320, 320)
@export var bleeding_severity: int = 0

@export var base_pain := 0.0
var _actual_pain: float = 0.0

@export var base_awareness := 0.0
var _actual_awareness: float = 0.0

@export var base_finesse := 1.0
var _actual_finesse: float = 1.0

@export var base_movement := 1.0
var _actual_movement: float = 1.0

@export var base_sight := 1.0
var _actual_sight: float = 1.0

@export_category("Long-term")
@export var hunger: float = 1.0
@export var thirst: float = 1.0
@export var temperature: float = 36.5
@export var sleep: float = 1.0
@export var comfort: float = 1.0
@export var stress: float = 0.0

signal died
signal state_change(new_state: State)
var current_state: int = State.ALIVE
var down_reason: int = DownReason.NOT

enum DownReason {
	NOT = 0,
	UNCONSCIOUS = 1,
	SHOCK = 2,
	INCAPACITATED = 3
}

enum State {
	ALIVE = 0,
	DOWN_AND_OUT = 1,
	DEAD = 2
}

func change_state(state: int):
	state_change.emit(state)
	current_state = state

func kill():
	change_state(State.DEAD)
	died.emit()

func _ready() -> void:
	initialize_limbs()
	adjust_base_stats()
	recalculate_stats()

func health_delta():
	adjust_base_stats()
	recalculate_stats()
	update_state_on_stats()

var limb_rarities = {}
func initialize_limbs():
	for limb_data in starting_limbs:
		var limb = LimbComponent.new()
		limb.limb_data = limb_data
		limb.max_hp = limb_data.max_health
		limb.hp = limb_data.health
		limb.health_changed.connect(health_delta.unbind(1))
		limb.name = limb_data.limb_id
		limb_rarities[limb] = limb_data.chance_to_hit
		limbs.append(limb)

func update_state_on_stats():
	if current_state != State.DEAD:
		var unconscious = _actual_awareness < .2
		var incapacitated = _actual_movement < .2
		var shock = _actual_pain > .8
		if unconscious or incapacitated or shock:
			change_state(State.DOWN_AND_OUT)
			
			if unconscious:
				down_reason = DownReason.UNCONSCIOUS
			elif incapacitated:
				down_reason = DownReason.INCAPACITATED
			elif shock:
				down_reason = DownReason.SHOCK
		else:
			change_state(State.ALIVE)
			down_reason = DownReason.NOT
		
		if blood.hp <= 0 or _actual_awareness <= 0:
			kill()

func adjust_base_stats():
	for limb in limbs:
		for key in limb.limb_data.factors.keys():
			self[key] = 0
	for limb in limbs:
		var data = limb.limb_data
		var hp_percent = limb.hp / limb.max_hp
		if limb.hp <= 0 and limb.limb_data.critical:
			base_awareness = -100.0
		for key in data.factors.keys():
			self[key] += data.factors[key] * hp_percent
	base_awareness = max(base_awareness, 0)

func recalculate_stats():
	base_pain = _actual_pain
	
	var pain_modifier = 0.0
	if _actual_pain > .1:
		pain_modifier = -min(_actual_pain / 2, 0.5)
	
	var blood_modifier = 0.0
	var blood_percentage = blood.hp / blood.max_hp
	if blood_percentage <= .9:
		blood_modifier = -min(.65, 1.0 - blood_percentage)
	_actual_awareness = base_awareness + pain_modifier + blood_modifier
	
	_actual_finesse = base_finesse * _actual_awareness
	_actual_movement = base_movement * _actual_awareness
	_actual_sight = base_sight * _actual_awareness

func take_damage(amount: int):
	# Choose a random limb to take damage
	var weighted_sum = 0
	for n in limb_rarities:
		weighted_sum += limb_rarities[n]
	
	var targeted_limb: LimbComponent
	var item = randi_range(0, weighted_sum)
	for n in limb_rarities:
		if item <= limb_rarities[n]:
			n.take_damage(amount)
			targeted_limb = n
			break
		item -= limb_rarities[n]
	
	adjust_base_stats()
	recalculate_stats()
	update_state_on_stats()
	
	var severity = 0
	if current_state == State.DEAD:
		severity = PopupManager.SEVERITY_HIGH
	elif current_state == State.DOWN_AND_OUT:
		severity = PopupManager.SEVERITY_MED
	
	PopupManager.popup("%s: %d" % [targeted_limb.limb_data.limb_name, amount], host.global_position, severity)
