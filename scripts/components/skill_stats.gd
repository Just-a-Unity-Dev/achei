extends Node
class_name SkillStatsComponent

@export_category("Body")
@export var strength:		float = 600.0 # How strong are you?
@export var endurance:		float = 600.0 # How long can you endure physical stress?
@export var sneak:			float = 600.0 # How good are you at sneaking?

@export_category("Ingenuinity")
@export var doctor:			float = 600.0 # Can you diagnose and treat issues?
@export var engineer:		float = 600.0 # Can you design and engineer new items?

@export_category("Finesse")
@export var repair:			float = 600.0 # Can you repair old or worn out items?
@export var cook:			float = 600.0 # How good are you at cooking?
@export var fish:			float = 600.0 # Can you fish?
@export var craft:			float = 600.0 # Can you craft?
@export var farm:			float = 600.0 # Can you farm?

@export_category("Combat")
@export var toughness:		float = 600.0 # How resilient are you to melee attacks?
@export var firearms:		float = 600.0 # Are you good at aiming, reloading, and operating a firearm?
@export var archery:		float = 600.0 # Are you good at aiming, reloading, and using a bow?
@export var throwing:		float = 600.0 # How good are you at throwing weapons?
@export var unarmed:		float = 600.0 # You can be strong, and still not know how to punch.
@export var melee:			float = 600.0 # How good are you at using melee weapons?

@export_category("Composure")
@export var reason:			float = 600.0 # Can you reason or negotiate your way in or out of a situation?
@export var intimidate:		float = 600.0 # Can you intimidate or make someone fear you?

var xp_amounts = {1: 200, 2: 400, 3: 600, 4: 800, 5: 1000, 6: 1500, 7: 2000, 8: 2500, 9: 3000, 10: 4000}
var modifier_amount = {0: -0.20, 1: -.15,2: -.1, 3: +0, 4: .05, 5: .1, 6: .15, 7: .2, 8: .25, 9: .30, 10: .35}

func get_level(xp: float) -> int:
	for i in range(xp_amounts.size(), 1, -1):
		var val = xp_amounts[i]
		if xp >= val:
			return i
	return 0

func get_modifier(xp: float) -> float:
	return modifier_amount[get_level(xp)]

func _ready() -> void:
	pass
