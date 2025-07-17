extends CharacterBody2D
class_name Character

@export var character_name: String = "Rain Caldwell"
@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent

@onready var selectable = $Selectable
var destination: Vector2 = Vector2.ZERO

const BASE_SPEED = 2650
var cache_speed: int = 0

func recalculate_speed():
	var speed = BASE_SPEED
	speed += skills.endurance * 25
	speed *= max(health.consciousness * 2, 1)
	speed *= health.movement
	speed *= (1.0 - health.pain)
	
	cache_speed = speed

func _ready() -> void:
	selectable.received_order.connect(_received_order)
	selectable.selected.connect(_selected)
	selectable.deselected.connect(_deselected)
	recalculate_speed()

func _selected():
	trigger_info_update()

func _deselected():
	pass

func _draw() -> void:
	if destination != Vector2.ZERO:
		draw_circle(destination - global_position, 32, Color.PALE_GREEN * Color(1,1,1,0.5), false, 4)

func _received_order(parameters: Dictionary):
	var mouse_pos = parameters["mouse_pos"]
	destination = mouse_pos
	trigger_info_update()

func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": character_name}
	values.append("HP: %d/%d" % [health.hp, health.max_hp])
	
	if destination != Vector2.ZERO:
		values.append("Current order: Move to position")
	else:
		values.append("Idle.")
	values.append("Speed: %.2f m/s" % [(cache_speed / 64) * get_physics_process_delta_time()])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

func _physics_process(delta: float) -> void:
	if destination != Vector2.ZERO:
		if global_position.distance_to(destination) < 1.5:
			destination = Vector2.ZERO
			trigger_info_update()
		else:
			var direction = global_position.direction_to(destination)
			velocity = direction * delta * cache_speed
		
		move_and_slide()
		queue_redraw()
