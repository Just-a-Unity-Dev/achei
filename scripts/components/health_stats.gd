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
var is_dead = false

func kill():
	is_dead = true
	died.emit()
	
	host.global_rotation_degrees = 90

func _ready() -> void:
	initialize_limbs()
	adjust_base_stats()
	recalculate_stats()

func health_delta():
	adjust_base_stats()
	recalculate_stats()
	print("Stats updated")

func initialize_limbs():
	for limb_data in starting_limbs:
		var limb = LimbComponent.new()
		limb.limb_data = limb_data
		limb.max_hp = limb_data.max_health
		limb.hp = limb_data.health
		limb.health_changed.connect(health_delta.unbind(1))
		limbs.append(limb)

func adjust_base_stats():
	for limb in limbs:
		for key in limb.limb_data.factors.keys():
			self[key] = 0
	for limb in limbs:
		var data = limb.limb_data
		for key in data.factors.keys():
			var hp_percent = limb.hp / limb.max_hp
			self[key] += data.factors[key] * hp_percent

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
	_actual_movement = base_finesse * _actual_awareness
	_actual_sight = base_finesse * _actual_awareness

func take_damage(amount: int):
	# TODO: Better damage distribution than this bs
	limbs[randi() % 6].take_damage(amount)
	
	adjust_base_stats()
	recalculate_stats()
	
	var severity = 0
	if _actual_awareness <= 0:
		severity = PopupManager.SEVERITY_HIGH
		kill()
	
	PopupManager.popup(str(amount), host.global_position, severity)
