extends Node

var selected_list: Array[Noun]
var has_selection:
	get:
		return selected_list.size() > 0

signal new_selected

func try_deselect_all():
	assign_new_selected_list([])

func try_deselect(to_select: Noun):
	to_select.is_selected = false
	to_select.deselected.emit()

func try_select(to_select: Noun):
	to_select.is_selected = true
	to_select.selected.emit()

func assign_new_selected_list(new: Array[Noun]):
	for selected in selected_list:
		try_deselect(selected)
	
	selected_list = new
	
	for selected in selected_list:
		try_select(selected)
	new_selected.emit()

func get_selectable_in_box(top_left: Vector2, bottom_right: Vector2) -> Array[Noun]:
	if top_left.x > bottom_right.x:
		var tmp_1 = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = tmp_1
	if top_left.y > bottom_right.y:
		var tmp_2 = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = tmp_2
	
	var box = Rect2(top_left, bottom_right - top_left)
	var selected: Array[Noun] = []
	
	for unit in get_tree().get_nodes_in_group("noun"):
		if unit is Noun:
			if not box.has_point(unit.get_position_from.global_position):
				continue
			selected.append(unit)
	return selected

func send_verb(verb: Verb, doer: Noun, target: Noun, parameters: Dictionary, add_onto: bool):
	var new_order = verb.order.new()
	doer.received_order.emit(new_order, target, parameters, add_onto)

func send_verbs(verb: Verb, doers: Array[Noun], target: Noun, parameters: Dictionary, add_onto: bool):
	for doer in doers:
		send_verb(verb, doer, target, parameters, add_onto)

func try_get_nouns_at_position(pos: Vector2) -> Array[Noun]:
	var new_selected_units: Array[Noun] = []
	for unit in get_tree().get_nodes_in_group("noun"):
		if unit is Noun:
			if pos.distance_to(unit.get_position_from.global_position) > unit.selection_range:
				continue
			new_selected_units.append(unit)
	return new_selected_units

func try_get_first_noun_at_position(pos: Vector2) -> Noun:
	var noun: Noun = null
	for unit in get_tree().get_nodes_in_group("noun"):
		if unit is Noun:
			if pos.distance_to(unit.get_position_from.global_position) > unit.selection_range:
				continue
			noun = unit
			break
	return noun

func try_select_at_position(pos: Vector2):
	var new_selected_units: Array[Noun] = try_get_nouns_at_position(pos)
	assign_new_selected_list(new_selected_units)
