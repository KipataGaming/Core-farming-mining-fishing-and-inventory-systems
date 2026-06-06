extends Node2D

var plant_scene = preload("res://scenes/objects/plant.tscn")
var plant_info_scene = preload("res://scenes/ui/plant_info.tscn")
var projectile_scene = preload("res://scenes/machines/projectile.tscn")
var blob_scene = preload("res://scenes/objects/blob.tscn")
var machine_scenes = {
	Enum.Machine.SPRINKLER: preload("res://scenes/machines/sprinkler.tscn"),
	Enum.Machine.SCARECROW: preload("res://scenes/machines/scare_crow.tscn"),
	Enum.Machine.FISHER: preload("res://scenes/machines/fisher.tscn")}
var used_cells: Array[Vector2i]
var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")
var raining: bool:
	set(value):
		raining = value
		$Layers/RainFloorParticles.emitting = value
		$Overlay/RainDropsParticles.emitting = value
		$Music/Rain.playing = value
@onready var player = $Objects/Player
@onready var day_transition_material = $Overlay/CanvasLayer/DayTransitionLayer.material
@export var daytime_color: Gradient
@export var rain_color: Color
@export var volume_curve: Curve

const MACHINE_PREVIEW_TEXTURES = {
	Enum.Machine.SPRINKLER: {'texture':preload("res://graphics/icons/sprinkler.png"), 'offset': Vector2i(0,0)},
	Enum.Machine.FISHER: {'texture':preload("res://graphics/icons/fisher.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.SCARECROW: {'texture':preload("res://graphics/icons/scarecrow.png"), 'offset': Vector2i(0,-4)},
	Enum.Machine.DELETE: {'texture':preload("res://graphics/icons/delete.png"), 'offset': Vector2i(0,0)}}


func _on_player_tool_use(tool: Enum.Tool, pos: Vector2) -> void:
	var grid_coord: Vector2i = Vector2i(int(pos.x / Data.TILE_SIZE),int(pos.y / Data.TILE_SIZE))
	grid_coord.x += -1 if pos.x < 0 else 0
	grid_coord.y += -1 if pos.y < 0 else 0
	var has_soil = grid_coord in $Layers/SoilLayer.get_used_cells()
	match tool:
		Enum.Tool.HOE:
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var target_coord = grid_coord + Vector2i(dx, dy)
					var cell = $Layers/GrassLayer.get_cell_tile_data(target_coord) as TileData
					if cell and cell.get_custom_data('farmable'):
						$Layers/SoilLayer.set_cells_terrain_connect([target_coord], 0, 0)
					if raining:
						$Layers/SoilWaterLayer.set_cell(target_coord, 0, Vector2i(randi_range(0,2),0))
		Enum.Tool.WATER:
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var target_coord = grid_coord + Vector2i(dx, dy)
					if target_coord in $Layers/SoilLayer.get_used_cells():
						$Layers/SoilWaterLayer.set_cell(target_coord, 0, Vector2i(randi_range(0,2),0))
		Enum.Tool.FISH:
			if not grid_coord in $Layers/GrassLayer.get_used_cells():
				$Objects/Player.start_fishing()
		Enum.Tool.SEED:
			var seed_type = player.current_seed
			
			# Check if it's a fruit seed
			var fruit_seed_map = {
				Enum.Seed.ORANGE: Enum.Item.ORANGE_FRUIT,
				Enum.Seed.LEMON: Enum.Item.LEMON_FRUIT,
				Enum.Seed.LIME: Enum.Item.LIME_FRUIT,
				Enum.Seed.BANANA: Enum.Item.BANANA_FRUIT,
				Enum.Seed.PEAR: Enum.Item.PEAR_FRUIT,
				Enum.Seed.APRICOT: Enum.Item.APRICOT_FRUIT,
				Enum.Seed.MANGO: Enum.Item.MANGO_FRUIT,
				Enum.Seed.GUAVA: Enum.Item.GUAVA_FRUIT,
			}
			
			if fruit_seed_map.has(seed_type):
				var tree = preload("res://scenes/objects/tree.tscn").instantiate()
				tree.position = Vector2(grid_coord * Data.TILE_SIZE)
				tree.seed_type = seed_type # Assign before adding to tree
				$Objects.add_child(tree) # _ready() runs here, seed_type is already set
			elif has_soil and grid_coord not in used_cells:
				# Plant crop
				var item_mapping = {
					Enum.Seed.TOMATO: Enum.Item.TOMATO,
					Enum.Seed.WHEAT: Enum.Item.WHEAT,
					Enum.Seed.CORN: Enum.Item.CORN,
					Enum.Seed.PUMPKIN: Enum.Item.PUMPKIN,
				}
				var selected_item = item_mapping.get(seed_type)
				
				if selected_item != null and Data.items[selected_item] > 0:
					var plant_res = PlantResource.new()
					plant_res.setup(seed_type, selected_item)
					var plant = plant_scene.instantiate()
					plant.setup(grid_coord, $Objects, plant_res, plant_death)
					used_cells.append(grid_coord)
					
					var plant_info = plant_info_scene.instantiate()
					plant_info.setup(plant_res)
					$Overlay/CanvasLayer/PlantInfoContainer.add(plant_info)
				
		Enum.Tool.AXE, Enum.Tool.SWORD, Enum.Tool.PICKAXE:
			var target_pos = Vector2(grid_coord * Data.TILE_SIZE)
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var area_pos = target_pos + Vector2(dx * Data.TILE_SIZE, dy * Data.TILE_SIZE)
					for object in get_tree().get_nodes_in_group('Objects'):
						if object.position.distance_to(area_pos) < 20:
							if object.has_method("hit"):
								object.hit(tool)


func _on_player_diagnose() -> void:
	$Overlay/CanvasLayer/PlantInfoContainer.visible = not $Overlay/CanvasLayer/PlantInfoContainer.visible


func _on_player_day_change() -> void:
	day_restart()


func _on_player_build(current_machine: int) -> void:
	if current_machine != Enum.Machine.DELETE:
		var machine = machine_scenes[current_machine].instantiate()
		machine.setup(player.get_machine_coord(), self, $Objects)
	else:
		for machine in get_tree().get_nodes_in_group('Machines'):
			machine.delete(player.get_machine_coord() / 16)


func _on_player_machine_change(current_machine: int) -> void:
	$Overlay/MachinePreviewSprite.texture = MACHINE_PREVIEW_TEXTURES[current_machine]['texture']


func _on_player_close_shop() -> void:
	$Overlay/CanvasLayer/ShopUI.hide()
	player.current_state = Enum.State.DEFAULT


func _ready() -> void:
	add_to_group("Level")
	Data.forecast_rain = [true, false].pick_random()
	player.connect('day_change', day_restart)
	for character in get_tree().get_nodes_in_group('Characters'):
		character.connect('open_shop', open_shop)
	
	var level_data = Data.load_game()
	if level_data:
		load_level_state(level_data)
		
	# Check if player passed out or slept
	if Data.passed_out_last_night:
		var bed = get_node_or_null("Objects/House/Bed")
		if bed:
			player.global_position = bed.global_position + Vector2(-16, 0)
		var tool_ui = player.get_node_or_null("ToolUI")
		if tool_ui and tool_ui.has_method("show_notification"):
			tool_ui.show_notification("Passed out! Woke up in bed with half energy.")
		Data.passed_out_last_night = false
		Data.stamina = Data.max_stamina * 0.5
		Data.health = Data.max_health


func _process(_delta: float) -> void:
	var daytime_point = Data.current_time / Data.DAY_DURATION
	var color = daytime_color.sample(daytime_point).lerp(rain_color, 0.5 if raining else 0.0)
	if volume_curve:
		$Music/BGMusic.volume_db = volume_curve.sample(daytime_point)
	$Overlay/DayTimeColor.color = color
	
	# machine preview 
	$Overlay/MachinePreviewSprite.visible = player.current_state == Enum.State.BUILDING
	$Overlay/MachinePreviewSprite.position = player.get_machine_coord() + MACHINE_PREVIEW_TEXTURES[player.current_machine]['offset']

func day_restart():
	Data.save_game(get_level_state())
	var tween = create_tween()
	tween.tween_property(day_transition_material, "shader_parameter/progress", 1.0, 1.0)
	tween.tween_interval(0.5)
	tween.tween_callback(level_reset)
	tween.tween_property(day_transition_material, "shader_parameter/progress", 0.0, 1.0)


func get_level_state() -> Dictionary:
	var state = {
		"soil": [],
		"soil_water": [],
		"used_cells": [],
		"plants": [],
		"machines": []
	}
	
	for cell in $Layers/SoilLayer.get_used_cells():
		state["soil"].append({"x": cell.x, "y": cell.y})
		
	for cell in $Layers/SoilWaterLayer.get_used_cells():
		state["soil_water"].append({"x": cell.x, "y": cell.y})
		
	for cell in used_cells:
		state["used_cells"].append({"x": cell.x, "y": cell.y})
	
	for plant in get_tree().get_nodes_in_group("Plants"):
		state["plants"].append({
			"pos": {"x": plant.position.x, "y": plant.position.y},
			"coord": {"x": plant.coord.x, "y": plant.coord.y},
			"age": plant.res.age,
			"death_count": plant.res.death_count,
			"seed_type": plant.seed_type if "seed_type" in plant else 0
		})
		
	for machine in get_tree().get_nodes_in_group("Machines"):
		state["machines"].append({
			"pos": {"x": machine.position.x, "y": machine.position.y},
			"type": machine.machine_type if "machine_type" in machine else 0
		})
		
	return state


func load_level_state(state: Dictionary):
	# Restore Soil
	$Layers/SoilLayer.clear()
	if "soil" in state:
		for cell_data in state["soil"]:
			var cell = _parse_v2i(cell_data)
			$Layers/SoilLayer.set_cells_terrain_connect([cell], 0, 0)
		
	$Layers/SoilWaterLayer.clear()
	if "soil_water" in state:
		for cell_data in state["soil_water"]:
			var cell = _parse_v2i(cell_data)
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))
		
	used_cells.clear()
	if "used_cells" in state:
		for cell_data in state["used_cells"]:
			used_cells.append(_parse_v2i(cell_data))
		
	# Restore Plants
	for plant in get_tree().get_nodes_in_group("Plants"):
		plant.queue_free()
		
	if "plants" in state:
		for p_data in state["plants"]:
			var plant_res = PlantResource.new()
			var s_type = int(p_data["seed_type"])
			var r_item = Data.PLANT_DATA[s_type]['reward']
			plant_res.setup(s_type, r_item)
			plant_res.age = float(p_data["age"])
			plant_res.death_count = int(p_data["death_count"])
			
			var coord = _parse_v2i(p_data["coord"])
			var pos = _parse_v2(p_data["pos"])
			
			var plant = plant_scene.instantiate()
			plant.setup(coord, $Objects, plant_res, plant_death)
			plant.position = pos
			# update sprite frame
			plant.get_node("FlashSprite2D").frame = int(plant_res.age)

	# Restore Machines
	for machine in get_tree().get_nodes_in_group("Machines"):
		machine.queue_free()
		
	if "machines" in state:
		for m_data in state["machines"]:
			var m_type = int(m_data["type"])
			var pos = _parse_v2(m_data["pos"])
			var machine = machine_scenes[m_type].instantiate()
			machine.setup(pos, self, $Objects)


