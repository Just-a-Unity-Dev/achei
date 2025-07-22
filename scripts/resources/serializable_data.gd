# Provides (de)serialization functionality going to and from JSON/Dicts
# All data container objects should inherit from this and override get_serialized_property_names() and get_unique_id_prefix()
extends Resource
class_name SerializableData

############ Override these ############

func get_unique_id_prefix() -> String:
	# returns a prefix used in unique ID string generation
	# Should be something like Fleet- or Ship-
	# For read only serializable objects this is irrelevant as IDs are pulled from file and not dynamically generated
	breakpoint	# This should not be run in the base class. Override in subclasses
	return ""

func get_serialized_property_names() -> Array:
	# Override in subclasses.
	var serialized_property_names: Array = [] # All properties you wish to serialize(ex "player_health", "global_position") should be listed here in in string format
	breakpoint	# this code should never be run in the base class. Override this method in subclasses
	return serialized_property_names

func custom_get_converter(_dict_repr):
	# custom code to inject values into dict repr(which is passed by reference)
	return
	
func custom_set_converter(_dict_repr):
	# custom code to build custom objects from dict repr
	return

func get_id() -> String:
	# override in subclasses to return the primary id var
	# this will be called via duck typing
	breakpoint
	return ""

############ Optional Overrides ############

func read_json_file_cache(_file_path: String) -> Dictionary:
	# optional reading of json file contents from cache singleton
	# override to provide file caching functionality 
	return {}

func write_json_file_cache(_file_path: String, _data: Dictionary) -> void:
	# optional saving of json file contents from cache singleton
	# override to provide file caching functionality
	pass
	
func rebuild_references(_object_id_to_object: Dictionary) -> void:
	# override in other classes
	# rebuilds references to objects using a map during game loading
	# should be called in SaveHandler after all objects are built
	breakpoint
	pass

############ Base Serialization Functionality ############

func dict_representation_get() -> Dictionary:
	# returns a json friendly dictionary representation of this object for serialization
	# takes all whitelisted properties from this object and puts them in the dictionary
	var dict_repr = {}
	var serialized_property_names: Array = self.get_serialized_property_names()	# get whitelisted properties
	
	for property_data in self.get_property_list():
		var property_name: String = property_data["name"]
		var property_value = self.get(property_name)
		if serialized_property_names.has(property_name):
			# vectors into arrays
			if property_name.ends_with("position") or property_name.ends_with("pos"):
				var pos: Vector2 = property_value # typecast
				property_value = [pos.x, pos.y]
			# convert resources to resource_paths
			if property_name.ends_with("resource") or property_name.ends_with("resource"):
				var res: Resource = property_value # typecast
				property_value = res.resource_path
			# stringify colors to html codes
			if property_name.ends_with("color"):
				var color: Color = property_value # typecast
				property_value = color.to_html(true)
			
			dict_repr[property_name] = property_value
	
	self.custom_get_converter(dict_repr)
	return dict_repr

func dict_representation_set(dict_repr: Dictionary) -> void:
	# Use a json dictionary to set properties of serializable
	for k in dict_repr.keys():
		var key: String = k
		var value = dict_repr[key]
		# unstringify colors from html code
		if key.ends_with("color"):
			value = Color(value)
		# convert resource_paths to resources
		if key.ends_with("resource") or key.ends_with("resource"):
			value = load(value)
		# vectors from arrays
		if key.ends_with("position") or key.ends_with("pos"):
			var vector_x = value[0]
			var vector_y = value[1]
			value = Vector2(vector_x, vector_y)
		self.set(key, value)
	
	self.custom_set_converter(dict_repr)


func save_to_json(file_path: String):
	var dict_representation: Dictionary = self.dict_representation_get()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	var json = JSON.new()
	file.store_line(json.stringify(dict_representation))
	
	file.close()

func load_from_json(file_path: String):
	# overwrite the data where possible from json or cached json
	self.dict_representation_set(self.load_data_from_file(file_path))
		
	
func load_data_from_file(file_path: String) -> Dictionary:
	# obtain data from file or cache and return it
	
	# check if data already cached
	var cached_data: Dictionary = self.read_json_file_cache(file_path).duplicate(true)
	if len(cached_data) == 0:
		# not cached
		# read data from file
		if not FileAccess.file_exists(file_path):
			breakpoint
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file != 0:
			breakpoint
			
		var data = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		json.parse_string(data)
		var dict_representation: Dictionary = json.data # parse
		self.write_json_file_cache(file_path, dict_representation) # cache data
		return dict_representation # return data
	else:
		return cached_data

############ Diffing and Compression ############

func get_compression_preserved_keys() -> Array:
	# override this to include keys that will always get preserved during compression
	breakpoint
	return []

func get_compressed_dict(dict_repr: Dictionary, template_dict: Dictionary, always_preserve_keys: Array = self.get_compression_preserved_keys()):
	# takes a dict repr of an object, and strips out anything that matches the templated dict
	# if a key is listed as preserved it will be kept regardless of diff
	var compressed_dict_repr: Dictionary = {}
	for key in dict_repr:
		if always_preserve_keys.has(key):
			compressed_dict_repr[key] = dict_repr[key]
			continue
		if template_dict.has(key):
			if template_dict[key] != dict_repr[key]:
				compressed_dict_repr[key] = dict_repr[key]
		else:
			compressed_dict_repr[key] = dict_repr[key]
	return compressed_dict_repr
