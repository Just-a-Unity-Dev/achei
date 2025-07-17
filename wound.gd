extends Resource
class_name Wound

@export var wound_name = ""
@export var wound_description = ""
@export var body_part_affected: int = -1

@export var initial_severity = 0.3
@export var maximum_severity = 1.0

@export var severity_growth = 0.001