func _parse_v2(data) -> Vector2:
	if data is Dictionary: return Vector2(float(data.x), float(data.y))
	if data is String:
		var s = data.replace("(", "").replace(")", "").replace(" ", "")
		var p = s.split(",")
		if p.size() >= 2: return Vector2(float(p[0]), float(p[1]))
	return Vector2.ZERO


func _parse_v2i(data) -> Vector2i:
	if data is Dictionary: return Vector2i(int(data.x), int(data.y))
	if data is String:
		var s = data.replace("(", "").replace(")", "").replace(" ", "")
		var p = s.split(",")
		if p.size() >= 2: return Vector2i(int(p[0]), int(p[1]))
	return Vector2i.ZERO


var mining_object_scene = preload("res://scenes/objects/mining_object.tscn")

func spawn_mining_objects(count: int = 5):
	var spawn_points = $BlobSpawnPositions.get_children()
	for i in count:
		if spawn_points:
			var marker = spawn_points.pick_random()
			var mining_node = mining_object_scene.instantiate()
			mining_node.position = marker.position
			
			# Map the randomized item type to the corresponding MiningObject.OreType
			var item_type = Data.get_random_ore_type()
			var ore_map = {
				Enum.Item.STONE: MiningObject.OreType.STONE,
				Enum.Item.GOLD: MiningObject.OreType.GOLD,
				Enum.Item.SILVER: MiningObject.OreType.SILVER,
				Enum.Item.PLATINUM: MiningObject.OreType.PLATINUM,
				Enum.Item.DIAMOND: MiningObject.OreType.DIAMOND,
				Enum.Item.RUBY: MiningObject.OreType.RUBY,
				Enum.Item.SAPPHIRE: MiningObject.OreType.SAPPHIRE,
				Enum.Item.EMERALD: MiningObject.OreType.EMERALD
			}
			
			mining_node.ore_type = ore_map.get(item_type, MiningObject.OreType.STONE)
			$Objects.add_child(mining_node)

