extends BaseOrder

var destination: Vector2

func start() -> void:
	set_status("Moving to position.")
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
