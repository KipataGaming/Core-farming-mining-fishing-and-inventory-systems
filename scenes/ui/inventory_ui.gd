extends CanvasLayer

var resource_texture_scene = preload("res://scenes/ui/resource_texture.tscn")
var decoration_texture = preload("res://graphics/tilesets/decoration.png")

const ITEM_CONFIG = {
	Enum.Item.STONE: {"color": Color.GRAY, "frame": 7},
	Enum.Item.IRON: {"color": Color.DIM_GRAY, "frame": 5},
	Enum.Item.GOLD: {"color": Color.GOLD, "frame": 5},
	Enum.Item.SILVER: {"color": Color.LIGHT_GRAY, "frame": 5},
	Enum.Item.PLATINUM: {"color": Color.CYAN, "frame": 5},
	Enum.Item.DIAMOND: {"color": Color.WHITE, "frame": 5},
	Enum.Item.RUBY: {"color": Color.RED, "frame": 5},
	Enum.Item.SAPPHIRE: {"color": Color.BLUE, "frame": 5},
	Enum.Item.EMERALD: {"color": Color.GREEN, "frame": 5},
	Enum.Item.TOMATO: {"color": Color.RED, "frame": 0},
	Enum.Item.CORN: {"color": Color.YELLOW, "frame": 0},
	Enum.Item.PUMPKIN: {"color": Color.ORANGE, "frame": 0},
	Enum.Item.WHEAT: {"color": Color.TAN, "frame": 0},
}

const ICON_OVERRIDES = {
	Enum.Item.STONE: "grayfish.png",
	Enum.Item.GOLD: "goldfish.png",
	Enum.Item.SILVER: "silverfish.png",
	Enum.Item.FISH: "goldfish.png",
	Enum.Item.SUNFISH: "goldfish.png",
	Enum.Item.CRAPPIE: "silverfish.png",
	Enum.Item.SMALLMOUTH_BASS: "grayfish.png",
	Enum.Item.LARGEMOUTH_BASS: "grayfish.png",
	Enum.Item.PIKE: "goldfish.png",
	Enum.Item.MUSKIE: "silverfish.png",
	Enum.Item.CATFISH: "grayfish.png",
	Enum.Item.CARP: "silverfish.png",
}

@onready var tab_container = $Panel/TabContainer
@onready var general_grid = $Panel/TabContainer/General/GridContainer
@onready var ores_grid = $Panel/TabContainer/Ores/GridContainer
@onready var seeds_grid = $Panel/TabContainer/Seeds/GridContainer

func _ready() -> void:
	visible = false
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if get_tree().paused and not visible:
			return
		visible = !visible
		get_tree().paused = visible
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_HIDDEN
		if visible:
			update_inventory()
		else:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func create_icon(frame: int) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = decoration_texture
	var col = frame % 4
	var row = frame / 4
	atlas.region = Rect2(col * 16, row * 16, 16, 16)
	return atlas

func create_dot_icon(color: Color) -> ImageTexture:
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	var center = Vector2(8, 8)
	var radius = 6
	for y in range(16):
		for x in range(16):
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)

func get_item_icon_config(item: Enum.Item) -> Dictionary:
	# 1. Check for Fish-specific data (now in Data.FISH_DATA)
	if Data.FISH_DATA.has(item):
		return {"icon": Data.FISH_DATA[item]["icon"], "color": Color.WHITE}
	
	# 2. Check for Procedural Ores/Gems
	if ITEM_CONFIG.has(item):
		var config = ITEM_CONFIG[item]
		return {"icon": create_icon(config.get("frame", 5)), "color": config.get("color", Color.WHITE)}
		
	# 3. Check for Procedural Seeds/Fruits
	if item in [Enum.Item.TOMATO, Enum.Item.CORN, Enum.Item.PUMPKIN, Enum.Item.WHEAT, Enum.Item.ORANGE_FRUIT, Enum.Item.LEMON_FRUIT, Enum.Item.LIME_FRUIT, Enum.Item.BANANA_FRUIT, Enum.Item.PEAR_FRUIT, Enum.Item.APRICOT_FRUIT, Enum.Item.MANGO_FRUIT, Enum.Item.GUAVA_FRUIT]:
		var config = Data.ITEM_DISPLAY_DATA.get(item, {"color": Color.WHITE, "frame": 0})
		return {"icon": create_dot_icon(config.get("color", Color.WHITE)), "color": Color.WHITE}
		
	# 4. Check for general File-based icons (with explicit override check)
	var icon_filename = ICON_OVERRIDES.get(item, Enum.Item.keys()[item].to_lower().replace("_fruit", "") + ".png")
	var icon_path = "res://graphics/icons/" + icon_filename
	if ResourceLoader.exists(icon_path):
		return {"icon": load(icon_path), "color": Color.WHITE}
		
	# 5. Default Fallback
	return {"icon": preload("res://graphics/icons/wood.png"), "color": Color.WHITE}

func update_inventory() -> void:
	for child in general_grid.get_children(): child.queue_free()
	for child in ores_grid.get_children(): child.queue_free()
	for child in seeds_grid.get_children(): child.queue_free()
	
	for item in Data.items:
		if Data.items[item] > 0:
			var resource_texture = resource_texture_scene.instantiate()
			var config = get_item_icon_config(item)
			
			resource_texture.setup(item, config["icon"])
			resource_texture.modulate = config["color"]
			resource_texture.tooltip_text = Enum.Item.keys()[item].capitalize()
			
			if item in [Enum.Item.STONE, Enum.Item.IRON, Enum.Item.GOLD, Enum.Item.SILVER, Enum.Item.PLATINUM, Enum.Item.DIAMOND, Enum.Item.RUBY, Enum.Item.SAPPHIRE, Enum.Item.EMERALD]:
				ores_grid.add_child(resource_texture)
			elif item in [Enum.Item.TOMATO, Enum.Item.CORN, Enum.Item.PUMPKIN, Enum.Item.WHEAT, Enum.Item.ORANGE_FRUIT, Enum.Item.LEMON_FRUIT, Enum.Item.LIME_FRUIT, Enum.Item.BANANA_FRUIT, Enum.Item.PEAR_FRUIT, Enum.Item.APRICOT_FRUIT, Enum.Item.MANGO_FRUIT, Enum.Item.GUAVA_FRUIT]:
				seeds_grid.add_child(resource_texture)
				resource_texture.clicked.connect(_on_seed_selected)
			else:
				general_grid.add_child(resource_texture)

func _on_seed_selected(seed_item: Enum.Item) -> void:
	var item_to_seed_map = {
		Enum.Item.TOMATO: Enum.Seed.TOMATO,
		Enum.Item.CORN: Enum.Seed.CORN,
		Enum.Item.PUMPKIN: Enum.Seed.PUMPKIN,
		Enum.Item.WHEAT: Enum.Seed.WHEAT,
		Enum.Item.ORANGE_FRUIT: Enum.Seed.ORANGE,
		Enum.Item.LEMON_FRUIT: Enum.Seed.LEMON,
		Enum.Item.LIME_FRUIT: Enum.Seed.LIME,
		Enum.Item.BANANA_FRUIT: Enum.Seed.BANANA,
		Enum.Item.PEAR_FRUIT: Enum.Seed.PEAR,
		Enum.Item.APRICOT_FRUIT: Enum.Seed.APRICOT,
		Enum.Item.MANGO_FRUIT: Enum.Seed.MANGO,
		Enum.Item.GUAVA_FRUIT: Enum.Seed.GUAVA,
	}
	
	if item_to_seed_map.has(seed_item):
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.current_seed = item_to_seed_map[seed_item]
			visible = false
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
