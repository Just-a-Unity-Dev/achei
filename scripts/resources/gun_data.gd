extends Resource
class_name GunData

@export_category("Metadata")
@export var gun_name: String = "template weapon"
@export var accuracy_skill: StringName = &"firearms"
@export var image: Texture2D
@export_category("Damage and Stats")
@export var damage_min: int = 0
@export var damage_max: int = 0
@export var shots_fired: int = 0
@export_category("Cooldown")
@export var base_cooldown: float = 0
@export var base_reload: float = 0
@export var time_between_shots: float = 0
@export_category("Ranges")
@export var minimum_range: float = 1.5
@export var short_range: float = 2
@export var medium_range: float = 3
@export var long_range: float = 4
