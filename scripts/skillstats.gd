extends Node
class_name SkillStatsComponent

@export_category("Body")
@export var strength:		float = 1.0 # How strong are you?
@export var endurance:		float = 1.0 # How long can you endure physical stress?
@export var sneak:			float = 1.0 # How good are you at sneaking?

@export_category("Ingenuinity")
@export var doctor:			float = 1.0 # Can you diagnose and treat issues?
@export var engineer:		float = 1.0 # Can you design and engineer new items?

@export_category("Finesse")
@export var repair:			float = 1.0 # Can you repair old or worn out items?
@export var cook:			float = 1.0 # How good are you at cooking?
@export var fish:			float = 1.0 # Can you fish?
@export var craft:			float = 1.0 # Can you craft?
@export var farm:			float = 1.0 # Can you farm?

@export_category("Combat")
@export var toughness:		float = 1.0 # How resilient are you to melee attacks?
@export var firearms:		float = 1.0 # Are you good at aiming, reloading, and operating a firearm?
@export var archery:		float = 1.0 # Are you good at aiming, reloading, and using a bow?
@export var throwing:		float = 1.0 # Are you good at aiming and throwing things?
@export var punch:			float = 1.0 # You can be strong, and still not know how to punch.
@export var stab:			float = 1.0 # How good are you at stabbing people? Spears, halberds, etc.
@export var slash:			float = 1.0 # How good are you at slashing people? Axes, knives, etc.

@export_category("Perception")
@export var scavenge:		float = 1.0 # How good are you at scavenging items?
@export var navigate:		float = 1.0 # How good are you at navigating terrain?

@export_category("Composure")
@export var reason:			float = 1.0 # Can you reason or negotiate your way in or out of a situation?
@export var intimidate:		float = 1.0 # Can you intimidate or make someone fear you?
