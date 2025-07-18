extends Resource
class_name LimbData

## What should this limb be called in the backend?
@export var limb_id := &"unknown"
## What GUI bar does this limb apply to?
@export var gui_bar_name := &"unknown"
## What is the name of this limb?
@export var limb_name := "unknown"

## How much health does this limb called?
@export var health := 0.0
## How much health can this limb store?
@export var max_health := 0.0

## If this limb is destroyed, will it kill the host?
@export var critical := false
## Can this limb be amputated?
@export var removeable := false

## What's the chance to hit this limb?
@export var chance_to_hit: int

## How much does this stat increase another?
@export var factors: Dictionary[StringName, float]
