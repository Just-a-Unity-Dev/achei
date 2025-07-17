extends Node
class_name Skill

@export var skill_name: StringName
@export var xp = 0
var level:
	get:
		for i in range(xp_amounts.size(), 1, -1):
			var val = xp_amounts[i]
			if xp >= val:
				return i
		return 0

func get_modifier() -> float:
	return modifier_amount[level]

static func make(new_name: StringName) -> Skill:
	var new = Skill.new()
	new.skill_name = new_name
	return new

var xp_amounts = {
	1: 200,
	2: 400,
	3: 600,
	4: 800,
	5: 1000,
	6: 1500,
	7: 2000,
	8: 2500,
	9: 3000,
	10: 4000
}
var modifier_amount = {
	0:  -0.20,
	1:  -.15,
	2:  -.1,
	3:  +0,
	4:  +.05,
	5:  +.10,
	6:  +.15,
	7:  +.20,
	8:  +.25,
	9:  +.30,
	10: +.35
}
