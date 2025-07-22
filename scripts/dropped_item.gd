extends StaticBody2D
@export var attached_item: ItemData

@onready var noun := $Noun

func _ready() -> void:
	$Sprite2D.texture = attached_item.item_texture_resource
	$SelectedSprite.texture = attached_item.item_texture_resource
	$Label.text = attached_item.item_name
	noun.update_info_array(attached_item.item_name, [attached_item.item_description])
