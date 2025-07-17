extends CharacterBody2D
class_name Character

@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent

@onready var selectable = $Selectable

func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": name}
	values.append("HP: %d/%d" % [health.hp, health.max_hp])
	#values.append("Stats: %d STR, %d FIN, %d TOG, %d END, %d PER, %d COM" % [strength, finesse, toughness, endurance, perception, composure])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

func _process(delta: float) -> void:
	trigger_info_update()
