extends CanvasLayer
@export var select_container: BoxContainer
@export var base_frame: BoxContainer
@export var pawn_dropdown: Panel

@export var menu_lists: Array[Panel]

@export var verb_container: GridContainer
@export var verb_button: PackedScene

@export var skill_containers: Array[BoxContainer]

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

@export_category("Limb menu")
@export var limb_source_container: BoxContainer
@export var bleed_severity_label: Label

var current_focus: Noun

func _ready() -> void:
	SelectionManager.new_selected.connect(_on_new_selected)
	select_container.hide()

func generic_update_container(container: HBoxContainer, value: float, max_value: float = -1.0):
	var bar: ProgressBar = container.get_node("Label")
	bar.value = value
	if max_value != -1.0:
		bar.max_value = max_value

func update_skill_hud():
	if current_focus == null: return
	var character = current_focus.get_parent()
	
	if character is Character:
		var skills = character.skills
		var main_container: Array[Control] = []
		for container in skill_containers:
			main_container.append_array(container.get_children())
		
		for control in main_container:
			if control is HBoxContainer:
				var name_label: Label = control.get_node("Name")
				var level_bar: ProgressBar = control.get_node("Label")
				var value_label: Label = control.get_node("Label/Value")
				
				var xp = skills[control.name]
				
				name_label.text = control.name
				level_bar.value = xp
				value_label.text = "LVL: %d" % skills.get_level(xp)

func update_health_hud():
	if current_focus == null: return
	var character = current_focus.host
	
	if character is Character:
		generic_update_container(blood_container, character.health.blood.hp, character.health.blood.max_hp)
		generic_update_container(pain_container, character.health._actual_pain)
		generic_update_container(conscious_container, character.health._actual_awareness)
		generic_update_container(handling_container, character.health._actual_finesse)
		generic_update_container(movement_container, character.health._actual_movement)
		generic_update_container(sight_container, character.health._actual_sight)
		generic_update_container(hunger_container, character.health.hunger)
		generic_update_container(thirst_container, character.health.thirst)
		#generic_update_container(temperature_container, character.health.temperature)
		generic_update_container(sleep_container, character.health.sleep)
		generic_update_container(comfort_container, character.health.comfort)
		generic_update_container(stress_container, character.health.stress)
		
		bleed_severity_label.text = ""
		for x in range(character.health.bleeding_severity): bleed_severity_label.text += "<"
		
		for limb in character.health.limbs:
			var box: HBoxContainer = limb_source_container.get_node(str(limb.limb_data.gui_bar_name))
			if box == null: continue
			generic_update_container(box, limb.hp, limb.max_hp)
			generic_update_container(box, limb.hp, limb.max_hp)
			box.get_node("Name").text = limb.limb_data.limb_name
			box.get_node("Label/Value").text = "%d/%d hp" % [limb.hp, limb.max_hp]

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
	if event.is_action_pressed("time_scale_4"):
		Engine.time_scale = 4.0
	
	if event is InputEventKey:
		if current_focus != null:
			for verb in current_focus.verbs:
				if verb.input_event_name == "": continue
				if event.is_action_pressed(verb.input_event_name):
					# Verb keybinds
					selected_verb.emit(verb)

func enable_menu(to_enable: Panel):
	for menu in menu_lists:
		if menu == to_enable: continue
		menu.hide()
	
	if to_enable != null:
		to_enable.visible = false if to_enable.visible else true

func update_hud(info: Dictionary):
	for label in base_frame.get_children():
		if info.has(label.name):
			label.text = info[label.name]
			label.show()
		else:
			label.hide()

func _info_updated(new_info: Dictionary):
	update_hud(new_info)

func _process(_delta: float) -> void:
	update_skill_hud() # TODO: On skill delta, update skill HUD

func clear_verbs():
	for child in verb_container.get_children():
		child.queue_free()

signal selected_verb(verb: Verb)
func _verb_button_pressed(verb: Verb):
	selected_verb.emit(verb)

func generate_verbs():
	clear_verbs()
	for verb in current_focus.verbs:
		if verb.verb_type != Verb.VerbType.TARGET_ONLY:
			var new_button: Button = verb_button.instantiate()
			new_button.get_node("Label").text = verb.verb_name
			new_button.get_node("Image").texture = verb.verb_image
			
			var key_event_node = new_button.get_node("KeyEvent")
			if verb.input_event_name == "":
				key_event_node.visible = false
			else:
				# TODO: Will need support for multikey/controllers ... if we ever get around to that
				var event = InputMap.action_get_events(verb.input_event_name)[0]
				if event is InputEventKey:
					key_event_node.text = event.as_text_physical_keycode()
			new_button.pressed.connect(_verb_button_pressed.bind(verb))
			verb_container.add_child(new_button)

func try_connect_signal(to_bind: Signal, function: Callable) -> bool:
	if not to_bind.is_connected(function):
		to_bind.connect(function)
		return true
	return false

func try_disconnect_signal(to_unbind: Signal, function: Callable) -> bool:
	if to_unbind.is_connected(function):
		to_unbind.disconnect(function)
		return true
	return false

func _on_new_selected():
	select_container.hide()
	
	# Disconnect previous info autoreload call
	if current_focus != null:
		try_disconnect_signal(current_focus.info_updated, _info_updated)
		if current_focus.host is Character:
			try_disconnect_signal(current_focus.host.health.on_health_change, update_health_hud)
	current_focus = null
	
	var selected_list = SelectionManager.selected_list
	select_container.show()
	pawn_dropdown.hide()
	verb_container.hide()
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
		
		if current_focus.host is Character:
			try_connect_signal(current_focus.host.health.on_health_change, update_health_hud)
		update_health_hud()
		
		update_hud(current_focus.info)
		generate_verbs()
		verb_container.show()

#region Button signal connects
func _on_health_pressed() -> void:
	enable_menu($MarginContainer/Control/SelectContainer/Health)

func _on_skills_pressed() -> void:
	enable_menu($MarginContainer/Control/SelectContainer/Skills)
#endregion
