extends CharacterBody2D
class_name Character

@export var character_name: String = "Rain Caldwell"
@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent

@onready var selectable = $Selectable
var destination: Vector2 = Vector2.ZERO

var list_of_orders: Array[BaseOrder]

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
	recalculate_speed()

func _selected(): trigger_info_update()

func _draw() -> void:
	if destination != Vector2.ZERO and selectable.is_selected:
		var current_position = global_position
		for order in list_of_orders:
			if "destination" in order:
				draw_circle(order.destination - global_position, 32, Color.PALE_GREEN * Color(1,1,1,0.5), false, 4)

func add_order(order: BaseOrder, parameters: Dictionary):
	order.setup(self, parameters)
	list_of_orders.push_back(order)

func clear_orders():
	if list_of_orders.size() > 0:
		var current_order = list_of_orders[0]
		current_order.end(false)
	list_of_orders.clear()

func _received_order(parameters: Dictionary, add_onto: bool):
	var mouse_pos = parameters["mouse_pos"]
	destination = mouse_pos
	
	var order = preload("res://scripts/orders/move_to_point.gd").new()
	if not add_onto: clear_orders()
	add_order(order, parameters)
	
	trigger_info_update()

func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": character_name}
	values.append("HP: %d/%d" % [health.hp, health.max_hp])
	
	if list_of_orders.size() > 0:
		var order_string = "Current order: %s" % list_of_orders[0].current_status
		if list_of_orders.size() != 1:
			order_string += " (and %d more...)" % [list_of_orders.size() - 1]
		values.append(order_string)
	else:
		values.append("Idle")
	values.append("Speed: %.2f m/s" % [(cache_speed / 64) * get_physics_process_delta_time()])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

func _physics_process(delta: float) -> void:
	if list_of_orders.size() > 0:
		var current_order = list_of_orders[0]
		if not current_order.update_status.is_connected(trigger_info_update):
			current_order.update_status.connect(trigger_info_update.unbind(1))
		if not current_order.started:
			current_order.start()
			trigger_info_update()
		
		if current_order.finished:
			current_order.update_status.disconnect(trigger_info_update)
			list_of_orders.pop_front()
			trigger_info_update()
		else:
			current_order.do(delta)
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	queue_redraw()
