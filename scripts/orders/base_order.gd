extends RefCounted
## An order that can be completed by characters.
class_name BaseOrder

## The character performing this order.
var host: Character
## Order related parameters.
var parameters: Dictionary
## Has this order finished?
var finished: bool
## Has this order started?
var started: bool
## The current status of the order.
var current_status: String

signal order_finished(success: bool)
signal update_status(new_status: String)

func set_status(new_status: String):
	update_status.emit(new_status)
	current_status = new_status

func setup(new_host: Character, new_parameters: Dictionary) -> void:
	host = new_host
	parameters = new_parameters

func start() -> void:
	started = true

func do(delta: float) -> void:
	pass

func end(succeed: bool):
	finished = true
	order_finished.emit(succeed)
