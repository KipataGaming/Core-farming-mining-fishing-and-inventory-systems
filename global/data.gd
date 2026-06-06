extends Node

const PLAYER_SKINS = {
	Enum.Style.BASIC: preload("res://graphics/characters/main/main_basic.png"),
	Enum.Style.BASEBALL: preload("res://graphics/characters/main/main_blue.png"),
	Enum.Style.COWBOY: preload("res://graphics/characters/main/main_cowboy.png"),
	Enum.Style.ENGLISH: preload("res://graphics/characters/main/main_grey.png"),
	Enum.Style.STRAW: preload("res://graphics/characters/main/main_straw.png"),
	Enum.Style.BEANIE: preload("res://graphics/characters/main/main_red.png")}
const TILE_SIZE = 16
const PLANT_DATA = {
	Enum.Seed.TOMATO: {
		'texture': "res://graphics/plants/tomato.png",
		'icon_texture': "res://graphics/icons/tomato.png",
		'name':'Tomato',
		'h_frames': 3,
		'grow_speed': 0.6,
		'death_max': 3,
		'reward': Enum.Item.TOMATO},
	Enum.Seed.CORN: {
		'texture': "res://graphics/plants/corn.png",
		'icon_texture': "res://graphics/icons/corn.png",
		'name':'Corn',
		'h_frames': 3,
		'grow_speed': 1.0,
		'death_max': 2,
		'reward': Enum.Item.CORN},
	Enum.Seed.PUMPKIN: {
		'texture': "res://graphics/plants/pumpkin.png",
		'icon_texture': "res://graphics/icons/pumpkin.png",
		'name':'Pumpkin',
		'h_frames': 3,
		'grow_speed': 0.3,
		'death_max': 3,
		'reward': Enum.Item.PUMPKIN},
	Enum.Seed.WHEAT: {
		'texture': "res://graphics/plants/wheat.png",
		'icon_texture': "res://graphics/icons/wheat.png",
		'name':'Wheat',
		'h_frames': 3,
		'grow_speed': 1.0,
		'death_max': 3,
		'reward': Enum.Item.WHEAT}}

const MACHINE_UPGRADE_COST = {
	Enum.Machine.DELETE: {},
	Enum.Machine.SPRINKLER: {
		'name': 'Sprinkler',
		'cost' :{Enum.Item.TOMATO: 30, Enum.Item.WHEAT: 20},
		'icon': preload("res://graphics/icons/sprinkler.png"),
		'color': Color.SEA_GREEN},
	Enum.Machine.FISHER: {
		'name': 'Fisher',
		'cost' :{Enum.Item.WOOD: 25, Enum.Item.FISH: 15},
		'icon': preload("res://graphics/icons/fisher.png"),
		'color': Color.SLATE_GRAY},
	Enum.Machine.SCARECROW: {
		'name': 'Scarecrow',
		'cost' : {Enum.Item.PUMPKIN: 15, Enum.Item.CORN: 15},
		'icon': preload("res://graphics/icons/scarecrow.png"),
		'color': Color.BURLYWOOD}}

const FISH_DATA = {
	Enum.Item.SUNFISH: {"name": "Sunfish", "rarity": 0.8, "difficulty": 1, "icon": preload("res://graphics/icons/goldfish.png")},
	Enum.Item.CRAPPIE: {"name": "Crappie", "rarity": 0.7, "difficulty": 2, "icon": preload("res://graphics/icons/silverfish.png")},
	Enum.Item.SMALLMOUTH_BASS: {"name": "Smallmouth Bass", "rarity": 0.5, "difficulty": 3, "icon": preload("res://graphics/icons/fish.png")},
	Enum.Item.LARGEMOUTH_BASS: {"name": "Largemouth Bass", "rarity": 0.5, "difficulty": 3, "icon": preload("res://graphics/icons/fish.png")},
	Enum.Item.PIKE: {"name": "Pike", "rarity": 0.3, "difficulty": 4, "icon": preload("res://graphics/icons/goldfish.png")},
	Enum.Item.MUSKIE: {"name": "Muskie", "rarity": 0.1, "difficulty": 5, "icon": preload("res://graphics/icons/silverfish.png")},
	Enum.Item.CATFISH: {"name": "Catfish", "rarity": 0.6, "difficulty": 2, "icon": preload("res://graphics/icons/fish.png")},
	Enum.Item.CARP: {"name": "Carp", "rarity": 0.4, "difficulty": 2, "icon": preload("res://graphics/icons/silverfish.png")},
}


