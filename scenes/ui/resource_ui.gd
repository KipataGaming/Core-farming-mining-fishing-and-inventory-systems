extends Control

var resource_texture_scene = preload("res://scenes/ui/resource_texture.tscn")
var decoration_texture = preload("res://graphics/tilesets/decoration.png")

const ITEM_COLORS = {
	Enum.Item.STONE: Color.GRAY,
	Enum.Item.IRON: Color.DIM_GRAY,
	Enum.Item.GOLD: Color.GOLD,
	Enum.Item.SILVER: Color.LIGHT_GRAY,
	Enum.Item.PLATINUM: Color.CYAN,
	Enum.Item.DIAMOND: Color.WHITE,
	Enum.Item.RUBY: Color.RED,
	Enum.Item.SAPPHIRE: Color.BLUE,
	Enum.Item.EMERALD: Color.GREEN,
}

func create_ore_icon(_color: Color) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = decoration_texture
	# Frame 7 in 4x2 grid (hframes=4, vframes=2)
	# 4th column (3), 2nd row (1). Assuming 16x16 tiles.
	atlas.region = Rect2(3 * 16, 1 * 16, 16, 16)
	return atlas

func _ready() -> void:
	hide()
	for key in Data.items.keys():
		var item_type = key as Enum.Item
		var resource_texture = resource_texture_scene.instantiate()
		
		var icon
		if ITEM_COLORS.has(item_type):
			icon = create_ore_icon(ITEM_COLORS[item_type])
			resource_texture.setup(item_type, icon)
			# ResourceTexture is the root of the scene, not a child "TextureRect"
			resource_texture.modulate = ITEM_COLORS[item_type]
		else:
			# Fallback for non-ore items
			var default_icons = {
				Enum.Item.WOOD: preload("res://graphics/icons/wood.png"),
				Enum.Item.APPLE: preload("res://graphics/icons/apple.png"),
				Enum.Item.FISH: preload("res://graphics/icons/goldfish.png"),
				Enum.Item.CORN: preload("res://graphics/icons/corn.png"),
				Enum.Item.TOMATO: preload("res://graphics/icons/tomato.png"),
				Enum.Item.PUMPKIN: preload("res://graphics/icons/pumpkin.png"),
				Enum.Item.WHEAT: preload("res://graphics/icons/wheat.png"),
			}
			icon = default_icons.get(item_type)
			if icon:
				resource_texture.setup(item_type, icon)
				
		$HBoxContainer.add_child(resource_texture)


func reveal(auto_hide: bool = true):
	for i in $HBoxContainer.get_children():
		i.update()
	show()
	if auto_hide:
		$HideTimer.start()
