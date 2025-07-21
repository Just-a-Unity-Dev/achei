extends Node

const SEVERITY_LOW = 0
const SEVERITY_MED = 1
const SEVERITY_HIGH = 2
const SEVERITY_GOOD = 3
const SEVERITY_GREAT = 4

var colors = {
	SEVERITY_LOW: Color(1,1,1),
	SEVERITY_MED: Color(1,1,0),
	SEVERITY_HIGH: Color(1,0,0),
	SEVERITY_GOOD: Color(0,.5,1),
	SEVERITY_GREAT: Color(0,1,0)
}

func popup(text: String, where: Vector2, severity: int = 0):
	var label = PopupLabel.new()
	label.text = text
	label.position = where + (Vector2.ONE * 32 * randf_range(-1,1))
	label.add_theme_color_override("font_color", colors[severity])
	get_tree().current_scene.add_child(label)
