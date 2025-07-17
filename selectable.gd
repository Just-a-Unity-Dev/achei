extends Node
## Marks this object as a selectable object.
class_name Selectable

@export var get_position_from: Node2D
@export var selection_range: float = 32.0
@export var show_when_selected: CanvasItem

var info: Dictionary
var is_selected = false

signal selected
signal deselected
signal info_updated(info: Dictionary)
signal received_order(mouse_pos: Vector2, parameters: Dictionary)

func _ready() -> void:
	selected.connect(_on_select)
	deselected.connect(_on_deselect)
	show_when_selected.hide()

func _on_select():
	show_when_selected.show()

func _on_deselect():
	show_when_selected.hide()

func _init() -> void:
	add_to_group("selectable", false)

## Updates the info in the selectable info variable.
func update_info(new_info: Dictionary):
	info_updated.emit(new_info)
	info = new_info
