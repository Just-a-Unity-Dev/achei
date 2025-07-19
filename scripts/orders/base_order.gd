extends RefCounted
## An order that can be completed by characters.
class_name BaseOrder

## The Character performing this order.
var subject: Character
## The target of this order.
var target: Noun
## What noun is being used to do the verb?
var with: Noun

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

var progress: float = -1.0

func set_status(new_status: String):
	update_status.emit(new_status)
	current_status = new_status

func setup(new_subject: Character, new_target: Noun = null, new_with: Noun = null, new_parameters: Dictionary = {}) -> void:
	subject = new_subject
	target = new_target
	with = new_with
	
	parameters = new_parameters

func start() -> void:
	started = true

func do(delta: float) -> void:
	pass

func end(succeed: bool):
	finished = true
	order_finished.emit(succeed)
