extends Node
## Base class for anything that has health, a max health, and can die.
class_name HealthComponent

@export var hp: float = 10.0
@export var max_hp: float = 10.0
var popup_at: Node2D

signal died
var is_dead = false

static func make(current_hp: float, new_max_hp: float, popup: Node2D = null) -> HealthComponent:
	var new = HealthComponent.new()
	new.hp = current_hp
	new.max_hp = new_max_hp
	new.popup_at = popup
	return new

func kill():
	is_dead = true
	died.emit()

func take_damage(amount: int):
	if popup_at != null:
		var severity = 0
		if (hp - amount) <= 0:
			severity = PopupManager.SEVERITY_HIGH
		PopupManager.popup(str(amount), popup_at.global_position, severity)
	hp -= amount
	
	if hp <= 0:
		kill()