func level_reset():
	for plant in get_tree().get_nodes_in_group('Plants'):
		plant.grow(plant.coord in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	$Overlay/CanvasLayer/PlantInfoContainer.update_all()
	
	# Reset time cycle for new day
	Data.current_time = 0.0
	
	# Position player in bed
	var bed = get_node_or_null("Objects/House/Bed")
	if bed:
		player.global_position = bed.global_position + Vector2(-16, 0)
		
	# Restore stats
	if Data.passed_out_last_night:
		Data.stamina = Data.max_stamina * 0.5
		Data.health = Data.max_health
		var tool_ui = player.get_node_or_null("ToolUI")
		if tool_ui and tool_ui.has_method("show_notification"):
			tool_ui.show_notification("Passed out! Woke up in bed with half energy.")
		Data.passed_out_last_night = false
	else:
		Data.stamina = Data.max_stamina
		Data.health = Data.max_health
		Data.day += 1
		
	# Add spawning at the end of reset
	spawn_mining_objects(5)

	$Timers/DayTimer.start()
	for object in get_tree().get_nodes_in_group('Objects'):
		if 'reset' in object:
			object.reset()


	raining = Data.forecast_rain
	Data.forecast_rain = [true, false].pick_random()
	
	if raining:
		for cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))


func plant_death(coord: Vector2i):
	used_cells.erase(coord)


