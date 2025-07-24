extends CharacterBody2D
class_name Character

@export var character_name: String = "Rain Caldwell"
@export var health: HealthStatsComponent
@export var skills: SkillStatsComponent
@export var tilemap: TileMapLayer

@export var sprite: Sprite2D
@export var current_gun_node: Node2D
@export var current_gun_sprite: Sprite2D


enum MovementState {
	WALK = 0,
	SPRINT = 1,
	SNEAK = 2
}

@export var current_movement_state: MovementState
@export var current_weapon: GunData

## Used for getting the current tile data and current_tile deltas on trigger_info_update
var current_tile: StringName = &"unknown"

@onready var noun = $Noun

var list_of_orders: Array[BaseOrder]

const PIXEL_SECOND = 60*32
const BASE_SPEED = 2.5*PIXEL_SECOND
var cache_speed: int = 0

func try_switch_movement_state(target_state: MovementState):
	if health._actual_movement < .5:
		target_state = MovementState.WALK
	else:
		target_state = target_state

func recalculate_speed():
	var speed = BASE_SPEED
	var endurance_mod := skills.get_modifier(skills.endurance)
	speed += endurance_mod * (10 * PIXEL_SECOND)
	speed *= health._actual_movement
	
	if current_movement_state == MovementState.SPRINT:
		speed *= 2 * (endurance_mod + 1.0)
	elif current_movement_state == MovementState.SNEAK:
		speed *= 0.65 * (skills.get_modifier(skills.sneak) + 1.0)
	
	var map_tile_data = get_map_tile_data_below()
	speed *= map_tile_data.movement_penalty
	
	cache_speed = speed

func _init() -> void:
	add_to_group("character")

func _ready() -> void:
	noun.received_order.connect(_received_order)
	noun.selected.connect(_selected)
	health.died.connect(_on_death)
	health.state_change.connect(_on_state_change)
	health.took_damage.connect(_on_took_damage)
	current_gun_sprite.texture = current_weapon.item_texture_resource
	
	print(current_weapon.dict_representation_get())
	print(DefinitionManager.recursively_save(self))
	
	if tilemap != null:
		recalculate_speed()

func get_serialized_property_names():
	return [
		"character_name",
		"current_weapon",
		"health"
	]

func _on_took_damage(_amount: int, _limb: LimbComponent):
	sprite.self_modulate = Color(1,0,0)
	var tween = get_tree().create_tween().bind_node(sprite)
	tween.tween_property(sprite, "self_modulate", Color(1,1,1), 0.2)

func _on_state_change(new_state: int):
	var tween = get_tree().create_tween().bind_node(sprite)
	if new_state != 0:
		tween.tween_property(sprite, "rotation_degrees", 90, .15)
	else:
		tween.tween_property(sprite, "rotation_degrees", 0, .15)
	if new_state >= health.State.DOWN_AND_OUT:
		clear_orders()
	velocity = Vector2.ZERO
	trigger_info_update()
	queue_redraw()

func _on_death():
	velocity = Vector2.ZERO
	clear_orders()
	queue_redraw()
	trigger_info_update()

func _selected(): trigger_info_update()

const TRANSPARENCY = Color(1,1,1,.75)

func _draw() -> void:
	# Basic draw function drawing move orders/atttack orders.
	# This should be delegated into the orders themselves to _draw, but it's fine ... for now.
	if health.current_state != health.State.ALIVE: return
	
	var previous_position = global_position
	var i = 0
	for order in list_of_orders:
		if "destination" in order:
			if not noun.is_selected: continue
			draw_line(to_local(previous_position), to_local(order.destination), Color(1,1,1,.8), 2)
			
			var circle_size = 8
			if i == list_of_orders.size() - 1: circle_size = 16
			
			draw_circle(to_local(order.destination), circle_size, Color.PALE_GREEN * TRANSPARENCY, false, 4)
			previous_position = order.destination
		elif "time_since_last_hit" in order:
			if noun.is_selected:
				draw_circle(to_local(order.target_host.global_position), 22, Color.RED * TRANSPARENCY, false, 2)
			
			# Draw ranged combat
			if order.progress >= 0 and not order.actively_firing: # Hides progress bar but shows this thing
				var angle = global_position.angle_to_point(order.target_host.global_position)
				var direction = global_position.direction_to(order.target_host.global_position)
				var progress: float = deg_to_rad((order.attack_progress / 30.0) * 360.0)
				draw_arc(direction * 30, 10, angle - progress, angle + progress, 50, Color.WHITE * Color(1,1,1,.5), 20)
		i += 1
	
	if current_weapon != null and noun.is_selected:
		draw_circle(Vector2.ZERO, current_weapon.minimum_range * 32, Color.DARK_RED * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.short_range * 32, Color.GREEN * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.medium_range * 32, Color.YELLOW * TRANSPARENCY, false, 2.20)
		draw_circle(Vector2.ZERO, current_weapon.long_range * 32, Color.RED * TRANSPARENCY, false, 2.20)

