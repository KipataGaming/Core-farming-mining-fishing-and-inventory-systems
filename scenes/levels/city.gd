extends Node2D

@export var city_width: int = 20
@export var city_height: int = 20
@onready var tile_layer = $Layers/TileMapLayer

func _ready() -> void:
	generate_city()

func generate_city():
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(8, 8) # Pico-8 tiles are 8x8
	tile_layer.tile_set = tile_set
	
	# Load Kenney Tiles
	var dir = DirAccess.open("res://kenney_pico-8-city/Tiles/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var tile_id = 0
		while file_name != "":
			if file_name.ends_with(".png"):
				var texture = load("res://kenney_pico-8-city/Tiles/" + file_name)
				var atlas = TileSetAtlasSource.new()
				atlas.texture = texture
				atlas.create_tile(Vector2i(0, 0))
				tile_set.add_source(atlas, tile_id)
				tile_id += 1
			file_name = dir.get_next()
	
	# Simple grid generator
	for x in range(city_width):
		for y in range(city_height):
			# Just fill with random tiles for now to test
			var source_id = randi() % tile_set.get_source_count()
			tile_layer.set_cell(Vector2i(x, y), source_id, Vector2i(0, 0))
