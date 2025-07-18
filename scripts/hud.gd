extends CanvasLayer
@export var select_container: BoxContainer
@export var base_frame: BoxContainer
@export var pawn_dropdown: Panel

@export var menu_lists: Array[Panel]

@export_category("Health menu")
@export var blood_container: HBoxContainer
@export var pain_container: HBoxContainer
@export var conscious_container: HBoxContainer
@export var handling_container: HBoxContainer
@export var movement_container: HBoxContainer
@export var sight_container: HBoxContainer
@export var hunger_container: HBoxContainer
@export var thirst_container: HBoxContainer
@export var temperature_container: HBoxContainer
@export var sleep_container: HBoxContainer
@export var comfort_container: HBoxContainer
@export var stress_container: HBoxContainer

@export var limb_source_container: BoxContainer

var current_focus: Selectable

func _ready() -> void:
	SelectionManager.new_selected.connect(_on_new_selected)
	select_container.hide()

func generic_update_container(container: HBoxContainer, value: float, max_value: float = -1.0):
	var bar: ProgressBar = container.get_node("Label")
	bar.value = value
	if max_value != -1.0:
		bar.max_value = max_value

func update_health_hud():
	if current_focus == null: return
	var character = current_focus.get_parent()
	
	if character is Character:
		generic_update_container(blood_container, character.health.blood.hp, character.health.blood.max_hp)
		generic_update_container(pain_container, character.health._actual_pain)
		generic_update_container(conscious_container, character.health._actual_consciousness)
		generic_update_container(handling_container, character.health._actual_handling)
		generic_update_container(movement_container, character.health._actual_movement)
		generic_update_container(sight_container, character.health._actual_sight)
		generic_update_container(hunger_container, character.health.hunger)
		generic_update_container(thirst_container, character.health.thirst)
		#generic_update_container(temperature_container, character.health.temperature)
		generic_update_container(sleep_container, character.health.sleep)
		generic_update_container(comfort_container, character.health.comfort)
		generic_update_container(stress_container, character.health.stress)
		
		for limb in character.health.limbs:
			generic_update_container(
				limb_source_container.get_node(str(limb.limb_data.gui_bar_name)),
				limb.hp,
				limb.max_hp
			)
			
		
		#head_container
		#right_arm_container
		#right_leg_container
		#left_arm_container
		#left_leg_container

var base_physics_ticks_per_second = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("time_toggle_pause"):
		get_tree().paused = not get_tree().paused
	if event.is_action_pressed("time_scale_1"):
		Engine.time_scale = 1.0
	if event.is_action_pressed("time_scale_2"):
		Engine.time_scale = 2.0
	if event.is_action_pressed("time_scale_3"):
		Engine.time_scale = 3.0

func enable_menu(to_enable: Panel):
	for menu in menu_lists:
		if menu != to_enable:
			menu.hide()
	
	if to_enable != null:
		if to_enable.visible:
			to_enable.hide()
		else:
			to_enable.show()

func _on_health_pressed() -> void:
	enable_menu($MarginContainer/Control/SelectContainer/Health)

func update_hud(info: Dictionary):
	for label in base_frame.get_children():
		if info.has(label.name):
			label.text = info[label.name]
			label.show()
		else:
			label.hide()

func _info_updated(new_info: Dictionary):
	update_hud(new_info)

func _process(delta: float) -> void:
	update_health_hud()

func _on_new_selected():
	select_container.hide()
	
	# Disconnect previous info autoreload call
	if current_focus != null and current_focus.info_updated.is_connected(_info_updated):
		current_focus.info_updated.disconnect(_info_updated)
	current_focus = null
	
	var selected_list = SelectionManager.selected_list
	select_container.show()
	pawn_dropdown.hide()
	enable_menu(null)
	if selected_list.size() < 1:
		# Selected no objects, so just hide the HUD
		select_container.hide()
	elif selected_list.size() > 1:
		# Selected more than one object, so show multiple objects
		update_hud({"title": "Multiple objects (x%d)" % selected_list.size()})
	else:
		# Selected exactly one object, so set up funky things
		# Allows the UI to update when the selectable requests for an update / info autoreload
		current_focus = SelectionManager.selected_list[0]
		current_focus.info_updated.connect(_info_updated)
		pawn_dropdown.visible = current_focus.selectable_id == StringName("Pawn")
		update_hud(current_focus.info)
