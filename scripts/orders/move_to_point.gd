extends BaseOrder

var destination: Vector2

func setup(new_subject: Character, _new_target: Noun = null, _new_with: Noun = null, new_parameters: Dictionary = {}) -> void:
	super(new_subject, null, null, new_parameters)
	destination = parameters["mouse_pos"]

func start() -> void:
	set_status("Moving to position")
	destination = parameters["mouse_pos"]
	super()

func do(delta: float) -> void:
	if destination != Vector2.ZERO:
		var speed = delta * subject.cache_speed
		var distance = subject.global_position.distance_to(destination)
		if distance < 8:
			end(true)
		else:
			var direction = subject.global_position.direction_to(destination)
			subject.velocity = (direction * speed).limit_length(distance / delta)

func end(succeed: bool):
	if not succeed: # Move order failed, stop moving
		subject.velocity = Vector2.ZERO
	if subject.list_of_orders.size() <= 1: # This is the last order
		subject.velocity = Vector2.ZERO
	else:
		if "destination" not in subject.list_of_orders[1]: # Next order is not a movement order
			subject.velocity = Vector2.ZERO
	super(succeed)
