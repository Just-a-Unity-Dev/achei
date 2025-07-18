extends Node
class_name HealthStatsComponent

@export var host: Character

@export_category("Wounds")
#@export var wounds: Array[Wound]
@export var torso: HealthComponent = HealthComponent.make(320, 320)

@export_category("Immediate health")
@export var blood: HealthComponent = HealthComponent.make(320, 320)
@export var bleeding_severity: int = 0

@export var base_pain := 0.0
var _actual_pain: float = 0.0

@export var base_consciousness := 1.0
var _actual_consciousness: float = 1.0

@export var base_handling := 1.0
var _actual_handling: float = 1.0

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
	recalculate_stats()

func recalculate_stats():
	base_pain = _actual_pain
	
	var pain_modifier = 0.0
	if _actual_pain > .1:
		pain_modifier = -min(_actual_pain / 2, 0.5)
	
	var blood_modifier = 0.0
	var blood_percentage = blood.hp / blood.max_hp
	if blood_percentage <= .9:
		blood_modifier = -min(.65, 1.0 - blood_percentage)
	_actual_consciousness = base_consciousness + pain_modifier + blood_modifier
	
	_actual_handling = base_handling * _actual_consciousness
	_actual_movement = base_handling * _actual_consciousness
	_actual_sight = base_handling * _actual_consciousness

func take_damage(amount: int):
	torso.take_damage(amount)
	
	var severity = 0
	if _actual_consciousness <= 0:
		severity = PopupManager.SEVERITY_HIGH
	
	PopupManager.popup(str(amount), host.global_position, severity)
