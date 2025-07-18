extends Node

const SEVERITY_LOW = 0
const SEVERITY_MED = 1
const SEVERITY_HIGH = 2

func popup(text: String, where: Vector2, severity: int = 0):
	var label = PopupLabel.new()
	label.text = text
	label.position = where + (Vector2.ONE * (32+16) * randf_range(-1,1))
	
	if severity == SEVERITY_LOW:
		label.add_theme_color_override("font_color", Color(1,1,1))
	elif severity == SEVERITY_MED:
		label.add_theme_color_override("font_color", Color(1,1,0))
	elif severity == SEVERITY_HIGH:
		label.add_theme_color_override("font_color", Color(1,0,0))
	
	get_tree().current_scene.add_child(label)
