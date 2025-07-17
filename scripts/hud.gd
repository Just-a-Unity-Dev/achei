extends CanvasLayer
@export var select_container: BoxContainer
@export var base_frame: BoxContainer
@export var pawn_dropdown: Panel

@export var menu_lists: Array[Panel]

var current_focus: Selectable

func _ready() -> void:
	SelectionManager.new_selected.connect(_on_new_selected)
	select_container.hide()

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
	enable_menu($MarginContainer/Control/VBoxContainer/Health)

func update_hud(info: Dictionary):
	for label in base_frame.get_children():
		if info.has(label.name):
			label.text = info[label.name]
			label.show()
		else:
			label.hide()

func _info_updated(new_info: Dictionary):
	update_hud(new_info)

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
