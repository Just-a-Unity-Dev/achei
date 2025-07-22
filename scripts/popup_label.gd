extends Label
class_name PopupLabel

var lifetime: float = 0.0
var resolution: float = 3.0

func _init() -> void:
	z_index = 100 + randi_range(0, 25)

const OUTLINE_SIZE = 6
const STOP_FLOAT_TIME = 0.3
const FADE_AFTER = 5.0
const FADE_LERP_MULTIPLIER = 2.5

var speed: int = 7
var initial_position: Vector2
var before_float_position: Vector2
var start_floating: bool = false

func _ready() -> void:
	add_theme_color_override("font_outline_color", Color(0,0,0))
	add_theme_constant_override("outline_size", 6 * resolution)
	add_theme_font_size_override("font_size", get_theme_default_font_size() * resolution)
	scale /= resolution
	speed = randf_range(5,8)
	
	# Smoothly tween out of the initial pos
	if Engine.time_scale < 3:
		position = initial_position
		var tween = get_tree().create_tween().bind_node(self).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "position", before_float_position, STOP_FLOAT_TIME)
		await tween.finished
	else:
		# Player basically wont even notice
		position = before_float_position
	start_floating = true

func _process(delta: float) -> void:
	if not start_floating: return # Don't start floating, animation is likely playing
	
	lifetime += delta
	position += Vector2(2, -4) * speed * delta
	
	if lifetime > FADE_AFTER:
		# Fade out
		modulate = modulate.lerp(Color.TRANSPARENT, FADE_LERP_MULTIPLIER * delta)
		if modulate.is_equal_approx(Color.TRANSPARENT):
			queue_free.call_deferred()