@onready var progress_bar = $ProgressBar
func _process(_delta: float) -> void:
	if list_of_orders.size() > 0:
		var current_order = list_of_orders[0]
		progress_bar.visible = current_order.progress > 0.0
		progress_bar.value = list_of_orders[0].progress
	else:
		progress_bar.hide()

## Queues an order, and places it at the back of the list
func add_order(order: BaseOrder, target: Noun, parameters: Dictionary, front: bool = false):
	if health.current_state != health.State.ALIVE: return
	order.setup(self, target, null, parameters)
	if order.finished:
		return # Setup caused order to end prematurely
	
	if front:
		list_of_orders.push_front(order)
	else:
		list_of_orders.push_back(order)

## Clears the list of orders
func clear_orders():
	if list_of_orders.size() > 0:
		var current_order = list_of_orders[0]
		current_order.end(false)
	list_of_orders.clear()

## Returns the map tile id below this character
func get_map_tile_id_below() -> StringName:
	var coords = tilemap.local_to_map(position)
	var tile = tilemap.get_cell_tile_data(coords)
	var tile_id = tile.get_custom_data("tile_id")
	return tile_id

## Returns the map tile data below this character
func get_map_tile_data_below() -> MapTileData:
	return TileManager.get_tile_data(get_map_tile_id_below())

func _received_order(order: BaseOrder, target: Noun, parameters: Dictionary, add_onto: bool):
	# Noun emits this signal, which then determines what order to add to the queue
	if not add_onto:
		clear_orders()
	
	if not add_onto: clear_orders()
	add_order(order, target, parameters)
	
	trigger_info_update()

## Updates the Selectable's status info. Expensive, and should be called when an update happens.
func trigger_info_update() -> void:
	var values: Array[String] = []
	var title := character_name
	if health.current_state == health.State.DEAD: 
		title = "%s (dead)" % character_name
		values.append("Dead.")
	elif health.current_state == health.State.DOWN_AND_OUT: 
		title = "%s (downed)" % character_name
		values.append("Downed (%s)." % tr("down-reason-%d" % health.down_reason))
	else:
		if list_of_orders.size() > 0:
			var order_string = "Current order: %s" % list_of_orders[0].current_status
			if list_of_orders.size() != 1:
				order_string += " (and %d more...)" % [list_of_orders.size() - 1]
			values.append(order_string)
		else:
			values.append("Idling around")
	
		if current_weapon != null: values.append("Holding a %s" % current_weapon.item_name)
	
	var map_tile_data = get_map_tile_data_below()
	values.append("Currently on: %s (%d%% speed)" % [map_tile_data.tile_name, map_tile_data.movement_penalty * 100])
	
	var speed = ((cache_speed / 32.0) / float(Engine.physics_ticks_per_second))
	values.append("Moving at %.2f u/s" % [speed])
	
	noun.update_info_array(title, values)

func _physics_process(delta: float) -> void:
	if health.current_state != health.State.ALIVE: return
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
	
	# Handles tile delta-ing
	var tile_id = get_map_tile_id_below()
	if current_tile != tile_id:
		# TODO: This should be a signal, a lot of these deltas should be signals
		recalculate_speed()
		trigger_info_update()
		current_tile = tile_id
	
	queue_redraw()
	move_and_slide()
