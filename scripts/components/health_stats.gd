extends Node
class_name HealthStatsComponent

@export var host: Character

@export_category("Wounds")
#@export var wounds: Array[Wound]
@export var torso: HealthComponent = HealthComponent.make(320, 320)

@export_category("Immediate health")
@export var pain := 0.0
@export var blood: HealthComponent = HealthComponent.make(0, 320)
@export var consciousness := 1.0
@export var handling := 1.0
@export var movement := 1.0
@export var sight := 1.0
@export var psychokinetic_sensitvity := 0.5

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

func take_damage(amount: int):
	torso.take_damage(amount)
	
	var severity = 0
	if consciousness <= 0:
		severity = PopupManager.SEVERITY_HIGH
	PopupManager.popup(str(amount), host.global_position, severity)
