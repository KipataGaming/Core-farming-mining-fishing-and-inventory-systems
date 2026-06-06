extends StaticBody2D

var health := 3:
	set(value):
		health = value
		if health <= 0:
			$FlashSprite2D.hide()
			$Stump.show()
			var shape = RectangleShape2D.new()
			shape.size = Vector2(12,6)
			$CollisionShape2D.shape = shape
			$CollisionShape2D.position.y = 8
			Data.change_item(Enum.Item.WOOD, randi_range(2,4))

var seed_type: Enum.Seed = Enum.Seed.TOMATO:
	set(value):
		seed_type = value
		if is_node_ready():
			reset()

func _ready() -> void:
	add_to_group("Objects")
	$FlashSprite2D.frame = [0,1].pick_random()
	if $Apples.get_child_count() == 0:
		reset()

func hit(tool: Enum.Tool, _dir: Vector2 = Vector2.ZERO):
	if tool == Enum.Tool.AXE:
		$FlashSprite2D.flash()
		get_apple()
		health -= 1

func create_apples(num: int):
	var apple_markers = $AppleSpawnPositions.get_children().duplicate(true)
	
	# Determine texture based on seed_type
	var fruit_texture_map = {
		Enum.Seed.ORANGE: preload("res://graphics/icons/orange.png"),
		Enum.Seed.LEMON: preload("res://graphics/icons/lemon.png"),
		Enum.Seed.LIME: preload("res://graphics/icons/lime.png"),
		Enum.Seed.BANANA: preload("res://graphics/icons/banana.png"),
		Enum.Seed.PEAR: preload("res://graphics/icons/pear.png"),
		Enum.Seed.APRICOT: preload("res://graphics/icons/apricot.png"),
		Enum.Seed.MANGO: preload("res://graphics/icons/mango.png"),
		Enum.Seed.GUAVA: preload("res://graphics/icons/guava.png"),
	}
	var texture = fruit_texture_map.get(seed_type, preload("res://graphics/plants/apple.png"))
	
	for i in num:
		var pos_marker = apple_markers.pop_at(randi_range(0, apple_markers.size() - 1))
		var sprite = Sprite2D.new()
		sprite.texture = texture
		$Apples.add_child(sprite)
		sprite.position = pos_marker.position

func get_apple():
	if $Apples.get_children():
		$Apples.get_children().pick_random().queue_free()
		
		var seed_to_fruit_map = {
			Enum.Seed.ORANGE: Enum.Item.ORANGE_FRUIT,
			Enum.Seed.LEMON: Enum.Item.LEMON_FRUIT,
			Enum.Seed.LIME: Enum.Item.LIME_FRUIT,
			Enum.Seed.BANANA: Enum.Item.BANANA_FRUIT,
			Enum.Seed.PEAR: Enum.Item.PEAR_FRUIT,
			Enum.Seed.APRICOT: Enum.Item.APRICOT_FRUIT,
			Enum.Seed.MANGO: Enum.Item.MANGO_FRUIT,
			Enum.Seed.GUAVA: Enum.Item.GUAVA_FRUIT,
		}
		
		var fruit_item = seed_to_fruit_map.get(seed_type, Enum.Item.APPLE)
		Data.change_item(fruit_item)

func reset():
	if health > 0:
		for apple in $Apples.get_children():
			apple.queue_free()
		create_apples(randi_range(0,3))
		health = 3
