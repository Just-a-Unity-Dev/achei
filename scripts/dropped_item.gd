extends StaticBody2D
@export var attached_item: ItemData

func _ready() -> void:
	$Sprite2D.texture = attached_item.item_texture_resource
	$SelectedSprite.texture = attached_item.item_texture_resource
	$Label.text = attached_item.item_name
