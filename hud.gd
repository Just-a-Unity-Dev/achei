extends CanvasLayer
@onready var panel = $Panel
@onready var base_frame = $Panel/MarginContainer/BaseFrame

func _ready() -> void:
	SelectionManager.new_selected.connect(_on_new_selected)
	panel.hide()

func _on_new_selected():
	panel.hide()
	var selected_list = SelectionManager.selected_list
	if selected_list.size() != 1:
		return
	panel.show()
	var selected = SelectionManager.selected_list[0]
	
	for label in base_frame.get_children():
		if selected.info.has(label.name):
			label.text = selected.info[label.name]
			label.show()
		else:
			label.hide()
