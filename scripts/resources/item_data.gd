extends SerializableData
class_name ItemData

@export var item_id: String = "item_unknown"
@export var item_texture_resource: Texture2D
@export var item_name: String = "Unknown item"
@export var item_description: String = "I don't know..."

func get_serialized_property_names() -> Array:
	return [
		"item_id",
		"item_texture_resource",
		"item_name",
		"item_description",
	]

func get_id() -> String:
	return self.item_id
