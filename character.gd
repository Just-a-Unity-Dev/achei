extends CharacterBody2D
class_name Character

@export var health: HealthStats

@export_category("Atributes")
@export var strength: int = 1
@export var finesse: int = 1
@export var toughness: int = 1
@export var endurance: int = 1
@export var perception: int = 1
@export var composure: int = 1

@export_category("Skills")
@export var athletics:		int = 100
@export var sneak:			int = 100
@export var doctor:			int = 100
@export var gather:			int = 100
@export var repair:			int = 100
@export var engineer:		int = 100
@export var navigate:		int = 100
@export var cook:			int = 100
@export var fish:			int = 100
@export var craft:			int = 100
@export var farm:			int = 100
@export var reason:			int = 100
@export var intimidate:		int = 100
@export var firearms:		int = 100
@export var archery:		int = 100
@export var throwing:		int = 100
@export var punch:			int = 100
@export var stab:			int = 100
@export var slash:			int = 100

@onready var selectable = $Selectable

func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": name}
	values.append("HP: %d/%d" % [health.hp, health.max_hp])
	values.append("Stats: %d STR, %d FIN, %d TOG, %d END, %d PER, %d COM" % [strength, finesse, toughness, endurance, perception, composure])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

func _process(delta: float) -> void:
	trigger_info_update()
