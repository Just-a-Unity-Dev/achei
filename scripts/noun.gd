extends Node
## Marks this object as a noun, which can be used as either a Subject, Target or With.
class_name Noun

@export var selectable_id: StringName
@export var get_position_from: Node2D
@export var selection_range: float = 16.0
@export var show_when_selected: CanvasItem

@export var host: Node2D

var info: Dictionary
var is_selected = false

signal selected
signal deselected
signal info_updated(info: Dictionary)
signal received_order(parameters: Dictionary, add_onto: bool)

func _ready() -> void:
	selected.connect(_on_select)
	deselected.connect(_on_deselect)
	show_when_selected.hide()

func _on_select():
	show_when_selected.show()

func _on_deselect():
	show_when_selected.hide()

func _init() -> void:
	add_to_group("noun", false)

## Updates the info in the selectable info variable.
func update_info(new_info: Dictionary):
	info_updated.emit(new_info)
	info = new_info
