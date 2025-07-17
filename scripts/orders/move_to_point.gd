extends BaseOrder

var destination: Vector2

func setup(new_host: Character, new_parameters: Dictionary) -> void:
	super(new_host, new_parameters)
	destination = parameters["mouse_pos"]

func start() -> void:
	set_status("Moving to position")
	destination = parameters["mouse_pos"]
	super()

func do(delta: float) -> void:
	if destination != Vector2.ZERO:
		if host.global_position.distance_to(destination) < 1.5:
			destination = Vector2.ZERO
			end(true)
		else:
			var direction = host.global_position.direction_to(destination)
			host.velocity = direction * delta * host.cache_speed

func end(succeed: bool):
	if host.list_of_orders.size() <= 1: # This is the last order
		host.velocity = Vector2.ZERO
	else:
		if "destination" not in host.list_of_orders[1]: # Next order is not a movement order
			host.velocity = Vector2.ZERO
	super(succeed)
