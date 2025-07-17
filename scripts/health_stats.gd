extends Node
class_name HealthStatsComponent

@export var host: Character

@export_category("Wounds")
#@export var wounds: Array[Wound]
@export var hp: float = 10.0
@export var max_hp: float = 10.0

@export_category("Immediate health")
@export var pain: float = 0.0
@export var blood: float = 1.0
@export var consciousness: float = 1.0
@export var manipulation: float = 1.0
@export var movement: float = 1.0
@export var psychokinetic_sensitvity: float = 0.5

@export_category("Long-term")
@export var hunger: float = 1.0
@export var thirst: float = 1.0
@export var temperature: float = 36.0
@export var sleep: float = 1.0
@export var comfort: float = 1.0
@export var stress: float = 0.0

signal died
var is_dead = false

func kill():
	hp = 0.0
	is_dead = true
	died.emit()
	
	host.global_rotation_degrees = 90

# TODO: Implement proper wounds.
func take_damage(amount: int):
	var severity = 0
	if (hp - amount) <= 0:
		severity = PopupManager.SEVERITY_HIGH
	PopupManager.popup(str(amount), host.global_position, severity)
	hp -= amount
	
	if hp <= 0:
		kill()
