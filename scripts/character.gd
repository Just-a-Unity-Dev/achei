extends CharacterBody2D
class_name Character

@export var character_name: String = "Rain Caldwell"
@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent
@export var tilemap: TileMapLayer

@export var current_weapon: GunData

@onready var selectable = $Selectable

var list_of_orders: Array[BaseOrder]

const BASE_SPEED = 2650
var cache_speed: int = 0

func recalculate_speed():
	var speed = BASE_SPEED
	speed += skills.endurance.get_modifier() * 25
	speed *= max(health.consciousness * 2, 1)
	speed *= health.movement
	speed *= (1.0 - health.pain)
	
	var coords = tilemap.local_to_map(position)
	var tile = tilemap.get_cell_tile_data(coords)
	speed *= tile.get_custom_data("movement_penalty")
	
	cache_speed = speed

func _init() -> void:
	add_to_group("character")

func _ready() -> void:
	selectable.received_order.connect(_received_order)
	selectable.selected.connect(_selected)
	health.died.connect(_on_death)
	recalculate_speed()

func _on_death():
	velocity = Vector2.ZERO
	clear_orders()
	queue_redraw()

func _selected(): trigger_info_update()

const TRANSPARENCY = Color(1,1,1,.75)

func _draw() -> void:
	# Basic draw function drawing move orders/atttack orders.
	# This should be delegated into the orders themselves to _draw, but it's fine ... for now.
	if health.is_dead: return
	
	var previous_position = global_position
	var i = 0
	for order in list_of_orders:
		if "destination" in order:
			if not selectable.is_selected: continue
			draw_line(to_local(previous_position), to_local(order.destination), Color(1,1,1,.8), 2)
			var circle_size = 8
			if i == list_of_orders.size() - 1: circle_size = 16
			draw_circle(to_local(order.destination), circle_size, Color.PALE_GREEN * TRANSPARENCY, false, 4)
			previous_position = order.destination
		if "target" in order:
			if selectable.is_selected:
				draw_circle(to_local(order.target.global_position), 22, Color.RED * TRANSPARENCY, false, 2)
			
			# Draw ranged combat
			var angle = global_position.angle_to_point(order.target.global_position)
			var progress = deg_to_rad(45 * (1.0 - order.progress))
			draw_arc(Vector2.ZERO, 32, angle - progress, angle + progress, 3, Color.WHITE * TRANSPARENCY, 4)
		i += 1
	
	if current_weapon != null and selectable.is_selected:
		draw_circle(Vector2.ZERO, current_weapon.minimum_range * 32, Color.DARK_RED * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.short_range * 32, Color.GREEN * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.medium_range * 32, Color.YELLOW * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.long_range * 32, Color.RED * TRANSPARENCY, false, 2.20)

## Queues an order, and places it at the back of the list
func add_order(order: BaseOrder, parameters: Dictionary):
	if health.is_dead: return
	order.setup(self, parameters)
	list_of_orders.push_back(order)

## Overrides the current order and places this order at the front of the list
func add_order_first(order: BaseOrder, parameters: Dictionary):
	if health.is_dead: return
	order.setup(self, parameters)
	list_of_orders.push_front(order)

## Clears the list of orders
func clear_orders():
	if list_of_orders.size() > 0:
		var current_order = list_of_orders[0]
		current_order.end(false)
	list_of_orders.clear()

func _received_order(parameters: Dictionary, add_onto: bool):
	# Camera emits this signal, which then determines what order to do
	# This will likely be replaced with a verb system some time in the future (please)
	var mouse_pos = parameters["mouse_pos"]
	
	# TODO: Parameters have a "order_type"
	var order: BaseOrder
	if "target" in parameters.keys():
		order = preload("res://scripts/orders/ranged_attack.gd").new()
	else:
		order = preload("res://scripts/orders/move_to_point.gd").new()
	
	if not add_onto: clear_orders()
	add_order(order, parameters)
	
	trigger_info_update()

## Updates the Selectable's status info. Expensive, and should be called when an update happens.
func trigger_info_update() -> void:
	var values: Array[String] = []
	var new_info = {"title": character_name}
	if health.is_dead: 
		new_info.title = "%s (dead)" % character_name
		values.append("Dead.")
	else:
		values.append("HP: %.2f%%" % [health.consciousness * 100])
	
		if list_of_orders.size() > 0:
			var order_string = "Current order: %s" % list_of_orders[0].current_status
			if list_of_orders.size() != 1:
				order_string += " (and %d more...)" % [list_of_orders.size() - 1]
			values.append(order_string)
		else:
			values.append("Idling around")
	
		if current_weapon != null: values.append("Holding a %s" % current_weapon.gun_name)
	
	var coords = tilemap.local_to_map(position)
	var tile = tilemap.get_cell_tile_data(coords)
	values.append("Currently on: %s (%d%% speed)" % [tile.get_custom_data("tile_name"), tile.get_custom_data("movement_penalty") * 100])
	values.append("Speed: %.2f m/s" % [(cache_speed / 32) * get_physics_process_delta_time()])
	
	for i in range(values.size()):
		new_info["key"+str(i+1)] = values[i]
	selectable.update_info(new_info)

## Used for current_tile deltas on trigger_info_update
var previous_tile: String = "None"

func _physics_process(delta: float) -> void:
	if health.is_dead: return
	# Do the list of orders
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
	
	# Tile-based movement penalties
	var coords = tilemap.local_to_map(position)
	var tile = tilemap.get_cell_tile_data(coords)
	var tile_name = tile.get_custom_data("tile_name")
	if previous_tile != tile_name:
		# TODO: This is a shitty method. Fix this.
		recalculate_speed()
		trigger_info_update()
	
	move_and_slide()
	queue_redraw()
