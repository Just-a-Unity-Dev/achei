extends Camera2D

var _target_zoom: float = 1.0
const MIN_ZOOM: float = 0.2
const MAX_ZOOM: float = 2
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 8.0

func zoom_in():
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_out():
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))

var start_pos_world: Vector2 # World: used to detect units within range
var end_pos_world: Vector2

var start_pos_screen: Vector2 # Screen: used to draw stuff
var end_pos_screen: Vector2

enum DragMode {
	NONE = 0,
	SELECT = 1,
	RULER = 2
}
var drag_mode: DragMode = DragMode.NONE
var ruler_label := Label.new()

func _init() -> void:
	z_index = 1000 # Make sure our UI is above the others

var hud: CanvasLayer

func _ready():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(ruler_label)
	add_child(canvas_layer)
	ruler_label.hide()

func _draw():
	if drag_mode == DragMode.SELECT:
		draw_rect(Rect2(start_pos_screen, end_pos_screen - start_pos_screen), Color(1,1,1), false, -1.0, false)
	elif drag_mode == DragMode.RULER:
		draw_line(start_pos_screen, end_pos_screen, Color(1,1,1))
		draw_circle(start_pos_screen, 2, Color(1,1,1))
		draw_circle(end_pos_screen, 2, Color(1,1,1))
		ruler_label.text = "%.2fm" % [start_pos_world.distance_to(end_pos_world) / 64]
		ruler_label.global_position = get_viewport_rect().size / 2

## Handles the sending of orders to selectables.
func handle_order_sending():
	SelectionManager.send_orders(SelectionManager.selected_list, {"mouse_pos": get_global_mouse_position()})

## Handles several LMB interactions such as selecting and ruler mode.
func handle_lmb_interactions(event: InputEventMouseButton):
	if drag_mode == DragMode.NONE:
		if event.shift_pressed:
			drag_mode = DragMode.RULER
		else:
			drag_mode = DragMode.SELECT
	
	if event.pressed:
		# Input began, assign start_pos
		start_pos_world = get_global_mouse_position()
		start_pos_screen = get_local_mouse_position()
		
		end_pos_screen = Vector2.ZERO
		end_pos_world = Vector2.ZERO
		
		if drag_mode == DragMode.RULER:
			# Show the distance label if we're in ruler mode
			ruler_label.show()
	else:
		if drag_mode == DragMode.SELECT:
			# If we're using selection box, do some quick work
			if end_pos_world == Vector2.ZERO or (end_pos_world.distance_to(start_pos_world) < 16):
				# If we just clicked (no motion) or the selection box is so small, then just select at mouse pos
				SelectionManager.try_select_at_position(get_global_mouse_position())
			else:
				# Otherwise, just get all selectables in a box
				var selected = SelectionManager.get_selectable_in_box(start_pos_world, end_pos_world)
				SelectionManager.assign_new_selected_list(selected)
		elif drag_mode == DragMode.RULER: # Just hide the ruler
			ruler_label.hide()
		
		drag_mode = DragMode.NONE
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE: # Pans the camera around
			position -= event.relative / zoom
		if drag_mode != DragMode.NONE: # Sets the end_pos parameters and triggers redraw
			end_pos_screen = get_local_mouse_position()
			end_pos_world = get_global_mouse_position()
			queue_redraw()
	if event.is_action_pressed("ui_cancel"): # Deselects all objects if ESC is not handled
		SelectionManager.try_deselect_all()
	if event is InputEventMouseButton:
		if event.is_pressed(): # Handles zoom in/zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()
		
		if event.button_index == MOUSE_BUTTON_RIGHT and not event.is_pressed():
			handle_order_sending()
		if event.button_index == MOUSE_BUTTON_LEFT:
			handle_lmb_interactions(event)
