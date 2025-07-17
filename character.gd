extends CharacterBody2D
class_name Character

@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent

@onready var selectable = $Selectable
var destination: Vector2 = Vector2.ZERO

func _ready() -> void:
	selectable.received_order.connect(_received_order)
	selectable.selected.connect(_selected)

func _selected():
	trigger_info_update()

func _received_order(parameters: Dictionary):
	var mouse_pos = parameters["mouse_pos"]
	destination = mouse_pos
	trigger_info_update()

func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": name}
	values.append("HP: %d/%d" % [health.hp, health.max_hp])
	
	if destination != Vector2.ZERO:
		values.append("Current order: Move to position")
	else:
		values.append("Idle.")
	#values.append("Stats: %d STR, %d FIN, %d TOG, %d END, %d PER, %d COM" % [strength, finesse, toughness, endurance, perception, composure])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

func _physics_process(delta: float) -> void:
	if destination != Vector2.ZERO:
		var direction = global_position.direction_to(destination)
		velocity = direction * delta * 5000
		if global_position.distance_to(destination) < 1:
			destination = Vector2.ZERO
			trigger_info_update()
		move_and_slide()
