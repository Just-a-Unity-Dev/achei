extends CanvasLayer
@onready var panel = $Panel
@onready var base_frame = $Panel/MarginContainer/BaseFrame

var current_focus: Selectable

func _ready() -> void:
	SelectionManager.new_selected.connect(_on_new_selected)
	panel.hide()

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
	panel.hide()
	
	# Disconnect previous info autoreload call
	if current_focus != null and current_focus.info_updated.is_connected(_info_updated):
		current_focus.info_updated.disconnect(_info_updated)
	current_focus = null
	
	var selected_list = SelectionManager.selected_list
	if selected_list.size() != 1:
		return # TODO: Multiple select UI
	
	panel.show()
	
	# Allows the UI to update when the selectable requests for an update / info autoreload
	current_focus = SelectionManager.selected_list[0]
	current_focus.info_updated.connect(_info_updated)
	update_hud(current_focus.info)
