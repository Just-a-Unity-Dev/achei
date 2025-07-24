extends Node

#func load_definition(definition: Definition, keys: Dictionary) -> Variant:
	#var new = definition.definition_script.new()
	#for key in keys.keys():
		#var value = keys[key]
		#new[key] = value
	#return new

func recursively_save(root_object: Object) -> Dictionary:
	var dict_repr = {}
	if root_object.has_method("get_serialized_property_names"):
		var serialized_property_names = root_object.get_serialized_property_names()
		for property_data in root_object.get_property_list():
			var property_name: String = property_data["name"]
			var property_value = root_object.get(property_name)
			if serialized_property_names.has(property_name):
				if property_value is Object:
					dict_repr[property_name] = recursively_save(property_value)
				else:
					dict_repr[property_name] = property_value
	else:
		printerr("Tried to recursively save object %s which lacked get_serialized_property_names" % [root_object])
	return dict_repr
