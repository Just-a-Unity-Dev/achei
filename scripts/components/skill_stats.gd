extends Node
class_name SkillStatsComponent

@export_category("Body")
@export var strength:		Skill = Skill.make(&"strength") # How strong are you?
@export var endurance:		Skill = Skill.make(&"endurance") # How long can you endure physical stress?
@export var sneak:			Skill = Skill.make(&"sneak") # How good are you at sneaking?

@export_category("Ingenuinity")
@export var doctor:			Skill = Skill.make(&"doctor") # Can you diagnose and treat issues?
@export var engineer:		Skill = Skill.make(&"engineer") # Can you design and engineer new items?

@export_category("Finesse")
@export var repair:			Skill = Skill.make(&"repair") # Can you repair old or worn out items?
@export var cook:			Skill = Skill.make(&"cook") # How good are you at cooking?
@export var fish:			Skill = Skill.make(&"fish") # Can you fish?
@export var craft:			Skill = Skill.make(&"craft") # Can you craft?
@export var farm:			Skill = Skill.make(&"farm") # Can you farm?

@export_category("Combat")
@export var toughness:		Skill = Skill.make(&"toughness") # How resilient are you to melee attacks?
@export var firearms:		Skill = Skill.make(&"firearms") # Are you good at aiming, reloading, and operating a firearm?
@export var archery:		Skill = Skill.make(&"archery") # Are you good at aiming, reloading, and using a bow?
@export var throwing:		Skill = Skill.make(&"throwing") # Are you good at aiming and throwing things?
@export var punch:			Skill = Skill.make(&"punch") # You can be strong, and still not know how to punch.
@export var stab:			Skill = Skill.make(&"stab") # How good are you at stabbing people? Spears, halberds, etc.
@export var slash:			Skill = Skill.make(&"slash") # How good are you at slashing people? Axes, knives, etc.

@export_category("Perception")
@export var scavenge:		Skill = Skill.make(&"scavenge") # How good are you at scavenging items?
@export var navigate:		Skill = Skill.make(&"navigate") # How good are you at navigating terrain?

@export_category("Composure")
@export var reason:			Skill = Skill.make(&"reason") # Can you reason or negotiate your way in or out of a situation?
@export var intimidate:		Skill = Skill.make(&"intimidate") # Can you intimidate or make someone fear you?

func _ready() -> void:
	print(reason.level)
