extends Resource
class_name HealthStats

@export_category("Wounds")
#@export var wounds: Array[Wound]
@export var hp: float = 10.0
@export var max_hp: float = 10.0

@export_category("Health")
@export var pain: float = 0.0
@export var blood: float = 1.0
@export var consciousness: float = 1.0
@export var manipulation: float = 1.0
@export var movement: float = 1.0
@export var psychokinetic_sensitvity: float = 0.5
@export var hunger: float = 1.0
@export var thirst: float = 1.0
@export var temperature: float = 36.0
@export var sleep: float = 1.0
@export var comfort: float = 1.0
@export var stress: float = 1.0
