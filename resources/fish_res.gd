class_name FishResource extends Resource

@export var name: String
@export var rarity: float # 0.0 to 1.0
@export var difficulty: int

var item_type: Enum.Item

func setup(p_name: String, p_rarity: float, p_difficulty: int, p_item: Enum.Item):
	name = p_name
	rarity = p_rarity
	difficulty = p_difficulty
	item_type = p_item