const HOUSE_COST = {
	1: {Enum.Item.WOOD: 30, Enum.Item.APPLE: 20},
	2: {Enum.Item.WOOD: 40, Enum.Item.APPLE: 30}}
const STYLE_UPGRADES = {
	Enum.Style.BASIC: {},
	Enum.Style.COWBOY: {
		'name': 'Cowboy',
		'cost':{Enum.Item.WOOD: 8, Enum.Item.CORN: 6},
		'icon': preload("res://graphics/icons/cowboy.png"),
		'color': Color.SANDY_BROWN},
	Enum.Style.ENGLISH: {
		'name': 'Oldie',
		'cost':{Enum.Item.CORN: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/english.png"),
		'color': Color.LIGHT_GRAY},
	Enum.Style.BASEBALL: {
		'name': 'Baseball',
		'cost':{Enum.Item.TOMATO: 8, Enum.Item.APPLE: 6},
		'icon': preload("res://graphics/icons/blue.png"),
		'color': Color.SKY_BLUE},
	Enum.Style.BEANIE: {
		'name': 'Beanie',
		'cost':{Enum.Item.PUMPKIN: 8, Enum.Item.WHEAT: 6},
		'icon': preload("res://graphics/icons/beanie.png"),
		'color': Color.INDIAN_RED},
	Enum.Style.STRAW: {
		'name': 'Straw',
		'cost':{Enum.Item.FISH: 8, Enum.Item.WOOD: 6},
		'icon': preload("res://graphics/icons/straw.png"),
		'color': Color.BURLYWOOD}}
const TOOL_STATE_ANIMATIONS = {
	Enum.Tool.HOE: 'Hoe',
	Enum.Tool.AXE: 'Axe',
	Enum.Tool.WATER: 'Water',
	Enum.Tool.SWORD: 'Sword',
	Enum.Tool.FISH: 'Fish',
	Enum.Tool.SEED: 'Seed',
	Enum.Tool.PICKAXE: 'Axe',
	
	}

var forecast_rain: bool
var unlocked_styles: Array = [Enum.Style.BASIC, Enum.Style.ENGLISH]
var unlocked_machines: Array = [Enum.Machine.DELETE, Enum.Machine.SPRINKLER, Enum.Machine.FISHER, Enum.Machine.SCARECROW]
var shop_connection = {
	Enum.Shop.HAT: {'tracker': unlocked_styles, 'all': STYLE_UPGRADES.keys()},
	Enum.Shop.MAIN: {'tracker': unlocked_machines, 'all': MACHINE_UPGRADE_COST.keys()},
}
var items = {
	Enum.Item.WOOD: 9,
	Enum.Item.APPLE: 8,
	Enum.Item.CORN: 9,
	Enum.Item.WHEAT: 5,
	Enum.Item.PUMPKIN: 7,
	Enum.Item.TOMATO: 4,
	Enum.Item.STONE: 0,
	Enum.Item.IRON: 0,
	Enum.Item.GOLD: 0,
	Enum.Item.SILVER: 0,
	Enum.Item.PLATINUM: 0,
	Enum.Item.DIAMOND: 0,
	Enum.Item.RUBY: 0,
	Enum.Item.SAPPHIRE: 0,
	Enum.Item.EMERALD: 0,
	Enum.Item.SUNFISH: 0,
	Enum.Item.CRAPPIE: 0,
	Enum.Item.SMALLMOUTH_BASS: 0,
	Enum.Item.LARGEMOUTH_BASS: 0,
	Enum.Item.PIKE: 0,
	Enum.Item.MUSKIE: 0,
	Enum.Item.CATFISH: 0,
	Enum.Item.CARP: 0,
	Enum.Item.ORANGE_FRUIT: 0,
	Enum.Item.LEMON_FRUIT: 0,
	Enum.Item.LIME_FRUIT: 0,
	Enum.Item.BANANA_FRUIT: 0,
	Enum.Item.PEAR_FRUIT: 0,
	Enum.Item.APRICOT_FRUIT: 0,
	Enum.Item.MANGO_FRUIT: 0,
	Enum.Item.GUAVA_FRUIT: 0}
# Player Status & Time Cycle Variables
var health: float = 100.0
var max_health: float = 100.0
var stamina: float = 100.0
var max_stamina: float = 100.0

const ITEM_DISPLAY_DATA = {
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
	Enum.Item.ORANGE_FRUIT: {"color": Color.ORANGE, "frame": 0},
	Enum.Item.LEMON_FRUIT: {"color": Color.YELLOW, "frame": 0},
	Enum.Item.LIME_FRUIT: {"color": Color.GREEN, "frame": 0},
	Enum.Item.BANANA_FRUIT: {"color": Color.YELLOW, "frame": 0},
	Enum.Item.PEAR_FRUIT: {"color": Color.CHARTREUSE, "frame": 0},
	Enum.Item.APRICOT_FRUIT: {"color": Color.ORANGE_RED, "frame": 0},
	Enum.Item.MANGO_FRUIT: {"color": Color.DARK_ORANGE, "frame": 0},
	Enum.Item.GUAVA_FRUIT: {"color": Color.LIGHT_GREEN, "frame": 0},
	Enum.Item.WOOD: {"color": Color.BROWN, "frame": 0},
	Enum.Item.APPLE: {"color": Color.RED, "frame": 0},
	Enum.Item.FISH: {"color": Color.CYAN, "frame": 0},
	Enum.Item.SUNFISH: {"color": Color.ORANGE, "frame": 0},
	Enum.Item.CRAPPIE: {"color": Color.SILVER, "frame": 0},
	Enum.Item.SMALLMOUTH_BASS: {"color": Color.DARK_GREEN, "frame": 0},
	Enum.Item.LARGEMOUTH_BASS: {"color": Color.GREEN, "frame": 0},
	Enum.Item.PIKE: {"color": Color.OLIVE, "frame": 0},
	Enum.Item.MUSKIE: {"color": Color.DARK_OLIVE_GREEN, "frame": 0},
	Enum.Item.CATFISH: {"color": Color.DARK_GRAY, "frame": 0},
	Enum.Item.CARP: {"color": Color.SANDY_BROWN, "frame": 0},
}

# Ore generation weights (must sum to 100)
var ore_weights = {
	Enum.Item.STONE: 50,
	Enum.Item.GOLD: 5,
	Enum.Item.SILVER: 15,
	Enum.Item.PLATINUM: 5,
	Enum.Item.DIAMOND: 2,
	Enum.Item.RUBY: 8,
	Enum.Item.SAPPHIRE: 8,
	Enum.Item.EMERALD: 7
}

func get_random_ore_type() -> int:
	var total = 0
	for weight in ore_weights.values():
		total += weight

	var roll = randi() % total
	var current = 0
	for ore_item in ore_weights.keys():
		current += ore_weights[ore_item]
		if roll < current:
			return ore_item
	return Enum.Item.STONE # Fallback

var day: int = 1
var current_time: float = 0.0 # Seconds elapsed since 5:30 AM
const DAY_DURATION: float = 180.0 # 3 minutes total active time

var passed_out_last_night: bool = false
var slept_in_bed: bool = false

func _process(delta: float) -> void:
	var scene = get_tree().current_scene
	if scene and (scene.name == "Level" or scene.name == "Cave"):
		if not get_tree().paused:
			current_time += delta
			if current_time >= DAY_DURATION:
				current_time = 0.0
				pass_out()

func get_time_string() -> String:
	var ratio = clamp(current_time / DAY_DURATION, 0.0, 1.0)
	var start_minutes = 5 * 60 + 30 # 5:30 AM = 330 minutes
	var end_minutes = 26 * 60 # 2:00 AM next day = 1560 minutes
	var total_minutes = start_minutes + ratio * (end_minutes - start_minutes)
	var hour = (int(total_minutes) / 60) % 24
	var minute = int(total_minutes) % 60
	return "%02d:%02d" % [hour, minute]

func pass_out():
	passed_out_last_night = true
	day += 1
	# Reset states
	health = max_health
	stamina = max_stamina * 0.5
	current_time = 0.0
	
	var scene = get_tree().current_scene
	if scene and scene.name != "Level":
		# Transition to main level
		get_tree().change_scene_to_file("res://scenes/levels/level.tscn")
	elif scene and scene.has_method("day_restart"):
		scene.day_restart()

func change_item(item: Enum.Item, amount: int = 1, auto_hide: bool = true):
	items[item] += amount
	get_tree().get_first_node_in_group("ResourceUI").reveal(auto_hide)


func reset_game():
	# Reset items
	for key in items.keys():
		items[key] = 0
	items[Enum.Item.WOOD] = 9
	items[Enum.Item.APPLE] = 8
	items[Enum.Item.CORN] = 9
	items[Enum.Item.WHEAT] = 5
	items[Enum.Item.PUMPKIN] = 7
	items[Enum.Item.TOMATO] = 4
	items[Enum.Item.ORANGE_FRUIT] = 5
	items[Enum.Item.LEMON_FRUIT] = 5
	items[Enum.Item.LIME_FRUIT] = 5
	items[Enum.Item.BANANA_FRUIT] = 5
	items[Enum.Item.PEAR_FRUIT] = 5
	items[Enum.Item.APRICOT_FRUIT] = 5
	items[Enum.Item.MANGO_FRUIT] = 5
	items[Enum.Item.GUAVA_FRUIT] = 5
	
	# Reset stats
	day = 1
	health = 100.0
	max_health = 100.0
	stamina = 100.0
	max_stamina = 100.0
	
	unlocked_styles = [Enum.Style.BASIC, Enum.Style.ENGLISH]
	unlocked_machines = [Enum.Machine.DELETE, Enum.Machine.SPRINKLER, Enum.Machine.FISHER, Enum.Machine.SCARECROW]
	
	# Delete save file
	if FileAccess.file_exists("user://savegame.json"):
		DirAccess.remove_absolute("user://savegame.json")

func save_game(level_data: Dictionary):
	var save_dict = {
		"items": items,
		"unlocked_styles": unlocked_styles,
		"unlocked_machines": unlocked_machines,
		"level_data": level_data,
		"day": day,
		"health": health,
		"stamina": stamina
	}
	var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_file.store_line(json_string)


func load_game() -> Dictionary:
	if not FileAccess.file_exists("user://savegame.json"):
		return {}
	
	var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		return {}
	
	var save_dict = json.get_data()
	# restore data items with type casting
	for key in save_dict["items"].keys():
		var item_id = int(key)
		if item_id == Enum.Item.FISH:
			continue
		items[item_id] = int(save_dict["items"][key])
	
	unlocked_styles = save_dict["unlocked_styles"]
	unlocked_machines = save_dict["unlocked_machines"]
	
	if save_dict.has("day"):
		day = int(save_dict["day"])
	if save_dict.has("health"):
		health = float(save_dict["health"])
	if save_dict.has("stamina"):
		stamina = float(save_dict["stamina"])
	
	return save_dict["level_data"]