func create_projectile(start_pos: Vector2, dir: Vector2):
	var projectile = projectile_scene.instantiate()
	projectile.setup(start_pos, dir)
	$Objects.add_child(projectile)


func water_plants(coord: Vector2i):
	const SOIL_DIRECTIONS = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1,  0),Vector2i(1,0), Vector2i(-1,  1), 
		Vector2i(0,  1), Vector2i(1,  1)]
	for dir in SOIL_DIRECTIONS:
		var cell = coord + dir
		if cell in $Layers/SoilLayer.get_used_cells():
			$Layers/SoilWaterLayer.set_cell(cell, 0, Vector2i(randi_range(0,2),0))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and player.current_state != Enum.State.SHOP:
		if not has_node("PauseMenu"):
			var pause_menu = pause_menu_scene.instantiate()
			pause_menu.name = "PauseMenu"
			add_child(pause_menu)


func _on_blob_timer_timeout() -> void:
	var plants = get_tree().get_nodes_in_group('Plants')
	var spawn_points = $BlobSpawnPositions.get_children()
	if plants and spawn_points:
		var blob = blob_scene.instantiate()
		var pos = spawn_points.pick_random().position
		blob.setup(pos, plants.pick_random(), $Objects)


func open_shop(shop_type: Enum.Shop):
	$Overlay/CanvasLayer/ShopUI.reveal(shop_type)
	player.current_state = Enum.State.SHOP
