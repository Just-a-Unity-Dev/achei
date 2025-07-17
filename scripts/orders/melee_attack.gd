extends BaseOrder

var target: Character
var time_since_last_hit: float = 3.0

func setup(new_host: Character, new_parameters: Dictionary) -> void:
	super(new_host, new_parameters)
	target = new_parameters["target"]

func start() -> void:
	set_status("Attacking other pawn with melee")
	super()

func do(delta: float) -> void:
	pass
