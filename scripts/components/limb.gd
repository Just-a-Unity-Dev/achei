extends HealthComponent
## Simple off-shoot of HealthComponent that has a limb_data attached
class_name LimbComponent

@export var limb_data: LimbData
## Is this limb mangled?
@export var mangled: bool = false
