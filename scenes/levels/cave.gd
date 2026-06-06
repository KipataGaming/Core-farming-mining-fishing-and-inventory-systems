extends Node2D

var mining_object_scene = preload("res://scenes/objects/mining_object.tscn")
var ladder_scene = preload("res://scenes/objects/ladder.tscn")
var blob_scene = preload("res://scenes/objects/blob.tscn")
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

@export var width: int = 60
@export var height: int = 60
@export var fill_percent: float = 0.4
@export var max_steps: int = 2000

var grid: Array = []
@onready var floor_layer = $Layers/FloorLayer
@onready var wall_layer = $Layers/WallLayer
@onready var player = $Objects/Player

func _ready() -> void:
	generate_cave()


func generate_cave():
	# Initialize grid
	grid = []
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(1) # 1 = Wall, 0 = Floor
	
	# Drunkard's Walk
	var current_pos = Vector2i(width / 2, height / 2)
	var steps = 0
	var floor_cells = []
	
	while steps < max_steps:
		if grid[current_pos.x][current_pos.y] == 1:
			grid[current_pos.x][current_pos.y] = 0
			floor_cells.append(current_pos)
			steps += 1
		
		var dir = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
		current_pos += dir
		
		# Keep in bounds with margin
		current_pos.x = clamp(current_pos.x, 2, width - 3)
		current_pos.y = clamp(current_pos.y, 2, height - 3)

	# Apply to TileMap
	floor_layer.clear()
	wall_layer.clear()
	
	var floor_v2i = []
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 0:
				floor_v2i.append(Vector2i(x, y))
			else:
				# Use a simple wall tile ID
				wall_layer.set_cell(Vector2i(x, y), 0, Vector2i(0, 0)) 

	floor_layer.set_cells_terrain_connect(floor_v2i, 0, 0)
	
	# Spawn Player at start
	player.position = Vector2(width / 2, height / 2) * Data.TILE_SIZE
	
	# Spawn Content
	spawn_cave_content(floor_cells)


func spawn_cave_content(floor_cells: Array):
	# Spawn Ladder at the player start
	var ladder = ladder_scene.instantiate()
	ladder.position = player.position + Vector2(16, 0)
	$Objects.add_child(ladder)

	# Spawn Mining Objects
	for i in range(width * height * 0.03): # Reduced density
		var cell = floor_cells.pick_random()
		if cell.distance_to(Vector2i(width / 2, height / 2)) < 5: continue 
		
		var rock = mining_object_scene.instantiate()
		rock.position = Vector2(cell.x, cell.y) * Data.TILE_SIZE + Vector2(8, 8)
		
		# Randomize rock type
		var roll = randf()
		if roll > 0.95: rock.item_type = Enum.Item.GOLD
		elif roll > 0.8: rock.item_type = Enum.Item.IRON
		else: rock.item_type = Enum.Item.STONE
		
		$Objects.add_child(rock)

	# Spawn Enemies
	for i in range(15): # Increased enemies slightly
		var cell = floor_cells.pick_random()
		if cell.distance_to(Vector2i(width / 2, height / 2)) < 5: continue
		var blob = blob_scene.instantiate()
		blob.position = Vector2(cell.x, cell.y) * Data.TILE_SIZE
		$Objects.add_child(blob)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not has_node("PauseMenu"):
			var pause_menu = pause_menu_scene.instantiate()
			pause_menu.name = "PauseMenu"
			add_child(pause_menu)
