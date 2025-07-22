extends Label
class_name PopupLabel

var lifetime: float = 0.0
var resolution: float = 3.0

func _init() -> void:
	z_index = 100 + randi_range(0, 25)

var speed: int = 7

func _ready() -> void:
	add_theme_color_override("font_outline_color", Color(0,0,0))
	add_theme_constant_override("outline_size", 6 * resolution)
	add_theme_font_size_override("font_size", get_theme_default_font_size() * resolution)
	scale /= resolution
	speed = randf_range(5,8)

func _process(delta: float) -> void:
	lifetime += delta
	position += Vector2(2, -4) * speed * delta
	if lifetime > 5.0:
		queue_free.call_deferred()
