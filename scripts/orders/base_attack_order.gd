extends BaseOrder
class_name BaseAttackOrder

var time_since_last_hit: float = 0.0

func start() -> void:
	set_status("Attacking other pawn with melee")
	super()

func do(delta: float) -> void:
	pass
