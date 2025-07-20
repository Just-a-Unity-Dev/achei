extends Node

const TILE_DEF_PATH := "res://resources/tiles/"

var _tile_cache: Dictionary[StringName, MapTileData] = {}

func load_tiles():
	var directory = DirAccess.open(TILE_DEF_PATH)
	for file in directory.get_files():
		var path := TILE_DEF_PATH + file
		var resource: MapTileData = load(path)
		_tile_cache[resource.tile_id] = resource

func get_tile_data(tile_id: StringName) -> MapTileData:
	return _tile_cache.get(tile_id)

func _ready() -> void:
	load_tiles()
