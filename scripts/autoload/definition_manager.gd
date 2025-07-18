extends Node

func load_definition(definition: Definition, keys: Dictionary) -> Variant:
	var new = definition.definition_script.new()
	for key in keys.keys():
		var value = keys[key]
		new[key] = value
	return new
