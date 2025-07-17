extends Node

var selected_list: Array[Selectable]

signal new_selected

func try_deselect_all():
	assign_new_selected_list([])

func try_deselect(to_select: Selectable):
	to_select.is_selected = false
	to_select.deselected.emit()

func try_select(to_select: Selectable):
	to_select.is_selected = true
	to_select.selected.emit()

func assign_new_selected_list(new: Array[Selectable]):
	for selected in selected_list:
		try_deselect(selected)
	
	selected_list = new
	
	for selected in selected_list:
		try_select(selected)
	new_selected.emit()

func get_selectable_in_box(top_left: Vector2, bottom_right: Vector2) -> Array[Selectable]:
	if top_left.x > bottom_right.x:
		var tmp_1 = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = tmp_1
	if top_left.y > bottom_right.y:
		var tmp_2 = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = tmp_2
	
	var box = Rect2(top_left, bottom_right - top_left)
	var selected: Array[Selectable] = []
	
	for unit in get_tree().get_nodes_in_group("selectable"):
		if unit is Selectable:
			if not box.has_point(unit.get_position_from.global_position):
				continue
			selected.append(unit)
	return selected

func send_order(object: Selectable, parameters: Dictionary, add_onto: bool):
	object.received_order.emit(parameters, add_onto)

func send_orders(objects: Array[Selectable], parameters: Dictionary, add_onto: bool):
	for object in objects:
		send_order(object, parameters, add_onto)

func try_select_at_position(pos: Vector2):
	var new_selected_units: Array[Selectable] = []
	for unit in get_tree().get_nodes_in_group("selectable"):
		if unit is Selectable:
			if pos.distance_to(unit.get_position_from.global_position) > unit.selection_range:
				continue
			new_selected_units.append(unit)
		break
	assign_new_selected_list(new_selected_units)
